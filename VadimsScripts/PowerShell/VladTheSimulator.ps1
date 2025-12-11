
function Simulate-PortScanning{
    param(
        [Parameter(Mandatory = $true)]
        $TargetIP
        )
    Write-Host "Performing Port Scanning on $TargetIP"
    $Port = 80,443,8080,8443,22,21,23,25,53,135,139,445,3389,389,53,636,3268,3269,464,593,88,137,138,139,445,389,53,636,3268,3269,464,593,88,137,138,139,445 
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

Function Simulate-BloodhoundStyleEnumeration {
    param(
        [Parameter(Mandatory = $true)]
        $TargetIPCSV
        )
    
    $TargetIPHosts = Get-HostsFromCSV $TargetIPCSV

    for ($i = 0; $i -lt $TargetIPHosts.Count; $i++) {
        Write-Host "Performing Bloodhound Style Enumeration on" $TargetIPHosts[$i] "via the IPC share"
    #SAMR Calls to enumerate local users and groups
    $TargetIP = $TargetIPHosts[$i]
    $Users = [ADSI]"WinNT://$TargetIP/Users"
    $Groups = [ADSI]"WinNT://$TragetIP/Groups"
    Write-Host $Users
    Write-Host "------------------------------"
    Write-Host $Groups
    #WKSVC Calls to enumerate local services on a remote host
    $Services = Get-Service -ComputerName $TargetIP | Where-Object {$_.Status -eq "Running"}
    Write-Host "-------------------------------"
    Write-Host $Services
    #SRVSVC Calls to enumerate sessions
    Get-WmiObject -Class Win32_Session -ComputerName $TargetIP
    }
    

    
}

Function Simulate-AVDetectionViaEICAR {
    param(
    [Parameter(Mandatory = $true)]    
    $TargetIP
    )
    Write-Host "Performing AV Detection via EICAR on $TargetIP"
    $Credential = Get-Credential
    Invoke-Command -ComputerName $TargetIP -Credential $Credential -ScriptBlock {
        Invoke-WebRequest "https://www.eicar.org/download/eicar.com.txt" -o ./sample.txt
    }
    
}

Function Get-HostsFromCSV {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CSVPath
    )
    if (-Not (Test-Path $CSVPath)) {
        Write-Host "File $CSVPath does not exist."
        return $null
    }
    $dataArray = @()
    try {
        $dataArray = Import-Csv -Path $CSVPath
        Write-Host "Successfully imported $($dataArray.Count) rows from $CSVPath"
    }
    catch {
        Write-Host "Failed to import CSV: $_"
        return $null
    }
    return $HostArray
}

Write-Host "                   .---------------------------------------------------.
                              /                                                     \
                             /     /\                     /\                         \
                            /     /  \                   /  \                         \
                           /     /^^^^\_________________/^^^^\                         \
                          /     /      \               /      \                         \
                  /\     /     /  /\    \             /    /\  \     /\                 \
                 /  \   /     /  /  \    \___________/    /  \  \   /  \                 \
                /^^^^\_/_____/^^/^^^^\                 /^^^^\^^\___/^^^^\                |
               /      \      /  /      \_______________/      \  \       \               |
        ______/  /\    \    /  /        |             |        \  \    /\ \_______       |
       |      \ /  \    \__/  /         |  /\     /\  |         \  \__/  \ /      |      |
       | ^^^^^ /^^^^\        /   _      | |  |   |  | |      _    \        /^^^^^ |      |
       |       \      \_____/   | |     | |  |___|  | |     | |    \______/       |      |
       |        \    /\         |_|     | |   ___   | |     |_|         /\        |      |
       |_________\  /  \________________| |  (___)  | |________________/  \_______|      |
               /^^^^^^\                 |_|_________|_|                /^^^^^^\          |
              /        \______________________________________________/        \         |
             /                                                                 \        /
            /___________________________________________________________________\______/


                         ███████ Vlad the Simulator ███████
"

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
    Simulate-BloodhoundStyleEnumeration($TargetIPRange)
}
ElseIf ($Option -eq 3) {
    Simulate-AVDetectionViaEICAR($TargetIP)
}
