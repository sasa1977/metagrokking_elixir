FROM debian:8.9 as base
RUN apt-get update && apt-get install -y openssl
RUN apt-get install -y locales && locale-gen en_US.UTF-8 en_us && \
  dpkg-reconfigure locales && \
  locale-gen C.UTF-8 && \
  /usr/sbin/update-locale LANG=C.UTF-8
ENV LANG=C.UTF-8 LANGUAGE=C.UTF-8 LC_ALL=C.UTF-8


FROM base as phoenix_project_builder
RUN apt-get install -y \
      git automake autoconf libreadline-dev libncurses-dev libssl-dev libyaml-dev \
      libxslt-dev libffi-dev libtool unixodbc-dev curl build-essential unzip
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.3.0
RUN bash -c ". ~/.asdf/asdf.sh && \
  asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git && \
  asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git && \
  asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git && \
  ~/.asdf/plugins/nodejs/bin/import-release-team-keyring"
COPY .tool-versions /shopping_list/
RUN bash -c ". ~/.asdf/asdf.sh && cd /shopping_list && asdf install"
RUN bash -c ". ~/.asdf/asdf.sh && cd /shopping_list && mix local.hex --force && mix local.rebar --force"


FROM phoenix_project_builder as release
COPY . /shopping_list
RUN bash -c ". ~/.asdf/asdf.sh && cd /shopping_list && \
  mix deps.get && \
  pushd assets && npm install && popd && \
  mix shopping_list.release"
RUN mkdir /final_release && cd /final_release && \
  tar xzvf /shopping_list/_build/prod/rel/shopping_list/releases/0.1.0/shopping_list.tar.gz


FROM base
COPY --from=release /final_release /shopping_list
WORKDIR /shopping_list
