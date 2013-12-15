package Curses::UI::Table;

use strict;
use warnings;

use Curses;
use Curses::UI::Common;
use Curses::UI::Widget;
use Curses::UI::Listbox;

our $VERSION = '0.1';
use base qw/Curses::UI::ContainerWidget/;

my %routines = ( 'loose-focus'   => \&loose_focus );
 
my %bindings = ( 
    KEY_ENTER() => 'loose-focus',
    CUI_TAB()   => 'loose-focus',
    KEY_BTAB()  => 'loose-focus',
);

sub new {
    my $class = shift;
 
    my %userargs = @_;
    # keys_to_lowercase(\%userargs);
 
    my %args = (
        -parent    => undef,    # the parent window
        -width     => undef,    # the width of the checkbox
        -x         => 0,        # the horizontal pos. rel. to parent
        -y         => 0,        # the vertical pos. rel. to parent
        -checked   => 0,        # checked or not?
        -label     => '',       # the label text
        -onchange  => undef,    # event handler
        -bg        => -1,
        -fg        => -1,
        -columns   => [],
        %userargs,
        -bindings  => {%bindings},
        -routines  => {%routines},
        -focus     => 0,        # value init
        -nocursor  => 0,        # this widget uses a cursor
    );
 
    # The windowscr height should be 1.
    # $args{-height} = height_by_windowscrheight(10, %args);
 
    my $self = $class->SUPER::new( %args );
    $self->{__table_width} = $self->width - 5; # Dirty hack (for prototyping only)  
    
    my $table_header = $self->add( 
       'table_header', 'Label',
        %args,
        -text       => $self->_make_header_text( $args{-columns} ),
        -y          => 0,
        -border     => 0,
        -width      => -1, 
        -height     => 1,
        -bg         => 'magenta',
        -bbg        => 'white',
        -fg         => 'white',
        -bold       => 1,
        -focus      => 0,
    );
    $table_header->focusable(0);

    $self->add( 
       'table_body', 'Listbox',
        -y          => 1,
        -vscrollbar => 1,
        -border     => 0,
        -bg         => 'blue',
        -bbg        => 'blue',
        -fw         => 'white',
        -onchange   => sub {},
        $self->_make_table_listbox($args{-rows}, $args{-columns})
    );
 
    $self->onFocus(sub {
        my $self = shift;
        $self->getobj('table_body')->focus();
    });
    return $self;
}

sub update_data {
    my ($self, $columns, $rows) = @_;


    $self->getobj('table_header')->text(
        $self->_make_header_text( $columns )
    );

    my %args = $self->_make_table_listbox($rows, $columns);

    $self->getobj('table_body')->values($args{-values});
    $self->getobj('table_body')->labels($args{-labels});
}

sub _make_header_text {
    my ( $self, $columns ) = @_;
    return '' unless @$columns;

    my $col_width = int($self->{__table_width}/@$columns);
    my @labels = map { sprintf( "%-${col_width}.${col_width}s", $_->{-label}) } @$columns;

    return join( '|', @labels );
}

sub _make_table_listbox {
    my ( $self, $rows, $columns ) = @_;
    return ( -values => [], -labels => {} ) unless @$columns;

    my $col_width = int($self->{__table_width}/@$columns);

    my ($id_key) = map { $_->{-key} } grep { $_->{-isid} } @$columns;
    my @keys = map { $_->{-key} } @$columns;
    
    my ( @ids, %labels );
    no warnings;
    foreach my $row ( @$rows ) {
        my $id = $row->{$id_key};
        
        push @ids, $id;
        my @values = map { sprintf( "%-${col_width}.${col_width}s", $_ ) } @{$row}{@keys};
        $labels{$id} = join( '|', @values );
    } 

    return (
        -values => \@ids,
        -labels => \%labels
    );
}

1;
