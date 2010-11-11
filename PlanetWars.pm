package PlanetWars;
use warnings;
use strict;
use POSIX;
use Scalar::Util qw(blessed);
use List::Util qw(first);
use Planet;
use Fleet;

sub new {
    my ($class, $gameState) = @_;
    my $self = {
        _planets => [],
        _fleets  => [],
    };
    bless $self, $class;
    $self->ParseGameState($gameState);
    return $self;
}

sub NumPlanets {
    my ($self) = @_;
    return scalar(@{$self->{_planets}});
}

sub GetPlanet {
    my ($self, $planet_id) = @_;
    my $planet = first { $_->PlanetID == $planet_id } $self->Planets;
    croak("planet $planet_id doesnt exist") unless $planet;
    return $planet;
}

sub NumFleets {
    my ($self) = @_;
    return scalar(@{$self->{_fleets}});
}

sub GetFleet {
    my ($self, $fleet_id) = @_;
    my $fleet = first { $_->FleetID == $fleet_id } $self->Fleets;
    croak("fleet $fleet_id doesnt exist") unless $fleet;
    return $fleet;
}

sub Planets {
    my ($self) = @_;
    return @{$self->{_planets}};
}

sub MyPlanets {
    my ($self) = @_;
    return grep { $_->Owner == 1 } $self->Planets;
}

sub NeutralPlanets {
    my ($self) = @_;
    return grep { $_->Owner == 0 } $self->Planets;
}

sub EnemyPlanets {
    my ($self) = @_;
    return grep { $_->Owner == 2 } $self->Planets;
}

sub NotMyPlanets {
    my ($self) = @_;
    return grep { $_->Owner != 1 } $self->Planets;
}

sub Fleets {
    my ($self) = @_;
    return @{$self->{_fleets}};
}

sub MyFleets {
    my ($self) = @_;
    return grep { $_->Owner == 1 } $self->Fleets;
}

sub EnemyFleets {
    my ($self) = @_;
    return grep { $_->Owner == 2 } $self->Fleets;
}

sub Distance {
    my ($self, $source_planet, $destination_planet) = @_;

    # If IDs passed, fetch the related object:
    $source_planet = $self->GetPlanet($source_planet)
        unless blessed $source_planet;

    $destination_planet = $self->GetPlanet($destination_planet)
        unless blessed $destination_planet;

    my $dx = $source_planet->X - $destination_planet->X;
    my $dy = $source_planet->Y - $destination_planet->Y;
    return abs(&POSIX::ceil(sqrt($dx * $dx + $dy * $dy)));
}

sub IssueOrder {
    my ($self, $source_planet, $destination_planet, $num_ships) = @_;
    print "$source_planet $destination_planet $num_ships\n";
}

sub IsAlive {
    my ($self, $player_id) = @_;
    if ($player_id == 1) {
        return scalar($self->MyPlanets || $self->MyFleets);
    }
    elsif ($player_id == 2) {
        return scalar($self->EnemyPlanets || $self->EnemyFleets);
    }
}

sub ParseGameState {
    my ($self, $gameState) = @_;
    my $planet_id = 0;
    my $fleet_id = 0;

    foreach (@$gameState) {
        next if /\s*#/; # Skip comments.

        if ($_ =~ m/^\s*P\s(\S+)\s(\S+)\s(\S+)\s(\S+)\s(\S+)/) {;
            push(
                @{$self->{_planets}},
                new Planet($planet_id,$1,$2,$3,$4,$5)
            );
            $planet_id++;
        } elsif ($_ =~ m/^\s*F\s(\S+)\s(\S+)\s(\S+)\s(\S+)\s(\S+)\s(\S+)/) {
            push(
                @{$self->{_fleets}},
                new Fleet($fleet_id,$1,$2,$3,$4,$5,$6)
            );
            $fleet_id++;
        } else {
            die('invalid parseinput')
        };
    }
}

sub FinishTurn {
    print "go\n";
}

1;
