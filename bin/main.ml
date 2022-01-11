(** Shows how to configure authentication and access control in the web interface.
    Run this and visit "/login" for configuration instructions. *)

let program_name = "gitlab ci"

let url = Uri.of_string "https://gitlab.ci.ocamllabs.io"

open Current.Syntax

module Git = Current_git
module Gitlab = Current_gitlab
module Docker = Current_docker.Default

(* Limit to one (or two) build at a time. *)
let pool = Current.Pool.create ~label:"docker" 1

let () = Prometheus_unix.Logging.init ()

let weekly = Current_cache.Schedule.v ~valid_for:(Duration.of_day 7) ()

let gitlab_status_of_state = function
  | Ok _              -> Gitlab.Api.Status.v ~url `Success ~description:"Passed" ~name:program_name
  | Error (`Active _) -> Gitlab.Api.Status.v ~url `Pending ~name:program_name
  | Error (`Msg m)    -> Gitlab.Api.Status.v ~url `Failure ~description:m ~name:program_name

(* Generate a Dockerfile for building all the opam packages in the build context. *)
let dockerfile ~base =
  let open Dockerfile in
  from (Docker.Image.hash base) @@
  workdir "/src" @@
  add ~src:["*.opam"] ~dst:"/src/" () @@
  run "opam install . --show-actions --deps-only -t | awk '/- install/{print $3}' | xargs opam depext -iy" @@
  copy ~src:["."] ~dst:"/src/" () @@
  run "opam install -tv ."

(* Run "docker build" on the latest commit in Git repository [repo]. *)
let pipeline ~gitlab ~repo_id () =
  let dockerfile =
    let+ base = Docker.pull ~schedule:weekly "ocaml/opam:alpine-3.14-ocaml-4.10" in
    `Contents (dockerfile ~base)
  in
  Gitlab.Api.ci_refs gitlab ~staleness:(Duration.of_day 90) repo_id
  |> Current.list_iter (module Gitlab.Api.Commit) @@ fun head ->
  let src = Git.fetch (Current.map Gitlab.Api.Commit.id head) in

  Docker.build ~pool ~pull:false ~dockerfile (`Git src)
  |> Current.state
  |> Current.map gitlab_status_of_state
  |> Gitlab.Api.Commit.set_status head program_name

(* Access control policy. *)
let has_role user role =
  match user with
  | None -> role = `Viewer              (* Unauthenticated users can only look at things. *)
  | Some user ->
    match Current_web.User.id user, role with
    | "gitlab:tmcgilchrist", _ -> true  (* This user has all roles *)
    | _, (`Viewer | `Builder) -> true   (* Any GitLab user can cancel and rebuild *)
    | _ -> false

let main config mode repo_id auth gitlab =
  let engine = Current.Engine.create ~config (pipeline ~repo_id ~gitlab) in
  let authn = Option.map Current_gitlab.Auth.make_login_uri auth in
  let routes =
    Routes.(s "login" /? nil @--> Current_gitlab.Auth.login auth) ::
    Routes.(s "webhooks" / s "gitlab" /? nil @--> Gitlab.webhook ~webhook_secret:(Gitlab.Api.webhook_secret gitlab)) ::
    Current_web.routes engine in
  let site = Current_web.Site.v ?authn ~has_role ~name:program_name routes in
  Lwt_main.run begin
    Lwt.choose [
      Current.Engine.thread engine;
      Current_web.run ~mode site;
    ]
  end

(* Command-line parsing *)

open Cmdliner

let cmd =
  let doc = "Build the head commit of a local Git repository using Docker." in
  Term.(term_result (const main $ Current.Config.cmdliner $ Current_web.cmdliner $ Current_gitlab.Repo_id.cmdliner $ Current_gitlab.Auth.cmdliner $ Current_gitlab.Api.cmdliner)),
  Term.info program_name ~doc

let () = Term.(exit @@ eval cmd)
