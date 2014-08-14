/*

sudo apt-get install postgresql-plperl-9.3
create language plperlu

*/

CREATE FUNCTION extract_contents_from_html(text) returns text AS $$
  use HTML::TreeBuilder;
  use HTML::FormatText;
  my $tree = HTML::TreeBuilder->new;
  $tree->parse_content(shift);
  my $formatter = HTML::FormatText->new(leftmargin=>0, rightmargin=>78);
  $text = $formatter->format($tree);
$$ LANGUAGE plperlu;
