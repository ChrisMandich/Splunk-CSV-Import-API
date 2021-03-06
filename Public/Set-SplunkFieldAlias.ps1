function Set-SplunkFieldAlias{
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
            Set-SplunkFieldAlias -Credential $creds -SplunkApp "search" -Value @{test1="field1";} -Name "cim_v1" -Stanza "syslog"
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
            [hashtable]$Value = $(Throw "HashTable of Alias`' is not defined"),
            [String]$Name = $(Throw "Alias Name is not defined"),
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
                [Uri] $SplunkAppUri = [String]$Uri.AbsoluteUri + "servicesNS/admin/" + $SplunkApp + "/data/props/fieldaliases" 
                $params.Add('Uri',$SplunkAppUri)
            }
            else{
                # Provide Error Output
                Write-Error "Error creating URI"
            }

            # The following code generates a data payload to be imported into Splunk. The data payload needs to include: Alias Name, Stanza and Alias'. 
            # The Data Payload is formatted in the following structure: "name=<Name>;stanza=<Stanza>;alias.test1=test2"
            If ($PSBoundParameters.ContainsKey('Name')){
                $data = "name=$Name;"
            }
            else{
                Write-Error -Message "Alias Name not provided"
            }
            If ($PSBoundParameters.ContainsKey('Stanza')){
                $data += "stanza=$Stanza;"
            }
            else{
                Write-Error -Message "Stanza not provided"
            }
            If ($PSBoundParameters.ContainsKey('Value')){
                foreach ($h in $Value.Keys){
                    $data += "alias.$($Value.item($h))=$h;"
                }
                $params.Add('Body',$data)
            }
            else{
                Write-Error -Message "Alias Hashtable not provided"
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