FROM ocaml/opam:debian-10-ocaml-4.10 AS build
RUN sudo apt-get update && sudo apt-get install libev-dev capnproto m4 pkg-config libsqlite3-dev libgmp-dev graphviz -y --no-install-recommends
RUN cd ~/opam-repository && git pull origin -q master && git reset --hard ea1cdb424d9dd6d8e0c620b3b23238076a1ec76a && opam update

WORKDIR /src
COPY --chown=opam ocaml-ci-gitlab.opam /src/
RUN opam-2.1 install -y --deps-only .
ADD --chown=opam . .
RUN opam-2.1 exec -- dune build ./_build/install/default/bin/ocaml-ci-gitlab

FROM debian:10
RUN apt-get update && apt-get install libev4 openssh-client curl gnupg2 dumb-init git graphviz libsqlite3-dev ca-certificates netbase -y --no-install-recommends
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN echo 'deb [arch=amd64] https://download.docker.com/linux/debian buster stable' >> /etc/apt/sources.list
RUN apt-get update && apt-get install docker-ce -y --no-install-recommends
WORKDIR /
ENTRYPOINT ["dumb-init", "/usr/local/bin/ocaml-ci-gitlab"]
RUN apt-get install ca-certificates -y  # https://github.com/mirage/ocaml-conduit/issues/388
COPY --from=build /src/_build/install/default/bin/ocaml-ci-gitlab /usr/local/bin/
