package EVCenter::View::HTML;

use strict;
use warnings;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die         => 1,
    ENCODING           => 'utf-8',
    WRAPPER            => 'wrapper.tt',
);

=head1 NAME

EVCenter::View::HTML - TT View for EVCenter

=head1 DESCRIPTION

TT View for EVCenter.

=head1 SEE ALSO

L<EVCenter>

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
