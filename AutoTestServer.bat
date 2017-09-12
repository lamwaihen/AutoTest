@echo off

@rem Setup network drive here.


echo Begin to wait for new jobs.
pushd v:\autotest\Tools-AutoTest\Jobs

:new_job_loop
	@rem
	echo %time%
	dir /b *.py
	for /f %%i in ('dir /b /a-d *.py ^| find /c /v ""') do @call set count=%%i
	echo %count%
	
	timeout 5 > NUL
goto new_job_loop


popd