package CSS::Coverage;
use Moose;
use CSS::SAC;
use CSS::Coverage::Deparse;

has css_file => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has html_files => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
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

sub check {
    my $self = shift;

    my $sac = CSS::SAC->new({
        DocumentHandler => $self,
    });

    $sac->parse({ filename => $self->css_file });
}

__PACKAGE__->meta->make_immutable;

1;
