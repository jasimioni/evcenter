FROM ubuntu:24.04

# Install necessary packages

RUN apt-get update && apt install -y cpanminus libcatalyst-perl libcatalyst-devel-perl postgresql-client \
            liblog-any-adapter-filehandle-perl libcatalyst-plugin-compress-perl libcatalyst-plugin-unicode-perl \
            libcatalyst-authentication-store-dbix-class-perl libcatalyst-plugin-session-store-file-perl \
            build-essential libcatalyst-plugin-configloader-perl libcatalyst-plugin-static-simple-perl \
            libcatalyst-model-adaptor-perl libcatalyst-view-tt-perl libcatalyst-view-json-perl \
            libdbix-connector-perl libsql-abstract-more-perl libdbd-pg-perl libhash-merge-simple-perl \
            libcatalyst-plugin-smarturi-perl libcatalyst-action-renderview-perl libdigest-sha-perl \
            libnet-snmp-perl starman

RUN cpanm Catalyst::Plugin::Session::State::Stash Log::Any::Adapter::Catalyst Digest::SHA1

RUN apt-get install -y git libmodule-install-perl

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/jasimioni/evcenter.git /evcenter

WORKDIR /evcenter

EXPOSE 3000

ENV PERL5LIB="${PERL5LIB}:.:lib" \
    EVCENTER_DBHOST=localhost \
    EVCENTER_DBNAME=evcenter \
    EVCENTER_DBUSER=evcenter \
    EVCENTER_DBPASS=evcenter \
    EVCENTER_DBPORT=5432 \
    EVCENTER_MODE=production 

CMD ["/evcenter/start.sh"]

# To build the image, run:
# docker build -t evcenter:latest .

# To run the container, use:
# docker run --rm -d -e EVCENTER_DBHOST=<DBHOST> -p 3000:3000 evcenter:latest
# docker run --rm -d -e EVCENTER_DBHOST=<DBHOST> -e EVCENTER_MODE=development -p 3000:3000 evcenter:latest