# Define variables
$baseDir = "C:\temp\TLSInspection"
$opensslPath = "C:\Program Files\OpenSSL-Win64\bin\openssl.exe"
$csrPath = "$baseDir\TLSinspection.csr"
$rootCertPath = "$baseDir\rootCA.pfx"
$outputCertPath = "$baseDir\signed_TLSi_certificate.cer"
$rootCertPEM = "$baseDir\rootCA.pem"
$rootKeyPEM = "$baseDir\rootCA_key.pem"

# Prompt user for password
Write-Host "Please enter a password for the certificate: " -ForegroundColor Yellow -NoNewline
$securePassword = Read-Host -AsSecureString
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
$pfxPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
$password = $securePassword # Use the secure string version for certificate operations

# Create directory if it doesn't exist
if (-not (Test-Path -Path $baseDir)) {
    New-Item -ItemType Directory -Path $baseDir -Force | Out-Null
}

# Check if OpenSSL exists
if (-not (Test-Path $opensslPath)) {
    Write-Host "Error: OpenSSL executable not found at $opensslPath" -ForegroundColor Red
    exit 1
}

# Check if the CSR exists
if (-not (Test-Path $csrPath)) {
    Write-Host "Error: CSR file not found at $csrPath" -ForegroundColor Red
    exit 1
}

# Generate a new self-signed root CA certificate using CurrentUser store
$rootCert = New-SelfSignedCertificate -Subject "CN=My Test Root CA" `
    -KeyExportPolicy Exportable `
    -KeyUsage CertSign, CRLSign, DigitalSignature `
    -KeyLength 2048 `
    -KeyAlgorithm RSA `
    -HashAlgorithm SHA256 `
    -NotAfter (Get-Date).AddYears(1) `
    -TextExtension @("2.5.29.19={text}ca=TRUE&pathLength=3") `
    -CertStoreLocation "Cert:\CurrentUser\My"

# Export the certificate to a CER file (public key only)
Export-Certificate -Cert $rootCert -FilePath "$baseDir\rootCA.cer" -Force

# Export to PFX (includes private key)
Export-PfxCertificate -Cert $rootCert -FilePath $rootCertPath -Password $password -Force




# Check if root certificate PFX exists
if (-not (Test-Path $rootCertPath)) {
    Write-Host "Error: Root certificate PFX not found at $rootCertPath" -ForegroundColor Red
    exit 1
}

# Create a temporary file for the PFX password
$tempPwdFile = [System.IO.Path]::GetTempFileName()
Set-Content -Path $tempPwdFile -Value $pfxPassword -NoNewline

try {
    # Step 1: Convert PFX to PEM format (certificate + private key)
    Write-Host "Converting PFX to PEM format..." -ForegroundColor Yellow
    & $opensslPath pkcs12 -in $rootCertPath -out $rootCertPEM -nodes -passin "file:$tempPwdFile"
    
    # Step 2: Extract private key from the PEM file
    Write-Host "Extracting private key..." -ForegroundColor Yellow
    & $opensslPath pkey -in $rootCertPEM -out $rootKeyPEM
    
    # Step 3: Extract certificate from the PEM file
    $rootCertOnlyPEM = "$rootCertPEM.cert"
    & $opensslPath x509 -in $rootCertPEM -out $rootCertOnlyPEM

    # Step 4: Sign the CSR with the root CA certificate and key
    Write-Host "Signing the CSR with the root CA certificate..." -ForegroundColor Yellow
    & $opensslPath x509 -req -in $csrPath -CA $rootCertOnlyPEM -CAkey $rootKeyPEM -CAcreateserial -out $outputCertPath -days 1825
    
    # Check if output certificate was created successfully
    if (Test-Path $outputCertPath) {
        Write-Host "Certificate signing successful!" -ForegroundColor Green
        Write-Host "Signed certificate saved to: $outputCertPath" -ForegroundColor Green
        
        # Display certificate information
        Write-Host "`nSigned Certificate Information:" -ForegroundColor Cyan
        & $opensslPath x509 -in $outputCertPath -text -noout
    } else {
        Write-Host "Error: Failed to create signed certificate" -ForegroundColor Red
    }
}
catch {
    Write-Host "Error occurred: $_" -ForegroundColor Red
}
finally {
    # Clean up temporary files
    if (Test-Path $tempPwdFile) {
        Remove-Item -Path $tempPwdFile -Force
    }
}

Write-Host "Self-signed Root CA certificate created at $baseDir\rootCA.cer"
Write-Host "PFX file (with private key) created at $rootCertPath"
Write-Host "Certificate thumbprint: $($rootCert.Thumbprint)"
Write-Host "Your TLS inspection certificate has been signed and saved to $outputCertPath" -ForegroundColor Green