#!/usr/bin/perl -w

use strict;
use utf8;
require Text::Metaphone::Amharic;

my $am = new Text::Metaphone::Amharic ( grandularity => "high" );

my $count = 0;
foreach ($am->metaphone ( "ጠትጠ" )) {
	$count++;
	printf "%2i: $_\n", $count;
}
print "----------------\n";

$am->grandularity ( "medium" );
$count = 0;
foreach ($am->metaphone ( "ጠትጠ" )) {
	$count++;
	printf "%2i: $_\n", $count;
}
print "----------------\n";

$am->grandularity ( "low" );
$count = 0;
foreach ($am->metaphone ( "ጠትጠ" )) {
	$count++;
	printf "%2i: $_\n", $count;
}


__END__

=head1 NAME

grandularity.pl - Amharic Metaphone demonstrator grandularity levels.

=head1 SYNOPSIS

./grandularity.pl

=head1 DESCRIPTION

This is a simple demonstration script that generates Amharic Metaphone
keys in Ethiopic script that demonstrates the three grandularity levels
("high", "medium" and "low") with a fictional word.

=head1 AUTHOR

Daniel Yacob,  L<dyacob@cpan.org|mailto:dyacob@cpan.org>

=head1 SEE ALSO

L<Text::Metaphone::Amharic>

=cut
