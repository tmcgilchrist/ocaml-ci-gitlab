#!/bin/bash -ex

docker -c ci.ocamllabs.io build -t ocaml-ci-gitlab -f Dockerfile .
docker -c ci.ocamllabs.io stack rm ocaml-ci-gitlab
sleep 15
docker -c ci.ocamllabs.io stack deploy -c stack.yml ocaml-ci-gitlab
