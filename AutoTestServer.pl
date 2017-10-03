#!/bin/env perl
use strict;
use warnings;

use File::Path;
#use File::Copy::Recursive qw(rcopy);
use JSON qw();
use Term::ANSIColor qw(:constants);

my $_autoTestDir_ = "V:\\autotest";
my $_fileServerConfig_ = $_autoTestDir_."\\Tools-AutoTest\\Config\\AutoTestServer.json";
my $_fileClientBatch_ = $_autoTestDir_."\\Jobs\\AutoTestClient.bat";
my @_dataServerConfig_ = ();
my @_runningMachines_ = ();

my $_loop_ = 1;
my $_waitShort_	= 30;	# Shorter wait for loop.
my $_waitLong_ = 60;	# Longer wait for loop.
my $_input_ = "";

# Jobs
my $_LOGID_ = "";			# e.g. "563524"
my $_CLASS_ = "";			# e.g. "PSPX10"
my $_OPTIONS_ = "";			# e.g. "Main-Branch"
my $_CUSTOMER_ = "";		# e.g. "PhotoUlt(QA)-Retail(Release)"
my $_VERSION_ = "";			# e.g. "20.0.0.132"
my $_VERSIONEXTENSION_ = "";			# e.g. "b"
my $_ALIAS_ = "";			# e.g. "Ultimate"

&main();
exit(0);

sub main()
{
	# Parse the server config file before we start
	&parseConfig();

	my @_files_;
	while($_loop_)
	{
		# Check if new jobs exist
		@_files_ = glob($_autoTestDir_."\\Jobs\\*.py");
		if (scalar @_files_ > 0)
		{
			# Make sure no VM is running
			open(my $vmResult, "powershell Get-VM \"| Where-Object {\$_.State -eq 'Running'} \" |");
			if (eof $vmResult)
			{
				foreach my $file (@_files_) 
				{			
					&getDateTime("Test begin for $file");
					# Once we have found new job, parse its content to get matching server config and create tasks
					my @tasks = &parseJob($file);
					
					(scalar @tasks == 0) and next;
					
					&createClientBatchScript($file, \@tasks);
					
					rmtree($_autoTestDir_."\\".$_LOGID_);
					
					# We will start to dispatch by launching VMs.
					&dispatchTasks(\@tasks);
					
					# Now we have to collect the results
					&collectResults($_LOGID_, \@tasks);
					
					# Shutdown the VMs.
					system("powershell Stop-VM -VMName Win*");
					
					# Remove the job.
					system("rename ".$file." ".$_LOGID_.".xxx");
				}
				
				$_loop_ = 0;
			}
			else
			{
				&getDateTime("Testing in progress");
			}
			close($vmResult);
		}
		else
		{
			&getDateTime("No jobs available");
		}
		
		sleep($_waitLong_);
	}
}

#
#	To collect results from all VMs.
#
sub collectResults()
{
	&getDateTime("collectResults Start");
	my $logID = shift;
	my @tasks = @{my $t = shift};
	
	# TO-DO: Make sure tasks and results are perfect match.
	my $waitResults = 1;
	while ($waitResults)
	{
		print YELLOW, "  All machines are testing for ".$logID."...\n", RESET;
		sleep($_waitLong_);
		my @results = glob($_autoTestDir_."\\".$logID."\\*.xml");
		if (scalar @results == scalar @tasks)
		{
		
			open(my $vmResult, "powershell Get-VM \"| Where-Object {\$_.State -eq 'Running'} \" |");
			if (eof $vmResult)
			{
				$waitResults = 0;				
			}
			close($vmResult);			
		}
	}
	print GREEN, "  All testing are completed\n", RESET;
	system("rebot --name ".$logID." --outputdir ".$_autoTestDir_."\\".$logID." ".$_autoTestDir_."\\".$logID."\\*.xml");
	print CYAN, "  Test result created \n", RESET;
	&getDateTime("collectResults End");
}

#
#	Create a batch script contains all tasks for VMs to run.
#
sub createClientBatchScript()
{
	&getDateTime("createClientBatchScript Start");
	my $variableFile = shift;
	my @tasks = @{my $t = shift};

	open(my $fh, '>', $_fileClientBatch_) or die("Can't open \$_fileClientBatch_\": $!\n");
	print $fh "\@echo off\n";
	print $fh "setlocal\n";
	print $fh "for /f \"tokens=4-5 delims=. \" %%i in ('ver') do set VERSION=%%i.%%j\n";
	print $fh "for /f \"tokens=3 delims= \" %%g in ('reg query \"hklm\\system\\controlset001\\control\\nls\\language\" /v Installlanguage') do set LANGUAGE=%%g\n";
	for my $task (@tasks)
	{
		my $outputName = $task->{OS}."_".$task->{LCID}."_".$task->{TESTCASE};
		my $processor = "AMD64";
		my $version = "10.0";
		if ($task->{OS} eq "Win7-32")
		{
			$processor = "x86";
			$version = "6.1";
		}
		elsif ($task->{OS} eq "Win7-64")
		{
			$version = "6.1";
		}
		elsif ($task->{OS} eq "Win81-64")
		{
			$version = "6.3";
		}
		print $fh "if \"%PROCESSOR_ARCHITECTURE%\" == \"".$processor."\" if \"%version%\" == \"".$version."\" if \"%language%\" == \"".$task->{LCID}."\" ";
		print $fh "if not exist ".$_autoTestDir_."\\".$_LOGID_."\\".$outputName.".xml (\n";
		print $fh "\techo ".$outputName."\n";
		
		print $fh "\trobot ^\n";
		print $fh "\t--test ".$task->{TESTCASE}." ^\n";
		print $fh "\t--name ".$outputName." ^\n";
		print $fh "\t--variablefile ".$variableFile." ^\n";
		print $fh "\t--outputdir ".$_autoTestDir_."\\".$_LOGID_." ^\n";
		print $fh "\t--output ".$outputName." ^\n";
		print $fh "\t".$_autoTestDir_.$task->{PROJECT}."\n";
		print $fh "\tgoto exit\n)\n\n";
	}
	print $fh ":exit\n";
	print $fh "endlocal\n";
#	print $fh "shutdown /i\n";
	close($fh);
	print CYAN, "  Client batch script created: ", RESET, $_fileClientBatch_."\n";
	&getDateTime("createClientBatchScript End");
}

sub dispatchTasks()
{
	&getDateTime("dispatchTasks Start");
	my @tasks = @{my $t = shift};
	
	while(scalar @tasks > 0)
	{
		my $task = shift(@tasks);
		my $machine = "Win10-64-EN";
		if ($task->{OS} eq "Win10-64")
		{
			if ($task->{LCID} eq "0404") {$machine = "Win10-64-TW";}
			elsif ($task->{LCID} eq "0407") {$machine = "Win10-64-DE";}
			elsif ($task->{LCID} eq "0C0A") {$machine = "Win10-64-ES";}
			elsif ($task->{LCID} eq "040C") {$machine = "Win10-64-FR";}
			elsif ($task->{LCID} eq "0410") {$machine = "Win10-64-IT";}
			elsif ($task->{LCID} eq "0411") {$machine = "Win10-64-JP";}
			elsif ($task->{LCID} eq "0413") {$machine = "Win10-64-NL";}
			elsif ($task->{LCID} eq "0419") {$machine = "Win10-64-RU";}
		}
		elsif ($task->{OS} eq "Win7-64")
		{
			
		}
		elsif ($task->{OS} eq "Win81-64")
		{
			
		}	
		
		print YELLOW, "  Selected machine ".$machine." for test case ".$task->{TESTCASE}."\n", RESET;
		# If machine is not running, start it
		open(my $vmResult, "powershell Get-VM -VMName ".$machine." \"| Where-Object {\$_.State -eq 'Running'} \" |");
		if (eof $vmResult)
		{
			print GREEN, "  ".$machine." is available.\n", RESET;
			system("powershell Restore-VMSnapshot -Name ATReady -VMName ".$machine." -Confirm:\$false");
			system("powershell Start-VM -VMName ".$machine);

			push(@_runningMachines_, $machine);
		}
		else
		{
			print RED, "  ".$machine." is working on previous test case...\n", RESET;
			push(@tasks, $task);
			
			sleep($_waitShort_);
			# Check if any running machines are available.
		}
		close($vmResult);
		print YELLOW, "  There are ".scalar @tasks." tasks still remain.\n", RESET;
	}
	&getDateTime("dispatchTasks End")
}

sub getDateTime()
{
	my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	my $DateTime = sprintf("%02d/%02d/%02d %02d:%02d:%02d",
							$year+1900,
							$mon+1,
							$mday,
							$hour,
							$min,
							$sec );
	print BRIGHT_MAGENTA, "  ========== ", BOLD BRIGHT_BLUE, "[$DateTime]: $_[0]\n", RESET;
}

sub parseConfig()
{
	my $json_text = do {
	   open(my $json_fh, "<", $_fileServerConfig_) or die("Can't open \$_fileServerConfig_\": $!\n");
	   local $/;
	   <$json_fh>
	};

	my $json = JSON->new;
	my $decodedJson = $json->decode($json_text);
	@_dataServerConfig_ = @{$decodedJson->{CONFIG}};

	# for ( @{$_dataServerConfig_->{CONFIG}} ) {
		# my $config = $_;
		# print $config->{CLASS}."\n";
		# for ( @{$config->{TASK}} ) {
			# print "\t$_->{TESTCASE}\n";
		# }
	# }
}

#
#	Match auto test job with pre-defined server configs.
#	Class > Customer > Options
#
sub parseJob()
{
	&getDateTime("parseJob Start");
	my $file = shift;
	
	open(my $fh, '<', $file);
	while(<$fh>)
	{
		if ($_ =~ /LOGID="(\d+)"/) {	$_LOGID_ = $1;	}
		elsif ($_ =~ /CLASS="(\S+)"/) {	$_CLASS_ = $1;	}
		elsif ($_ =~ /OPTIONS="(\S+)"/) {	$_OPTIONS_ = $1;	}
		elsif ($_ =~ /CUSTOMER="(\S+)"/) {	$_CUSTOMER_ = $1;	}
		elsif ($_ =~ /VERSION="(\S+)"/) {	$_VERSION_ = $1;	}
		elsif ($_ =~ /VERSIONEXTENSION="([a-z]?)"/) {	$_VERSIONEXTENSION_ = $1;	}
		elsif ($_ =~ /ALIAS="(\S+)"/) {	$_ALIAS_ = $1;	}
	}
	close($fh);
	print YELLOW, "  CLASS ", RESET, $_CLASS_, YELLOW, " CUSTOMER ", RESET, $_CUSTOMER_, YELLOW, " OPTIONS ", RESET, $_OPTIONS_."\n", RESET;
	
	my @result = ();
	for my $config (@_dataServerConfig_) 
	{
		my $class = (defined $config->{CLASS}) ? $config->{CLASS} : "";
		my $customer = (defined $config->{CUSTOMER}) ? lc($config->{CUSTOMER}) : "";
		my $options = (defined $config->{OPTIONS}) ? $config->{OPTIONS} : "";
		
		#print YELLOW, "class ".$class." customer ".$customer." options ".$options."\n", RESET;
		# Pick the best match.
		if (($class eq $_CLASS_ && $customer eq "" && $options eq "") ||
			($class eq $_CLASS_ && $customer eq lc($_CUSTOMER_) && $options eq "") ||
			($class eq $_CLASS_ && $customer eq lc($_CUSTOMER_) && $options eq $_OPTIONS_))
		{
			@result = @{$config->{TASK}};
		}
	}

	print CYAN, "\tThere are ". scalar @result." tasks for this job.\n", RESET;
	for ( @result ) 
	{
		print "\t$_->{OS} $_->{LCID} $_->{TESTCASE}\n";
	}
	return @result;
	&getDateTime("parseJob End");
}