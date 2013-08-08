package CSS::Coverage::XPath;
use strict;
use warnings;
use base 'HTML::Selector::XPath';

our %PASSTHRU = map { $_ => 1 } qw/
    hover
    link
    visited
    active
    focus
/;

sub parse_pseudo {
    my ($self, $pseudo) = @_;

    if ($PASSTHRU{$pseudo}) {
        return "[true()]";
    }

    return;
}

1;

