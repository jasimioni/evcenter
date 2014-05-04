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
    $jsonrpc = {} if (ref $jsonrpc ne 'HASH');

    my $jsonrpc_output = {};

    my $o_method = $jsonrpc->{method};

    if ($o_method eq 'auth') {
        if ($c->authenticate($jsonrpc->{params})) {
            $c->forward('/Auth/calculate_permissions');
            $jsonrpc_output->{result} = { message => "Authentication Successful", auth => $c->sessionid };
        } else {
            $jsonrpc_output->{error} = {
                code => 'AUTHENTICATION_FAILURE',
                message => "Authentication Failure",
            }
        }
    } else {
        $c->stash('_session' => { id => $jsonrpc->{auth} } ) if (defined $jsonrpc->{auth});
        if ($c->user_exists) {
            my ($controller, $method) = split(/\./, $o_method);
            $controller =~ s/\W//g;
            $method     =~ s/\W//g;
            $controller = "Private::$controller";

            # $jsonrpc->{id} => Check if already processed this
            # Maybe: Set stash value with request id. Check if duplicated.
            # On end function Store it on already processed file

            if (defined $c->controller($controller) && $c->controller($controller)->can($method)) {
                $jsonrpc_output = $c->forward($controller, $method, [ $jsonrpc->{params} ]);
                $jsonrpc_output = {} if (ref $jsonrpc_output ne 'HASH');
            } else {
                $jsonrpc_output->{error} = {
                    code => 'METHOD_NOT_FOUND',
                    message => "Method not found",
                }
            }
        } else {
            $jsonrpc_output->{error} = {
                code => 'AUTHENTICATION_REQUIRED',
                message => "Authentication Required",
            }
        }
         
    }

    $jsonrpc_output->{id}      = $jsonrpc->{id}      if (exists $jsonrpc->{id});
    $jsonrpc_output->{jsonrpc} = $jsonrpc->{jsonrpc} if (exists $jsonrpc->{jsonrpc});
    $c->stash(jsonrpc_output => $jsonrpc_output);
}

sub set_error_code {
    my ( $self, $error ) = @_;

    my %error_code = (
        'GENERIC_ERROR'             => -10000,
        'ADD_EVENTS_FAILURE'        => 10000,
        'AUTHENTICATION_REQUIRED'   => 10100,
        'AUTHENTICATION_FAILURE'    => 10101,
        'SERVER_NOT_OPERATIONAL'    => 20000,
        'DATABASE_NOT_OPERATIONAL'  => 20001,
        'DATABASE_ACTION_FAILURE'   => 20002,
        'METHOD_NOT_FOUND'          => -32601,
        'INVALID_METHOD_PARAMETER'  => -32602,
    );

    return defined $error_code{$error} ? $error_code{$error} : $error;
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
    				code    => 'GENERIC_ERROR', # Generic Error
    				message => $jsonrpc_output->{error},
    			};
    		}
            $jsonrpc_output->{error}{code} = $self->set_error_code($jsonrpc_output->{error}{code});
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
