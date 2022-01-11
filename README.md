# ocaml-ci-gitlab

A CI for OCaml projects on GitLab

## Features

- Available on all major platform (Windows, Linux and Windows)

## Installation

### Using Opam

```bash
opam install ocaml-ci-gitlab
```

### Using a script

```bash
curl -fsSL https://github.com//ocaml-ci-gitlab/raw/main/script/install.sh | bash
```

## Usage

### `ocaml-ci-gitlab hello NAME`

Greets the name given in argument.

## Contributing

Take a look at our [Contributing Guide](CONTRIBUTING.md).

## TODO

 - ~~Setup deployment to docker stack~~
 - ~~OAuth login for GitLab~~
 - ~~Respond to webhooks for projects in GitLab~~
 - Backport Gitlab Auth into ocaml-gitlab
   - Prep new release with oauth support
 - Validate oauth refresh token is used and works
 - Port full pipeline analysis steps along with cluster submissions for building
 - Add new projects to build via web form (see Log Analysis)
 