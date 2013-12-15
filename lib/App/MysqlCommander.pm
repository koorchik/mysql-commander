package App::MysqlCommander;

use DBI;
use Try::Tiny;
use Data::Dumper;

use Modern::Perl;
use Moo;
use MooX::Options;

use App::MysqlCommander::UI;

option 'user' => (
    is       => 'ro',
    short    => 'u',
    format   => 's',
    required => 1,
    doc      => 'User for login if not current user.'
);

option 'database' => (
    is       => 'ro',
    short    => 'D',
    format   => 's',
    required => 1,
    doc      => 'Database to use.'
);

option 'password' => (
    is       => 'ro',
    short    => 'p',
    format   => 's',
    doc      => "Password to use when connecting to server. If password is not given it's asked from the tty."
);


has 'dbh' => ( is => 'lazy' );
has 'ui'  => ( is => 'lazy' );

sub run {
    say 'Starting app...';

    my $self = shift;
    $self->ui->run();
}

sub _build_ui {
    my $self  = shift;

    my $ui = App::MysqlCommander::UI->new();

    $ui->on('sql_update' => sub {
        my ( $ui, $sql ) = @_;

        try {
            my $data = $self->dbh->selectall_arrayref($sql, { Slice => {} });
            $ui->update_data($data);
        } 
        catch {
            warn $_;
        };
    });

    return $ui;
}

sub _build_dbh {
    my $self = shift;

    my $dsn = "DBI:mysql:". $self->database ."=mysql;";
    my $dbh = DBI->connect($dsn, $self->user, $self->password, {RaiseError =>1});
    return $dbh;
}

1;

