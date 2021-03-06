#!/usr/bin/perl
use strict;
use warnings;

use Device::SerialPort;

unless (scalar(@ARGV) == 3){
  print STDERR "Usage:  $0 <STEPS> <DELAY_SECONDS> <COUNT>\n";
  exit;
}

main();

sub main{
  my $port = Device::SerialPort->new("/dev/ttyUSB0");
  
  $port->baudrate(115200);
  $port->databits(8);
  $port->parity("none");
  $port->stopbits(1);
  $port->read_char_time(0);       # don't wait for each character
  $port->read_const_time(1000);   # 1 second per unfulfilled "read" call
  
  sleep(5);
  
  my $move_count = $ARGV[0] if $ARGV[0];
  my $move_delay = $ARGV[1] if $ARGV[1];
  my $move_repeat = $ARGV[2] if $ARGV[2];
  
  for (1..$move_repeat){
    my $write_count = $port->write(qq(R$move_count;));
    sleep($move_delay);
  }
}
