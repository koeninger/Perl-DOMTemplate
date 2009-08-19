#!/usr/bin/perl

use strict;
use warnings;
use Test::Simple tests => 4;

use DOMTemplate::Selector qw( css );
use Benchmark;

our $t = HTML::TreeBuilder->new_from_content(<DATA>);
$t->elementify();

# convenience method, since as_HTML may have whitespace
sub eqls {
  my ($sel, $str) = @_;
  $sel = css($sel)->($t);
  if ($sel) {
    $sel = $sel->as_HTML;
    chomp $sel;
  }
  $sel ||= '';
  return $sel eq $str;
}

my @divs = css('div')->($t);
ok ( scalar(@divs) == 2 );
ok ( eqls 'html body div#content p#monkey-name.big em', '<em>booze</em>' );
ok ( eqls 'div#footer', '<div id="footer"></div>' );
ok ( eqls 'p#monke3y-name.big em', '' );


# # benchmark

# timethese( 100000,
#            {
#             'css' =>
#             sub{css('html body div#content p#monkey-name.big em')->($t);},
#             'css_2' =>
#             sub{css_2('html body div#content p#monkey-name.big em')->($t);},
#            });


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
