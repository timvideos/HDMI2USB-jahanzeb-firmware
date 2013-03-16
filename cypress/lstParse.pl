#!/usr/bin/perl -w

use strict;
use warnings;

my (@tdoList, @tdiList, @tmsList, @tckList, @ioaList);

while ( <STDIN> ) {
	if ( m/^   ([0-9A-F][0-9A-F][0-9A-F][0-9A-F]) (A2|30) B0 (  |0C)\s+\d+[^;]+_TDO.*?$/ ) {
		push(@tdoList, 1 + hex($1));
	}
	if ( m/^   ([0-9A-F][0-9A-F][0-9A-F][0-9A-F]) 92 B1\s+\d+[^;]+_TDI.*?$/ ) {
		push(@tdiList, 1 + hex($1));
	}
	if ( m/^   ([0-9A-F][0-9A-F][0-9A-F][0-9A-F]) [9D]2 B2\s+\d+[^;]+_TMS.*?$/ ) {
		push(@tmsList, 1 + hex($1));
	}
	if ( m/^   ([0-9A-F][0-9A-F][0-9A-F][0-9A-F]) [CD]2 B3\s+\d+[^;]+_TCK.*?$/ ) {
		push(@tckList, 1 + hex($1));
	}
	if ( m/^   ([0-9A-F][0-9A-F][0-9A-F][0-9A-F]) 85 9C 80/ ) {
		push(@ioaList, 2 + hex($1));
	}
}

print "// THIS FILE IS MACHINE-GENERATED! DO NOT EDIT IT!\n//\n";

if ( @ioaList != 1 ) {
	die "ERROR: There must be exactly one occurrence of IOA!\n";
}
print "static const uint16 ioaList[] = {\n\t".sprintf("0x%04X", $ioaList[0]).",\n\t0x0000\n};\n\n";

print "static const uint16 tdoList[] = {\n";
foreach ( @tdoList ) {
	print "\t".sprintf("0x%04X", $_).",\n";
}
print "\t0x0000\n};\n\n";

print "static const uint16 tdiList[] = {\n";
foreach ( @tdiList ) {
	print "\t".sprintf("0x%04X", $_).",\n";
}
print "\t0x0000\n};\n\n";

print "static const uint16 tmsList[] = {\n";
foreach ( @tmsList ) {
	print "\t".sprintf("0x%04X", $_).",\n";
}
print "\t0x0000\n};\n\n";

print "static const uint16 tckList[] = {\n";
foreach ( @tckList ) {
	print "\t".sprintf("0x%04X", $_).",\n";
}
print "\t0x0000\n};\n\n";
