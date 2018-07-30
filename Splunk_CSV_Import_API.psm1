<#
Chris Mandich
version 0.0.1

X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X
X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X

CHANGELOG

20180730 -- Intial Creation

X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X
X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X

#>

# Check to see if the version of powershell is greater than 6.0. This is to support the SkipCertificateCheck for invoke-webrequest. 
if($PSVersionTable.PSVersion.Major -lt 6)
{
    $message = "The PS Version ($PSVersionTable.PSVersion.Major) is not supported. Try version PS Core 6+"
    Write-Error -Message $message
}

#Get public and private function definition files.
    $Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1)
    $Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
    $ModuleRoot = $PSScriptRoot
    $Global:config = Get-Content -Path $PSScriptRoot\Private\config.json | ConvertFrom-Json

# Setup Config / Global Variables
Try{
    [uri]$Global:uri = $config.uri
}
catch{
    [uri]$Global:uri = Read-Host -Prompt 'Input Splunk URI'
}
Try{
    [Bool]$Global:SkipCertificateCheck = [Bool]$config.SkipCertificateCheck
}
Catch{
    [Bool]$Global:SkipCertificateCheck = $false
}

#Output Configuration 
Write-Host "URI: $uri"
Write-Host "SkipCertificateCheck: $SkipCertificateCheck"

#Dot source the files
    Foreach($import in @($Public + $Private))
    {
        Try
        {
            . $import.fullname
        }
        Catch
        {
            Write-Error -Message "Failed to import function $($import.fullname): $_"
        }
    }

#Specify allowed functions for users.
Export-ModuleMember -Function $Public.Basename
