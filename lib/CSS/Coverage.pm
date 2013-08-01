package CSS::Coverage;
use Moose;
use CSS::SAC;
use CSS::Coverage::Document;
use CSS::Coverage::XPath;
use CSS::Coverage::Report;
use HTML::TreeBuilder::XPath;

with 'CSS::Coverage::DocumentDelegate';

has css => (
    is       => 'ro',
    isa      => 'Str|ScalarRef',
    required => 1,
);

has documents => (
    is       => 'ro',
    isa      => 'ArrayRef[Str|ScalarRef]',
    required => 1,
);

has html_trees => (
    is      => 'ro',
    isa     => 'ArrayRef',
    builder => '_build_html_trees',
    lazy    => 1,
);

has _sac_document => (
    is      => 'ro',
    isa     => 'CSS::Coverage::Document',
    default => sub { CSS::Coverage::Document->new(delegate => shift) },
    lazy    => 1,
);

has _report => (
    is      => 'rw',
    isa     => 'CSS::Coverage::Report',
    clearer => '_clear_report',
);

has _ignore_next_rule => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

sub _build_html_trees {
    my $self = shift;
    my @trees;

    for my $document (@{ $self->documents }) {
        my $tree = HTML::TreeBuilder::XPath->new;
        $tree->ignore_unknown(0);

        if (ref($document)) {
            $tree->parse($$document);
            $tree->eof;
        }
        else {
            $tree->parse_file($document);
        }

        push @trees, $tree;
    }

    return \@trees;
}

sub check {
    my $self = shift;

    my $sac = CSS::SAC->new({
        DocumentHandler => $self->_sac_document,
    });

    my $report = CSS::Coverage::Report->new;
    $self->_report($report);

    my $css = $self->css;
    if (ref($css)) {
        $sac->parse({ string => $$css });
    }
    else {
        $sac->parse({ filename => $css });
    }

    $self->_clear_report;

    return $report;
}

# -- CSS::Coverage::DocumentDelegate

sub _check_selector {
    my ($self, $selector) = @_;

    if ($self->_ignore_next_rule) {
        $self->_ignore_next_rule(0);
        return;
    }

    my $xpath = CSS::Coverage::XPath->new($selector)->to_xpath;

    for my $tree (@{ $self->html_trees }) {
        if ($tree->exists($xpath)) {
            return;
        }
    }

    if ($self->_report) {
        $self->_report->add_unmatched_selector($selector);
    }
    else {
        warn "This selector matches no documents: $selector\n";
    }
}

sub _got_coverage_directive {
    my ($self, $directive) = @_;

    if ($directive eq 'dynamic' || $directive eq 'ignore') {
        $self->_ignore_next_rule(1);
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

CSS::Coverage

=head1 SYNOPSIS

    css-coverage style.css index.html second.html
        Unmatched selectors (3):
            div.form-actions button:first-child
            .expanded span.open
            ul.attn li form textarea


    my $coverage = CSS::Coverage->new(
        css       => $css_file,
        documents => \@html_files,
    );

    my $report = $coverage->check;

    print for $report->unmatched_selectors;

=head1 Attributes

=head2 css (Str|ScalarRef)

If given a string, C<css> is treated as a filename. If given as a scalar reference, C<css> is treated as CSS code.

=head2 documents (ArrayRef[Str|ScalarRef])

A list of HTML documents. For each document, strings are treated as filenames; scalar reference as raw HTML code.

=head1 API

=head2 check

Runs a coverage check of the given CSS against the given documents. Returns a L<CSS::Coverage::Report> object.

=cut

