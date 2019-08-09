Function rehostNC{
param ([string]$ServerName,[string]$partition,[string]$ValidSource)

	repadmin /unhost $servername "$partition"
		
	$eventfound = "false" 
	$inc=1 
	while($eventfound -eq "false"){ 
		try{ 
			# UNHOST EVENT CHECK (EVENT 1660 / INSTANCEID 1073743484) 
			$temp = get-eventlog -ComputerName $servername -LogName 'Directory Service' -InstanceId 1073743484 -newest 1 -ErrorAction Stop -after (get-date).addminutes(-120) 
			$eventfound = "true" 
			Write-Host "[$((Get-Date).DateTime)] : GC unhosting check on $servername (event 1660) [SUCCESS]"
			Start-Sleep -Seconds 1 

			# REHOST GC 
			Write-Host "[$((Get-Date).DateTime)] : Rehosting the partition $partition on the server $servername using the valid source $ValidSource..."
			Start-Sleep -Seconds 1 
			repadmin /rehost $servername "$partition" $ValidSource
		} 
		catch{ 
			# WAIT WHILE EVENT 1660 NOT REGISTERED 
			$string = $error[0].Exception.message.Tostring() 
			if (($string -eq "No matches found") -and ($inc -le 6)){ 
				Write-Host "[$((Get-Date).DateTime)] : GC unhosting check on $servername (event 1660). Next retry in 10 seconds... [WARNING]"
				Start-Sleep -Seconds 10 
				$inc++ 
			} 
			else { 
				Write-Host "[$((Get-Date).DateTime)] : Cannot find event 1660. GC unhosting process fails on $servername [ERROR]`n---- EXIT -----`n"
			} 
		} 
	} 
}
