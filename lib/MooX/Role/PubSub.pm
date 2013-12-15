package MooX::Role::PubSub;

use Moo::Role;

has '_pub_sub_events' => (
    is      => 'ro',
    default => sub { +{} }
);

sub trigger {
    my ($self, $event_name, $data) = @_;
    
    if ( $self->_pub_sub_events->{$event_name} ) {
         $self->_pub_sub_events->{$event_name}->($self, $data);
    }
};

sub on {
    my ($self, $event_name, $cb) = @_;

    $self->_pub_sub_events->{$event_name} = $cb;
}

sub off {
    my ($self, $event_name) = @_;
    delete $self->_pub_sub_events->{$event_name};    
}



1;

