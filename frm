#! /usr/local/bin/perl
use warnings;
use strict;
our $VERSION = 0.01;

# Happy little script to duplicate from(1) but for Maildir format
# instead of mbox.  Now with extra asskicking!
#  
# David 'cogent' Hand  2006-0809-0837
#
# TODO:  add POD, including SYNOPSIS for auto_help and auto_version
# TODO:  Make taint-safe
# TODO:  support $ENV{MAILPATH}, maybe?

use File::Find;
use POSIX qw| strftime |;
use Getopt::Long qw| :config auto_help auto_version |;

# defaults for command-line options
my $DISPLAY_MESSAGES = 1;
my $DISPLAY_COUNT = 1;
my @SENDERS = ();
my @INCOMING = ();  # actually, this default is after the next bit.

# get and process command-line options
GetOptions(
    'list|messages!'        => \$DISPLAY_MESSAGES,
    'count!'                => \$DISPLAY_COUNT,
    'sender|senders:s'      => \@SENDERS,
    'incoming|mailbox:s'    => \@INCOMING,
);
my $SENDERS = join '|', map { quotemeta } grep { length > 1 } @SENDERS;
$SENDERS = qr/$SENDERS/io;

# handle -incoming intelligently
unshift @INCOMING, $ENV{MAIL} unless scalar @INCOMING;
for (@INCOMING) {  # process tilde directories (from perlfaq5)
    s{
	^~	# begin with a tilde
	([^/]*) # capture between the tilde and the first slash
    }{
	# if $1 is empty, that means it's me.  ( ~/foo -> ~cogent/foo )
	$1 ? ( getpwnam($1) )[7]
	   : $ENV{HOME}
    }ex;
}

my %FIND_OPTIONS = (
    wanted => \&wanted,
    preprocess => \&preprocess,
);

my $COUNT = 0;
my @MESSAGES;

find(\%FIND_OPTIONS, @INCOMING);
if ($DISPLAY_MESSAGES) {
    print sort @MESSAGES
}
if ($DISPLAY_COUNT) {
    if ($DISPLAY_MESSAGES && $COUNT) {
	print '-' x 16, sprintf "\n    Total:%6d\n", $COUNT;
    } else {
	my $verb	= $COUNT == 1 ? "is" : "are";
	my $number	= $COUNT == 0 ? "no" : $COUNT;
	my $s   	= $COUNT == 1 ? "" : "s";

	print "There $verb $number message$s in your incoming mailbox.\n"
    }
}

# program execution ends here

sub wanted {
    if (-e && -f && -r) {
	my $from_line = 0;
	my $mtime = (stat)[9];
	open MAILFILE, '<', $_ or die "Can't open $File::Find::name: $!";
	while (<MAILFILE>) {
	    if (/^From: (.*(?:$SENDERS).*)$/o) {
		push @MESSAGES,
		strftime('[%Y-%m%d-%H%M]', localtime($mtime)) . " $1\n"
		if $DISPLAY_MESSAGES;
		++$COUNT;
		last;
	    }
	}
	close MAILFILE or warn "Oddly, can't close $File::Find::name: $!";
    }
}

sub preprocess {
    #sort {(stat($a))[9] <=> (stat($b))[9]} grep !/^\./, @_;
    # Actually, let's make that a Schwartzian Transform
    map  { $_->[0] }
    sort { $a->[1] <=> $b->[1] }
    map  {[ $_, (stat($_))[9] ]}
    grep {  !/^\./ }
    @_;
}
