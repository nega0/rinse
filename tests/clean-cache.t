#!/usr/bin/perl -w
#
#  Test that we can remove .rpm files from our cache.
#
# Steve
# --


use strict;
use File::Temp;
use Test::More qw( no_plan );


#
#  Find our script
#
my $script = undef;
$script = "./bin/rinse"  if ( -e "./bin/rinse" );
$script = "../bin/rinse" if ( -e "../bin/rinse" );

ok( $script, "We found our script" );


#
#  Create a random directory
#
my $dir = File::Temp::tempdir( CLEANUP => 1 );
ok( -d $dir, "The temporary directory exists" );


#
#  Populate the tree with RPM files.
#
createRPMS( $dir );

#
#  Count the RPM files.
#
my $count = countRPM( $dir );
ok( $count, "We have some RPM files: $count" );

#
#  Delete the cache
#
system( "perl $script --cache-dir=$dir --clean-cache" );

#
#  Count them again
#
$count = countRPM( $dir );
is( $count, 0, "The RPM files are all correctly removed!" );





sub createRPMS
{
    my( $dir ) = ( @_ );

    my @rand = qw/ foo bar baz bart steve /;
    foreach my $f ( sort( @rand ) )
    {
        `touch $dir/$f.rpm`;
        ok( -e "$dir/$f.rpm", "Created random RPM file $f.rpm" );
    }
}


sub countRPM
{
    my( $dir ) = ( @_ );

    my $count = 0;
    foreach my $file ( sort( glob( $dir . "/*.rpm" ) ) )
    {
        $count += 1;
    }

    return $count;
}
