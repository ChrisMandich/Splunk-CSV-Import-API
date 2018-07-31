function Set-SplunkFieldExtract{
    <#
        .SYNOPSIS
            This function can be used to Set all Splunk Alias' defined on the Splunk Server
        .DESCRIPTION
            Performs a REST request with the HTTP Method of Get to the specified Splunk Server and returns the data for the defined server
        .PARAMETER Credential
            Specifies a user account that has permission to send the request. Type is a PSCredential Object
        .PARAMETER Uri
            URI in the form of https://sh.splunk.com:8089
        .PARAMETER SkipCertificateCheck
            Allows SkipCertificateCheck Certificates to be used
        .EXAMPLE
            Set-SplunkFieldAlias -Credential $creds -SplunkApp "search" -AliasHashTable @{test1="field1";} -AliasName "cim_v1" -Stanza "syslog"
        #>
        [CmdletBinding()]
        [OutputType([psobject])]
        param (
            [Parameter(Mandatory=$true,
                       ValueFromPipelineByPropertyName=$true,
                       Position=0)]
            [System.Management.Automation.PSCredential]$Credential,
            [Uri]$Uri = $Global:Uri,
            [Bool]$SkipCertificateCheck = $Global:SkipCertificateCheck,
            [String]$SplunkApp = $(Throw "Splunk App Not Defined"),
            [String]$Value = $(Throw "Extract string value is not defined"),
            [String]$Name = $(Throw "Extract Name is not defined"),
            [String]$Type = $(Throw "Extract Type is not defined"),
            [String]$Stanza = $(Throw "Stanza is not defined.")
        )
        Begin{
            # Provide Entrance Context
        }
        process {
            $Params = @{
                #Sets the HTTP Method to Delete, this requests deletes the data from the KVStore
                'Method' = "Post"
                # Add additional required Parameters
            }
            if ($SkipCertificateCheck -eq $true){
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
    
            if ($Uri){
                # Specified Splunk App
                # https://localhost:8089//servicesNS/admin/search/data/props/fieldaliases
                [Uri] $SplunkAppUri = [String]$Uri.AbsoluteUri + "servicesNS/admin/" + $SplunkApp + "/data/props/extractions" 
                $params.Add('Uri',$SplunkAppUri)
            }
            else{
                # Provide Error Output
                Write-Error "Error creating URI"
            }

            # The following code generates a data payload to be imported into Splunk. The data payload needs to include: Alias Name, Stanza and Alias'. 
            # The Data Payload is formatted in the following structure: "name=<AliasName>;stanza=<Stanza>;alias.test1=test2"
            If ($PSBoundParameters.ContainsKey('Name')){
                $data = "name=$Name;"
            }
            else{
                Write-Error -Message "Extract Name not provided"
            }
            If ($PSBoundParameters.ContainsKey('Stanza')){
                $data += "stanza=$Stanza;"
            }
            else{
                Write-Error -Message "Stanza not provided"
            }
            If ($PSBoundParameters.ContainsKey('Type')){
                $data += "type=$Type;"
            }
            else{
                Write-Error -Message "Extract Value not provided"
            }
            If ($PSBoundParameters.ContainsKey('Value')){
                $data += "value=$Value;"
                $params.Add('Body',$data)
            }
            else{
                Write-Error -Message "Extract Value not provided"
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