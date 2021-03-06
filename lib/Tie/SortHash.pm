package Tie::SortHash;

use 5.006;
use strict;
use warnings;

our $VERSION = '1.01_01';

sub iterate {
  my( $hash, $sort, $lastkey ) = @_;
  my $iwantthis                = 0;

  # Iterate over sort order keys until we find what we want
  foreach my $key ( eval "sort { $sort } keys %{\$hash}" ) {

    return( $hash->{$key}, $key ) if $iwantthis || ! defined $lastkey;

    $iwantthis = 1 if $key eq $lastkey;
  }

  # If our sort block is screwed up, report
  die $@ if $@;

  # We ran out of keys.
  return;
} ## iterate()

sub sortblock {
  my( $self, $sort ) = @_;

  # Change default syntax to OO version
  $sort =~ s/\$hash/\$hash->/gso;

  # Test the sort block
  my $hash = $self->{DATA};
  my @keys = eval "sort { $sort } keys %{\$hash}";

  # If there's an error, freak out
  die $@ if $@;

  $self->{SORT} = $sort;

  return 1;
} ## sortblock()

sub TIEHASH {
  my $class = shift;

  my $hash  = shift || {};

  # If there's no sort block, supply a good default,
  # that's what this module's for, right?
  my $sort  = shift || '$a cmp $b || $a <=> $b';

  # Declare the data
  my $self = {
      # copy the hash
      DATA => { %{$hash} }
  };

  # Add our sort block to the data
  sortblock( $self, $sort );

  return bless $self, $class;
} # TIEHASH()

sub CLEAR {
  my $self      = shift;
  $self->{DATA} = {};
  return;
} # CLEAR()

sub DELETE {
  my( $self, $key ) = @_;

  # Delete the key pointing to the just removed value
  return delete $self->{DATA}->{$key};
} # DELETE()

sub EXISTS {
  my( $self, $key ) = @_;
  return exists $self->{DATA}->{$key};
} # EXISTS()

sub FETCH {
  my( $self, $key ) = @_;
  return exists $self->{DATA}->{$key} ? $self->{DATA}->{$key} : undef;
} # FETCH()

sub FIRSTKEY {
  my $self = shift;
  # reset hash iterator
  keys %{$self->{DATA}};
  return iterate( $self->{DATA}, $self->{SORT}, undef );
} # FIRSTKEY()

sub NEXTKEY {
  my( $self, $lastkey ) = @_;
  return iterate( $self->{DATA}, $self->{SORT}, $lastkey );
} # NEXTKEY()

sub STORE {
  my( $self, $key, $value )  = @_;

  # Add the value
  $self->{DATA}->{$key} = $value;

  return $value;
} # STORE()

1;

__END__

=encoding utf-8

=head1 NAME

Tie::SortHash - Keep hashes in a sorted order

=head1 SYNOPSIS

  use Tie::SortHash;

  my %people = (
                'John Doe'  => 33,
                'Jane Doe'  => 29,
                'Jim Smith' => 15,
               );

  my $sortblock = q(
                    my $c = (split /\s+/, $a)[1];
                    my $d = (split /\s+/, $b)[1];

                           $c cmp $d
                              ||
                    $hash{$a} <=> $hash{$b}
                   );

  tie %people, 'Tie::SortHash', \%people, $sortblock;

  foreach my $name ( keys %people ) {
    print $name . " is " . $people{$name} . " years old.\n";
  }

  # This output will always be
  Jane Doe is 29 years old.
  John Doe is 33 years old.
  Jim Smith is 15 years old.

=head1 DESCRIPTION

This module is a designed to be a lightweight hash sorting mechanism.
It is often frustrating to have a hash return elements in a random order,
such as when using the C<keys()>, C<values()> and C<each()> functions,
or simply when iterating over them.

=head1 METHODS

=head2 Tie

In order to C<tie()> your hash to C<Tie::SortHash>, you can use any of
these methods:

  tie HASH, 'Tie::SortHash', HASHREF, SORTBLOCK;

  tie HASH, 'Tie::SortHash', HASHREF;

  tie HASH, 'Tie::SortHash';

It is important to remember that if you have elements in your C<HASH>
already, you must supply a reference to that hash in C<HASHREF>.

For example:

  tie %people, 'Tie::SortHash', \%people;

If you don't, C< %people> will be set to an empty hash.  You probably
don't want that.

=head2 Standard Tied Hash Methods

C<Tie::SortHash> implements all the methods that a C<tie>d hash class should.
These are: C<TIEHASH>, C<CLEAR>, C<DELETE>, C<EXISTS>, C<FETCH>,
C<FIRSTKEY>, C<NEXTKEY> and C<STORE>.  With the exception of a few, these all
work as they would on a normal hash.  Those exceptions include:

=over 4

=item C<FIRSTKEY>

This will produce the first key according to the L<"sortblock">.

=item C<NEXTKEY>

This will produce each key according to the L<"sortblock">, excluding the
first which is hanled by C<FIRSTKEY>.

It is a B<really> bad idea to change the L<"sortblock"> in the middle of an
iteration, unless you actually want to.
( I'd be interested in why, though. )

=back

=head2 sortblock

After you have tied your hash, you can change the sort block at any time.
Some examples include:

  (tied %people)->sortblock( q( $hash{$b} <=> $hash{$a} ) );

or:

  my $tied_ref = tie my %people, 'Tie::SortHash', \%people;

  $tied_ref->sortblock( q(
                          $hash{$a} <=> $hash{$b}
                                    ||
                                 $b cmp $a
                      )  );

It is important to remember a few things about the sort block.

=over 4

=item Always pass the sort block in a non-interpolated scalar

This allows you to have greater control over the sorting that you would
like to do.  Without it, you couldn't sort by value because your program
would complain that C< %hash> hasn't been declared.  And C<$a> and C<$b> would
need to be represented more like C<$Tie::SortHash::a>.

=item C< %hash> is generic within your sort block.

This is because the internal representation of the tie hash is most likley
I<not> representative of the hash you're C<tie>ing.  And it allows the
ability to manipulate and sort accoring to value.

In other words, within your L<"sortblock">, C< %hash> is the C<Tie::SortHash>s'
representation of your hash.

=item What happens when you have a syntax error in your L<"sortblock">?

The program C<die>s, just like it would with any other syntax error.  You
will recieve a nice message ( C<$@> ) when this occurs.  It
will die when you try to assign to the L<"sortblock">.

=back

=head1 AUTHOR

Casey Tweten E<lt>casey@geeknest.comE<gt>
Grzegorz Rożniecki E<lt>xaerxess@gmail.comE<gt>

=head1 COPYRIGHT

Copyright (c) 2000 Casey Tweten. All rights reserved.
This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

=over 4

=item L<perltie>

=item L<Tie::Hash::Sorted>

=back

=cut
