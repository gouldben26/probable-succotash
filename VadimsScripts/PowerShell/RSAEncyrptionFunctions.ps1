# Function to encrypt a file using RSA public key
function Encrypt-FileRSA {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath,
        [Parameter(Mandatory=$true)]
        [string]$PublicKeyPath
    )

    try {
        # Read file bytes
        $fileBytes = [System.IO.File]::ReadAllBytes($FilePath)

        # Read public key from file
        $publicKey = Get-Content -Path $PublicKeyPath

        # Create RSA object and import public key
        $rsa = [System.Security.Cryptography.RSACryptoServiceProvider]::new(2048)
        $rsa.FromXmlString($publicKey)

        # RSA can only encrypt small data, so use AES for file, encrypt AES key with RSA
        $aes = [System.Security.Cryptography.Aes]::Create()
        $aes.GenerateKey()
        $aes.GenerateIV()
        $aesKey = $aes.Key
        $aesIV = $aes.IV

        # Encrypt file with AES
        $encryptor = $aes.CreateEncryptor()
        $encryptedFile = $encryptor.TransformFinalBlock($fileBytes, 0, $fileBytes.Length)

        # Encrypt AES key and IV with RSA
        $encryptedKey = $rsa.Encrypt($aesKey, $true)
        $encryptedIV = $rsa.Encrypt($aesIV, $true)

        # Combine encryptedKey, encryptedIV, and encryptedFile
        $output = ($encryptedKey + $encryptedIV + $encryptedFile)

        # Write to file (overwrite or create new)
        [System.IO.File]::WriteAllBytes($FilePath, $output)

        # Clean up
        $encryptor.Dispose()
        $aes.Dispose()
        $rsa.Dispose()

        Write-Host "File encrypted with RSA successfully."
    }
    catch {
        Write-Error "RSA file encryption failed: $($_.Exception.Message)"
    }
}

# Function to decrypt a file using RSA private key
function Decrypt-FileRSA {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath,
        [Parameter(Mandatory=$true)]
        [string]$PrivateKeyPath
    )

    try {
        # Read encrypted file bytes
        $allBytes = [System.IO.File]::ReadAllBytes($FilePath)

        # Read private key from file
        $privateKey = Get-Content -Path $PrivateKeyPath

        # Create RSA object and import private key
        $rsa = [System.Security.Cryptography.RSACryptoServiceProvider]::new(2048)
        $rsa.FromXmlString($privateKey)

        # Calculate sizes
        $rsaKeySize = 2048 / 8 # 256 bytes for 2048-bit key
        $encryptedKey = $allBytes[0..($rsaKeySize-1)]
        $encryptedIV = $allBytes[$rsaKeySize..((2*$rsaKeySize)-1)]
        $encryptedFile = $allBytes[(2*$rsaKeySize)..($allBytes.Length-1)]

        # Decrypt AES key and IV
        $aesKey = $rsa.Decrypt($encryptedKey, $true)
        $aesIV = $rsa.Decrypt($encryptedIV, $true)

        # Decrypt file with AES
        $aes = [System.Security.Cryptography.Aes]::Create()
        $aes.Key = $aesKey
        $aes.IV = $aesIV
        $decryptor = $aes.CreateDecryptor()
        $decryptedFile = $decryptor.TransformFinalBlock($encryptedFile, 0, $encryptedFile.Length)

        # Write decrypted data back to file (overwrite)
        [System.IO.File]::WriteAllBytes($FilePath, $decryptedFile)

        # Clean up
        $decryptor.Dispose()
        $aes.Dispose()
        $rsa.Dispose()

        Write-Host "File decrypted with RSA successfully."
    }
    catch {
        Write-Error "RSA file decryption failed: $($_.Exception.Message)"
    }
}

Decrypt-FileRSA -FilePath "$env:USERPROFILE\Desktop\GetGot.txt" -PrivateKeyPath 'C:\Users\Vadim.AzureAD\Documents\GitHub\probable-succotash\VadimsScripts\PowerShell\PrivateKey.txt'
