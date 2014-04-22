use utf8;
package Auth::Schema::Result::UcUser;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Auth::Schema::Result::UcUser

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<uc_users>

=cut

__PACKAGE__->table("uc_users");

=head1 ACCESSORS

=head2 username

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 200

=head2 password

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 details

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 filter

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 filter_type

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=cut

__PACKAGE__->add_columns(
  "username",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 200 },
  "password",
  { data_type => "varchar", is_nullable => 1, size => 200 },
);

=head1 PRIMARY KEY

=over 4

=item * L</username>

=back

=cut

__PACKAGE__->set_primary_key("username");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-20 12:32:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XgKKsFqAxZ53y4/aRZomJw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
