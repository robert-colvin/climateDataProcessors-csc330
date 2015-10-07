package State;


sub new 
{
	my $class = shift;
	my $self = {
		_state => shift,
		_readings => shift,
		_tempsum => shift,	
	};

	#print "aye $self->{_state}\n";
	#print "readings $self->{_readings}\n";
	#print "sum $self->{_tempsum}\n";

	bless $self, $class;	
	return $self;
}
sub getState
{	
	my($self) = @_;
	return $self->{_state};
}
sub getReadings
{	
	my($self) = @_;
	return $self->{_readings};
}sub getTemp
{	
	my($self) = @_;
	return $self->{_tempsum};
}
sub addTemp
{
	my($self, $tempsum, $reads2add) =@_;
	$self->{_tempsum} = $self->{_tempsum} + $tempsum if defined($tempsum);
	$self->{_readings} = $self->{_readings}+ $reads2add if defined($reads2add);
	return $self->{_tempsum}
}
sub toString
{
	my ($self) = @_;
	return sprintf '%2s   %9d   %4s  %.1f\n', $self->_state, $self->_readings, "          ", $self->(_tempSum/_readings);
}
1;

