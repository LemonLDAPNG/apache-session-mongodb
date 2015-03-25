package Apache::Session::MongoDB;

use 5.010;
use strict;

our $VERSION = '0.11';
our @ISA     = qw(Apache::Session);

use Apache::Session;
use Apache::Session::Lock::Null;
use Apache::Session::Store::MongoDB;
use Apache::Session::Generate::MD5;
use Apache::Session::Serialize::MongoDB;

sub populate {
    my $self = shift;

    $self->{object_store} = Apache::Session::Store::MongoDB->new($self);
    $self->{lock_manager} = Apache::Session::Lock::Null->new($self);
    $self->{generate}     = \&Apache::Session::Generate::MD5::generate;
    $self->{validate}     = \&Apache::Session::Generate::MD5::validate;
    $self->{serialize}    = \&Apache::Session::Serialize::MongoDB::serialize;
    $self->{unserialize}  = \&Apache::Session::Serialize::MongoDB::unserialize;
}

1;

__END__
# TODO:
sub searchOn {
    my ( $class, $args, $selectField, $value, @fields ) = splice @_;
}

sub searchOnExpr {
    my ( $class, $args, $selectField, $value, @fields ) = splice @_;
}

sub get_key_from_all_sessions {
    my ( $class, $args, $data ) = splice @_;
}

1;

=head1 NAME

Apache::Session::MongoDB - An implementation of Apache::Session

=head1 SYNOPSIS

 use Apache::Session::MongoDB;
 
 tie %hash, 'Apache::Session::MongoDB', $id, {
    Host => 'locahost',
    Port => 27017
 };

=head1 DESCRIPTION

This module is an implementation of Apache::Session.  It uses the MongoDB
backing store and no locking.  See the example, and the documentation for
Apache::Session::Store::MongoDB for more details.

=head1 SEE ALSO

L<Apache::Session>

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.fr<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Xavier Guimard, E<lt>x.guimard@free.fr<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
