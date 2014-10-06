use strict;
use warnings;

use Test::More 0.88;
END { done_testing }
use Tie::SortHash;

my $tied_ref = tie my %hash, 'Tie::SortHash', {
    perl   => 1,
    python => 2,
    java   => 3,
    php    => 4,
};

ok( $tied_ref->isa( 'Tie::SortHash' ) );
ok( $tied_ref->sortblock( q( $a cmp $b ) ) );

my @keys = keys %hash;
is_deeply( \@keys, [ qw( java perl php python ) ] );

ok( (tied %hash)->sortblock( q( $hash{$a} <=> $hash{$b} ) ) );

my @values = values %hash;
is_deeply( \@values, [ 1..4 ] );

ok( delete $hash{java} == 3 );

$hash{asp} = 5;
ok( $hash{asp} == 5 );

@values = values %hash;
is_deeply( \@values, [ qw( 1 2 4 5 ) ] );

undef %hash;
ok( ! %hash );
