function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
         [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $Description = [String]::Empty,

        [System.Boolean]
        $Enabled = $true,

		[ValidateSet('RG','CG','ALL')]
        [System.String]
        $ResourceGroupType,

        [System.String]
        $ResourceGroupName,

		[Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserGroupNames,

		[ValidateSet('3389','*')]
        [System.String]
        $PortNumbers = '3389',

		[ValidateSet('RDP')]
        [System.String]
        $ProtocolNames = 'RDP',

		[ValidateSet('Present','Absent')]
		[System.String]
        $Ensure = 'Present'
    )

	Write-Verbose "Getting current CAP settings for `"$($Name)`""

	$returnValue = @{
		Name = [System.String]
		Description = [System.String]
		Enabled = [System.Boolean]
		ResourceGroupType = [System.String]
		ResourceGroupName = [System.String]
		UserGroupNames = [System.String]
		PortNumbers = [System.Boolean]
		ProtocolNames = [System.Boolean]
    }

	$Result = Get-RdsGwRap -Name $Name

	If ($Result){
		$returnValue.Name = $Name
		$returnValue.Description = $Result.Description
		$returnValue.Enabled = $Result.Enabled
		$returnValue.ResourceGroupType = $Result.ResourceGroupType
		$returnValue.ResourceGroupName = $Result.ResourceGroupName
		$returnValue.UserGroupNames = $Result.UserGroupNames
		$returnValue.PortNumbers = $Result.PortNumbers
		$returnValue.ProtocolNames = $Result.ProtocolNames
		$returnValue.Ensure = 'Present'
	}
	Else
	{
		$returnValue.Name = $Name
		$returnValue.Ensure = 'Absent'
	}

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $Description = [String]::Empty,

        [System.Boolean]
        $Enabled = $true,

		[ValidateSet('RG','CG','ALL')]
        [System.String]
        $ResourceGroupType,

        [System.String]
        $ResourceGroupName,

		[Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserGroupNames,

		[ValidateSet('3389','*')]
        [System.String]
        $PortNumbers = '3389',

		[ValidateSet('RDP')]
        [System.String]
        $ProtocolNames = 'RDP',

		[ValidateSet('Present','Absent')]
		[System.String]
        $Ensure = 'Present'
    )

	$RapArgs = @{
        Name = $Name
        Description = $Description
        Enabled = $Enabled
        ResourceGroupType = $ResourceGroupType
        ResourceGroupName = $ResourceGroupName
        UserGroupNames = $UserGroupNames
        ProtocolNames = $ProtocolNames
        PortNumbers = $PortNumbers
    }

	If ($Ensure -eq 'Present') {
		Write-Verbose "Creating RAP `"$($Name)`"."
        $Invoke = Invoke-CimMethod -Namespace root/CIMV2/TerminalServices -ClassName Win32_TSGatewayResourceAuthorizationPolicy -MethodName Create -Arguments $RapArgs
        if ($Invoke.ReturnValue -ne 0) {
            throw ('Failed creating RAP Policy. Returnvalue: {0}' -f $Invoke.ReturnValue)
		}
    }

	If ($Ensure -eq 'Absent') {
		Write-Verbose "Deleting CAP `"$($Name)`"."
		Get-RdsGwRap -Name $Name | Remove-RdsGwRap
	}
    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."

    #Include this line if the resource requires a system reboot.
    #$global:DSCMachineStatus = 1


}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $Description = [String]::Empty,

        [System.Boolean]
        $Enabled = $true,

		[ValidateSet('RG','CG','ALL')]
        [System.String]
        $ResourceGroupType,

        [System.String]
        $ResourceGroupName,

		[Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserGroupNames,

		[ValidateSet('3389','*')]
        [System.String]
        $PortNumbers = '3389',

		[ValidateSet('RDP')]
        [System.String]
        $ProtocolNames = 'RDP',

		[ValidateSet('Present','Absent')]
		[System.String]
        $Ensure = 'Present'
    )

	$currentValues = Get-TargetResource @PSBoundParameters
	$Result = [System.Boolean](
		($currentValues.Name -ieq $Name) -and `
		($currentValues.Ensure -ieq $Ensure)
	)
	
	If ($Result) {Write-Verbose "RAP settings for `"$($Name)`" in desired state"}
	Else {Write-Verbose "RAP settings for `"$($Name)`" NOT in desired state"}

	$Result
    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."


    <#
    $result = [System.Boolean]
    
    $result
    #>
}

function Get-RdsGwRap {
    [cmdletbinding(DefaultParameterSetName='list')]
    param (
        [Parameter(Mandatory, ParameterSetName='Named')]
        [ValidateNotNullOrEmpty()]
        [string] $Name
    )
    $QueryParams = @{
        Namespace = 'root/CIMV2/TerminalServices'
        ClassName = 'Win32_TSGatewayResourceAuthorizationPolicy'
    }
    if ($PSCmdlet.ParameterSetName -eq 'Named') {
        $QueryParams.Add('Filter',('Name = "{0}"' -f $Name))
    }
    Get-CimInstance @QueryParams
}

function Remove-RdsGwRap {
    [cmdletbinding(SupportsShouldProcess, ConfirmImpact='High')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $RdsGwRap
    )
    if ($PSCmdlet.ShouldProcess($RdsGwRap)) {
        $Invoke = $RdsGwRap | Invoke-CimMethod -MethodName Delete
        if ($Invoke.ReturnValue -ne 0) {
            throw ('Failed removing CAP Policy. Returnvalue: {0}' -f $Invoke.ReturnValue)
        }
    }
}

Export-ModuleMember -Function *-TargetResource

