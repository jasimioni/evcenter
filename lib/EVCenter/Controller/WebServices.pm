package EVCenter::Controller::WebServices;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

EVCenter::Controller::WebServices - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub default :Path :Args() {
    my ( $self, $c, @args) = @_;

    $c->stash(current_view => 'JSON');
    my $jsonrpc = $c->req->body_data;

    my $jsonrpc_output = {};

    my $method = $jsonrpc->{method};
    my ($controller, $method) = split(/\./, $method);
    $controller =~ s/\W//g;
    $method     =~ s/\W//g;
    $controller = "Private::$controller";

    if (defined $c->controller($controller) && $c->controller($controller)->can($method)) {
    	$jsonrpc_output = $c->forward($controller, $method, [ $jsonrpc->{params} ]);
	} else {
		$jsonrpc_output->{error} = {
			code => -32601,
			message => "Method not found",
		}
	}

    $jsonrpc_output->{id}      = $jsonrpc->{id}      if (exists $jsonrpc->{id});
    $jsonrpc_output->{jsonrpc} = $jsonrpc->{jsonrpc} if (exists $jsonrpc->{jsonrpc});
    $c->stash(jsonrpc_output => $jsonrpc_output);
}

sub end :ActionClass('RenderView') {
	my ($self, $c) = @_;

    my $jsonrpc = $c->req->body_data;
    my $jsonrpc_output = $c->stash->{jsonrpc_output};

    if (! defined $jsonrpc_output->{error} && ! defined $jsonrpc_output->{result}) {
    	$jsonrpc_output->{error} = 'No Output Generated';
    }

	if (defined $jsonrpc->{jsonrpc} && $jsonrpc->{jsonrpc} >= 2) {
    	# JSON-RPC 2.0 não pode ter error e result ao mesmo tempo
    	delete $jsonrpc_output->{error}  if (defined $jsonrpc_output->{result});
    	if (defined $jsonrpc_output->{error}) {
    		delete $jsonrpc_output->{result};
    		if (! ref $jsonrpc_output->{error}) {
    			# RPC 2.0 precisa que erro seja objeto, então se for string, converte pra objeto.
    			$jsonrpc_output->{error} = {
    				code    => -10000, # Generic Error
    				message => $jsonrpc_output->{error},
    			};
    		}
    	}
    } elsif (defined $jsonrpc->{version} && $jsonrpc->{version} < 2) {
		# JSON-RPC 1.1 precisa ter error e output definidos, como null se não forem úteis
    	$jsonrpc_output->{error}  = undef if (defined $jsonrpc_output->{result});				 
    	$jsonrpc_output->{result} = undef if (defined $jsonrpc_output->{error});				 
    } 
}

=encoding utf8

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
