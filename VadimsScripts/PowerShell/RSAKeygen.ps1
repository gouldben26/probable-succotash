$RSACNG = [System.Security.Cryptography.RSACng]::new(3072)
$ExportedPublicKey = $RSACNG.key.Export([System.Security.Cryptography.CngKeyBlobFormat]::GenericPublicBlob)
$ExportedPrivateKey = $RSACNG.key.Export([System.Security.Cryptography.CngKeyBlobFormat]::GenericPrivateBlob)

Add-Content -Path .\key.txt -Value "Public Key: $ExportedPublicKey /n Private Key: $ExportedPrivateKey"
