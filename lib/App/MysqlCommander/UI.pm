package App::MysqlCommander::UI;

use Modern::Perl;
use Moo;

with 'App::MysqlCommander::Role::PubSub';

use Curses::UI;
use Curses;
use Curses::UI::Table;


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

    my @columns = ({
        -isid  => 1,
        -key   => 'user_id',
        -label => 'User ID'
    }, 
    {
        -key   => 'first_name',
        -label => 'First Name'
    },
    {
        -key   => 'middle_name',
        -label => 'Middle Name'
    },
    {
        -key   => 'last_name',
        -label => 'Last Name'
    },
    {
        -key   => 'email',
        -label => 'Email'
    });

    my @rows = ({
        user_id     => 1,
        first_name  => 'Vasya',
        middle_name => 'Vaskin',
        last_name   => 'Pupkin',
        email       => 'vasya.email@mail.com'
    },
    {
        user_id     => 2,
        first_name  => 'Vasya2',
        middle_name => 'Vaskin2',
        last_name   => 'Pupkin2',
        email       => 'vasya.email@mail.com'
    },
    {
        user_id     => 3,
        first_name  => 'Vasya3',
        middle_name => 'Vaskin3',
        last_name   => 'Pupkin3',
        email       => 'vasya.email@mail.com'
    });

    my $results_table = $main_window->add( 
       'results_table', 'Table',
        -y          => 7,
        -border     => 1,
        -title      => 'Results',
        -bg         => 'blue',
        -bbg        => 'blue',
        -fw         => 'white',
        -columns    => \@columns,
        -rows       => \@rows
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