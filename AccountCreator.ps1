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
        <#Random password generator#>
        $PlainTextPassword= -Join (@('0'..'9';'A'..'Z';'a'..'z';'@';'!';'#';'&') | Get-Random -Count $PasswordLength)
        $Password=ConvertTo-SecureString -String $PlainTextPassword -AsPlainText -Force
       
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

        <#Show every user parameter except password#>
        Write-Output $ADUserParams
        
        <#If it have expiration date create user with it#>
        if($Date){
            New-ADUser @ADUserParams -AccountExpirationDate $Date
        }else{
            New-ADUser @ADUserParams
        }
        
        <#Shows user password + basic params#>
        Write-Output "User create for $FirstName $LastName with the username: $UserName and password: $PlainTextPassword"
    }
    catch {
        Write-Error $_.Exception.Message
    }
}

<#Create the user#>
New-OneOffADUser -FirstName "TestFirstName2" -LastName "TestLastName2" -UserName "TestUser2" -Reason "Test2" -Server "wservertest.local" -ExpirationDate "2024-5-31"