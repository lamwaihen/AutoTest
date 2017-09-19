#!/bin/env perl
use strict;
use warnings;

use File::Path;
#use File::Copy::Recursive qw(rcopy);
use JSON qw();
use Term::ANSIColor qw(:constants);

my $_autoTestDir_ = "V:\\autotest";
my $_fileServerConfig_ = $_autoTestDir_."\\Tools-AutoTest\\Config\\AutoTestServer.json";
my $_fileClientBatch_ = $_autoTestDir_."\\Tools-AutoTest\\Jobs\\AutoTestClient.bat";
my @_dataServerConfig_ = ();
my $_loop_ = 1;
my $_loopInterval_	= 5;	# Loop every 5 sec.
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
		@_files_ = glob($_autoTestDir_."\\Tools-AutoTest\\Jobs\\*.py");
		print scalar @_files_."\n";
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
					print CYAN, "\tThere are ". scalar @tasks." tasks for this job.\n", RESET;
					
					&createClientBatchScript($file, \@tasks);
					
					# We will start to dispatch by launching VMs.
					&dispatchTasks(\@tasks);
					
					# Now we have to collect the results
					&collectResults($_LOGID_, \@tasks);
					
					# Shutdown the VMs.
					system("powershell Stop-VM -VMName Win*");
					
					# Remove the job.
#					system("rename $file test.xxx");
				}
				
				$_loop_ = 0;
			}
			else
			{
				&getDateTime("Testing in progress");
			}
		}
		else
		{
			&getDateTime("No jobs available");
		}
		
		sleep($_loopInterval_);
	}
}

#
#	To collect results from all VMs.
#
sub collectResults()
{
	my $logID = shift;
	my @tasks = @{my $t = shift};
	
	# TO-DO: Make sure tasks and results are perfect match.
	my $waitResults = 1;
	while ($waitResults)
	{
		print "Testing...\n";
		sleep(30);
		my @results = glob($_autoTestDir_."\\".$logID."\\*.xml");
		if (scalar @results == scalar @tasks)
		{
			$waitResults = 0;
			last;
		}
	}
	
	system("rebot --name ".$logID." --outputdir ".$_autoTestDir_."\\".$logID." ".$_autoTestDir_."\\".$logID."\\*.xml");
}

#
#	Create a batch script contains all tasks for VMs to run.
#
sub createClientBatchScript()
{
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
	close($fh);
}

sub dispatchTasks()
{
	my @tasks = @{my $t = shift};
	
	for my $task (@tasks)
	{
		my $machine = "Win10-64-EN";
		if ($task->{OS} eq "Win10-64")
		{
			if ($task->{LCID} eq "0411") {$machine = "Win10-64-JP";}
		}
		elsif ($task->{OS} eq "Win7-64")
		{
			
		}
		elsif ($task->{OS} eq "Win81-64")
		{
			
		}	

		system("powershell Restore-VMSnapshot -Name ATReady -VMName ".$machine." -Confirm:\$false");
		system("powershell Start-VM -VMName ".$machine);		
	}
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
	#print BRIGHT_MAGENTA, "  ========== ", BOLD BRIGHT_BLUE, "[$_[0]]: $DateTime", BRIGHT_MAGENTA, " ==========\n", RESET;
	print "[$DateTime]: $_[0]\n";
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
	
	my @result = ();
	for my $config (@_dataServerConfig_) 
	{		
		if (defined $config->{CUSTOMER} && $config->{CLASS} eq $_CLASS_)
		{
			if (defined $config->{CUSTOMER} && $config->{CUSTOMER} eq $_CUSTOMER_)
			{			
				if (defined $config->{OPTIONS} && $config->{OPTIONS} eq $_OPTIONS_)
				{	
					@result = @{$config->{TASK}};
					last;
				}				
				else
				{
					# select the first available
					@result = @{$config->{TASK}};
				}
			}
			else
			{
				# select the first available
				@result = @{$config->{TASK}};
			}
		}
	}

	for ( @result ) 
	{
		print "\t$_->{TESTCASE}\n";
	}
	return @result;
}