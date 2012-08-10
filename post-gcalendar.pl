#!/usr/bin/perl
# last updated : 2012/08/10 16:35:15 JST
#
# google calendar にログをポストするスクリプト。
#

use strict;
eval ("use Net::Google::Calendar"); die "[err] Net::Google::Calendar is Not Install.\n" if $@;
eval ("use Crypt::Simple passphrase => 'pass phrase';"); die "[err] Crypt::Simple is Not Install.\n" if $@;
eval ("use YAML;"); die "[err] YAML module is Not Install.\n" if $@;
use Getopt::Long;
use Pod::Usage 'pod2usage';
use Path::Class;
eval ("use File::HomeDir;"); die "[err] File::HomeDir module is Not Install.\n" if $@;
use Term::ReadKey;
use utf8;

binmode STDOUT, ":utf8";

my $conf_file = ".google.yml";
my $ID;
my $pass;
my $Calendar_name;
my $g_title;
my $g_contents;
my $g_status;
my $conf_name;

GetOptions(
		   'calendar=s'	=> \$Calendar_name,
		   'title=s'	=> \$g_title,
		   'contents=s' => \$g_contents,
		   'status=s'	=> \$g_status,
		   'config=s'   => \$conf_name,
		  );

# set account.
my $yaml = file(File::HomeDir->my_home, $conf_file);
print $yaml, "\n";
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
	  if ($g_status) {
		&add_schedule;
	  } else {
		print "Not Status.\n";
		exit;
	  }
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
}

sub conf_set {
  my $conf = YAML::LoadFile($yaml) or die "$yaml: $!";
  $ID = $conf->{account};
  $pass = decrypt($conf->{password});
}

sub read_schedule_file {
  my $conf_file = file($conf_name);
  if ( -e $conf_file) {
	my $cyaml = YAML::LoadFile($conf_file) or die "$yaml: $!";
	$Calendar_name = $cyaml->{Calendar};
	$g_title	   = $cyaml->{Title};
	$g_contents	   = $cyaml->{Contents};
	$g_status	   = $cyaml->{status};
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
  $entry->status($g_status);
  $entry->when(DateTime->now, DateTime->now );
  print "\nsucceed.\n";
  $cal->add_entry($entry);
}

__END__

=head1 NAME

post-gcalendar - POST schedule to Google Calendar

=head1 SYNOPSIS

  $ post-gcalendar -config [template YAML file]
  $ post-gcalendar --calendar "" --title "" 
                     --contents "" --status ""

=cut



