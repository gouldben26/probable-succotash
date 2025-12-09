Write-Host "Hi there! So you want to get into some shenanigans? Please select From one of the following options:
Note: This script is intented to be ran on a host targeting a windows machine on the network
1. Simiulate Port Scanning
2. Simiulate Bloodhound Style Enumeration
3. Simulate an AV Detection via EICAR. "

$Option = Read-Host "Enter your choice"
$TargetIP = Read-Host "Enter the target IP address"

If ($Option -eq 1) {
    Simulate-PortScanning($TargetIP)
}
ElseIf ($Option -eq 2) {
    Simulate-BloodhoundStyleEnumeration($TargetIP)
}
ElseIf ($Option -eq 3) {
    Simulate-AVDetectionViaEICAR($TargetIP)
}

function Simulate-PortScanning($TargetIP){
    Write-Host "Performing Port Scanning on $TargetIP"
    $Port = 1..1024 
    ForEach ($Port in $Port) {
        $Socket = New-Object System.Net.Sockets.TcpClient
        Try {
            $Socket.Connect($TargetIP, $Port)
        }
        Catch {
            Write-Host "Port $Port is closed"
        }
        if ($Socket.Connected) {
            Write-Host "Port $Port is open"
        }
    }
}

Function Simulate-BloodhoundStyleEnumeration {($TargetIP)
    Write-Host "Performing Bloodhound Style Enumeration on $TargetIP via the IPC share"
    #SAMR Calls to enumerate local users and groups
    $Users = [ADSI]"WinNT://$TargetIP/Users"
    $Groups = [ADSI]"WinNT://$TargetIP/Groups"
    $Users.Children | ForEach-Object {
        Write-Host "User: $_.Name"
    }
    $Groups.Children | ForEach-Object {
        Write-Host "Group: $_.Name"
    }
    #SRVSVC calls to enumerate services
    $Services = [ADSI]"WinNT://$TargetIP/Services"
    $Services.Children | ForEach-Object {
        Write-Host "Service: $_.Name"
    }
    #WKSSVC call to enumerate workstation info 
    $Workstation = [ADSI]"WinNT://$TargetIP/Workstation"
    $Workstation.Children | ForEach-Object {
        Write-Host "Workstation: $_.Name"
    }
}

Function Simulate-AVDetectionViaEICAR {($TargetIP)
    Write-Host "Performing AV Detection via EICAR on $TargetIP"
    New-PSsession -ComputerName $TargetIP
    Invoke-Command -ScriptBlock {{
        $EICARURL = "https://www.eicar.org/download/eicar.com.txt"
        Invoke-WebRequest -Uri $EICARURL -OutFile "C:\Windows\Temp\EICAR.txt"
    }}
}

