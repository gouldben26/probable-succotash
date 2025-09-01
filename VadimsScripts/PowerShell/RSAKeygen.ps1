function New-RSAKeyPair {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PublicKeyPath,
        [Parameter(Mandatory = $true)]
        [string]$PrivateKeyPath,
        [int]$KeySize = 2048
    )

    try {
        # Create new RSA key pair
        $rsa = [System.Security.Cryptography.RSACryptoServiceProvider]::new($KeySize)

        # Export keys as XML strings
        $publicKey = $rsa.ToXmlString($false)  # Public key only
        $privateKey = $rsa.ToXmlString($true)  # Private + public key

        # Save keys to files
        Set-Content -Path $PublicKeyPath -Value $publicKey
        Set-Content -Path $PrivateKeyPath -Value $privateKey

        # Clean up
        $rsa.Dispose()

        Write-Host "RSA key pair generated successfully."
        Write-Host "Public key saved to: $PublicKeyPath"
        Write-Host "Private key saved to: $PrivateKeyPath"
    }
    catch {
        Write-Error "RSA key generation failed: $($_.Exception.Message)"
    }
}


New-RSAKeyPair -PublicKeyPath 'C:\Users\Vadim.AzureAD\Documents\GitHub\probable-succotash\VadimsScripts\PowerShell\PublicKey.txt' -PrivateKeyPath 'C:\Users\Vadim.AzureAD\Documents\GitHub\probable-succotash\VadimsScripts\PowerShell\PrivateKey.txt'