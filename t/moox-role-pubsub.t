#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

# Simple class
package Test::MyPubSub;
use Moo;
with 'MooX::Role::PubSub';

sub method1 {
    shift->trigger('method1', { data => 'data1'} );
}

sub method2 {
    shift->trigger('method2', { data => 'data2'} );
}


# Return to test
package main;

use Test::More;

subtest 'Role consumption' => sub {
    my $obj = new_ok('Test::MyPubSub');
    can_ok($obj, qw/trigger on off/);
};

subtest 'Simple subscribe' => sub {
    my $obj = new_ok('Test::MyPubSub');

    my $event_occured = 0;
    $obj->on('method1' => sub { 
        my ($obj, $data) = @_;

        isa_ok( $obj, 'Test::MyPubSub' );
        is_deeply($data, { data => 'data1'}, 'data should be correct');

        $event_occured++;
    });

    ok(!$event_occured, 'event not occured yet');
    
    $obj->method2();
    ok(!$event_occured, 'event not occured yet ');

    $obj->method1();
    is($event_occured, 1, 'event occured first time');


    $obj->method1();
    is($event_occured, 2, 'event occured second time');
};


subtest 'Double subscribe' => sub {
    my $obj = new_ok('Test::MyPubSub');

    my $event_count_first_listener = 0;
    $obj->on('method1' => sub { 
        my ($obj, $data) = @_;

        isa_ok( $obj, 'Test::MyPubSub' );
        is_deeply($data, { data => 'data1'}, 'data should be correct');

        $event_count_first_listener++;
    });

    my $event_count_second_listener = 0;
    $obj->on('method1' => sub { 
        my ($obj, $data) = @_;

        isa_ok( $obj, 'Test::MyPubSub' );
        is_deeply($data, { data => 'data1'}, 'data should be correct');

        $event_count_second_listener++;
    });

    ok(!$event_count_first_listener, 'first listener event not occured yet');
    ok(!$event_count_second_listener, 'second listener event not occured yet');
    
    $obj->method2();
    ok(!$event_count_first_listener, 'first listener event not occured yet ');
    ok(!$event_count_second_listener, 'second listener event not occured yet ');

    $obj->method1();
    is($event_count_first_listener, 1, 'first listener event occured first time');
    is($event_count_second_listener, 1, 'second listener event occured first time');


    $obj->method1();
    is($event_count_first_listener, 2, 'first listener event occured second time');
    is($event_count_second_listener, 2, 'second listener event occured second time');
};

subtest 'Unsubscribe all listeners' => sub {
    my $obj = new_ok('Test::MyPubSub');

    my $event_count_first_listener = 0;
    $obj->on('method1' => sub { $event_count_first_listener++ });

    my $event_count_second_listener = 0;
    $obj->on('method1' => sub { $event_count_second_listener++ });

    $obj->off('method1');
    $obj->method1();
    is($event_count_first_listener, 0, 'first listener event shoud not occure');
    is($event_count_second_listener, 0, 'second listener event shoud not occure');
};

subtest 'Unsubscribe listeners one by one' => sub {
    my $obj = new_ok('Test::MyPubSub');

    my $event_count_first_listener = 0;
    my $first_listener = sub { $event_count_first_listener++ };
    $obj->on( 'method1' => $first_listener );

    my $event_count_second_listener = 0;
    my $second_listener = sub { $event_count_second_listener++ };
    $obj->on( 'method1' => $second_listener );

    
    $obj->method1();
    is($event_count_first_listener, 1, 'first listener event shoud occure');
    is($event_count_second_listener, 1, 'second listener event shoud occure');

    $event_count_first_listener = $event_count_second_listener = 0;
    $obj->off( 'method1', $second_listener );
    $obj->method1();
    is($event_count_first_listener, 1, 'first listener event shoud occure');
    is($event_count_second_listener, 0, 'second listener event shoud not occure after unsubscribe');

    $event_count_first_listener = $event_count_second_listener = 0;
    $obj->off( 'method1', $first_listener );
    $obj->method1();
    is($event_count_first_listener, 0, 'first listener event shoud not occure after unsubscribe');
    is($event_count_second_listener, 0, 'second listener event shoud not occure after unsubscribe');

};

done_testing();