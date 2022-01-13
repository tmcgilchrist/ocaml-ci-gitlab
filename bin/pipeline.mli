val v :
  ?ocluster:Cluster_api.Raw.Client.Submission.t Capnp_rpc_lwt.Sturdy_ref.t ->
  app:Current_gitlab.Api.t ->
  solver:Ocaml_ci_api.Solver.t ->
  unit -> unit Current.t
(** The main ocaml-ci-gitlab pipeline *)
