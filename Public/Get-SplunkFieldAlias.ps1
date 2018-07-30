function Get-SplunkFieldAlias{
<#
    .SYNOPSIS
        This function can be used to get all Splunk Alias' defined on the Splunk Server
    .DESCRIPTION
        Performs a REST request with the HTTP Method of Get to the specified Splunk Server and returns the data for the defined server
    .PARAMETER Credential
        Specifies a user account that has permission to send the request. Type is a PSCredential Object
    .PARAMETER Uri
        URI in the form of https://sh.splunk.com:8089
    .PARAMETER SkipCertificateCheck
        Allows SkipCertificateCheck Certificates to be used
    .EXAMPLE
        Get-SplunkFieldAlias -Credential $cred -Uri $uri -SkipCertificateCheck
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [System.Management.Automation.PSCredential]$Credential,
        [Uri]$Local:Uri = $Global:Uri,
        [Bool] $Local:SkipCertificateCheck = $Global:SkipCertificateCheck,
        [String]$SplunkApp = $(Throw "Splunk App Not Defined")
    )
    Begin{
        # Provide Entrance Context
    }
    process {
        $Params = @{
            #Sets the HTTP Method to Delete, this requests deletes the data from the KVStore
            'Method' = "Get"
            # Add additional required Parameters
        }
        if ($Local:SkipCertificateCheck -eq $true){
            # Works only on PS Core 6+
            $params.add('SkipCertificateCheck',$true)
        }

        if ($PSBoundParameters.ContainsKey('Credential')){
            $params.Add('Credential',$Credential)
        }
        else{
            # Provide Error Output
            Write-Error "Credential not provided"
        }

        if ($local:Uri){
            # Specified Splunk App
            # https://localhost:8089//servicesNS/admin/search/data/props/fieldaliases
            [Uri] $SplunkAppUri = [String]$Local:Uri.AbsoluteUri + "servicesNS/admin/" + $SplunkApp + "/data/props/fieldaliases"
            $params.Add('Uri',$SplunkAppUri)
        }
        else{
            # Provide Error Output
            Write-Error "Error creating URI"
        }

        # Invoke Rest Method
        try{
            Invoke-RestMethod @Params
        }
        catch{
            Write-Error "Failed to Invoke Restmethod"
        }
    }
    End{
        # Provide exit context
}
}