open Alcotest

let test_hello_with_name name () =
  let greeting = Ocaml_ci_gitlab.greet name in
  let expected = "Hello " ^ name ^ "!" in
  check string "same string" greeting expected

let suite =
  [ "can greet Tom", `Quick, test_hello_with_name "Tom"
  ; "can greet John", `Quick, test_hello_with_name "John"
  ]

let () =
  Alcotest.run "ocaml-ci-gitlab" [ "Ocaml_ci_gitlab", suite ]
