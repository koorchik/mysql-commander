package MooX::Role::PubSub;

use Moo::Role;

has '_event_listeners' => (
    is      => 'ro',
    default => sub { +{} }
);

sub trigger {
    my ($self, $event_name, $data) = @_;
    my $listeners = $self->_event_listeners->{$event_name} or return;

    foreach my $listener (@$listeners) {
        $listener->($self, $data);
    }
}

sub on {
    my ($self, $event_name, $cb) = @_;
    push @{$self->_event_listeners->{$event_name}}, $cb;
}

sub off {
    my ($self, $event_name, $cb) = @_;
    my $listeners = $self->_event_listeners->{$event_name} or return;

    if ($cb) {
        @$listeners = grep {$_ ne $cb} @$listeners; 
    } else {
        delete $self->_event_listeners->{$event_name};
    }
}

1;

