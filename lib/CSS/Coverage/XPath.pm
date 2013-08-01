package CSS::Coverage::XPath;
use strict;
use warnings;
use base 'HTML::Selector::XPath';

sub parse_pseudo {
    my ($self, $pseudo) = @_;

    if ($pseudo eq 'hover') {
        return "[true()]";
    }

    return;
}

1;

