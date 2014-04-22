#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install 1.02;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'EVCenter';
all_from 'lib/EVCenter.pm';

requires 'Catalyst::Runtime' => '5.90042';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Server::JSONRPC';
requires 'Catalyst::Action::RenderView';
requires 'Moose';
requires 'namespace::autoclean';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats

requires 'Catalyst::Plugin::SmartURI';
requires 'Catalyst::Plugin::Unicode';
requires 'Catalyst::View::TT';
requires 'Catalyst::Authentication::Store::DBIx::Class';

requires 'DBIx::Connector';
requires 'SQL::Abstract::More';
requires 'Log::Any::Adapter::Catalyst';
requires 'Module::Pluggable::Object';
requires 'JSON::MaybeXS';

test_requires 'Test::More' => '0.88';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
