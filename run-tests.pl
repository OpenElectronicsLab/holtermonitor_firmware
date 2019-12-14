#!/usr/bin/perl
# modified from: http://www.windmeadow.com/node/38

use strict;
use warnings;
use Time::HiRes qw(usleep nanosleep);

use Device::SerialPort;

# turn off output buffering
$| = 1;

# Set up the serial port
# 230400, 8N1 on the USB ftdi driver
my $port_str;
if ( -e "/dev/ttyACM0" ) {
    $port_str = "/dev/ttyACM0";
}
else {
    $port_str = "/dev/ttyUSB0";
}
print "acquiring $port_str\n";
my $port = Device::SerialPort->new($port_str);
if ( !$port ) {
    die "Port in use?";
}
print "have port: $port\n";

# $port->baudrate(230400);
$port->baudrate(115200);
$port->databits(8);
$port->parity("none");
$port->stopbits(1);

print "do the toggle device stuff ...\n";
$port->dtr_active(0);
$port->rts_active(1);
usleep(100000);

# $port->dtr_active(1);
$port->rts_active(0);
usleep(50000);

# $port->dtr_active(0);
print "should be toggled.\n";

#
#

my $done      = 0;
my $missing   = 0;
my $have_sent = 0;
my $failures  = 0;
my $test_complete_string;
my $test_complete_regex = qr/Tests completed with (\d+) failures/;
print "Starting read loop\n";
while ( !$done ) {

    # Poll to see if any data is coming in
    my $received = $port->lookfor();

    # If we get data, then print it
    if ($received) {
        print "$received\n";
        $missing = 0;

        # if match "Tests completed with %d failures"
        # then set done and failures
        if ( $received =~ m/$test_complete_regex/ ) {
            $test_complete_string = $received;
            $failures             = $1;
            $done                 = 1;
        }
    }
    else {
        Time::HiRes::usleep(2000);
        if ( ( $missing++ % 1000 ) == 0 ) {
            if ( ( not $have_sent ) or ( $missing > 1000 ) ) {

                # Send a number to the arduino
                my $write_out = $port->write("1");
                $have_sent = 1;
            }
            if ( $missing > 1000 ) {
                print "$missing\n";
            }
        }
    }
}
print "Done with read loop\n";

my $COLOR_NONE="\e[0m";
my $GREEN="\e[32;1m";
my $DARK_GREEN="\e[0;32m";
my $RED="\e[31;1m";
my $DARK_RED="\e[0;31m";
my $BROWN="\e[0;33m";

print (($failures) ? $RED : $GREEN);
print $test_complete_string, $COLOR_NONE, "\n";
exit $failures;
