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

my $timeout = 30;               # keep reading for 30 seconds after last successful read

sleep(5);

my ($read_count,$string) = $port->read(255);   # read *UP TO* 255 characters.
print $string,"\n";

my $write_count = $port->write(q(L1000;R1000;L1000;R1000;));

my $total_read_count = 0;
while ($timeout > 0){
  my ($read_count,$string) = $port->read(255);   # read *UP TO* 255 characters.
  if ($read_count > 0){
    $total_read_count += $read_count;
    print $string;
  } else{
    sleep(1);
    $timeout--;
  }
}

print qq(\nTotal bytes read: $total_read_count\nTotal bytes written: $write_count\n\n);
