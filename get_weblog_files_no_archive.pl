use strict;
use warnings;
use LWP::Simple;
use Data::Dumper;  
use HTTP::Request::Common;
use DateTime;

use Getopt::Long;
Getopt::Long::Configure ("bundling");
#-----------------------------------------------------------------------------------------
# Variable Declaration 

# Specific to log extraction
my $file_storage_dir = 'P:\Data_Analysis\Weblog_Data'; #'C:\Automation\Weblog_Data';
my $logs_dir = 'P:\Data_Analysis\Logs'; #'C:\Automation\logs';
my $r_script_dir = 'P:/R/New_approch_preserve_data/R_Scripts_Automated';
my $archive_dir = 'P:\Data_Analysis\Archive';

# Use date time function to get date in particular time zone
my $today = DateTime->now( time_zone => "America/Chicago" );

# End date is the date when the script runs	
my $end_date = $today->mdy('');
my $start_date = '';
my $download_type = '';
	
# Default type is 'weekly'
my ($type, $help) = ('w',0);
GetOptions ('t=s'  => \$type,
			'h'  => \$help
           );

# Files to extract
my @log_files = ('search_log', 'detailtab_log', 'codefix_log');
my %table_field_values = (
		'search_log' 	=> 'worldmvlog.us_dt_search_fix_ip',
		'detailtab_log'	=> 'worldmvlog.us_dt_detailtab_fix_ip',
		'codefix_log' 	=> 'worldmvlog.us_dt_codefix_fix_ip',
);

# Capture error logs and anything on command prompt - only when type is not custom-range
my $log_file = $logs_dir.'\log_file_'.$end_date.'.txt';

if($type ne "c") {
	open STDOUT, ">", "$log_file" or die "$0: open: $!";
	open STDERR, ">&STDOUT"       or die "$0: dup: $!";
}
#-----------------------------------------------------------------------------------------
# Code execution
			
# Check the validity of the input
  check_input(); 
# Get correct dates based on the options
  prepare_dates(); 
# Extract weblogs and process R algorithms for Data Analysis
  extract_logs_and_execute(); 
# Compress the log files to archive
#  cleanup_and_archive_log_file();
#-----------------------------------------------------------------------------------------
sub check_input{        
    usage() unless (!$help);

    my @errors =();
    if($type eq "") {
        push(@errors, "-t Type is required. Correct values are 'd' for daily, 'w' for weekly and 'm' for monthly");
    }
    
    if(@errors){
        logger("Pass -h parameter for usage info");
        foreach my $error (@errors){
            logger("Error: $error");
        }
        exit;
    }
}

sub prepare_dates{
	if ($type eq "d"){
		$download_type = 'daily';
		$start_date = $today -> subtract(days => 1)->mdy('');
	}
	elsif ($type eq "w"){
		$download_type = 'weekly';
		$start_date = $today -> subtract(weeks => 1)->mdy('');
	}
	elsif($type eq "m"){
		$download_type = 'monthly';
		$start_date = $today -> subtract(months => 1)->mdy('');
	}
	elsif($type eq "c"){
		$download_type = 'custom_range';
		
		print "\n You have selected option to enter custom dates to download logs. \n";
		print "\n Please enter custom dates below(MMDDYYYY): \n";
		print "\n Enter beginning date: ";
		chomp ($start_date = <STDIN>);
		
		print "\n Enter ending date: ";
		chomp ($end_date = <STDIN>);
	}
	else{
		die "Please enter proper option for type variable"
	}
}			

sub extract_logs_and_execute{
	my ($start_month, $start_day, $start_year)	= unpack('A02A02A04', $start_date); #split('/', $start_date); 
	my ($end_month, $end_day, $end_year)		= unpack('A02A02A04', $end_date); #split('/', $end_date); 

	# URL to access PHP get method of the web-server
	my $web_address = "http://172.24.210.21/reference/download/download.php?startdate[Y]=$start_year&startdate[m]=$start_month&startdate[d]=$start_day&endtdate[Y]=$end_year&endtdate[m]=$end_month&endtdate[d]=$end_day&table=";
	
	# Create an object of LWP::UserAgent
	my $ua = LWP::UserAgent->new;
	my $filenames_args = '';

    # Extract each log file
	foreach my $log_file (@log_files){
		#my $content = get($web_address) or die 'Unable to get page';
		my $log_file_txt = $log_file.'_'.$start_year.$start_month.$start_day.'_'.$end_year.$end_month.$end_day.".txt";
		my $req = GET $web_address.$table_field_values{$log_file};
		
		# Download the log file only if it doesn't exists and its size is non-zero
		if (! -e -s $file_storage_dir.'\\'.$log_file_txt){
			# Delete the existing empty file
			system ("DEL /F /Q $file_storage_dir\\$log_file_txt") if (-e $file_storage_dir.'\\'.$log_file_txt);
			
			$req->authorization_basic('29_ykaneda', '6T06YeBu0F5si1s');
			my $res = $ua->request($req, $file_storage_dir.'\\'.$log_file_txt);
			($res->is_success) ? print "\n $log_file_txt has been copied successfully \n" : 
								 die $res->status_line. "\n $log_file_txt has not been copied successfully \n";
		}
		else{
			print "\n Log file $log_file_txt already exist, so not downloading again. \n";
		}
		
		# Join file names to pass via command line arguments to R scripts		
		$filenames_args .= ' '.$log_file_txt;			 
	}
		
	# Calling R scripts with command line arguments 
    #system("RTerm --vanilla --args $filenames_args $start_date $end_date < $r_script_dir/Data_Load_Prod.R > $logs_dir\\Data_Load_Prod_$end_date.txt") == 0 or die "I can't take it anymore. Died for Data_Load_Prod.R";
	#system("RTerm --vanilla --args $start_date $end_date $download_type < $r_script_dir/Analysis1.R > $logs_dir\\Analysis1_$end_date.txt") == 0 or die "I can't take it anymore. Died for Analysis1.R";
	# system("RTerm --vanilla --args $start_date $end_date $download_type < $r_script_dir/Analysis2.R > $logs_dir\\Analysis2_$end_date.txt") == 0 or die "I can't take it anymore. Died for Analysis2.R";
	# system("RTerm --vanilla --args $start_date $end_date $download_type < $r_script_dir/Analysis3.R > $logs_dir\\Analysis3_$end_date.txt") == 0 or die "I can't take it anymore. Died for Analysis3.R";
	# system("RTerm --vanilla --args $start_date $end_date $download_type < $r_script_dir/Analysis4.R > $logs_dir\\Analysis4_$end_date.txt") == 0 or die "I can't take it anymore. Died for Analysis4.R";
	# system("RTerm --vanilla --args $start_date $end_date $download_type < $r_script_dir/Analysis5.R > $logs_dir\\Analysis5_$end_date.txt") == 0 or die "I can't take it anymore. Died for Analysis5.R";
	
	#RTerm --vanilla --args 12012013 01012014 m < P:/R/New_approch_preserve_data/R_Scripts_Automated/Data_Load_Prod.R 
	#RTerm --vanilla --args search_log_20131230_20140106.txt detailtab_log_20131230_20140106.txt codefix_log_20131230_20140106.txt < P:/R/New_approch_preserve_data/R_Scripts_Automated/Data_Load_Prod.R > temp_log.txt
	#RTerm --vanilla --args  search_log_20131230_20140106.txt detailtab_log_20131230_20140106.txt codefix_log_20131230_20140106.txt 12302013 01062014 custom-range < P:/R/New_approch_preserve_data/R_Scripts_Automated/Data_Load_Prod.R > P:\Data_Analysis\Logs\Data_Load_Prod_01062014.txt
 
}

sub cleanup_and_archive_log_file{
	system("MKDIR $archive_dir") unless(-d $archive_dir); #make sure it's created
	
	# Archive destination based on year
	my (undef, undef, $archive_year) = unpack('A02A02A04', $end_date);
	my $archive_destination = "$archive_dir\\archive_$archive_year.7z";
	
	# Archive log files
	system ("C:/\"Program Files\"/7-Zip/7z.exe  a -y $archive_destination $file_storage_dir\\*.txt"); 
	
	# Delete Archived log files
	system ("DEL /Q /F $file_storage_dir\\*.txt");
}
#-----------------------------------------------------------------------------------------
sub usage{    
    logger("Synopsis:");
    logger("     ./get_weblog_files.pl -t <weblog_file_type>");
    logger("\nDescription:");
    logger("     -Creates a connection to Japan's webserver to download web logs.");
    logger("     -The -t option provides flexibility to download web logs for different date ranges:");
    logger("            'd' - daily logs");
	logger("            'w' - weekly logs");
	logger("            'm' - monthly logs");
	logger("            'c' - custom range logs (allows user to input date range)");
    logger("\nOptions: (order is NOT important)");
    logger("     -h (optional) this help screen");
    logger("     --help (optional) same as -h");
    exit;
}

sub logger {
    my $out = shift;
    print qq{$out\n};
}
#-----------------------------------------------------------------------------------------
close STDOUT if($type ne "c");
close STDERR if($type ne "c");
exit 0;
1;
