#!/bin/env perl
use strict;
use warnings;

use File::Path;
use File::stat qw(stat);
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
my $_vmPerServer_ = 1;	# Number of VMs we can launch from server at the same time.
my $_input_ = "";
my $_date_ = "";

# Jobs
my $_BUILD_ = "";			# e.g. "Main-Branch_20.0.0.132b_PHOTOULT(QA)-PF(RELEASE)_LOGID563719"
my $_LOGID_ = "";			# e.g. "563524"
my $_STUB_ = "";			# e.g. "PSP2018_Pro"
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
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	$_date_ = sprintf("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

	my @_files_;
	while($_loop_)
	{
		# Parse the server config file before we start
		&parseConfig();	
	
		# Check if new jobs exist
		@_files_ = reverse(glob($_autoTestDir_."\\Jobs\\*.py"));
		if (scalar @_files_ > 0)
		{
			# Make sure no VM is running
			open(my $vmResult, "powershell Get-VM -ComputerName TPE-ATSERVER01,TPE-ATSERVER02,TPE-ATSERVER03 \"| Where-Object {\$_.State -eq 'Running'} \" |");
			if (eof $vmResult)
			{
				my @stubTasks;
				foreach my $file (@_files_) 
				{			
					&getDateTime("Test begin for $file");
					# Once we have found new job, parse its content to get matching server config and create tasks
					my @tasks = &parseJob($file);
					
					(scalar @tasks == 0) and next;
					
					&createClientBatchScript($file, \@tasks);

					if ($_LOGID_ ne "")
					{
						rmtree($_autoTestDir_."\\_".$_LOGID_);
						rmtree($_autoTestDir_."\\".$_LOGID_);
					}
					
					# We will start to dispatch by launching VMs.
					&dispatchTasks(\@tasks);
					
					# Now we have to collect the results
					if ($_LOGID_ ne "")
					{
						&collectResults($_LOGID_, \@tasks);
					}
					elsif ($_STUB_ ne "")
					{
						push(@stubTasks, @tasks);
						&waitResults("StubInstaller\\".$_date_, \@tasks, $_STUB_);						
					}
					
					# Shutdown the VMs.
					system("powershell Stop-VM -VMName Win* -ComputerName TPE-ATSERVER01 -TurnOff");
					system("powershell Stop-VM -VMName Win* -ComputerName TPE-ATSERVER02 -TurnOff");
					system("powershell Stop-VM -VMName Win* -ComputerName TPE-ATSERVER03 -TurnOff");
					
					# Remove the job.
					if ($_LOGID_ ne "")
					{
						system("rename ".$file." ".$_LOGID_.".xxx");
					}
					elsif ($_STUB_ ne "")
					{
						system("rename ".$file." ".$_STUB_.".xxx");
					}
				}
				
				if (scalar @stubTasks > 0)
				{
					&collectResults("PSPX10_StubInstaller\\".$_date_, \@stubTasks);
				}
				
#				$_loop_ = 0;
			}
			else
			{
#			print $vmResult;
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
	
	&waitResults($logID, \@tasks);
	print YELLOW, " xcopy /I /E /Q /Y $_autoTestDir_\\_$logID $_autoTestDir_\\$logID \n", RESET;
	open(my $copy, "xcopy /I /E /Q /Y $_autoTestDir_\\_$logID $_autoTestDir_\\$logID |");
	close($copy);
	system("rebot --name ".$_BUILD_." --outputdir ".$_autoTestDir_."\\".$logID." ".$_autoTestDir_."\\_".$logID."\\*.xml");
	print CYAN, "  Test result created \n", RESET;
	rmtree($_autoTestDir_."\\_".$logID);
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
	my $outputName;
	my $outputDir;

	for my $task (@tasks)
	{
		if ($_LOGID_ =~ /(\d+)/)
		{
			$outputDir = "_".$_LOGID_;
			$outputName = $task->{OS}."_".$task->{LCID}."_".$task->{TESTCASE};
		}
		else
		{
			$outputDir = "StubInstaller\\".$_date_;
			$outputName = $task->{OS}."_".$task->{LCID}."_".$task->{TESTCASE}."_".$_STUB_;
		}
		
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
		print $fh "if not exist ".$_autoTestDir_."\\".$outputDir."\\".$outputName.".xml (\n";
		print $fh "\techo ".$outputName."\n";
		
		print $fh "\trobot ^\n";
		print $fh "\t--test ".$task->{TESTCASE}." ^\n";
		print $fh "\t--name ".$outputName." ^\n";
		print $fh "\t--variablefile ".$variableFile." ^\n";
		print $fh "\t--outputdir ".$_autoTestDir_."\\".$outputDir." ^\n";
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
		my @vmInfo = &getMatchingVM($task->{OS}, $task->{LCID});		
		print YELLOW, "  Selected machine ".$vmInfo[0]." for test case ".$task->{TESTCASE}."\n", RESET;

		my $goNext = 0;
		# Check if VM exists in specific computer
		open (my $computerExist, "powershell Get-VM -ComputerName ".$vmInfo[1]." -ErrorAction SilentlyContinue \"| Where-Object {\$_.Name -eq '".$vmInfo[0]."'} | measure | % {\$_.Count} \" |");
		while (<$computerExist>)
		{
			if ($_ == 0)
			{
				print RED, "  ".$vmInfo[0]." on ".$vmInfo[1]." is not available for testing...\n", RESET;
				$goNext = 1;
			}
		}
		close($computerExist);
		($goNext == 1) and next;
		
		open(my $computerResult, "powershell Get-VM -ComputerName ".$vmInfo[1]." -ErrorAction SilentlyContinue \"| Where-Object {\$_.State -eq 'Running'} | measure | % {\$_.Count} \" |");
		while (<$computerResult>)
		{
			if ($_ >= $_vmPerServer_)
			{
				print RED, "  ".$vmInfo[0]." on ".$vmInfo[1]." is working on other test case...\n", RESET;
				push(@tasks, $task);
			
				sleep($_waitShort_);
				# Check if any running machines are available.
			}
			else
			{
				# If machine is not running, start it
				open(my $vmResult, "powershell Get-VM -VMName ".$vmInfo[0]." -ComputerName ".$vmInfo[1]." -ErrorAction SilentlyContinue \"| Where-Object {\$_.State -eq 'Running'} \" |");
				if (eof $vmResult)
				{
					print GREEN, "  ".$vmInfo[0]." is available.\n", RESET;
					system("powershell Restore-VMSnapshot -Name ATReady -VMName ".$vmInfo[0]." -ComputerName ".$vmInfo[1]." -Confirm:\$false");
					
					# Temporarily add more resources
					system("powershell Set-VMMemory -VMName ".$vmInfo[0]." -ComputerName ".$vmInfo[1]." -DynamicMemoryEnabled \$false -StartupBytes 4096MB");
					system("powershell Set-VMProcessor -VMName ".$vmInfo[0]." -ComputerName ".$vmInfo[1]." -Count 4");
					
					system("powershell Start-VM -VMName ".$vmInfo[0]." -ComputerName ".$vmInfo[1]);

					push(@_runningMachines_, $vmInfo[0]);
				}
				else
				{
					print RED, "  ".$vmInfo[0]." is working on previous test case...\n", RESET;
					push(@tasks, $task);
					
					sleep($_waitShort_);
					# Check if any running machines are available.
				}
				close($vmResult);
			}
		}
		close($computerResult);
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

sub getMatchingVM()
{
#	&getDateTime("getMatchingVM Start");
	my $os = shift;
	my $lcid = shift;
	
	my @result = ();

	if ($os eq "Win10-64")
	{
		if ($lcid eq "0404") {@result = ("Win10-64-TW", "TPE-ATSERVER03");}
		elsif ($lcid eq "0407") {@result = ("Win10-64-DE", "TPE-ATSERVER03");}
		elsif ($lcid eq "0C0A") {@result = ("Win10-64-ES", "TPE-ATSERVER03");}
		elsif ($lcid eq "040C") {@result = ("Win10-64-FR", "TPE-ATSERVER03");}
		elsif ($lcid eq "040D") {@result = ("Win10-64-IL", "TPE-ATSERVER03");}
		elsif ($lcid eq "0410") {@result = ("Win10-64-IT", "TPE-ATSERVER03");}
		elsif ($lcid eq "0411") {@result = ("Win10-64-JP", "TPE-ATSERVER03");}
		elsif ($lcid eq "0413") {@result = ("Win10-64-NL", "TPE-ATSERVER03");}
		elsif ($lcid eq "0415") {@result = ("Win10-64-PL", "TPE-ATSERVER03");}
		elsif ($lcid eq "0419") {@result = ("Win10-64-RU", "TPE-ATSERVER03");}
		else {@result = ("Win10-64-EN", "TPE-ATSERVER03");}
	}
	elsif ($os eq "Win7-64")
	{
		if ($lcid eq "0404") {@result = ("Win7SP1-64-TW", "TPE-ATSERVER01");}
		elsif ($lcid eq "0407") {@result = ("Win7SP1-64-DE", "TPE-ATSERVER01");}
		elsif ($lcid eq "0409") {@result = ("Win7SP1-64-EN", "TPE-ATSERVER01");}
		elsif ($lcid eq "0C0A") {@result = ("Win7SP1-64-ES", "TPE-ATSERVER01");}
		elsif ($lcid eq "040C") {@result = ("Win7SP1-64-FR", "TPE-ATSERVER01");}
		elsif ($lcid eq "0410") {@result = ("Win7SP1-64-IT", "TPE-ATSERVER01");}
		elsif ($lcid eq "0411") {@result = ("Win7SP1-64-JP", "TPE-ATSERVER01");}
		elsif ($lcid eq "0413") {@result = ("Win7SP1-64-NL", "TPE-ATSERVER01");}
		elsif ($lcid eq "0419") {@result = ("Win7SP1-64-RU", "TPE-ATSERVER01");}
		else {@result = ("Win10-64-EN", "TPE-ATSERVER01");}
	}
	elsif ($os eq "Win81-64")
	{
		if ($lcid eq "0404") {@result = ("Win81-64-TW", "TPE-ATSERVER02");}
		elsif ($lcid eq "0407") {@result = ("Win81-64-DE", "TPE-ATSERVER02");}
		elsif ($lcid eq "0409") {@result = ("Win81-64-EN", "TPE-ATSERVER02");}
		elsif ($lcid eq "0C0A") {@result = ("Win81-64-ES", "TPE-ATSERVER02");}
		elsif ($lcid eq "040C") {@result = ("Win81-64-FR", "TPE-ATSERVER02");}
		elsif ($lcid eq "0410") {@result = ("Win81-64-IT", "TPE-ATSERVER02");}
		elsif ($lcid eq "0411") {@result = ("Win81-64-JP", "TPE-ATSERVER02");}
		elsif ($lcid eq "0413") {@result = ("Win81-64-NL", "TPE-ATSERVER02");}
		elsif ($lcid eq "0419") {@result = ("Win81-64-RU", "TPE-ATSERVER02");}
		else {@result = ("Win10-64-EN", "TPE-ATSERVER02");}
	}	
#	&getDateTime("getMatchingVM End");
	return @result;
}

#
#	Get the list of result xml files to see if they match given tasks.
#
sub matchTasksWithResults()
{
	&getDateTime("matchTasksWithResults Start");
	my $logID = shift;
	my @tasks = @{my $t = shift};
	my $stub = shift;
	my @results = glob($_autoTestDir_."\\_".$logID."\\*.xml");	
	my $matchCount = 0;
	my $substring = "";
	
	print CYAN, "  There are ". scalar @tasks." tasks and ".scalar @results." results to match.\n", RESET;		
	foreach my $result (@results) 
	{		
		foreach my $task (@tasks)
		{
			if (defined $stub)
			{
				$substring = sprintf("%s_%s_%s_%s", $task->{OS}, $task->{LCID}, $task->{TESTCASE}, $stub);
			}
			else
			{
				$substring = sprintf("%s_%s_%s", $task->{OS}, $task->{LCID}, $task->{TESTCASE});
			}
		
			if (index($result, $substring) != -1)
			{
				# Make sure the machine is stopped, otherwise it's still writing.				
				my @vmInfo = &getMatchingVM($task->{OS}, $task->{LCID});
				open(my $vmResult, "powershell Get-VM -VMName ".$vmInfo[0]." -ComputerName ".$vmInfo[1]." -ErrorAction SilentlyContinue \"| Where-Object {\$_.State -eq 'Running'} \" |");
				if (eof $vmResult)
				{
					$matchCount++;
					print GREEN, "  Task result found: ", RESET, $result, "\n", RESET;
					last;
				}
				else
				{
					print RED, "  ".$vmInfo[0]." on ".$vmInfo[1]." is working on other test case...\n", RESET;
				}
			}
		}
	}
	
	&getDateTime("matchTasksWithResults End");
	return $matchCount == scalar @tasks;
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
		elsif ($_ =~ /LOGID="(PSP2018\S+)"/) {	$_STUB_ = $1;	}
		elsif ($_ =~ /CLASS="(\S+)"/) {	$_CLASS_ = $1;	}
		elsif ($_ =~ /OPTIONS="(\S+)"/) {	$_OPTIONS_ = $1;	}
		elsif ($_ =~ /CUSTOMER="(\S+)"/) {	$_CUSTOMER_ = $1;	}
		elsif ($_ =~ /VERSION="(\S+)"/) {	$_VERSION_ = $1;	}
		elsif ($_ =~ /VERSIONEXTENSION="([a-z]?)"/) {	$_VERSIONEXTENSION_ = $1;	}
		elsif ($_ =~ /ALIAS="(\S+)"/) {	$_ALIAS_ = $1;	}
	}
	close($fh);
	print YELLOW, "  CLASS ", RESET, $_CLASS_, YELLOW, " CUSTOMER ", RESET, $_CUSTOMER_, YELLOW, " OPTIONS ", RESET, $_OPTIONS_, YELLOW, " LOGID ", RESET, $_LOGID_, YELLOW, " STUB ", RESET, $_STUB_."\n", RESET;
	
	$_BUILD_ = $_OPTIONS_."_".$_VERSION_.$_VERSIONEXTENSION_."_".$_CUSTOMER_."_LOGID".$_LOGID_;
	
	my @result = ();
	for my $config (@_dataServerConfig_) 
	{
		my $class = (defined $config->{CLASS}) ? $config->{CLASS} : "";
		my $customer = (defined $config->{CUSTOMER}) ? uc($config->{CUSTOMER}) : "";
		my $options = (defined $config->{OPTIONS}) ? $config->{OPTIONS} : "";
		
		#print YELLOW, "class ".$class." customer ".$customer." options ".$options."\n", RESET;
		# Pick the best match.
		if (($class eq $_CLASS_ && $customer eq "" && $options eq "") ||
			($class eq $_CLASS_ && $customer eq uc($_CUSTOMER_) && $options eq "") ||
			($class eq $_CLASS_ && $customer eq uc($_CUSTOMER_) && $options eq $_OPTIONS_))
		{
			@result = @{$config->{TASK}};
		}
	}

	print CYAN, "\tThere are ". scalar @result." tasks for this job.\n", RESET;
	for ( @result ) 
	{
		print "\t$_->{OS} $_->{LCID} $_->{TESTCASE}\n";
	}
	&getDateTime("parseJob End");
	return @result;
}

#
#	To wait results from all VMs.
#
sub waitResults()
{
	&getDateTime("waitResults Start");
	my $logID = shift;
	my @tasks = @{my $t = shift};
	my $stub = shift;
	
	# TO-DO: Make sure tasks and results are perfect match.
	my $waitResults = 1;
	while ($waitResults)
	{
		print YELLOW, "  All machines are testing for ".$logID."...\n", RESET;
		sleep($_waitLong_);
		open(my $vmResult, "powershell Get-VM -ComputerName TPE-ATSERVER01,TPE-ATSERVER02,TPE-ATSERVER03 \"| Where-Object {\$_.State -eq 'Running'} \" |");
		if (&matchTasksWithResults($logID, \@tasks, $stub) || eof $vmResult)
		{
			$waitResults = 0;				
		}
		close($vmResult);			
	}
	print GREEN, "  All testing are completed\n", RESET;
	&getDateTime("waitResults End");
}