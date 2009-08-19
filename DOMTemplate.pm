package DOMTemplate;

# DOM based templating library, no more php-like tags in yr html

use strict;
use warnings;

use Carp qw( croak );
use DOMTemplate::Selector qw( css );
use DOMTemplate::Modifier qw( replace_content );
use HTML::TreeBuilder;
use Exporter 'import';

use vars qw( @EXPORT_OK );

@EXPORT_OK = qw( rules tmpl tree );

# takes a list of selector => modifier pairs.
# selector: sub that takes a HTML::Tree and returns matching elements.
# selector position will take as a shortcut a string to pass to css()
# modifier: sub that takes an element and any additional context args,
# destructively updates element.  shortcut can be scalar, to replace content.
# rules returns sub that applies modifiers, in order, to selected elements.
sub rules {
  my ( $pairs, $odd ) = ( [], '' );
  foreach my $x (@_) {
    $odd = ! $odd;
    $odd ? ( push @{$pairs}, ref($x) eq 'CODE' ? $x : [ css($x) ] ) :
      push @{$pairs->[-1]}, ref($x) eq 'CODE' ? $x :
        sub { replace_content( $_[0], $x) };
  };
  
  croak "Odd number of args, should take list of selector => modifier pairs"
    if $odd;

  return sub {
    my ($tree, @args) = @_;
    foreach my $p ( @{$pairs} ) {
      foreach my $elt ( $p->[0]->($tree) ) {
        $p->[1]->( $elt, @args);
      }
    }
    return $tree;
  }
}

# takes a filespec/tree and a rules list, turns filespec into a tree if necc,
# returns sub that takes context args, applies rules to tree, returns html
sub tmpl {
  my ( $tree, @ruleslist ) = @_;
  
  $tree = tree($tree)
    unless eval { $tree->isa('HTML::Element') ||
                    $tree->isa('HTML::TreeBuilder') };
  
  my $rules = rules(@ruleslist)
    or croak "invalid list of rules\n";

  return sub {
    #XXX updates are destructive, need copy, will probably leak memory
    my $t = $tree->clone();
    #XXX pretty-printing / escaping options, should as_HTML go here? 
    my $result = eval{ $rules->( $t, @_ )->as_HTML( '<>&', '', {} ) };
    $t->delete();
    return $result;
  }
}

# takes filespec, returns appropriately configured tree 
sub tree {
  my ($filespec) = @_;
  
  my $tree = HTML::TreeBuilder->new();
  $tree->store_comments(1);
  $tree->empty_element_tags(1);
  $tree->parse_file($filespec)
    or croak "couldnt create tree from filespec $filespec $!\n";
  $tree->elementify();
  return $tree;
}

1;
