# PowerShell Obfuscation Tools

Private collection of PowerShell obfuscation and decryption utilities.

## Files

### `obfuscate.ps1`
- **Purpose**: Obfuscates PowerShell scripts to protect source code
- **Features**: 
  - Variable name randomization
  - String encoding/encryption
  - Code structure transformation
  - Anti-analysis techniques
  - **AES-256 encryption** with password protection
  - **Base64 encoding** for binary data
  - **Salt generation** for enhanced security
  - **ZIP compression** to reduce file size
  - **Archive creation** with multiple file support

### `decrypt.ps1` 
- **Purpose**: Decrypts and deobfuscates protected PowerShell scripts
- **Features**:
  - Reverses obfuscation transformations
  - **AES-256 decryption** with password authentication
  - Decodes encrypted strings and Base64 content
  - Restores original variable names where possible
  - **PBKDF2 key derivation** from passwords
  - **ZIP decompression** and archive extraction

## Usage

```powershell
# Basic obfuscation
.\obfuscate.ps1 -InputFile "script.ps1" -OutputFile "obfuscated.ps1"

# Obfuscate with password protection (recommended)
.\obfuscate.ps1 -InputFile "script.ps1" -OutputFile "obfuscated.ps1" -Password "YourSecurePassword123!"

# Obfuscate with ZIP compression
.\obfuscate.ps1 -InputFile "script.ps1" -OutputFile "obfuscated.zip" -Compress -Password "YourSecurePassword123!"

# Obfuscate multiple files into archive
.\obfuscate.ps1 -InputPath "C:\Scripts\" -OutputFile "obfuscated_bundle.zip" -Compress -Password "YourSecurePassword123!"

# Advanced obfuscation with custom settings
.\obfuscate.ps1 -InputFile "script.ps1" -OutputFile "obfuscated.ps1" -Password "YourSecurePassword123!" -EncryptionLevel High

# Decrypt/deobfuscate a script
.\decrypt.ps1 -InputFile "obfuscated.ps1" -OutputFile "decrypted.ps1"

# Decrypt password-protected script
.\decrypt.ps1 -InputFile "obfuscated.ps1" -OutputFile "decrypted.ps1" -Password "YourSecurePassword123!"

# Extract and decrypt ZIP archive
.\decrypt.ps1 -InputFile "obfuscated.zip" -OutputPath "C:\Extracted\" -Password "YourSecurePassword123!"
```

## Encryption Details

### AES-256 Encryption
- **Algorithm**: Advanced Encryption Standard with 256-bit keys
- **Mode**: CBC (Cipher Block Chaining) with random IV
- **Key Derivation**: PBKDF2 with SHA-256 (10,000 iterations)
- **Salt**: Cryptographically secure random 32-byte salt per file

### Password Requirements
- **Minimum Length**: 8 characters
- **Recommended**: 12+ characters with mixed case, numbers, symbols
- **Storage**: Passwords are never stored - only used for key derivation
- **Security**: Uses secure string handling to minimize memory exposure

### Security Features
- **Random IV** generated for each encryption operation
- **Unique salt** per encrypted file prevents rainbow table attacks
- **Base64 encoding** for safe text representation of binary data
- **Memory clearing** of sensitive data after use

### ZIP Compression
- **Algorithm**: Deflate compression for optimal size reduction
- **Encryption**: ZIP contents are encrypted before compression
- **Format**: Standard ZIP archive format with encrypted entries
- **Metadata**: File names and paths are obfuscated within archive
- **Integrity**: CRC32 checksums for data validation
- **Performance**: Up to 70% size reduction for text-based scripts

## Security Notice

⚠️ **PRIVATE REPOSITORY** - These tools are for authorized security research and testing only.

- Do not share outside authorized personnel
- Use only on systems you own or have explicit permission to test
- Follow all applicable laws and regulations
- Maintain confidentiality of obfuscated code

## Development Notes

- Compatible with PowerShell 5.1 and PowerShell 7+
- Designed for Windows environments
- Regularly updated for latest obfuscation techniques
- **Cryptographic libraries**: Uses .NET System.Security.Cryptography
- **Performance**: Optimized for files up to 10MB
- **Compatibility**: Generated scripts work on target systems without additional dependencies

## Best Practices

### Password Security
- Use unique, strong passwords for each obfuscated script
- Store passwords securely (password managers recommended)
- Never hard-code passwords in other scripts
- Consider using environment variables for automation

### Operational Security
- Test decryption before deployment
- Keep backup copies of original scripts
- Use appropriate encryption level for sensitivity level
- Monitor for unauthorized access attempts

---
*Last updated: February 2026*
