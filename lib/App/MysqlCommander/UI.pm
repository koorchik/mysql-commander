package App::MysqlCommander::UI;

use Modern::Perl;
use Moo;

with 'App::MysqlCommander::Role::PubSub';

use Curses::UI;
use Curses;
use Curses::UI::Table;


has cui => ( 
    is      => 'lazy',
    default => sub { Curses::UI->new( -color_support => 1 ) }
);

has sql_editor => (
    is => 'rw'
);

has results_table => (
    is => 'rw'
);

has queries => (
    is      => 'ro',
    default => sub {+{
        'databases'   => 'SHOW DATABASES',
        'variables'   => 'SHOW VARIABLES',
        'statictics'  => 'SHOW TABLE STATUS',
        'processlist' => 'SHOW PROCESSLIST',
        'tables'      => 'SHOW TABLES',
    }}
);

sub run {
    my $self = shift;
    
    say 'RUN UI';

    $self->_compose_ui();
    $self->sql_editor->focus();
    $self->cui->mainloop();
}

sub redraw_results {

}

sub update_data {
    my ($self, $data) = @_;
     
    my $rows = $data;
    my $columns = $self->_make_columns_from_row( $rows->[0] );

    $self->results_table->update_data($columns, $rows);
}

sub _compose_ui {
    my $self = shift;

    $self->_append_main_menu();
    $self->_append_main_window();
    $self->_append_sql_editor();
    $self->_append_results_viewer();
    $self->_append_bindings_help();
    $self->_set_keyboard_bindings();
}


sub _append_results_viewer {
    my $self = shift;

    my $main_window = $self->cui->getobj('main_window');


    my $results_table = $main_window->add( 
       'results_table', 'Table',
        -y          => 7,
        -border     => 1,
        -title      => 'Results',
        -bg         => 'blue',
        -bbg        => 'blue',
        -fw         => 'white',
        -columns    => [],
        -rows       => [],
        -padbottom  => 1,
    );

    $self->results_table($results_table);
}

sub _append_main_menu {
    my $self = shift;

    my @menu = ({ 
        -label   => 'Main', 
        -submenu => [ { 
            -label => 'Choose Database', 
            -value => sub {
                $self->_execute_query('databases');
            }  
        },
        { 
            -label => 'Settings', 
            -value => sub {
                $self->_show_settings_dialog();
            }
        },
        { 
            -label => 'Quit', 
            -value => sub {
                $self->_show_exit_dialog();  
            }
        } ]
    },
    { 
        -label   => 'Server', 
        -submenu => [ 
        { 
            -label => 'Variables', 
            -value => sub {
                $self->_execute_query('variables');
            }  
        },
        { 
            -label => 'Statictics', 
            -value => sub {
                $self->_execute_query('statictics');
            }  
        },
        { 
            -label => 'Process list', 
            -value => sub {
                $self->_execute_query('processlist');
            }
        } ]
    },
    { 
        -label   => 'Database', 
        -submenu => [ 
        { 
            -label => 'Tables', 
            -value => sub {
                $self->_execute_query('tables');
            }  
        }]
    });

    my $menu = $self->cui->add(
        'main_menu', 'Menubar',
        -menu => \@menu,
        -fg   => "black",
        -bg   => 'cyan',
        -bold => 1,
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
        -text     => "",
    );

    $self->sql_editor($sql_editor);

    $sql_editor->set_binding( sub {
        my $query = $self->sql_editor->text;
        $self->trigger('sql_update', $query);
    }, "\cr");

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

sub _append_bindings_help {
    my $self = shift;
    $self->cui->getobj('main_window')->add( 
       'help', 'Label',
        -text       => 'CTRL+R Execute query | CTRL+X Menu | CTRL+Q Quit',  
        -y          => -1,     
        -border     => 0,
        -width      => -1, 
        -height     => 1,
        -bg         => 'white',
        -bbg        => 'white',
        -fg         => 'black',
        -bold       => 1,
    );
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

sub _execute_query {
    my ( $self, $query_name ) = @_;
    my $query = $self->queries->{$query_name};

    $self->sql_editor->text($query);
    $self->sql_editor->pos(100);
    $self->trigger('sql_update', $query);
}

sub _make_columns_from_row {
    my ($self, $row) = @_;
    return [] unless $row;

    my @columns;
    foreach my $key (sort keys %$row) {
        push @columns, {
            -isid  => 1,
            -key   => $key,
            -label => $key,
        }
    }

    return \@columns;
}

sub _show_settings_dialog {

}

1;