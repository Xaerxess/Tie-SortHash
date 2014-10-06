# NAME

Tie::SortHash - Keep hashes in a sorted order

# SYNOPSIS

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

# DESCRIPTION

This module is a designed to be a lightweight hash sorting mechanism.
It is often frustrating to have a hash return elements in a random order,
such as when using the `keys()`, `values()` and `each()` functions,
or simply when iterating over them.

# METHODS

## Tie

In order to `tie()` your hash to `Tie::SortHash`, you can use any of
these methods:

    tie HASH, 'Tie::SortHash', HASHREF, SORTBLOCK;

    tie HASH, 'Tie::SortHash', HASHREF;

    tie HASH, 'Tie::SortHash';

It is important to remember that if you have elements in your `HASH`
already, you must supply a reference to that hash in `HASHREF`.

For example:

    tie %people, 'Tie::SortHash', \%people;

If you don't, ` %people` will be set to an empty hash.  You probably
don't want that.

## Standard Tied Hash Methods

`Tie::SortHash` implements all the methods that a `tie`d hash class should.
These are: `TIEHASH`, `CLEAR`, `DELETE`, `EXISTS`, `FETCH`,
`FIRSTKEY`, `NEXTKEY` and `STORE`.  With the exception of a few, these all
work as they would on a normal hash.  Those exceptions include:

- `FIRSTKEY`

    This will produce the first key according to the ["sortblock"](#sortblock).

- `NEXTKEY`

    This will produce each key according to the ["sortblock"](#sortblock), excluding the
    first which is hanled by `FIRSTKEY`.

    It is a **really** bad idea to change the ["sortblock"](#sortblock) in the middle of an
    iteration, unless you actually want to.
    ( I'd be interested in why, though. )

## sortblock

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

- Always pass the sort block in a non-interpolated scalar

    This allows you to have greater control over the sorting that you would
    like to do.  Without it, you couldn't sort by value because your program
    would complain that ` %hash` hasn't been declared.  And `$a` and `$b` would
    need to be represented more like `$Tie::SortHash::a`.

- ` %hash` is generic within your sort block.

    This is because the internal representation of the tie hash is most likley
    _not_ representative of the hash you're `tie`ing.  And it allows the
    ability to manipulate and sort accoring to value.

    In other words, within your ["sortblock"](#sortblock), ` %hash` is the `Tie::SortHash`s'
    representation of your hash.

- What happens when you have a syntax error in your ["sortblock"](#sortblock)?

    The program `die`s, just like it would with any other syntax error.  You
    will recieve a nice message ( `$@` ) when this occurs.  It
    will die when you try to assign to the ["sortblock"](#sortblock).

# AUTHOR

Casey Tweten <casey@geeknest.com>
Grzegorz Rożniecki <xaerxess@gmail.com>

# COPYRIGHT

Copyright (c) 2000 Casey Tweten. All rights reserved.
This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

# SEE ALSO

- [perltie](https://metacpan.org/pod/perltie)
- [Tie::Hash::Sorted](https://metacpan.org/pod/Tie::Hash::Sorted)
