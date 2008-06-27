#!/usr/bin/perl -w
#
#  Test that our URLs are "neat"
#
# Steve
# --


use strict;
use Test::More qw( no_plan );



#
#  Find the file
#
my $file = undef;

foreach my $f ( qw! ../etc/rinse.conf ./etc/rinse.conf ! )
{
    $file = $f if ( -e $f );
}

ok( $file, "Found configuration file" );


#
#  Open the file
#
open( FILE, "<", $file ) or die "Failed to open $file - $!";

foreach my $line ( <FILE> )
{
    next if ( !$line );
    chomp( $line );

    if( my ( $key , $val ) = split( /=/, $line ) )
    {
        next if ( !$val );
        $val =~ s!http://!!g;

        ok( $val !~ /\/\//, "URL is neat: $val" );
    }
}

close ( FILE );
