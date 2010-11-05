#!/usr/bin/perl
use strict;
use warnings;

use Device::SerialPort;
my $port = Device::SerialPort->new("/dev/ttyUSB0");

$port->baudrate(115200);
$port->databits(8);
$port->parity("none");
$port->stopbits(1);
$port->read_char_time(0);       # don't wait for each character
$port->read_const_time(1000);   # 1 second per unfulfilled "read" call

sleep(5);

my $move_count = $ARGV[0] if $ARGV[0];
chomp($move_count);
my $write_count = $port->write(qq(L$move_count;));
