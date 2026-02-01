param(
    [Parameter(Mandatory=$true)]
    [string]$InputFile,
    
    [Parameter(Mandatory=$false)]
    [string]$Password = "",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputDir = "restored"
)

function Decrypt-Data {
    param([byte[]]$Data, [string]$Password)
    
    try {
        $AES = [System.Security.Cryptography.AesManaged]::new()
        $AES.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $AES.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
        
        # Extract salt, IV, and encrypted data
        $Salt = $Data[0..15]           # First 16 bytes = salt
        $IV = $Data[16..31]            # Next 16 bytes = IV  
        $EncryptedData = $Data[32..($Data.Length-1)]  # Rest = encrypted data
        
        # Generate key from password with the extracted salt
        $KeyGen = [System.Security.Cryptography.Rfc2898DeriveBytes]::new($Password, $Salt, 10000)
        $AES.Key = $KeyGen.GetBytes(32)  # 256-bit key
        $AES.IV = $IV
        
        # Decrypt the data
        $Decryptor = $AES.CreateDecryptor()
        $DecryptedBytes = $Decryptor.TransformFinalBlock($EncryptedData, 0, $EncryptedData.Length)
        
        $AES.Dispose()
        return $DecryptedBytes
        
    } catch {
        Write-Host "Decryption error: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

Write-Host "🔄 DECRYPTING OBFUSCATED FILE" -ForegroundColor Cyan
Write-Host "Input: $InputFile" -ForegroundColor White

# Initialize extraction success flag
$extractionSuccess = $false

# Check if input file exists
if (-not (Test-Path $InputFile)) {
    Write-Host "✗ Input file not found: $InputFile" -ForegroundColor Red
    exit 1
}

try {
    # Step 1: Read Base64 data
    Write-Host "`nStep 1: Reading Base64 data" -ForegroundColor Yellow
    $content = Get-Content $InputFile -Raw
    # Extract only the Base64 data (skip header and footer lines)
    $base64Data = ($content -split "`n" | Where-Object { $_ -notmatch "^#" -and $_.Trim() -ne "" }) -join ""
    
    # Step 2: Convert from Base64
    Write-Host "`nStep 2: Converting from Base64" -ForegroundColor Yellow
    $zipBytes = [System.Convert]::FromBase64String($base64Data)
    
    # Step 3: Decrypt if password provided
    if ($Password -ne "") {
        Write-Host "`nStep 3: Decrypting with password" -ForegroundColor Yellow
        $zipBytes = Decrypt-Data -Data $zipBytes -Password $Password
    } else {
        Write-Host "`nStep 3: No password provided, skipping decryption" -ForegroundColor Gray
    }
    
    # Step 4: Save as temporary ZIP
    Write-Host "`nStep 4: Creating temporary ZIP file" -ForegroundColor Yellow
    $tempZip = "temp_restored_$(Get-Random).zip"
    [System.IO.File]::WriteAllBytes($tempZip, $zipBytes)
    
    # Step 5: Extract and save as hardcoded filename
    Write-Host "`nStep 5: Extracting and saving as 'tester'" -ForegroundColor Yellow
    
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        
        # Create temp extraction directory
        $tempExtract = "temp_extract_$(Get-Random)"
        New-Item -ItemType Directory -Path $tempExtract -Force | Out-Null
        
        [System.IO.Compression.ZipFile]::ExtractToDirectory($tempZip, $tempExtract)
        
        # Find the first .exe file and rename it to "tester.exe"
        $extractedFiles = Get-ChildItem $tempExtract -Recurse
        $exeFile = $extractedFiles | Where-Object { $_.Extension -eq ".exe" } | Select-Object -First 1
        
        if ($exeFile) {
            Copy-Item $exeFile.FullName "tester.exe" -Force
        } else {
            # If no .exe found, just copy the first file as "tester"
            $firstFile = $extractedFiles | Select-Object -First 1
            if ($firstFile) {
                Copy-Item $firstFile.FullName "tester" -Force
            }
        }
        
        # Clean up temp extraction directory
        Remove-Item $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
        
        Write-Host "`n🎉 DECRYPTION COMPLETE!" -ForegroundColor Green
        Write-Host "📁 Original file restored as: tester.exe" -ForegroundColor White
        
        # Mark successful extraction for cleanup
        $extractionSuccess = $true
        
    } catch {
        # Fallback: save ZIP file for manual extraction
        Write-Host "✗ Automatic extraction failed: $($_.Exception.Message)" -ForegroundColor Yellow
        $finalZip = "decrypted_$(Get-Random).zip"
        Copy-Item $tempZip $finalZip -Force
        Write-Host "`n💡 ZIP file saved for manual extraction: $finalZip" -ForegroundColor Cyan
        Write-Host "   Extract and rename the .exe file to 'tester.exe'" -ForegroundColor Gray
        $extractionSuccess = $false
    }
    
} catch {
    Write-Host "✗ Error during decryption: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    # Clean up temp file - always remove if extraction was successful
    if ((Test-Path $tempZip) -and ($extractionSuccess -eq $true)) {
        Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
        Write-Host "🧹 Cleaned up temporary files" -ForegroundColor Gray
    } elseif (Test-Path $tempZip) {
        Write-Host "💡 TIP: Temporary ZIP file preserved for manual extraction: $tempZip" -ForegroundColor Blue
    }
}