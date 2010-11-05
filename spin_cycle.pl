#!/usr/bin/perl
use strict;
use warnings;

my $STEP_INTERVAL = 200;

## SCHEDULED JOB ##
my $dp = DanceParty::Stepper->new("/dev/ttyUSB0");
my $data = DanceParty::Data->new("master_filename.txt");

sleep(5);

main($dp,$data);
exit;

sub main{
  my ($dp,$data) = @_;
  my $current_coordinate = 0;

  # Spin
  # Step gradually 180-degrees to the right.
  for (my $i=0; $i<(2000/$STEP_INTERVAL); $i++){
    $current_coordinate += $STEP_INTERVAL;
    $dp->move_right($STEP_INTERVAL);
    $data->wash_and_rinse({ coordinate => 'R'.$i*$STEP_INTERVAL });
  }
  
  # Reset back to 0.
  $dp->move_left($current_coordinate);
  $current_coordinate = 0;
  
  # Step gradually 180 -degrees to the left.
  for (my $i=0; $i<(2000/$STEP_INTERVAL); $i++){
    $dp->move_left($i*$STEP_INTERVAL);
    $data->wash_and_rinse({ coordinate => 'L'.$i*$STEP_INTERVAL });
  }

  # Reset back to 0.
  $dp->move_right($current_coordinate);
  $current_coordinate = 0;

  $data->export_to_file();
}

## DAEMON ##
  # while(1){

  # Hop onto "strongest" signal as determined by proprietary algorithm
  # Wait a short while.
    # 1m -- ping
    # if Net failure, Re-Hop ^^
  # }

package DanceParty::Data;
sub new{
  my $class = shift;
  my $self = {};
  $self->{filename} = shift;
  $self->{master_file} = [];
  bless $self, $class;
  return $self;
}

sub wash_and_rinse{
  # Scan / Test / Rank / Randomize among strong signals
  my ($self,$args) = @_;

  # Do kismet stuff.
  # Read kismet data.
  my $kd = process_kismet(q(FILENAME_HERE));

  my $coordinate = $args->{coordinate};
  push @{$self->{master_file}}, qq[$coordinate,$kd];
}

sub process_kismet{
  my ($self,$filename) = @_;
  return 'blahblahblah';
}

sub export_to_file{
  my ($self) = @_;
  open FH, '>', $self->{master_file};
  print FH join("\n",@{$self->{master_file}});
  close FH;
}


package DanceParty::Stepper;
use Device::SerialPort;

sub new{
  my $class = shift;
  my $self = {};
  $self->{tty} = shift;
  $self->{port} = Device::SerialPort->new("/dev/ttyUSB0");
  $self->{port}->baudrate(115200);
  $self->{port}->databits(8);
  $self->{port}->parity("none");
  $self->{port}->stopbits(1);
  $self->{port}->read_char_time(0);       # don't wait for each character
  $self->{port}->read_const_time(1000);   # 1 second per unfulfilled "read" call
  bless $self, $class;
  return $self;
}

sub move_right{
  my ($self,$num_steps) = @_;
  $num_steps =~ s/\D//g;
  if ($num_steps =~ /\d/){
    my $write_count = $self->{port}->write(qq(R$num_steps;));
    return $num_steps
  } else {
    return 0;
  }
}

sub move_left{
  my ($self,$num_steps) = @_;
  $num_steps =~ s/\D//g;
  if ($num_steps =~ /\d/){
    my $write_count = $self->{port}->write(qq(L$num_steps;));
    return $num_steps
  } else {
    return 0;
  }
}

# 
# 
# my $command = $ARGV[0] if $ARGV[0];
# my $actual_command 
# 
# chomp($move_count);
# my $write_count = $port->write(qq(R$move_count;));
# 
# #!/usr/bin/perl
# use strict;
# use warnings;
# 
# use Device::SerialPort;
# my $port = Device::SerialPort->new("/dev/ttyUSB0");
# 
# # $port->baudrate(115200);
# # $port->databits(8);
# # $port->parity("none");
# # $port->stopbits(1);
# # $port->read_char_time(0);       # don't wait for each character
# # $port->read_const_time(1000);   # 1 second per unfulfilled "read" call
# 
# sleep(5);
# 
# my $move_count = $ARGV[0] if $ARGV[0];
# chomp($move_count);
# my $write_count = $port->write(qq(L$move_count;));
