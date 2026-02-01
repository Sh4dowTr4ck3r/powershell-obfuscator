param(
    [Parameter(Mandatory=$true)]
    [string]$InputPath,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputName = "document",
    
    [Parameter(Mandatory=$false)]
    [string]$FakeExtension = "txt",
    
    [Parameter(Mandatory=$false)]
    [string]$Password = ""
)

Write-Host "=== File Obfuscator for Security Testing ===" -ForegroundColor Green
Write-Host "Input: $InputPath" -ForegroundColor Yellow
if ($Password -ne "") {
    Write-Host "Password protection: ENABLED" -ForegroundColor Magenta
}

# Check if input exists
if (!(Test-Path $InputPath)) {
    Write-Host "Error: Input path does not exist!" -ForegroundColor Red
    exit 1
}

# Step 1: Compress to ZIP
Write-Host "Step 1: Compressing to ZIP" -ForegroundColor Cyan
$tempZip = "temp_$(Get-Random).zip"

try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::Open($tempZip, 'Create')
    $entry = $zip.CreateEntry([System.IO.Path]::GetFileName($InputPath))
    $entryStream = $entry.Open()
    $fileStream = [System.IO.File]::OpenRead($InputPath)
    $fileStream.CopyTo($entryStream)
    $entryStream.Close()
    $fileStream.Close()
    $zip.Dispose()
} catch {
    Write-Host "✗ Failed to compress: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 2: Encrypt if password provided
Write-Host "Step 2: $(if ($Password -ne '') { 'Encrypting with AES-256' } else { 'No encryption (no password provided)' })" -ForegroundColor Cyan
$zipBytes = [System.IO.File]::ReadAllBytes($tempZip)

try {
    if ($Password -ne "") {
        # Generate random salt and IV
        $salt = New-Object byte[] 16
        $iv = New-Object byte[] 16
        [System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($salt)
        [System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($iv)
        
        # Create AES encryption
        $keyBytes = [System.Text.Encoding]::UTF8.GetBytes($Password)
        $aes = [System.Security.Cryptography.Aes]::Create()
        $keyGen = [System.Security.Cryptography.Rfc2898DeriveBytes]::new($keyBytes, $salt, 10000)
        $aes.Key = $keyGen.GetBytes(32)
        $aes.IV = $iv
        
        $encryptor = $aes.CreateEncryptor()
        $encryptedData = $encryptor.TransformFinalBlock($zipBytes, 0, $zipBytes.Length)
        
        # Combine salt + IV + encrypted data
        $finalBytes = $salt + $iv + $encryptedData
        $aes.Dispose()
    } else {
        $finalBytes = $zipBytes
    }
} catch {
    Write-Host "✗ Failed to encrypt: $($_.Exception.Message)" -ForegroundColor Red
    Remove-Item $tempZip -ErrorAction SilentlyContinue
    exit 1
}

# Step 3: Save encrypted data to file
$outputFile = "$OutputName.$FakeExtension"
Write-Host "Step 3: Saving encrypted data to $outputFile" -ForegroundColor Cyan

try {
    # Encode the encrypted data to Base64 for text file storage
    $encodedData = [Convert]::ToBase64String($finalBytes)
    
    # Create a simple text file with the encoded data
    [System.IO.File]::WriteAllText($outputFile, $encodedData, [System.Text.Encoding]::UTF8)
    
} catch {
    Write-Host "✗ Failed to create output file: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # Clean up temp file
    Remove-Item $tempZip -ErrorAction SilentlyContinue
}

Write-Host "`n🎭 OBFUSCATION COMPLETE! 🎭" -ForegroundColor Green
Write-Host "📁 Obfuscated file: $outputFile" -ForegroundColor White
Write-Host "📋 Original size: $((Get-Item $InputPath).Length) bytes" -ForegroundColor White
Write-Host "📊 Final size: $((Get-Item $outputFile).Length) bytes" -ForegroundColor White

if ($Password -ne "") {
    Write-Host "🔐 Password protection: AES-256 encryption" -ForegroundColor Yellow
}

Write-Host "`nTo extract:" -ForegroundColor Cyan
Write-Host "Use: .\decrypt.ps1 -InputPath `"$outputFile`" -Password `"$Password`"" -ForegroundColor White