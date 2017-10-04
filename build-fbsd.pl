#!/usr/local/bin/perl
#
# build freebsd world->kernel->installkernel and report timings
# and other metrics; record and summarize results
#

use File::Basename;
use Getopt::Long;
use POSIX ":sys_wait_h";

# bring in the stages hash
require "/root/bin/fbsd-bldstages.pl";

%buildinfo = ();
@phases = qw(buildworld buildkernel);
$srcdir   = "/usr/src";

$ready = 1;  # don't build yet, still geting scaffolding together

# boiler plate defaults

$start_secs = time();
$start_time = dtstring();

select(STDOUT) ; $| = 1;
select(STDERR) ; $| = 1;

if ($ready == 1 ) {
    $revision = `cd /usr/src && svnlite info --show-item revision --no-newline .`;
    $vcurl    = `cd /usr/src && svnlite info --show-item url      --no-newline .`;
} else {
    $revision = "333333";
    $vcurl    = "https://svn.freebsd.org/base/stable/11";
}

$kconf    = "GENERIC";
$logdir   = "/var/log/bsdbuild" . "/" . "$revision";
system("mkdir -p $logdir");

# build pseudo uuid
$bs_uuid = $start_time . "|" . $vcurl . "|" . $kconf . "|" . $srcdir;
startup_message(dtstring(), $revision, $vcurl, $kconf, $bs_uuid);

foreach $cur_phase ( @phases ) {
    @states = @{$stages{$cur_phase}{'default'}};
    printf(" ... building phase %s ...\n", $cur_phase);
    $cur_log  = sprintf("%s/phase_%s", $logdir, $cur_phase);
    system("touch $cur_log");
    sleep(2);
  SCANFORK:
    if ($pid = fork) {
        $buildcmd = sprintf("cd %s && make -j 4 %s > %s 2>&1", $srcdir, $cur_phase, $cur_log);
        system("$buildcmd");
        sleep(5);
        $cpid = waitpid(-1, WNOHANG);
        sleep(20);
    } elsif (defined $pid) {
        $last_stamp = time();
        foreach $cur_step ( @states ) {
            $ns = 0;
            do {
                open(ZLOG, $cur_log) || die "failed to open the log file\n";
                while (<ZLOG>) {
                    $line = $_;
                    if ($line =~ /^$cur_step/) {
                        printf("       %-45s ...", substr($cur_step, 0, 45));
                        $buildsecs  = time() - $start_secs; # total time since we started
                        $step_secs  = time() - $last_stamp;
                        printf("%10s : %10s\n", 
                               stopwatch_display($step_secs),
                               stopwatch_display($buildsecs));
                        $ns = 1;
                    }
                    next if $ns == 1;
                }
                close(ZLOG) || warn "trouble closing logfile: $!\n";
                sleep(15);
            } until ($ns == 1);
            $last_stamp = time();
        }
        exit(0);
    } elsif ($! =~ /No more processes/) {
        sleep 5; redo SCANFORK;
    } else {
        die "**** fork not working...bailing out!\n";
    }
    printf("\n");
}

sub usage {
    printf("Usage: %s [-d|--debug] [-v|--verbose] [-r|--reboot] [-s|--srcdir=srcdir] [phase]", basename($0));
    printf("\n");
    printf(" -d : turn on debug output\n");
    printf(" -v : increase verbosity\n");
    printf(" -r : if buildworld and buildkernel exit 0, reboot automatically (DANGER)\n");
    printf("      CHECK /usr/src/UPDATING before assuming this will work!!!\n");
    printf(" -v : increase verbosity\n");
    printf(" -s : specify src directory\n");
}

sub dtstring {
    my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $mon++;
    $year += 1900;

    if ( $hour < 10 ) { $hour = "0" . $hour; }
    if ( $min < 10  ) { $min  = "0" . $min;  }
    if ( $sec < 10  ) { $sec  = "0" . $sec;  }
    if ( $mon < 10  ) { $mon  = "0" . $mon;  }
    if ( $mday < 10 ) { $mday = "0" . $mday; }

    return ("${year}${mon}${mday}.${hour}${min}${sec}");
}

sub startup_message {
    my $st  = shift;
    my $rev = shift;
    my $url = shift;
    my $ker = shift;
    my $uuid = shift;

    printf("\nBuilding FreeBSD (svn: %s)\n", $rev);
    printf("    Build Time :  %s\n", $st);
    printf("    SRC URL    :  %s\n", $url);
    printf("    KERNEL CONF:  %s\n", $ker);
    printf("    BUILD UUID :  %s\n", $uuid);
    printf("    SRC DIR    :  %s\n", $srcdir);
    printf("    LOG DIR    :  %s\n", $logdir);
    printf("\n");
}

sub stopwatch_display {
    my $secs   = shift;
    my $mins   = $secs / 60;
    my $hours  = $mins / 60;
    $mins      = $mins % 60;
    $secs      = $secs % 60;
    return sprintf("%02d:%02d:%02d", $hours, $mins, $secs);
}
