package Shadow::Help;

use strict;
use warnings;

our $bot;
our $module;
our %cmdlist = (
  General => {
    help => {
      cmd       => 'help',
      syntax    => '<topic>',
      shortdesc => 'Displays help information.',
      adminonly => 0
    },
  },
);


sub new {
  my ($class, $shadow) = @_;
  my $self             = {};
  $bot                 = $shadow;

  $bot->add_handler("privcmd help", 'dohelp');
  return bless($self, $class);
}

sub add_help {
  my ($self, $cmd, $class, $syntax, $desc, $admincmd) = @_;
  $admincmd = 0 if !$admincmd;

  $cmdlist{$class}->{$cmd} = {
    cmd       => $cmd,
    syntax    => $syntax,
    shortdesc => $desc,
    adminonly => $admincmd
  };
}

sub del_help {
  my ($self, $cmd, $class) = @_;

  delete $cmdlist{$class}{$cmd};
}

sub check_admin_class {
  my ($class) = @_;


  foreach my $k (keys %cmdlist) {
    if ($k eq $class) {
      foreach my $cmd (keys $cmdlist{$k}) {
        if ($cmdlist{$k}->{$cmd}{adminonly}) {
          return 1;
        }
      }
    }
  }

  return 0;
}

# IRC Handlers, these shouldn't be called directly.
sub dohelp {
  my ($nick, $host, $text) = @_;
  my $tab = "    ";

  my $nmax = 0;
  my $smax = 0;

  my ($ci, $cfmt, $si, $sfmt) = (0, "", 0, "");

  foreach my $c (keys %cmdlist) {
    foreach my $i (keys $cmdlist{$c}) {
      $nmax = length $cmdlist{$c}->{$i}{cmd} if (length $cmdlist{$c}->{$i}{cmd} >= $nmax);
      $smax = length $cmdlist{$c}->{$i}{syntax} if (length $cmdlist{$c}->{$i}{syntax} >= $smax);
    }
  }

  $bot->notice($nick, "\x02*** SHADOW HELP ***\x02");

  foreach my $c (keys %cmdlist) {
    if (check_admin_class($c)) {
      if ($bot->isbotadmin($nick, $host)) {
        $bot->notice($nick, " ");
        $bot->notice($nick, "\x02$c Commands\x02");
      }
    } else {
      $bot->notice($nick, " ");
      $bot->notice($nick, "\x02$c Commands\x02");
    }

    foreach my $k (keys $cmdlist{$c}) {
      if ($nmax >= length($cmdlist{$c}->{$k}{cmd})) {
        $ci   = $nmax - length $cmdlist{$c}->{$k}{cmd};
        $cfmt = " " x $ci;
      }
      if ($smax >= length $cmdlist{$c}->{$k}{syntax}) {
        $si   = $smax - length $cmdlist{$c}->{$k}{syntax};
        $sfmt = " " x $si;
      }

      if ($cmdlist{$c}->{$k}{adminonly}) {
        if ($bot->isbotadmin($nick, $host)) {
          $bot->notice($nick, "$tab\x02".$cmdlist{$c}->{$k}{cmd}."\x02".$cfmt."$tab".
               $cmdlist{$c}->{$k}{syntax}.$sfmt."$tab".$cmdlist{$c}->{$k}{shortdesc});
        } else {
          next;
        }
      } else {
        $bot->notice($nick, "$tab\x02".$cmdlist{$c}->{$k}{cmd}."\x02".$cfmt."$tab".
              $cmdlist{$c}->{$k}{syntax}.$sfmt."$tab".$cmdlist{$c}->{$k}{shortdesc});
      }
    }
  }

  $bot->notice($nick, " ");
  $bot->notice($nick, "[F] means the command can also be executed in a channel.  Example: .op user");
  $bot->notice($nick, "Use \x02/msg $Shadow::Core::nick help <topic>\x02 for command specific information.");
}


1;
