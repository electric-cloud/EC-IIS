package EC::Plugin::Logger;

use strict;
use warnings;
use Data::Dumper;

use constant {
    ERROR => -1,
    INFO => 0,
    DEBUG => 1,
    TRACE => 2,
};

sub new {
    my ($class, $level) = @_;
    $level ||= 0;
    my $self = {level => $level};
    return bless $self,$class;
}

sub level {
    my ($self, $level) = @_;
    if (defined $level) {
        $self->{level} = $level;
    }
    else {
        return $self->{level};
    }
}

sub info {
    my ($self, @messages) = @_;
    $self->_log(INFO, @messages);
}

sub debug {
    my ($self, @messages) = @_;
    $self->_log(DEBUG, '[DEBUG]', @messages);
}

sub error {
    my ($self, @messages) = @_;
    $self->_log(ERROR, '[ERROR]', @messages);
}

sub trace {
    my ($self, @messages) = @_;
    $self->_log(TRACE, '[TRACE]', @messages);
}


sub log_to_property {
    my ($self, $prop) = @_;

    if (defined $prop) {
        $self->{log_to_property} = $prop;
    }
    else {
        return $self->{log_to_property};
    }
}


sub _log {
    my ($self, $level, @messages) = @_;

    return if $level > $self->{level};
    my @lines = ();
    for my $message (@messages) {
        if (ref $message) {
            print Dumper($message);
            push @lines, Dumper($message);
        }
        else {
            print "$message\n";
            push @lines, $message;
        }
    }

   if ($self->{log_to_property}) {
        my $prop = $self->{log_to_property};
        my $value = "";
        eval {
            $value = $self->ec->getProperty($prop)->findvalue('//value')->string_value;
            1;
        };
        unshift @lines, split("\n", $value);
        $self->ec->setProperty($prop, join("\n", @lines));
    }
}

sub ec {
    my ($self) = @_;
    unless($self->{ec}) {
        require ElectricCommander;
        my $ec = ElectricCommander->new;
        $self->{ec} = $ec;
    }
    return $self->{ec};
}

1;
