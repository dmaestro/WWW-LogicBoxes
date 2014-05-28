package WWW::LogicBoxes::Domain;

use strict;
use warnings;

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

use Carp;
use Mozilla::PublicSuffix qw(public_suffix);

# VERSION
# ABSTRACT: LogicBoxes Domain Representation

has name => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has is_available => (
    is  => 'ro',
    isa => 'Bool',
    builder => '_build_is_available',
);

sub tld {
    my $self = shift;

    return public_suffix($self->name);
}

## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub _build_is_available {
## use critic

    croak "Not Yet Implemented";
}

__PACKAGE__->meta->make_immutable;
1;
