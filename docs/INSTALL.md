# Installation Steps

This was tested in Ubuntu 24.04. Most packages are available as .debs, but some
need to be installed from CPAN directly. Here are the steps:

##  Pre-Requisites Installation (Ubuntu 24.04)

```
apt update

apt install cpanminus libcatalyst-perl libcatalyst-devel-perl liblog-any-adapter-filehandle-perl \
            libcatalyst-plugin-compress-perl libcatalyst-plugin-unicode-perl libcatalyst-plugin-smarturi-perl \
            libcatalyst-authentication-store-dbix-class-perl libcatalyst-plugin-session-store-file-perl \
            build-essential libcatalyst-plugin-configloader-perl libcatalyst-plugin-static-simple-perl \
            libcatalyst-model-adaptor-perl libcatalyst-view-tt-perl libcatalyst-view-json-perl \
            libdbix-connector-perl libsql-abstract-more-perl libdbd-pg-perl libhash-merge-simple-perl \
            libcatalyst-action-renderview-perl libdigest-sha-perl starman

sudo cpanm Catalyst::Plugin::Session::State::Stash Log::Any::Adapter::Catalyst Digest::SHA1     
```

## PostgreSQL

EVCenter uses PostgreSQL as Backend. The database schema can be created using the contents of:

[database/schema/create_database.sql](https://github.com/jasimioni/evcenter/blob/master/database/schema/create_database.sql)e)


```
sudo apt update && sudo apt install -y postgresql
echo "CREATE USER evcenter WITH PASSWORD 'evcenter';" | sudo -u postgres psql
echo "CREATE DATABASE evcenter OWNER evcenter;" | sudo -u postgres psql
curl -q https://raw.githubusercontent.com/jasimioni/evcenter/refs/heads/master/database/schema/create_database.sql | sudo -u postgres psql evcenter
curl https://raw.githubusercontent.com/jasimioni/evcenter/refs/heads/master/database/schema/PopulateUserControl | sudo -u postgres psql evcenter
```