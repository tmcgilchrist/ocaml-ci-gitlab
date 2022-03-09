(lang dune 2.0)
(name ocaml-ci-gitlab)
(generate_opam_files true)
(formatting disabled)

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
  dune
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
