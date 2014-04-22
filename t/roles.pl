#!/usr/bin/perl

use common::sense;
use lib '../lib';
use EVCenter::Base::ACL;
use Data::Dumper;

my $acl = EVCenter::Base::ACL->new;

print 'Tree: ', Dumper $acl->get_user_group_tree('jsimioni');
print "Filtro: ", $acl->get_filter('jsimioni'), "\n";
print "Permissions: ", Dumper $acl->get_permissions('jsimioni');

print 'Tree: ', Dumper $acl->get_user_group_tree('cmunhoz');
print "Filtro: ", $acl->get_filter('cmunhoz'), "\n";
print "Permissions: ", Dumper $acl->get_permissions('cmunhoz');

