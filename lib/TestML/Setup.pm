package TestML::Setup;
use strict;
use warnings;

use YAML::XS;
use IO::All;
use Template::Toolkit::Simple;

use base 'Exporter';
@TestML::Setup::EXPORT = qw(setup);

my $config_file = 'testml.yaml';
my $base;
my $template;

sub setup {
    testml_setup(@ARGV);
}

sub testml_setup {
    my $conf = init(@_);
    my %data = %$conf;
    $data{bridge} ||= '';
    for my $file (io("$base/$conf->{testml}")->all_files) {
        my $testml_file = $data{testml_file} = $file->filename;
        my $name = $testml_file;
        $name =~ s/\.tml$// or next;

        my $src = "$base/$conf->{testml}/$testml_file";
        my $dest = "$base/$conf->{local}/$testml_file";
        
        my $filename = $conf->{filename};
        $filename =~ s/\$name/$name/;
        if (not -e "$base/$filename" or not -e $dest or -M $src < -M $dest) {
            if (@{$conf->{include}}) {
                next unless grep {$name eq $_} @{$conf->{include}};
            }
            next if grep {$name eq $_} @{$conf->{skip}};
            system("cp -f $src $dest") == 0
                or die "copy $src to $dest failed";
            print "Generating $filename\n";
            my $output = tt->render(\$template, \%data);
            io("$base/$filename")->print($output);
        }
    }
}

sub init {
    $config_file = shift;
    $config_file =~ /(.*)\//;
    $base = $1 || '.';
    my $conf = YAML::XS::LoadFile("$config_file");
    die "Missing or invalid 'testml' directory in $config_file"
        unless $conf->{testml} and -d "$base/$conf->{testml}";
    die "Missing or invalid 'local' directory in $config_file"
        unless $conf->{local} and -d "$base/$conf->{local}";
    $conf->{filename} ||= '$name.t';
    
    if ($conf->{template}) {
        $template = io("$base/$conf->{template}")->all;
    }
    else {
        die "Missing 'lang' in $config_file"
            unless $conf->{lang};
        no strict 'refs';
        $template = &{"template_$conf->{lang}"}();
    }

    return $conf;
}

sub template_pm5 {
    return <<'...';
use TestML -run,
[% IF bridge %]
    -bridge => '[% bridge %]',
[% END %]
    -testml => '[% testml_dir %]/[% testml_file %]';
...
}

sub template_pm6 {
    return <<'...';
use v6;
use TestML::Runner::TAP;

TestML::Runner::TAP.new(
    document => '[% testml_dir %]/[% testml_file %]',
[% IF bridge %]
    bridge => '[% bridge %]',
[% END %]
).run();
...
}

1;

=encoding utf-8

=head1 NAME

TestML::Setup - Generate Test Files for a TestML Suite

=head1 SYNOPSIS

    perl -MTestML::Setup -e setup testml.yaml

=head1 DESCRIPTION

A pure TestML suite contains no language specific code. Normally you
need to write a very small test program that points to a TestML document
and runs it.

This module does that for you. By providing a small YAML file, this
module will generate all your testml runtime programs for you.

=head1 AUTHOR

Ingy döt Net <ingy@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2010. Ingy döt Net.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
