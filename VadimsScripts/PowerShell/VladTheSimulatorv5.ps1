
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
    $TargetIPHosts = @()
    $TargetIPHosts = Get-HostsFromCSV $TargetIPCSV
    for ($i = 0; $i -lt $TargetIPHosts.Count; $i++) {
        Write-Host "Performing Bloodhound Style Enumeration on" $TargetIPHosts[$i] "via the IPC share"
    #SAMR Calls to enumerate local users and groups
    $TargetIP = $TargetIPHosts[$i]
    $PipeNames = @("epmapper", "lsarpc", "samr", "netlogon", "spoolss")
    foreach ($Pipe in $PipeNames) {
        try {
            $fs = [System.IO.File]::Open("\\$TargetIP\pipe\$Pipe", 'Open', 'ReadWrite', 'None')
            if ($fs) {
                Write-Host "Successfully accessed named pipe: $Pipe on $TargetIP"
                $fs.Close()
            }
        }
        catch {
            Write-Host "Could not access named pipe: $Pipe on $TargetIP : $($_.Exception.Message)"
        }
    }
    }
    

    
}

Function Simulate-AVDetectionViaEICAR {
    param(
    [Parameter(Mandatory = $true)]    
    $TargetIP
    )
    Write-Host "Performing AV Detection via EICAR on $TargetIP"
    Invoke-Command -ComputerName $TargetIP -Credential $Credential -ScriptBlock {
        Invoke-WebRequest "https://www.secure.eicar.org/eicar_com.zip" -o ./sample.zip
        Expand-Archive -Path .\sample.zip -DestinationPath .
        .\eicar.com
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
        for ($i = 0; $i -lt $dataarray.Count; $i++) {
            Write-Host $dataArray[$i]
            $dataArray[$i] = $dataArray[$i] -replace "@{IP=",""
            $dataArray[$i] = $dataArray[$i] -replace "}",""
            Write-Host $dataArray[$i]
        }
        Write-Host "Successfully imported $($dataArray.Count) rows from $CSVPath"
    }
    catch {
        Write-Host "Failed to import CSV: $_"
        return $null
    }
    return $dataArray
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

If ($Option -eq 1) {
    $TargetIP= Read-Host "Enter the target IP address"
    Simulate-PortScanning($TargetIP)
}
ElseIf ($Option -eq 2) {
    $TargetIPCSV = Read-Host "Enter the File Path of the targets CSV"
    Simulate-BloodhoundStyleEnumeration($TargetIPCSV)
}
ElseIf ($Option -eq 3) {
    $TargetIP= Read-Host "Enter the target IP address"
    Simulate-AVDetectionViaEICAR($TargetIP)
}
