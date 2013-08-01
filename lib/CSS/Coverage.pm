package CSS::Coverage;
use Moose;
use CSS::Coverage::Deparse;

has deparser => (
    is      => 'bare',
    isa     => 'CSS::Coverage::Deparse',
    default => sub { CSS::Coverage::Deparse->new },
    handles => ['stringify_selector'],
);

sub comment {
    my ($self, $comment) = @_;
    if ($comment =~ /coverage:(dynamic|ignore)/i) {
    }
}

sub end_selector {
    my ($self, $selectors) = @_;

    for my $parsed_selector (@$selectors) {
        my $selector = $self->stringify_selector($parsed_selector);

        print "$selector\n";
    }

    print "\n";
}

__PACKAGE__->meta->make_immutable;

1;
