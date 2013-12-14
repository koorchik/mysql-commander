package App::MysqlCommander;

use Modern::Perl;
use Moo;

has 'dbh' => ( is => 'rwp' );

sub run {
    say 'Starting app...';
}




package App::MysqlCommander::Queries;
use Moo;

sub show_tables {
    return 'SHOW TABLES';
}

sub show_databases {
    return 'SHOW DATABASES';
}

sub show_rows {
    my ($self, $table) = @_;

}

sub show_configuration_variables {
    return 'SHOW VARIABLES';
}

sub show_status {
    return 'SHOW STATUS';
}

sub explain_table {
    my ($self, $table) = @_;

}

sub show_processlist {
    return 'SHOW PROCESSLIST';
}

sub show_table_status {
    return 'SHOW TABLE STATUS';
}

1;

