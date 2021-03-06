package WWW::LogicBoxes::Role::Command::Contact;

use strict;
use warnings;

use Moose::Role;
use MooseX::Params::Validate;

use WWW::LogicBoxes::Types qw( Contact Int );

use WWW::LogicBoxes::Contact::Factory;

use Try::Tiny;
use Carp;

requires 'submit';

# VERSION
# ABSTRACT: Contact API Calls

sub create_contact {
    my $self   = shift;
    my (%args) = validated_hash(
        \@_,
        contact => { isa => Contact, coerce => 1 },
    );

    if( $args{contact}->has_id ) {
        croak "Contact already exists (it has an id)";
    }

    my $response = $self->submit({
        method => 'contacts__add',
        params => $args{contact}->construct_creation_request(),
    });

    $args{contact}->_set_id($response->{id});

    return $args{contact};
}

sub get_contact_by_id {
    my $self = shift;
    my ( $id ) = pos_validated_list( \@_, { isa => Int } );

    return try {
        my $response = $self->submit({
            method => 'contacts__details',
            params => {
                'contact-id' => $id,
            },
        });

        return WWW::LogicBoxes::Contact::Factory->construct_from_response( $response );
    }
    catch {
        if( $_ =~ m/^Invalid contact-id/ || $_ =~ m/^No Entity found/ ) {
            return;
        }

        croak $_;
    };
}

sub update_contact {
    my $self = shift;
    my (%args) = validated_hash(
        \@_,
        contact => { isa => Contact, coerce => 1 },
    );

    if( !$args{contact}->has_id ) {
        croak "Contact does not exist (it lacks an id)";
    }

    return try {
        $self->submit({
            method => 'contacts__modify',
            params => {
                'contact-id' => $args{contact}->id,
                %{ $args{contact}->construct_creation_request() },
            }
        });

        return $self->get_contact_by_id( $args{contact}->id );
    }
    catch {
        if( $_ =~ m/^Invalid contact-id/ || $_ =~ m/^No Entity found/ ) {
            croak 'Invalid Contact ID';
        }

        croak $_;
    };
}

sub delete_contact_by_id {
    my $self = shift;
    my ( $id ) = pos_validated_list( \@_, { isa => Int } );

    return try {
        $self->submit({
            method => 'contacts__delete',
            params => {
                'contact-id' => $id,
            },
        });

        return;
    }
    catch {
        croak $_;
    };
}

1;

__END__
=pod

=head1 NAME

WWW::LogicBoxes::Role::Command::Contact - Contact Related Operations

=head1 SYNOPSIS

    use WWW::LogicBoxes;
    use WWW::LogicBoxes::Customer;
    use WWW::LogicBoxes::Contact;

    my $customer = WWW::LogicBoxes::Customer->new( ... );
    my $contact  = WWW::LogicBoxes::Contact->new( ... );

    # Creation
    my $logic_boxes = WWW::LogicBoxes->new( ... );
    $logic_boxes->create_contact( contact => $contact );

    # Retrieval
    my $retrieved_contact = $logic_boxes->get_contact_by_id( $contact->id );

    # Update
    my $old_contact = $logic_boxes->get_contact_by_id( 42 );
    my $contact  = WWW::LogicBoxes::Contact->new(
        id => $old_contact->id,
        ...
    );

    $logic_boxes->update_contact( contact => $contact );

    # Deletion
    $logic_boxes->delete_contact_by_id( $contact->id );

=head1 REQURIES

submit

=head1 DESCRIPTION

Implements contact related operations with the L<LogicBoxes's|http://www.logicboxes.com> API.

=head1 METHODS

=head2 create_contact

    use WWW::LogicBoxes;
    use WWW::LogicBoxes::Customer;
    use WWW::LogicBoxes::Contact;

    my $customer = WWW::LogicBoxes::Customer->new( ... );
    my $contact  = WWW::LogicBoxes::Contact->new( ... );

    my $logic_boxes = WWW::LogicBoxes->new( ... );
    $logic_boxes->create_contact( contact => $contact );

    print 'New contact id: ' . $contact->id . "\n";

Given a L<WWW::LogicBoxes::Contact> or a HashRef that can be coerced into a L<WWW::LogicBoxes::Contact>, creates the specified contact with LogicBoxes.

=head2 get_contact_by_id

    use WWW::LogicBoxes;
    use WWW::LogicBoxes::Contact;

    my $logic_boxes = WWW::LogicBoxes->new( ... );
    my $contact     = $logic_boxes->get_contact_by_id( 42 );

Given an Integer ID, will return an instance of L<WWW::LogicBoxes::Contact> (or one of it's subclass for specialized contacts).  Returns undef if there is no matching L<contact|WWW::LogicBoxes::Contact> with the specified id.

=head2 update_contact

    use WWW::LogicBoxes;
    use WWW::LogicBoxes::Customer;
    use WWW::LogicBoxes::Contact;

    my $logic_boxes = WWW::LogicBoxes->new( ... );

    my $old_contact = $logic_boxes->get_contact_by_id( 42 );
    my $contact  = WWW::LogicBoxes::Contact->new(
        id => $old_contact->id,
        ...
    );

    $logic_boxes->update_contact( contact => $contact );

Given a L<WWW::LogicBoxes::Contact> or a HashRef that can be coerced into a L<WWW::LogicBoxes::Contact>, updates the contact with the specified id with L<LogicBoxes|http://www.logicboxes.com>.

=head2 delete_contact_by_id

    use WWW::LogicBoxes;
    use WWW::LogicBoxes::Contact;

    my $logic_boxes = WWW::LogicBoxes->new( ... );
    $logic_boxes->delete_contact_by_id( 42 );

Given an Integer ID, will delete the L<contact|WWW::LogicBoxes::Contact> with L<LogicBoxes|http://www.logicboxes.com>.

This method will croak if the contact is in use (assigned to a domain).

=cut

