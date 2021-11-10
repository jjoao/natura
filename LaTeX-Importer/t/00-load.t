#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'LaTeX::Importer' );
}

diag( "Testing LaTeX::Importer $LaTeX::Importer::VERSION, Perl $], $^X" );
