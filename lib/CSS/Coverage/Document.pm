package CSS::Coverage::Document;
use Moose;
use CSS::Coverage::Deparse;

has delegate => (
    is       => 'ro',
    does     => 'CSS::Coverage::DocumentDelegate',
    required => 1,
);

has deparser => (
    is      => 'bare',
    isa     => 'CSS::Coverage::Deparse',
    default => sub { CSS::Coverage::Deparse->new },
    handles => ['stringify_selector'],
);

sub comment {
    my ($self, $comment) = @_;
    if ($comment =~ /coverage\s*:\s*(\w+)/i) {
        $self->_got_coverage_comment($1);
    }
}

sub end_selector {
    my ($self, $selectors) = @_;

    for my $parsed_selector (@$selectors) {
        my $selector = $self->stringify_selector($parsed_selector);
        $self->delegate->_check_selector($selector);
    }
}

package CSS::Coverage::DocumentDelegate;
use Moose::Role;

requires '_check_selector', '_got_coverage_comment';

1;

