(lang dune 2.0)
(name ocaml-ci-gitlab)
(generate_opam_files true)

(license ISC)

(authors
  "Tim McGilchrist")

(maintainers
  "Tim McGilchrist")
(source (github tmcgilchrist/ocaml-ci-gitlab))

(package
 (name ocaml-ci-gitlab)
 (synopsis "A CI for OCaml projects on GitLab")
 (description "A CI for OCaml projects on GitLab")
 (depends
  (ocaml (>= 4.08.0))
  (alcotest :with-test)
  (odoc :with-doc)
   current
   current_git
   current_gitlab
   current_docker
   prometheus
   (cmdliner (>= 1.1.0))
   ocaml-ci
   ocaml-ci-service
   logs
   fmt))

(package
 (name ocaml-ci-gitlab-web)
 (synopsis "Web-server frontend for ocaml-ci")
 (conflicts (ocaml-migrate-parsetree (= "1.7.1")))
 (depends
  (yojson (>= 1.7.0))
  (logs (>= 0.7.0))
  (fmt (>= 0.8.9))
   current_rpc
   current_ansi
  (prometheus-app (>= 1.0))
   (cmdliner (>= 1.1.0))
   lwt
  (cohttp-lwt-unix (>= 2.2.0))
   tyxml
  (capnp-rpc-unix (>= 1.2))
   ocaml-ci-api
   conf-libev
   ppx_deriving_yojson))