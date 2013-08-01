package CSS::Coverage;
use Moose;
use CSS::SAC;
use CSS::Coverage::Document;
use CSS::Coverage::XPath;
use HTML::TreeBuilder::XPath;

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

has html_trees => (
    is      => 'ro',
    isa     => 'ArrayRef',
    builder => '_build_html_trees',
    lazy    => 1,
);

sub _build_html_trees {
    my $self = shift;
    my @trees;

    for my $filename (@{ $self->html_filenames}) {
        my $tree = HTML::TreeBuilder::XPath->new;
        $tree->parse_file($filename);
        push @trees, $tree;
    }

    return \@trees;
}

sub check {
    my $self = shift;

    my $sac = CSS::SAC->new({
        DocumentHandler => $self->sac_document,
    });

    $sac->parse({ filename => $self->css_filename });
}

sub _check_selector {
    my ($self, $selector) = @_;
    my $xpath = CSS::Coverage::XPath->new($selector)->to_xpath;

    for my $tree (@{ $self->html_trees }) {
        if ($tree->exists($xpath)) {
            return;
        }
    }

    warn "This selector matches no documents: $selector\n";
}

sub _got_coverage_directive {
    my ($self, $directive) = @_;

    if ($directive eq 'dynamic' || $directive eq 'ignore') {
    }
}

__PACKAGE__->meta->make_immutable;

1;
