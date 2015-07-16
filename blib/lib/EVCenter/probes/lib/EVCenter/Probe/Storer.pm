package EVCenter::Probe::Storer;

use common::sense;
use Moose;
use File::Spec::Functions;
use Carp qw/croak/;
use File::Path qw/make_path/;
use Log::Log4perl qw/get_logger/;
use FileHandle;
use Data::Dumper;
use Storable qw/freeze thaw/;
use FindBin;
use File::Find;
use Try::Tiny;

has log          => (is => 'ro', isa => 'Object', default => sub { get_logger });
has current_file => (is => 'rw', isa => 'Str' );
has directory    => (is => 'ro', isa => 'Str', required => 1);
has fh			 => (is => 'rw', isa => 'Object');
has error 		 => (is => 'rw', isa => 'Str');
has current_id 	 => (is => 'rw', isa => 'Str');
has probe_id	 => (is => 'ro', isa => 'Str', default => sub { $FindBin::Script });
has unprocessed  => (is => 'rw', isa => 'ArrayRef');

=encoding utf8

=head1 NAME

EVCenter::Probe:: - Class to handle request id and stored files for requests

=head1 SYNOPSIS

    use EVCenter::Probe::Storer;

    $storer = EVCenter::Probe::Storer->new(  directory => $directory,
                                           [ probe_id  => $probe_id ] );

    $storer->method; # (see method list below)

=head2 PARAMETERS

=head3 directory

The directory where the files will be stored

=head3 probe_id

The prefix of all files and IDs applied to requests.

=head1 DESCRIPTION

This class will provide some methods to control the ID of requests and to store,
retrieve and rename the store files used by the probes.

Store files hold a backup copy of source data, before being processed by the dispatcher.
This way, if the dispatcher has any problem to dispatch and the probe is shutdown,
it can try to reprocess the files.

It's a simple implementation of a L<Store and Forward|http://en.wikipedia.org/wiki/Store_and_forward>
concept, trying to avoid data loss in the case of network interruption.

=head1 METHODS

=cut

# The BUILD method will be called just after the object is created
# and it will open the directory - create it if it does not exist
# and finally create a new file to store new events. 
sub BUILD {
	my $self = shift;
	if (! -d $self->directory) {
		make_path $self->directory or croak "Directory " . $self->directory . ' does not exists and cannot be created';
	}

	$self->set_new_file or croak "Could not open new file for writing: " . $self->error;
}

# ->_search_unprocessed_files
# This method is used by get_unprocessed_file. It populates the object
# with all files in directory, which have the same probe_id prefix
# and are not set as .done. Files marked as .failed are renamed to .store
# to be reprocessed.
sub _search_unprocessed_files {
	my $self = shift;

	my $probe_id = $self->probe_id;
	my @unprocessed;
	my $f;

	# First, rename all failed to .store so they will be reprocessed.
	find(sub { 
			$self->current_file ne $File::Find::name &&
			/^${probe_id}_.*\.store\.failed$/ &&
			$self->set_file_as_unprocessed($File::Find::name) &&
			$self->log->info("Renamed ", $File::Find::name, " to try to reprocess");
		}, $self->directory);

	find(sub { 
			$self->current_file ne $File::Find::name &&
			/^(${probe_id}_.*)\.store$/ &&
			push @unprocessed, $1;
		}, $self->directory);

	@unprocessed = sort @unprocessed;
	$self->unprocessed(\@unprocessed);
	$self->log->debug("Unprocessed: @unprocessed");
}

=head2 get_unprocessed_file

    ($file, $id, $events, $error) = $storer->get_unprocessed_file;

This method is an iterator. Each call to it will return a file and the
events stored on it, parsed using ->read_events_from_file. 
In case of error, $error will be set.

=cut
sub get_unprocessed_file {
	my $self = shift;

	if (! defined $self->unprocessed) {
		$self->_search_unprocessed_files;
	}

	my $id = shift @{$self->unprocessed} or return ();
	my $file = catfile($self->directory, $id. '.store');
	my ($events, $error) = $self->read_events_from_file($file);
	return ($file, $id, $events, $error);
}

=head2 set_new_file

    my $fh = $storer->set_new_file;

This method will create a new file, in the directory specified in
object creation. The file will be named as probe_id . time . index . .store
where index is an incremental number. The method will make sure the index
is of a file that does not exists.

Return the filehandle created or undef on failure, and set $storer->error to 
the reason.

On creation $storer->current_id will be updated with the name of the file, minus
the .store extension.

=cut

sub set_new_file {
	my $self = shift;

	my $file = $self->probe_id . '_' . time();
	my $index = 1;

	# If file with same index exists, increment index until a free slot is found
	$index++ while (-e catfile($self->directory, $file . '_' . sprintf("%02d", $index) . '.store'));

	$file = $file . '_' . sprintf("%02d", $index);

	my $newfile = catfile($self->directory, $file . '.store');
	$self->log->debug("Creating new file: $newfile");

	$self->current_file($newfile);
	$self->current_id($file);

	# If there was an open file, close it now.
	$self->fh->close if defined $self->fh;

	# Open the new one
	$self->fh(FileHandle->new($newfile, 'w'));
	$self->fh->binmode if defined $self->fh;
	$self->error($!) if ! defined $self->fh;
	return $self->fh;
}

=head2 store

    $storer->store($data);

This method will freeze the data, using Storable::freeze and save
it to the current file (set by ->set_new_file method). The data saved
is the length of the frozen data plus the data itself.

=cut

sub store {
	my $self = shift;
	my ($data) = @_;

	my $frozen_data = freeze $data;
	my $length_data = length $frozen_data;

	$self->log->debug("Saved packet - Length: $length_data");
	$self->fh->print(pack('I', $length_data), $frozen_data) or die "Could not write to filehandle - $!";
	$self->fh->flush;
}

=head2 read_events_from_file

    ($events_array_ref, $error) = $storer->read_events_from_file($file);

This method will read all the events stored in file, then thaw (unfreeze) and
return them as an array_ref containing the events.

=cut

sub read_events_from_file {
	my $self = shift;
	my $file = shift;

	my @events;
	my $error = undef;

	try {
		my $fh = FileHandle->new($file, 'r') or die "Could not open $file - $!";
		my $integer_size = length pack('I', 0);
		my ($size, $event);

		while (my $bytes_read = $fh->read($size, $integer_size)) {
			if ($bytes_read != $integer_size) {
				die "Could not read an integer from $file";
			}
			$size = unpack('I', $size);
			my $bytes_read = $fh->read($event, $size);
			if ($bytes_read != $size) {
				die "Could not read the amount of bytes requested in $file";
			}
			$event = thaw $event;
			$self->log->debug('Just read the packet... ', Dumper $event);
			push @events, $event;
		}
	} catch {
		$error = "Failed to read some events: $_";
	};

	return (\@events, $error);
}

=head2 delete_processed

    $storer->delete_processed($max_age);

This method will take a $max_age parameter, in seconds, and will delete all
files in directory, which have the same prefix ($storer->probe_id) and the
.done suffix that are older than now - $max_age

=cut

sub delete_processed {
	my $self    = shift;
	my $max_age = shift;
	my $now     = time;

	my $probe_id = $self->probe_id;
	my @to_delete;
	find(sub { 
			if (/^${probe_id}_(\d+)_.*\.store\.done$/) {
				push @to_delete, $File::Find::name if ($now - $1 > $max_age);
			}
		}, $self->directory);
	if (@to_delete) {
		$self->log->info("Deleting expired files: @to_delete");
		unlink @to_delete or $self->log->error("Failed to delete files: $!");
	}
}

=head2 delete_processed

    $storer->delete_unprocessed($max_age);

This method will take a $max_age parameter, in seconds, and will delete all
files in directory, which have the same prefix ($storer->probe_id) and the
.store or .failed suffix that are older than now - $max_age

=cut

sub delete_unprocessed {
	my $self    = shift;
	my $max_age = shift;
	my $now     = time;

	my $probe_id = $self->probe_id;
	my @to_delete;
	find(sub { 
			if (/^${probe_id}_(\d+)_.*\.store(\.failed)?$/ && $File::Find::name ne $self->current_file) {
				push @to_delete, $File::Find::name if ($now - $1 > $max_age);
			}
		}, $self->directory);

	if (@to_delete) {
		$self->log->info("Deleting expired files: @to_delete");
		unlink @to_delete or $self->log->error("Failed to delete files: $!");
	}
}

=head2 set_to_done

    $storer->set_to_done($id);

This method will rename the file named by <$id>.store 
to <$id>.store.done to indicate that it was already processed.

=cut

sub set_to_done {
	my ( $self, $id ) = @_;
	my $store_file = catfile($self->directory, $id . '.store');
	rename $store_file, $store_file . '.done' if (-f $store_file);
}

=head2 set_to_failed

    $storer->set_to_failed($id);

This method will rename the file named by <$id>.store 
to <$id>.store.failed to indicate that it's processing failed

=cut

sub set_to_failed {
	my ( $self, $id ) = @_;
	my $store_file = catfile($self->directory, $id . '.store');
	rename $store_file, $store_file . '.failed' if (-f $store_file);
}

=head2 set_file_as_unprocessed

    $storer->set_file_as_unprocessed($file);

This method will rename the file named by $file (which must have
.failed suffix) to it's name without the suffix.

For exampe: C<probe_id_170100100_01.store.failed> will be renamed to
C<probe_id_170100100_01.store> to indicate that it will be reprocessed.

=cut

sub set_file_as_unprocessed {
	my ( $self, $store_file ) = @_;
	my ($unprocessed) = $store_file =~ /(.*)\.failed$/;
	return 0 if (! $store_file || ! $unprocessed);
	rename $store_file, $unprocessed;
}

=head1 SEE ALSO

L<Storable>, L<Store and Forward|http://en.wikipedia.org/wiki/Store_and_forward>

=head1 AUTHOR

Joao Andre Simioni <jasimioni@gmail.com>

=head1 LICENSE

TBD

=cut

1;
