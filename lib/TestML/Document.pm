package TestML::Document;
use strict;
use warnings;

use TestML::Base -base;

field 'meta' => -init => 'TestML::Document::Meta->new';
field 'tests' => -init => 'TestML::Document::Tests->new';
field 'data' => -init => 'TestML::Document::Data->new';

#-----------------------------------------------------------------------------
package TestML::Document::Meta;
use TestML::Base -base;

field 'testml' => 0.0.1;
field 'title' => '';
field 'tests' => 0;
field 'data_syntax' => 'testml';
field 'testml_block_marker' => '===';
field 'testml_entry_marker' => '---';

#-----------------------------------------------------------------------------
package TestML::Document::Tests;
use TestML::Base -base;

field 'tests' => [];
field 'iterator' => 0;

sub add {
    my $self = shift;
    push @{$self->tests}, shift;
}

sub reset {
    my $self = shift;
    $self->iterator(0);
}

sub next {
    my $self = shift;
    my $iterator = $self->iterator;
    $self->iterator($iterator + 1);
    return $self->tests->[$iterator];
}

package TestML::Document::Test;
use TestML::Base -base;

field 'op';
field 'left';
field 'right';

package TestML::Document::Expr;
use TestML::Base -base;

field 'start';
field 'functions' => [];
field 'iterator' => 0;

sub add {
    my $self = shift;
    push @{$self->functions}, shift;
}

sub reset {
    my $self = shift;
    $self->iterator(0);
}

sub next {
    my $self = shift;
    my $iterator = $self->iterator;
    $self->iterator($iterator + 1);
    return $self->functions->[$iterator];
}

sub peek {
    my $self = shift;
    my $iterator = $self->iterator;
    return $self->functions->[$iterator];
}

package TestML::Document::Function;
use TestML::Base -base;

field 'name';
field 'args' => [];

#-----------------------------------------------------------------------------
package TestML::Document::Data;
use TestML::Base -base;

field 'notes' => '';
field 'blocks' => [];
field 'iterator' => 0;

sub add {
    my $self = shift;
    push @{$self->blocks}, shift;
}

sub reset {
    my $self = shift;
    $self->iterator(0);
}

sub next {
    my $self = shift;
    my $iterator = $self->iterator;
    $self->iterator($iterator + 1);
    return $self->blocks->[$iterator];
}

package TestML::Document::Block;
use TestML::Base -base;

field 'description' => '';
field 'notes' => '';
field 'entries' => {};

sub add {
    my $self = shift;
    my $entry = shift;
    $self->entries->{$entry->name} = $entry;
}

sub fetch {
    my $self = shift;
    my $name = shift;
    return $self->entries->{$name};
}

package TestML::Document::Entry;
use TestML::Base -base;

field 'name' => '';
field 'notes' => '';
field 'value' => '';