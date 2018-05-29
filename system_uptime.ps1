
Function get_system_uptime 
    {
 
    Param([string[]]$Computername = $env:COMPUTERNAME)

    #$Computername = $env:COMPUTERNAME
    
    $Reboots = Get-WmiObject Win32_OperatingSystem -ComputerName $computername | Select-Object CSName,LastBootUpTime
    $Date = Get-Date
    
    Foreach ($reboot in $reboots) 
        {
        $last_reboot_time = [Management.ManagementDateTimeConverter]::ToDateTime($reboot.LastBootUpTime)
        New-TimeSpan -Start $last_reboot_time -End $Date | 
        Select-Object @{Name = "SystemName"; Expression = {$reboot.CSName}},@{Name = "LastRebootTime"; Expression = {$last_reboot_time}},Days,Hours,Minutes,Seconds 
        }
   
    } #end function

    Function get_system_uptime_2
    {
 
    Param([string[]]$Computername = $env:COMPUTERNAME)

    #$Computername = $env:COMPUTERNAME
    
    $Reboots = Get-WmiObject Win32_OperatingSystem -ComputerName $computername | Select-Object CSName,LastBootUpTime
    $Date = Get-Date
    
    $last_reboot_time = [Management.ManagementDateTimeConverter]::ToDateTime($reboots.LastBootUpTime)
    New-TimeSpan -Start $last_reboot_time -End $Date | 
    Select-Object @{Name = "SystemName"; Expression = {$reboots.CSName}},@{Name = "LastRebootTime"; Expression = {$last_reboot_time}},Days,Hours,Minutes,Seconds 

    } #end function

function remote_uptime
    {
    #$lastboottime = (Get-WmiObject -Class Win32_OperatingSystem -computername $item).LastBootUpTime
    $lastboottime = (Get-WmiObject -Class Win32_OperatingSystem).LastBootUpTime
    $sysuptime = (Get-Date) - [System.Management.ManagementDateTimeconverter]::ToDateTime($lastboottime)            
    $output = "\\$item has been up for: " + $sysuptime.days + " day(s), " + $sysuptime.hours + " hour(s), " + $sysuptime.minutes + " minute(s), " + $sysuptime.seconds + " second(s)"
    $output
    #script_output
    } 




    get_system_uptime
    get_system_uptime_2
    remote_uptime