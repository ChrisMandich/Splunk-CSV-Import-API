function Set-SplunkKOConfig{
        <#
        .SYNOPSIS
            This function can be used to Set Splunk Knowledge Objects based on there definitions in an imported CSV. 
        .PARAMETER Credential
            Specifies a user account that has permission to send the request. Type is a PSCredential Object
        .PARAMETER Uri
            URI in the form of https://sh.splunk.com:8089
        .PARAMETER SkipCertificateCheck
            Allows SkipCertificateCheck Certificates to be used
        .PARAMETER Path
            Specify the Path to the CSV being imported. 
        .EXAMPLE
            Set-SplunkKOConfig -Path $path -Credential $creds
        #>
        [CmdletBinding()]
        [OutputType([psobject])]
        param (
            [Parameter(Mandatory=$true,
                       ValueFromPipelineByPropertyName=$true,
                       Position=0)]
            [System.Management.Automation.PSCredential]$Credential,
            [Uri]$Uri = $Global:Uri,
            [Bool] $SkipCertificateCheck = $Global:SkipCertificateCheck,
            [String] $Path = $(Throw "Path not provided")
        )
        try{
            $content = Import-Csv $Path
        }
        catch{
            #TODO
        }

        # Set Alias' based on those defined in the CSV. 
        $content | Where-Object type -eq "alias" | Group-Object name, Stanza, splunkapp | ForEach-Object {
            $hash = @{}
            $_.Group | ForEach-Object {
                $hash.Add($_.aliasname, $_.aliasvalue) 
                $splunkapp =  $_.SplunkApp
                $name = $_.name
                $Stanza = $_.Stanza
            }
            Set-SplunkFieldAlias -Credential $Credential -Uri $Uri.AbsoluteUri -Name $name -Value $hash -Stanza $Stanza -SplunkApp $splunkapp -SkipCertificateCheck $SkipCertificateCheck
        }

        $content | Where-Object type -eq "eval" | ForEach-Object {
            Set-SplunkFieldEval -Credential $Credential -Uri $Uri.AbsoluteUri -SkipCertificateCheck $SkipCertificateCheck -SplunkApp $_.splunkapp -name $_.name -Value "$($_.evalvalue)" -Stanza "$($_.Stanza)"
        }

        $content | Where-Object type -eq "extract" | ForEach-Object {
            Set-SplunkFieldExtract -Name $_.name -Stanza $_.Stanza -SplunkApp $_.splunkapp -Type $_.extracttype -Value $_.extractvalue -Credential $Credential -SkipCertificateCheck $SkipCertificateCheck -Uri $Uri.AbsoluteUri
        }
}