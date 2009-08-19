#!/usr/bin/perl

use strict;
use warnings;
use Test::Simple tests => 5;

use DOMTemplate qw( rules tmpl tree);
use DOMTemplate::Modifier qw( val );

our $DEBUG = 1;

no strict 'subs';
our $t = tree(*main::DATA);
our $ctx = { 'foo' => 'bar', 'baz' => 'quux' };

# convenience method, since as_HTML may have whitespace
sub eqls {
  my ($str, @rules) = @_;
  my $tmpl = tmpl( $t, @rules );
  my $res = $tmpl->($ctx);
  chomp $res;
  warn "$str\n$res\n" if $DEBUG;
  return $res eq $str;
}

ok ( eqls '<html><head></head><body></body></html>',
  'body' => ''
 );

ok ( eqls '<html><head></head><body>body_content</body></html>',
  'html body' => 'body_content'
);

ok ( eqls '<html><head></head><body><h1>hello world</h1><div id="content">pears</div></body></html>',
     'div#content' => 'pears',
     'html body h1' => 'hello world',
     'div#footer' => sub { $_[0]->delete() }
);

ok ( eqls '<html><head></head><body>quux</body></html>',
  'html body' => sub { $_[0]->delete_content->push_content($_[1]->{'baz'}) }
);

ok ( eqls '<html><head></head><body>bar</body></html>',
  'html body' => val 'foo'
);

1;

__END__
<html>
  <head>
  </head>
  <body>
    <h1>helloo monkey</h1>
    <div id="content">
      <p id="monkey-name" class="big">your monkey's name is <b>joe</b> and he likes <em>booze</em> a lot.</p>
      <h2>your monkey's cousins are:</h2>
      <table>
        <tr>
          <th>cousin</th><th>likes</th>
        </tr>
        <tr class="cousin">
          <td class="name">jill</td><td class="likes">jam</td>
        </tr>
      </table>
    </div>
    <div id="footer"></div>
  </body>
</html>
