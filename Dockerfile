FROM ocaml/opam:debian-11-ocaml-4.13 AS build
RUN sudo apt-get update && sudo apt-get install libev-dev capnproto m4 pkg-config libsqlite3-dev libgmp-dev graphviz -y --no-install-recommends
RUN cd ~/opam-repository && git pull origin -q master && git reset --hard 61c80509aec809b94b4ff7a505235f1ba605c756 && opam update
RUN sudo ln -f /usr/bin/opam-2.1 /usr/bin/opam

COPY --chown=opam \
    ocurrent/current_docker.opam \
    ocurrent/current_git.opam \
    ocurrent/current_gitlab.opam \
    ocurrent/current.opam \
    /src/ocurrent/

COPY --chown=opam \
    ocaml-gitlab/gitlab-unix.opam \
    ocaml-gitlab/gitlab.opam \
    /src/ocaml-gitlab/

WORKDIR /src
RUN opam pin add -yn gitlab.dev "./ocaml-gitlab" && \
    opam pin add -yn gitlab-unix.dev "./ocaml-gitlab" && \
    opam pin add -yn current_docker.dev "./ocurrent" && \
    opam pin add -yn current_git.dev "./ocurrent" && \
    opam pin add -yn current_gitlab.dev "./ocurrent" && \
    opam pin add -yn current.dev "./ocurrent"
COPY --chown=opam ocaml-ci-gitlab.opam /src/
RUN opam install -y --deps-only .
ADD --chown=opam . .
RUN opam exec -- dune build ./_build/install/default/bin/ocaml-ci-gitlab

FROM debian:11
RUN apt-get update && apt-get install libev4 openssh-client curl gnupg2 dumb-init git graphviz libsqlite3-dev ca-certificates netbase -y --no-install-recommends
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN echo 'deb [arch=amd64] https://download.docker.com/linux/debian buster stable' >> /etc/apt/sources.list
RUN apt-get update && apt-get install docker-ce -y --no-install-recommends
WORKDIR /
ENTRYPOINT ["dumb-init", "/usr/local/bin/ocaml-ci-gitlab"]
RUN apt-get install ca-certificates -y  # https://github.com/mirage/ocaml-conduit/issues/388
COPY --from=build /src/_build/install/default/bin/ocaml-ci-gitlab /usr/local/bin/
