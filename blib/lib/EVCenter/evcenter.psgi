use strict;
use warnings;

use EVCenter;

my $app = EVCenter->apply_default_middlewares(EVCenter->psgi_app);
$app;

