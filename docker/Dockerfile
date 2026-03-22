FROM ubuntu:24.04

# Install necessary packages

RUN apt-get update && apt install -y cpanminus libcatalyst-perl libcatalyst-devel-perl \
            liblog-any-adapter-filehandle-perl libcatalyst-plugin-compress-perl libcatalyst-plugin-unicode-perl \
            libcatalyst-authentication-store-dbix-class-perl libcatalyst-plugin-session-store-file-perl \
            build-essential libcatalyst-plugin-configloader-perl libcatalyst-plugin-static-simple-perl \
            libcatalyst-model-adaptor-perl libcatalyst-view-tt-perl libcatalyst-view-json-perl \
            libdbix-connector-perl libsql-abstract-more-perl libdbd-pg-perl libhash-merge-simple-perl \
            libcatalyst-plugin-smarturi-perl libcatalyst-action-renderview-perl libdigest-sha-perl \
            libnet-snmp-perl starman

RUN cpanm Catalyst::Plugin::Session::State::Stash Log::Any::Adapter::Catalyst Digest::SHA1 \
          Catalyst::Plugin::Server::JSONRPC

RUN apt-get install -y git libmodule-install-perl

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/jasimioni/evcenter.git

WORKDIR /evcenter

ENTRYPOINT [ "/bin/bash" ]