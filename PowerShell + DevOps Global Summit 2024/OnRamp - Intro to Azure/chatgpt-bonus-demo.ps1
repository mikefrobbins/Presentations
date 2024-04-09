# Install the PowerShellAI module
Find-Module -Name PowerShellAI
# Install-Module -Name PowerShellAI
Find-PSResource -Name PowerShellAI
# Install-PSResource -Name PowerShellAI

# Ask ChatGPT for help with creating a new Azure Key Vault with Azure PowerShell
Get-GPT4Completion 'Create a new Azure Key Vault with Azure PowerShell'

# Show my blog article
Start-Process 'https://mikefrobbins.com/2023/10/12/securing-api-keys-with-powershell-secrets-management-in-azure-key-vault/'

# Retrieve my OpenAI API key from my Azure Key Vault
Set-OpenAIKey -Key (Get-Secret -Name OpenAIKey -Vault Area51)

# Ask ChatGPT for help with creating a new Azure Key Vault with Azure PowerShell
Get-GPT4Completion 'Create a new Azure Key Vault with Azure PowerShell'
