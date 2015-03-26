package Apache::Session::Store::MongoDB;

use 5.010;
use strict;

our $VERSION = '0.12';

use MongoDB;

our $default = {
    host       => 'localhost:27017',
    database   => 'sessions',
    collection => 'sessions',
};

sub new {
    my $class = shift;

    return bless {}, $class;
}

sub connection {
    my ( $self, $session ) = splice @_;
    return
      if ( defined $self->{collection} );
    my $conn_args;
    foreach my $w (qw(host username password ssl admin_db)) {
        my $t = $w;
        $t =~ s/^db_name$/admin_db/;
        $conn_args->{$t} = $session->{args}->{$t} || $default->{$t};
        delete $conn_args->{$t} unless ( defined $conn_args->{$t} );
    }
    my $s = MongoDB::MongoClient->new($conn_args)
      or die('Unable to connect to MongoDB server');
    $self->{collection} =
      $s->get_database( $session->{args}->{database} || $default->{database} )
      ->get_collection( $session->{args}->{collection}
          || $default->{collection} );
}

sub insert {
    my ( $self, $session ) = splice @_;
    $self->connection($session);
    die('no id') unless ( $session->{data}->{_session_id} );
    $session->{data}->{_id} = $session->{data}->{_session_id};
    $self->{collection}->insert( $session->{data} );
}

sub update {
    my ( $self, $session ) = splice @_;
    $self->remove($session);
    $self->insert($session);
}

sub materialize {
    my ( $self, $session ) = splice @_;
    $self->connection($session);
    $session->{data} = $self->{collection}
      ->find_one( { _id => $session->{data}->{_session_id} } );
    $session->{data}->{_session_id} = $session->{data}->{_id};
}

sub remove {
    my ( $self, $session ) = splice @_;
    $self->connection($session);
    $self->{collection}->remove( { _id => $session->{data}->{_session_id} } );
}

sub DESTROY {
    my $self = shift;
    $self->{collection} = undef;
}

1;
__END__

=head1 NAME

Apache::Session::MongoDB - An implementation of Apache::Session

=head1 SYNOPSIS

 use Apache::Session::MondoDB;

 # Using localhost server
 tie %hash, 'Apache::Session::MongoDB', $id, {};
 
 # More args:
 tie %hash, 'Apache::Session::MongoDB', $id, {
    Host     => 'locahost:27017',
    database => 'sessions',
    # Set here any MongoDB::new() arg
    # Note that :
    #  - 'db_name' is called 'admin_db' to avoid confusion with 'database'
    #  - 'database' is set by default to 'sessions'
 };

=head1 DESCRIPTION

This module is an implementation of Apache::Session. It uses the MongoDB
backing store and no locking. See the example, and the documentation for
Apache::Session::Store::MongoDB for more details.

=head1 SEE ALSO

L<Apache::Session>

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Xavier Guimard, E<lt>x.guimard@free.frE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
