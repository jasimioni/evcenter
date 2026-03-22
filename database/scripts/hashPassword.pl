#!/usr/bin/perl

use common::sense;
use DBI;
use Digest::SHA1 qw/sha1_base64/;

my ($username, $password) = @ARGV;

if (! defined $username || ! defined $password) {
    print "Usage: $0 <username> <newpassword>\n";
    exit 1;
}

print "Password: ", sha1_base64($password), "\n";

__END__

my $dbh = DBI->connect("dbi:Pg:dbname=evcenter", '', '', { AutoCommit => 1 });
my $sth = $dbh->prepare('INSERT INTO uc_users (username, password) VALUES (?, ?)');
$sth->execute($username, sha1_base64($password));
