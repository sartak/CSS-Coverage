package CSS::Coverage;
use Moose;
use CSS::SAC;
use CSS::Coverage::Document;

with 'CSS::Coverage::DocumentDelegate';

has sac_document => (
    is      => 'ro',
    isa     => 'CSS::Coverage::Document',
    default => sub { CSS::Coverage::Document->new(delegate => shift) },
    lazy    => 1,
);

has css_filename => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has html_filenames => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
);

sub check {
    my $self = shift;

    my $sac = CSS::SAC->new({
        DocumentHandler => $self->sac_document,
    });

    $sac->parse({ filename => $self->css_filename });
}

sub _check_selector {
    my ($self, $selector) = @_;
}

sub _got_coverage_comment {
    my ($self, $comment) = @_;

    if ($comment eq 'dynamic' || $comment eq 'ignore') {
    }
}

__PACKAGE__->meta->make_immutable;

1;
