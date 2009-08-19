package DOMTemplate::Selector;

# subs to select elements of interest in an HTML::Tree

use strict;
use warnings;

use HTML::TreeBuilder;
use Exporter 'import';
use List::Util qw( reduce );
use Memoize;

use vars qw( @EXPORT_OK );

@EXPORT_OK = qw( css );


# takes a string formatted like a css selector, eg
# 'div#an_id.a_class span#other_id em.other_class'
# returns a sub that will return the matching HTML::Element(s) or empty
sub css ($) {
  my ($spec) = @_;
  
  my @elts;
  foreach my $elt ( split /\s/, $spec ) {
    my ($tag) = $elt =~ m/^([-\w]+)/;
    my ($class) = $elt =~ m/\.([-\w]+)/;
    my ($id) = $elt =~ m/\#([-\w]+)/;
    push @elts, [
                 $tag ? ( '_tag' => $tag ) : (),
                 $class ? ( 'class' => $class ) : (),
                 $id ? ( 'id' => $id ) : (),
                ];
  }
  
  # XXX only returns one matching elment, not all
  # should also be done at 'compile' time
  return sub {
    reduce { $a && $a->look_down( @{$b} ) } ( $_[0], @elts );
  }
}

1;
