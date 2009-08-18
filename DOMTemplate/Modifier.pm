package DOMTemplate::Modifier;

# subs to make modifiying HTML::Elements easier

use strict;
use warnings;

use HTML::TreeBuilder;
use Exporter 'import';

use vars qw( @EXPORT_OK );

@EXPORT_OK = qw( key );

# assumes context args will start w/hashref, returns sub to replace element's
# content with value of given key
sub key ($) {
  my ($k) = @_;
  return sub { $_[0]->delete_content->push_content($_[1]->{$k}) };
}
