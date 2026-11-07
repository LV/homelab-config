#!/usr/bin/env perl
# Starts Codex's 5-hour usage window if none is running. Run it every few minutes.
#   --dry-run       read limits once, print the decision, send nothing
#   --limits FILE   use a saved rateLimits JSON instead of asking Codex (implies --dry-run)
use strict;
use warnings;
use Getopt::Long;
use JSON::PP;
use IPC::Open2;
use POSIX qw(strftime);

my $SLACK = 60;      # resetsAt this close to now+window means no window is running

GetOptions('dry-run' => \my $dry, 'limits=s' => \my $file) or die "bad options\n";
$dry = 1 if $file;

sub at { strftime '%a %-I:%M %p', localtime shift }

# Ask the Codex app server for live rate limits (same data as /status).
sub limits {
    if ($file) {
        open my $fh, '<', $file or die "$file: $!\n";
        return eval { decode_json(do { local $/; <$fh> }) };
    }
    my $pid = open2(my $out, my $in, 'codex app-server 2>/dev/null');
    print $in encode_json($_), "\n" for
        { jsonrpc => '2.0', id => 1, method => 'initialize',
          params => { clientInfo => { name => 'codex-kickstart', version => '1' } } },
        { jsonrpc => '2.0', method => 'initialized' },
        { jsonrpc => '2.0', id => 2, method => 'account/rateLimits/read' };
    my $res;
    eval {
        local $SIG{ALRM} = sub { die "timeout\n" };
        alarm 30;
        while (my $line = <$out>) {
            my $msg = eval { decode_json($line) } or next;
            if (($msg->{id} // 0) == 2) { $res = $msg->{result}; last }
        }
        alarm 0;
    };
    kill 'TERM', $pid;
    waitpid $pid, 0;
    return $res && $res->{rateLimits};
}

# Returns (start a window?, message).
sub decide {
    my ($rl) = @_;
    my $p = ref $rl eq 'HASH' && $rl->{primary};
    return (0, "Couldn't read limits; trying again next run")
        unless ref $p eq 'HASH' && $p->{resetsAt};

    my $w = $rl->{secondary};
    if (ref $w eq 'HASH' && ($w->{usedPercent} // 0) >= 100 && ($w->{resetsAt} // 0) > time) {
        return (0, "Weekly limit reached until " . at($w->{resetsAt}));
    }

    my $left   = $p->{resetsAt} - time;
    my $window = ($p->{windowDurationMins} // 300) * 60;
    return (1, "No window running (resets would be " . at($p->{resetsAt}) . "); starting one")
        if $left <= 0 || $left >= $window - $SLACK;
    return (0, "Window running, resets " . at($p->{resetsAt}));
}

my ($start, $msg) = decide(limits());
print $dry ? "[dry run] $msg\n" : "$msg\n";
exit 0 if $dry || !$start;
exec qw(codex exec --skip-git-repo-check --ephemeral -s read-only),
    '-C', $ENV{HOME}, '-c', 'model_reasoning_effort="low"', 'Say hello';
