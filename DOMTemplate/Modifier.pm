package DOMTemplate::Modifier;

# subs to make modifiying HTML::Elements easier

use strict;
use warnings;

use HTML::TreeBuilder;
use HTML::TreeBuilder::LibXML;

use Exporter 'import';

use vars qw( @EXPORT_OK );

@EXPORT_OK = qw( val replace_content );

# assumes context args will start w/hashref, returns sub to replace element's
# content with value of given key
sub val ($) {
  my ($k) = @_;
  return sub { replace_content( $_[0], $_[1]->{$k} ) };
}

sub replace_content {
  my ( $node, $val ) = @_;

  if ( $node->isa('HTML::TreeBuilder::LibXML::Node') ) {
    $node->{'node'}->removeChildNodes();
    $node->{'node'}->appendText($val);
  } else {
    $node->delete_content->push_content($val);
  }
}
