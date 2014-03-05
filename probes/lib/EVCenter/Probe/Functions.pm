package EVCenter::Probe::Functions;

use common::sense;
use Moose;
use Log::Log4perl qw/get_logger/;
use Data::Dumper;

=encoding utf8

=head1 NAME

EVCenter::Probe::Functions - Include some useful functions to make life easier

=head1 SYNOPSIS

    use EVCenter::Probe::Functions;
    
    EVCenter::Probe::Functions->function(@params);

=head1 DESCRIPTION

This class is used to provide some functions that didn't receive a full
class to operate, such as init_logger, which will configure the Log4perl.

=head1 FUNCTIONS

=head2 init_logger

    EVCenter::Probe::Functions->init_logger(%config);
    my $log = get_logger;

This method/function will initiate the Log4perl configuration. It will set log levels
and the file that must be used for logging.

=cut
sub init_logger {
	my $class = shift;
	my %config = @_;

    my $output    = defined $config{logfile} ? 'Logfile' : 'Screen';
    my $loglevel  = $config{loglevel} // 'INFO';
    my $logfile   = $config{logfile} // '/dev/null';
    my $max_files = $config{max_log_files} // 7;

    my $conf = qq(
        log4perl.category                       = $loglevel, $output

        log4perl.appender.Logfile               = Log::Dispatch::FileRotate
        log4perl.appender.Logfile.filename      = $logfile
        log4perl.appender.Logfile.DatePattern   = yyyy-MM-dd
        log4perl.appender.Logfile.TZ            = Brazil/East
        log4perl.appender.Logfile.max           = $max_files 
        log4perl.appender.Logfile.layout        = Log::Log4perl::Layout::PatternLayout
        log4perl.appender.Logfile.layout.ConversionPattern = %d %m %n

        log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
        log4perl.appender.Screen.stderr  = 0
        log4perl.appender.Screen.layout  = Log::Log4perl::Layout::PatternLayout
        log4perl.appender.Screen.layout.ConversionPattern = %d %m %n
    );

	Log::Log4perl->init( \$conf );
}

=head1 SEE ALSO

L<Log::Log4perl>

=head1 AUTHOR

Joao Andre Simioni <jasimioni@gmail.com>

=head1 TODO

This could be changed to a EVCenter::Probe::Config class, so it could control
all configuration paramters, including logging.

=head1 LICENSE

TBD

=cut

1;