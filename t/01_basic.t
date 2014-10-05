use strict;
use warnings;

use Test::More 0.88;
END { done_testing }
use Tie::SortHash;

my %hash = qw(
              perl   1
              python 2
              java   3
              php    4
             );

my $sortblock = q( $a cmp $b );

my $tied_ref = tie %hash, 'Tie::SortHash', \%hash;

ok( $tied_ref->isa( 'Tie::SortHash' ) );

ok( $tied_ref->sortblock( $sortblock ) );

my @keys = keys %hash;

ok( $keys[0] eq 'java' );

ok( $keys[3] eq 'python' );

ok( (tied %hash)->sortblock( q( $hash{$a} <=> $hash{$b} ) ) );

my @values = values %hash;

ok( $values[0] == 1 );

ok( $values[3] == 4 );

ok( delete $hash{java} == 3 );

$hash{asp} = 5;
ok( $hash{asp} == 5 );

@values = values %hash;

ok( $values[3] == 5 );

ok( ! undef %hash );
