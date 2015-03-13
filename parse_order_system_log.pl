use strict;
use warnings;

use DBI;
use Encode; 
use POSIX qw(strftime);

my $has_last_parse_info = 0;

my $dsn = "DBI:mysql:lottery;host=localhost";
my $username = "root";
my $password = '123456';

my $application = 'localordersystem';
 
# connect to MySQL database
my %attr = ( mysql_auto_reconnect=>1,
			 AutoCommit=>1,
			 PrintError=>0,  # turn off error reporting via warn()
             RaiseError=>1 );   # turn on error reporting via die()           
 
my $dbh;
my $stmt;
while(1) {
	eval{ 
	    $dbh  = DBI->connect($dsn,$username,$password, \%attr);

		my $_sql = "set names utf8";
		my $stmt2 = $dbh->prepare($_sql);
		$stmt2->execute();
		my $log_table_name = get_log_table();
		$_sql = "insert into $log_table_name (time, thread, level, 
				clazz, content) values (?,?,?,?,?)";
	    $stmt = $dbh->prepare($_sql);
		parse_log('C:/EBusiness(newui)/Order2011/log/log_root.txt') 
	};
	sleep(5);
	if($@){
		print "$@\n";
	}
	eval{
		$dbh->disconnect();
	}
}



sub parse_log {
	my $file_name = shift;
	my($pos, $parsetime, $end_content) = get_last_parse();
	if (defined($parsetime)) {
		print "$pos, $parsetime, $end_content\n";
	} else {
		print "not last parse record\n";
	}
	
	#get the position last read
	my($dev, $ino, $mode, $nlink, $uid, $gid, $rdev,
			$size, $atime, $mtime, $ctime, $blksize, $blocks) = stat($file_name);
	
	open FILE, '<', $file_name;
	if ($size >= $pos) {
		print "WARN: seek return error\n" unless seek(FILE, $pos, 0);
	}
	print "start read file.\n";
	my $text = '';
	while (<FILE>) {
		$text .= $_;
	}
	print "read finished\n";
	
	#update parse position
	update_parse_position(tell(FILE), strftime("%y-%m-%d %H:%M:%S",localtime(time)), '');
	close(FILE);

	while ($text =~ /
					([0-9]{4}-[0-9]{2}-[0-9]{2}\s[0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3})\s+
					 \[([0-9]{1,3})\]\s+
					 ([A-Z]{1,10})\s+
					 (\w+(?:\.\w+){0,})\s+
					 \[\(\w{1,}\)\]\s+
					 -\s+
					 (.*?)
					 (([0-9]{4}-[0-9]{2}-[0-9]{2}\s[0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3}){1})
					/smx
			or 
			$text =~ /
					([0-9]{4}-[0-9]{2}-[0-9]{2}\s[0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3})\s+
					 \[([0-9]{1,3})\]\s+
					 ([A-Z]{1,10})\s+
					 (\w+(?:\.\w+){0,})\s+
					 \[\(\w{1,}\)\]\s+
					 -\s+
					 (.*?)$
					/smx) {
		print "$1 $2 $3 $4\n";
		print "-----------------------------------------------------------------------\n";
		#print "$1 $2 $3 $4\n";
		
		
		if (defined($6)) {
			$text = $6.$';
		} else {
			$text = $';
		}


		insert_record_mysql(encode("utf-8", decode("gb2312", $1)), 
							encode("utf-8", decode("gb2312", $2)), 
							encode("utf-8", decode("gb2312", $3)), 
							encode("utf-8", decode("gb2312", $4)), 
							encode("utf-8", decode("gb2312", remove_changeline($5))));

	}
}

sub remove_changeline {
	my $content = $_[0];
	$content =~ s/[\r\n]$//;
	return $content;
}

sub insert_record_mysql {
	$stmt->execute(@_);
	#$stmt->commit();
}

sub get_last_parse {
	my $sql = "select filesize, parsetime, end_content from logsystem_parseposition 
			  where application='$application'";
	my $statement = $dbh->prepare($sql);
	$statement->execute();
	while(my @row = $statement->fetchrow_array){
		$has_last_parse_info = 1;
		return @row;
	}
}

sub update_parse_position {
	my ($filesize, $parsetime, $end_content);
	($filesize, $parsetime, $end_content) = @_;
	
	my $sql = "";
	if ($has_last_parse_info == 1) {
		$sql = "update logsystem_parseposition set filesize = ?, parsetime = ?, end_content = ?  
		        where application='$application'";
	} else {
		$sql = "insert into logsystem_parseposition (application,filesize,parsetime,end_content) values 
		        ('$application', ? ,? , ?)";
	}
	my $statement = $dbh->prepare($sql);
	$statement->execute(@_);
}

sub get_log_table {
	if ($application eq 'order_system') {
		return 'logsystem_ordersystemlogrecord';
	}
	return "logsystem_$application";
}