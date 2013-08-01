package CSS::Coverage::Report;
use Moose;

has unmatched_selectors => (
    traits => ['Array'],
    is     => 'bare',
    handles => {
        unmatched_selectors    => 'elements',
        add_unmatched_selector => 'push',
    },
);

1;

