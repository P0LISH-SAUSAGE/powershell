############################################################################################################################
##                                                                                                                        ##
##  backup script utiizing robocopy                                                                                       ##
##                                                                                                                        ##
##  Version: 1.1                                                                                                          ##
##                                                                                                                        ##
############################################################################################################################

param
	(
	[string]$run_type
	)
	
$backup_source_job1 = "D:\"
$backup_destination_job1 = "E:\"
$backup_source_job2 = "E:\"
$backup_destination_job2 = "F:\"
$log_file_path = "F:\backup_log\"

function get_dir_file_info ($path_info) 
	{
	$dir_info = Get-ChildItem $path_info -Recurse -Directory | Measure-Object | ForEach-Object{$_.Count}
	$file_info = Get-ChildItem $path_info -Recurse -File | Measure-Object | ForEach-Object{$_.Count}
	$size_info = [Math]::Round((Get-ChildItem $path_info -Recurse | Measure-Object -property length -sum).sum /1mb,2)
	$output = $path_info + "; Dirs = " + $dir_info + "; Files = " + $file_info + "; Size = " + $size_info 
	$output
	}

function write_log([string]$log_entry)
	{
	$log_exisits = (Test-Path $backup_log_file_name) 
	$new_log_entry =$log_entry
	
	if($log_exisits -eq 0)
		{
		$new_log_entry | Out-File $backup_log_file_name -Encoding "ASCII"
		}
	else
		{
		$new_log_entry | Out-File $backup_log_file_name -Encoding "ASCII" -append
		}
	}

function manual_backup
	{
	$start_time = Get-Date
	$log_date = Get-Date -f yyMMdd
	$backup_log_file_name = $log_file_path + "backup_" + $log_date + ".log"
	$path_info_before_src_job1 = get_dir_file_info $backup_source_job1
	$path_info_before_dst_job1 = get_dir_file_info $backup_destination_job1
	$path_info_before_src_job2 = get_dir_file_info $backup_source_job2
	$path_info_before_dst_job2 = get_dir_file_info $backup_destination_job2

	write_log "******************************************************************************************************************"
	write_log "Manual backup job started at $start_time"
	write_log ""
	write_log "Drive/Dir/File Info - BEFORE"
	Get-WmiObject Win32_logicaldisk | Where-Object{$_.mediatype -eq 12}| Format-Table DeviceId, VolumeName, @{ Label = "Size(GB)"; Expression={[System.Math]::Round($_.Size/1GB,2)}}, @{ Label = "FreeSpace(GB)"; Expression={[System.Math]::Round($_.FreeSpace/1GB,2)}} -auto | Out-File $backup_log_file_name -Encoding "ASCII" -append
	write_log "JOB 1"
	write_log "Source:  $path_info_before_src_job1 MB"
	write_log "Destination:  $path_info_before_dst_job1 MB"
	write_log ""
	write_log "JOB 2"
	write_log "Source:  $path_info_before_src_job2 MB"
	write_log "Destination:  $path_info_before_dst_job2 MB"
	write_log ""
	write_log "******************************************************************************************************************"
	write_log ""
	
	#robocopy.exe $backup_source_job1 $backup_destination_job1 /MIR /MT:16 /FFT /XA:SH /XD /TEE /Log+:$backup_log_file_name
	#robocopy.exe $backup_source_job2 $backup_destination_job2 /MIR /MT:16 /FFT /TEE /Log+:$backup_log_file_name	
	robocopy.exe $backup_source_job1 $backup_destination_job1 /MIR /MT:16 /FFT /XA:SH /XD "d:\$RECYCLE.BIN" "d:\System Volume Information" /TEE /Log+:$backup_log_file_name
	robocopy.exe $backup_source_job2 $backup_destination_job2 /MIR /MT:16 /FFT /XA:SH /XD "e:\$RECYCLE.BIN" "e:\System Volume Information" /TEE /Log+:$backup_log_file_name
	
	$path_info_after_src_job1 = get_dir_file_info $backup_source_job1
	$path_info_after_dst_job1 = get_dir_file_info $backup_destination_job1
	$path_info_after_src_job2 = get_dir_file_info $backup_source_job2
	$path_info_after_dst_job2 = get_dir_file_info $backup_destination_job2
	$end_time = Get-Date
	$total_time = $end_time - $start_time
	$total_time = get-date "$total_time" -f "HH:mm:ss"

	write_log ""
	write_log "******************************************************************************************************************"
	write_log "******************************************************************************************************************"
	write_log "Manual backup job finished at $end_time"
	write_log "It took $total_time for the job to complete"
	write_log ""
	write_log "Drive/Dir/File Info - AFTER"
	Get-WmiObject Win32_logicaldisk | Where-Object{$_.mediatype -eq 12}| Format-Table DeviceId, VolumeName, @{ Label = "Size (GB)"; Expression={[System.Math]::Round($_.Size/1GB,2)}}, @{ Label = "FreeSpace (GB)"; Expression={[System.Math]::Round($_.FreeSpace/1GB,2)}} -auto | Out-File $backup_log_file_name -Encoding "ASCII" -append
	write_log "JOB 1"
	write_log "Source:  $path_info_after_src_job1 MB"
	write_log "Destination:  $path_info_after_dst_job1 MB"
	write_log ""
	write_log "JOB 2"
	write_log "Source:  $path_info_after_src_job2 MB"
	write_log "Destination:  $path_info_after_dst_job2 MB"
	write_log ""
	write_log "******************************************************************************************************************"
	write_log "******************************************************************************************************************"
	write_log ""
	write_log ""
	write_log ""
	}

function scheduled_backup
	{
	$start_time = Get-Date
	$log_date = Get-Date -f yyMMdd
	$backup_log_file_name = $log_file_path + "backup_" + $log_date + ".log"
	$path_info_before_src_job1 = get_dir_file_info $backup_source_job1
	$path_info_before_dst_job1 = get_dir_file_info $backup_destination_job1
	$path_info_before_src_job2 = get_dir_file_info $backup_source_job2
	$path_info_before_dst_job2 = get_dir_file_info $backup_destination_job2
	
	write_log "******************************************************************************************************************"
	write_log "Scheduled backup job started at $start_time"
	write_log ""
	write_log "Drive/Dir/File Info - BEFORE"
	Get-WmiObject Win32_logicaldisk | Where-Object{$_.mediatype -eq 12}| Format-Table DeviceId, VolumeName, @{ Label = "Size (GB)"; Expression={[System.Math]::Round($_.Size/1GB,2)}}, @{ Label = "FreeSpace (GB)"; Expression={[System.Math]::Round($_.FreeSpace/1GB,2)}} -auto | Out-File $backup_log_file_name -Encoding "ASCII" -append
	write_log "JOB 1"
	write_log "Source:  $path_info_before_src_job1 MB"
	write_log "Destination:  $path_info_before_dst_job1 MB"
	write_log ""
	write_log "JOB 2"
	write_log "Source:  $path_info_before_src_job2 MB"
	write_log "Destination:  $path_info_before_dst_job2 MB"
	write_log ""
	write_log "******************************************************************************************************************"
	write_log ""

	#robocopy.exe $backup_source_job1 $backup_destination_job1 /MIR /MT:16 /FFT /XA:SH /XD /TEE /Log+:$backup_log_file_name
	#robocopy.exe $backup_source_job2 $backup_destination_job2 /MIR /MT:16 /FFT /TEE /Log+:$backup_log_file_name	
	robocopy.exe $backup_source_job1 $backup_destination_job1 /MIR /MT:16 /FFT /XA:SH /XD "d:\$RECYCLE.BIN" "d:\System Volume Information" /TEE /Log+:$backup_log_file_name
	robocopy.exe $backup_source_job2 $backup_destination_job2 /MIR /MT:16 /FFT /XA:SH /XD "e:\$RECYCLE.BIN" "e:\System Volume Information" /TEE /Log+:$backup_log_file_name
	
	$end_time = Get-Date
	$total_time = $end_time - $start_time
	$total_time = get-date "$total_time" -f "HH:mm:ss"
	$path_info_after_src_job1 = get_dir_file_info $backup_source_job1
	$path_info_after_dst_job1 = get_dir_file_info $backup_destination_job1
	$path_info_after_src_job2 = get_dir_file_info $backup_source_job2
	$path_info_after_dst_job2 = get_dir_file_info $backup_destination_job2

	write_log ""
	write_log "******************************************************************************************************************"
	write_log "******************************************************************************************************************"
	write_log "Scheduled backup job finished at $end_time"
	write_log "It took $total_time for the job to complete"
	write_log ""
	write_log "Drive/Dir/File Info - AFTER"
	Get-WmiObject Win32_logicaldisk | Where-Object{$_.mediatype -eq 12}| Format-Table DeviceId, VolumeName, @{ Label = "Size (GB)"; Expression={[System.Math]::Round($_.Size/1GB,2)}}, @{ Label = "FreeSpace (GB)"; Expression={[System.Math]::Round($_.FreeSpace/1GB,2)}} -auto | Out-File $backup_log_file_name -Encoding "ASCII" -append
	write_log "JOB 1"
	write_log "Source:  $path_info_after_src_job1 MB"
	write_log "Destination:  $path_info_after_dst_job1 MB"
	write_log ""
	write_log "JOB 2"
	write_log "Source:  $path_info_after_src_job2 MB"
	write_log "Destination:  $path_info_after_dst_job2 MB"
	write_log ""
	write_log "******************************************************************************************************************"
	write_log "******************************************************************************************************************"
	write_log ""
	write_log ""
	write_log ""
	}
	
if($run_type -eq "sch")
	{
	scheduled_backup
	}
else
	{
	manual_backup
	}