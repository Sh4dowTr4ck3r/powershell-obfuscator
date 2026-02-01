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

### `decrypt.ps1` 
- **Purpose**: Decrypts and deobfuscates protected PowerShell scripts
- **Features**:
  - Reverses obfuscation transformations
  - Decodes encrypted strings
  - Restores original variable names where possible

## Usage

```powershell
# Obfuscate a script
.\obfuscate.ps1 -InputFile "script.ps1" -OutputFile "obfuscated.ps1"

# Decrypt/deobfuscate a script  
.\decrypt.ps1 -InputFile "obfuscated.ps1" -OutputFile "decrypted.ps1"
```

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

---
*Last updated: February 2026*