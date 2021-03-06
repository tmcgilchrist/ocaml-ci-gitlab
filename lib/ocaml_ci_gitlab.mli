(** A CI for OCaml projects on GitLab *)

module Config = Config
module Error = Error

val greet : string -> string
(** Returns a greeting message.

    {4 Examples}

    {[ print_endline @@ greet "Jane" ]} *)
