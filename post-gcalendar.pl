#!/usr/bin/perl
# last updated : 2012/08/14 23:05:06 JST
#
# google calendar にログをポストするスクリプト。
#

use strict;
use Net::Google::Calendar;
use Crypt::Simple passphrase => 'pass phrase';
use YAML;
use Getopt::Long;
use Pod::Usage 'pod2usage';
use Path::Class;
use File::HomeDir;use Term::ReadKey;

my $conf_file = ".google.yml";
my $ID;
my $pass;
my $Calendar_name;
my $g_title;
my $g_contents;
my $conf_name;

GetOptions(
		   'calendar=s'	=> \$Calendar_name,
		   'title=s'	=> \$g_title,
		   'contents=s' => \$g_contents,
		   'config=s'   => \$conf_name,
		  );

# set account.
my $yaml = file(File::HomeDir->my_home, $conf_file);

if (-e $yaml) {
  my @st = stat $yaml;
  my $p = substr((sprintf "%03o", $st[2]), -3);
  if ( $p != 600) {
	chmod( 0600, $yaml);
  }
  &conf_set;
} else {
  print "Not account YAML file.\n";
  &input_password;
  my $yml_hash = {account => $ID, password => encrypt($pass)};
  YAML::DumpFile($yaml, $yml_hash);
  chmod( 0600, $yaml);
  print "created $yaml file.\n"
}


# option check.
if ($conf_name) { # 定型ファイルから読み込み。。
  &read_schedule_file;
  &add_schedule;
} elsif ($Calendar_name) {
  if ($g_title) {
	if ($g_contents) {
	  &add_schedule;
	} else {
	  print "not contents.\n";
	  exit;
	}
  } else {
	print "Not Title.\n";
	exit;
  }
} else {
  pod2usage();
}





sub input_password {
  print "Google Account : ";
  Term::ReadKey::ReadMode "normal";
  chomp( $ID = ReadLine 0 );
  print "\n";

  print "enter your password : ";
  Term::ReadKey::ReadMode "noecho";
  chomp( $pass = ReadLine 0 );
  Term::ReadKey::ReadMode "restore";
}

sub conf_set {
  my $conf = YAML::LoadFile($yaml) or die "$yaml: $!";
  $ID = $conf->{account};
  $pass = decrypt($conf->{password});
}

sub read_schedule_file {
  my $conf_file = file($conf_name);
  if ( -e $conf_file) {
	my $cyaml = YAML::LoadFile($conf_file) or die "$conf_name: $!";
	$Calendar_name = $cyaml->{Calendar};
	$g_title	   = $cyaml->{Title};
	$g_contents	   = $cyaml->{Contents};
  } else {
	print "Not Calendar FILE.\n";
	exit;
  }
}

sub add_schedule {
  print "Google Calendar to connecting....\n";
  my $cal = Net::Google::Calendar->new;
  $cal->login($ID, $pass) or die $@;
  print "connect\n";

  my $Calendar;
  for ($cal->get_calendars) {
	$Calendar = $_ if ($_->title eq $Calendar_name);
  }
  $cal->set_calendar($Calendar);

  print "\nwriting to schedule...\n";
  my $entry = Net::Google::Calendar::Entry->new();
  $entry->title($g_title);
  $entry->content($g_contents);
  $entry->status('confirmed');
  $entry->when(DateTime->now, DateTime->now );
  print "\nsucceed.\n";
  $cal->add_entry($entry);
}

__END__

=head1 NAME

post-gcalendar - POST schedule to Google Calendar

=head1 SYNOPSIS

  $ post-gcalendar -config [template YAML file]
  $ post-gcalendar --calendar "" --title "" --contents ""

=cut



