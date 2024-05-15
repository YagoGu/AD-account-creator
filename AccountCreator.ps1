function New-OneOffADUser{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$FirstName,
        [Parameter(Mandatory)]
        [string]$LastName,
        [Parameter(Mandatory)]
        [string]$UserName,
        [Parameter(Mandatory)]
        [string]$Reason,
        [Parameter(Mandatory)]
        [string]$Server,
        [Parameter()]
        [datetime]$ExpirationDate,
        [Parameter()]
        [int]$PasswordLength=15
    )

    <#Checks if expiration date is before current date#>
    try {
        if($ExpirationDate){
            $Date=Get-Date -Date $ExpirationDate
        }

        $PlainTextPassword= -Join (@('0'..'9';'A'..'Z';'a'..'z';'@';'!';'#';'&') | Get-Random -Count $PasswordLength)
        $Password=ConvertTo-SecureString -String $PlainTextPassword -AsPlainText -Force
        
        Write-Output $Password

       
        $ADUserParams=@{
            Name=$UserName
            GivenName=$FirstName
            SurName=$LastName
            SamAccountName=$UserName
            UserPrincipalName="$UserName@wservertest.local"
            Description=$Reason
            Title=$Reason
            Enabled=$true
            AccountPassword=$Password
            Server=$Server
        }

        <#Write-Output $ADUserParams#>
        <#Error is in here#>
        if($Date){
            New-ADUser @ADUserParams -AccountExpirationDate $Date
        }else{
            New-ADUser @ADUserParams
        }
        <##>

        Write-Output "User create for $FirstName $LastName with the username: $UserName and password: $PlainTextPassword"
    }
    catch {
        Write-Error $_.Exception.Message
    }
}

<#Create the user#>
New-OneOffADUser -FirstName "Yago" -LastName "Gutierrez" -UserName "yagouser" -Reason "Test" -Server "wservertest.local" -ExpirationDate "2024-5-31"