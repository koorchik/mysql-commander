package App::MysqlCommander::UI;

use Modern::Perl;
use Moo;

with 'App::MysqlCommander::Role::PubSub';

use Curses::UI;
use Curses;


has 'cui' => ( 
    'is'  => 'lazy',
    'default' => sub { Curses::UI->new( -color_support => 1 ) }
);

has 'sql_editor' => (
    'is' => 'rw'
);


sub run {
    my $self = shift;
    
    say 'RUN UI';

    $self->_compose_ui();
    $self->sql_editor->focus();
    $self->cui->mainloop();
}


sub _compose_ui {
    my $self = shift;

    $self->_append_main_menu();
    $self->_append_main_window();
    $self->_append_sql_editor();
    $self->_append_results_viewer();
    $self->_set_keyboard_bindings();
}


sub _append_results_viewer {
    my $self = shift;

    my $main_window = $self->cui->getobj('main_window');

    my $values = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ];
    my $labels = {
        1  => 'One       |One       |One       |One       |One       |One       |One       One       |One       ',   
        3  => 'Three     |Three     |Three     |Three     |Three     |Three     |Three     Three     |Three     ', 
        5  => 'Five      |Five      |Five      |Five      |Five      |Five      |Five      Five      |Five      ',  
        7  => 'Seven     |Seven     |Seven     |Seven     |Seven     |Seven     |Seven     Seven     |Seven     ', 
        9  => 'Nine      |Nine      |Nine      |Nine      |Nine      |Nine      |Nine      Nine      |Nine      ',  
        2  => 'Two       |Two       |Two       |Two       |Two       |Two       |Two       Two       |Two       ',
        4  => 'Four      |Four      |Four      |Four      |Four      |Four      |Four      Four      |Four      ',
        6  => 'Six       |Six       |Six       |Six       |Six       |Six       |Six       Six       |Six       ',
        8  => 'Eight     |Eight     |Eight     |Eight     |Eight     |Eight     |Eight     Eight     |Eight     ',
        10 => 'Ten       |Ten       |Ten       |Ten       |Ten       |Ten       |Ten       Ten       |Ten       ',
    };
    
    my $results_block =  $main_window->add( 
       undef, 'Container',
        -y          => 7,
        -border     => 1,
        -title      => 'Results',
        -vscrollbar => 1,
        -bg         => 'blue',
        -bbg        => 'blue',
        -fw         => 'white',
        -onchange   => \&listbox_callback,
    );
    
    my $results_table_header = $results_block->add( 
       'results_table_header', 'Label',
        -text       => $labels->{1},  
        -border     => 0,
        -width      => -1, 
        -height     => 1,
        -bg         => 'white',
        -bbg        => 'white',
        -fg         => 'blue',
        -bold       => 1,
    );

    my $results_table = $results_block->add( 
       'results_table', 'Listbox',
        -y          => 1,
        -values     => $values,
        -labels     => $labels,
        -vscrollbar => 1,
        -border     => 0,
        -bg         => 'blue',
        -bbg        => 'blue',
        -fw         => 'white',
        -onchange   => \&listbox_callback,
    );
}

sub _append_main_menu {
    my $self = shift;

    my @menu = ({ 
        -label   => 'Main', 
        -submenu => [ { 
            -label => 'Choose Database', 
            -value => \&exit_dialog  
        },
        { 
            -label => 'Settings', 
            -value => \&exit_dialog  
        },
        { 
            -label => 'Quit', 
            -value => \&exit_dialog  
        } ]
    },
    { 
        -label   => 'Server', 
        -submenu => [ 
        { 
            -label => 'Variables', 
            -value => \&exit_dialog  
        },
        { 
            -label => 'Statictics', 
            -value => \&exit_dialog  
        },
        { 
            -label => 'Process list', 
            -value => \&exit_dialog  
        } ]
    }, { 
        -label   => 'About', 
        -submenu => [ { 
            -label => 'Choose Database ^Q', 
            -value => \&exit_dialog  
        },
        { 
            -label => 'Show status      ^Q', 
            -value => \&exit_dialog  
        },
        { 
            -label => 'Show variables  ^Q', 
            -value => \&exit_dialog  
        },
        { 
            -label => 'Show process list  ^Q', 
            -value => \&exit_dialog  
        } ]
    });

    my $menu = $self->cui->add(
        'main_menu', 'Menubar',
        -menu => \@menu,
        -fg   => "white",
        -bg   => 'blue',
    );
}


sub _append_main_window {
    my $self = shift;

    $self->cui->add( 
        'main_window', 'Window',
        -border => 1,
        -y      => 1,
        -bbg    => 'blue',
    );
}

sub _append_sql_editor {
    my ( $self, $parent ) = @_;
    my $main_window = $self->cui->getobj('main_window');

    my $sql_editor = $main_window->add(
        "text", "TextEditor",
        -maxlines => 10,
        -height   => 6,
        -border   => 0,
        -bg       => 'white',
        -fg       => 'black',
        -text     => "Here is some text\n" . "And some more"
    );

    $self->sql_editor($sql_editor);

    $sql_editor->set_binding( sub {
        my $text = $self->sql_editor->text;
        #$self->trigger('sql_update', $text);
        $self->sql_editor->text('updated');
    }, KEY_ENTER);

    $main_window->add(
        undef, 'Label',
        -y      => 6,
        -width  => -1,
        -bg     => 'blue',
    );
}

sub _set_keyboard_bindings {
    my $self = shift;

    $self->cui->set_binding(sub {
        $self->cui->getobj('main_menu')->focus();
    }, "\cX");
    
    $self->cui->set_binding( sub {
        $self->_show_exit_dialog(); 
    }, "\cQ");
}

sub _show_exit_dialog {
    my $self = shift;

    my $return = $self->cui->dialog(
        -message   => "Do you really want to quit?",
        -title     => "Are you sure???", 
        -buttons   => ['yes', 'no'],
        -bbg       => 'blue',
        -bg        => 'blue',
    );
 
    exit(0) if $return;
}

1;