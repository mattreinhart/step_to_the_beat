#!/usr/bin/perl
use strict;
use warnings;

our $READ_TIMEOUT = 10; # seconds

use Device::SerialPort;

unless (scalar(@ARGV) == 4){
  print STDERR qq(Usage:  $0 <DIRECTION> <STEPS> <DELAY_SECONDS> <COUNT>\n);
  exit;
}
unless ($ARGV[0] =~ /^(L|R)$/){
  print STDERR qq(Usage:  $0 <DIRECTION> <STEPS> <DELAY_SECONDS> <COUNT>\n);
  print STDERR qq(DIRECTION must be L or R!\n);
}
unless ($ARGV[1] =~ /^\d+$/ && $ARGV[2] =~ /^\d+$/ && $ARGV[3] =~ /^\d+$/){
  print STDERR qq(Usage:  $0 <DIRECTION> <STEPS> <DELAY_SECONDS> <COUNT>\n);
  print STDERR qq(STEPS, DELAY_SECONDS, and COUNT must all be integers!\n);
}

main();

sub main{
  my $port = Device::SerialPort->new("/dev/ttyUSB0")
            || die "Couldn't initialize motor driver!\n";
  
  $port->baudrate(115200);
  $port->databits(8);
  $port->parity("none");
  $port->stopbits(1);
  $port->read_char_time(0);       # don't wait for each character
  $port->read_const_time(1000);   # 1 second per unfulfilled "read" call
  
  my $time = 1;
  my ($count,$saw);
  do{
    ($count,$saw)=$port->read(1);
    if ($count > 0){
      $time = $READ_TIMEOUT;
    } elsif ($time == $READ_TIMEOUT){
      print STDERR "Read timeout, $READ_TIMEOUT seconds, reached.  Aborting!\n";
      exit;
    } else{
      sleep(1);
      $time++;
    }
  } until ($time == $READ_TIMEOUT);
  
  my ($direction,$move_count,$move_delay,$move_repeat) = @ARGV;
  chomp($move_repeat);
  
  for (1..$move_repeat){
    my $write_count = $port->write(qq($direction$move_count;));
    sleep($move_delay);
  }
}
