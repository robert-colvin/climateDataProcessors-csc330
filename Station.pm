package Station;

sub new
{
	my $class = shift;
	my $self = {
		state => shift,
		stationid => shift,
	};
	bless $self, $class;
	return $self;
}
sub getState
{
	my($self) = @_;
	return $self->{state}; 
}
sub getStation
{
	my($self) = @_;
	return $self->{stationid};
}
1;
