use strict;
use warnings;
use DBI;
use Encode; 
use POSIX qw(strftime);
use 5.010;

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
		$dbh->do("set names utf8");
		parse_log() 
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
	my $last_logid = get_last_parse();
	print "last_logid = $last_logid\n";
	my $log_table_name = get_log_table();
	my $sql = "SELECT id, time, thread, level, clazz, content FROM $log_table_name WHERE content like '##############################################%' AND id > $last_logid";
	my $rows = GetValues($sql);
	my $new_last_logid = $last_logid;
	my $index = 1;
	foreach my $row (@$rows) {
		#print "$$row[0] $$row[1] $$row[2] $$row[3] $$row[4] $$row[5]\n";
		my ($clazz, $content, $start_id, $level, $thread, $time) = @$row;
		$content =~ s/[\r\n]$//;
		#print "$clazz $content\n";
		if ($content =~ /^##############################################IP: (.+)#(.+) 开始处理##############################################/s ){
			#print "$1\n";
			my $ip = $1;
			my $url = $2;
			my $sql2 = "SELECT id, time, thread, level, clazz, content FROM $log_table_name 
						  WHERE content = '---------------------------------------------$url 处理结束---------------------------------------------' 
						        AND thread = '$thread' AND clazz = '$clazz' AND id > $start_id LIMIT 1";
			my $rows2 = GetValues($sql2);
			if (@$rows2) {
				my $first_row = $$rows2[0];
				my $end_id = $$first_row[2];
				my $conent2 = $$first_row[1];
				print "Request: startid = $start_id, endid = $end_id\n";
				insert_request($start_id, $end_id, $ip, $url, $time);
				$new_last_logid = $start_id;
			}else{
				print "$sql2\n";
				print "不能找到$url对应的结束标志\n";
			}
		}
	}
	update_parse_position($new_last_logid);
	print "parse_log complete\n";
}

sub insert_request {
	my $request_table_name = get_request_table();
	my $sql = "INSERT INTO $request_table_name (firstLog, endLog, ip, memo, time) values (?, ?, ?, ?, ?)";
	my $stmt = $dbh->prepare($sql);
	$stmt->execute(@_);
}

sub get_last_parse {
	my $sql = "select logid from logsystem_requestparseposition where application='$application'";
	my $statement = $dbh->prepare($sql);
	$statement->execute();
	while(my @row = $statement->fetchrow_array){
		if (defined($row[0])){
			return $row[0];
		}else{
			return -1;
		}
	}
	return -1;
}

sub update_parse_position {
	my $logid = shift;
	print "new_last_logid = $logid\n";
	my $sql = "";
	if (get_last_parse() != -1) {
		$sql = "update logsystem_requestparseposition set logid = ? where application='$application'";
	} else {
		$sql = "insert into logsystem_requestparseposition (application, logid) values ('$application', ?)";
	}
	my $statement = $dbh->prepare($sql);
	$statement->execute($logid);
}

sub GetValues { 
	my $sql = shift;
	my $ignore_columns = shift;
	#print $sql."\n";
	
	my $stmt = $dbh->prepare($sql);
	$stmt->execute();
	
	my $rows = [];
	while( my $eachrow = $stmt->fetchrow_hashref){
		my $row = [];
		my @keys = keys %$eachrow;
		@keys = sort @keys;
		foreach my $key (@keys){
			#print "$key = ";
			if ( defined($eachrow->{$key}) ){
					#print $eachrow->{$key}; 
				}else{
					#print 'null';
				}
			if( not IsInList($key, $ignore_columns) ){
				push @$row, $eachrow->{$key};
			}
			#print "\n"
		}
		#print "\n";
		push @$rows, $row;
	}
	return $rows;
}

sub IsInList {
	my $name = shift;
	my $ignore_columns = shift;
	for my $each (@$ignore_columns){
		if ($name eq $each){
			return 1;
		}
	}
	return 0;
}

sub get_log_table {
	if ($application eq 'order_system') {
		return 'logsystem_ordersystemlogrecord';
	}
	return "logsystem_$application";
}

sub get_request_table {
	if ($application eq 'order_system') {
		return 'logsystem_requests';
	}
	return "logsystem_requests_$application"; 
}
