# Import the Active Directory module
Import-Module ActiveDirectory

# Define the root OU for Worldwide
$rootOU = "OU=Worldwide,DC=corp,DC=fittersnacker,DC=com"

# Step 1: Create Organizational Units (OUs)
Write-Host "Creating Organizational Units..."
New-ADOrganizationalUnit -Name "Worldwide" -Path "DC=corp,DC=fittersnacker,DC=com" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "North America" -Path $rootOU
New-ADOrganizationalUnit -Name "Canada" -Path "OU=North America,$rootOU"
New-ADOrganizationalUnit -Name "BC" -Path "OU=Canada,OU=North America,$rootOU"

# Sub-OUs for Richmond and Vancouver
New-ADOrganizationalUnit -Name "Richmond" -Path "OU=BC,OU=Canada,OU=North America,$rootOU"
New-ADOrganizationalUnit -Name "Vancouver" -Path "OU=BC,OU=Canada,OU=North America,$rootOU"

# Create Functional Groups
New-ADOrganizationalUnit -Name "IT" -Path "OU=Richmond,OU=BC,OU=Canada,OU=North America,$rootOU"
New-ADOrganizationalUnit -Name "SCM" -Path "OU=Richmond,OU=BC,OU=Canada,OU=North America,$rootOU"
New-ADOrganizationalUnit -Name "AF" -Path "OU=Vancouver,OU=BC,OU=Canada,OU=North America,$rootOU"
New-ADOrganizationalUnit -Name "HR" -Path "OU=Vancouver,OU=BC,OU=Canada,OU=North America,$rootOU"

Write-Host "Organizational Units created successfully."

# Step 2: Create Users in IT OU
Write-Host "Creating IT Users..."
$ITUsers = @(
    @{FirstName="Billy"; LastName="Kidd"; Title="Sr. Manager IT";},
    @{FirstName="Monty"; LastName="Ham"; Title="IT Specialist";},
    @{FirstName="Nancy"; LastName="Keys"; Title="IT Support";},
    @{FirstName="Benny"; LastName="Stairs"; Title="IT Administrator";}
)

foreach ($user in $ITUsers) {
    $name = "$($user.FirstName) $($user.LastName)"
    New-ADUser `
        -Name $name `
        -GivenName $user.FirstName `
        -Surname $user.LastName `
        -Title $user.Title `
        -SamAccountName "$($user.FirstName).$($user.LastName)" `
        -UserPrincipalName "$($user.FirstName).$($user.LastName)@corp.fittersnacker.com" `
        -Path "OU=IT,OU=Richmond,OU=BC,OU=Canada,OU=North America,$rootOU" `
        -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) `
        -Enabled $true
}

Write-Host "IT Users created successfully."

# Step 3: Create Security Groups
Write-Host "Creating Security Groups..."
New-ADGroup -Name "fs_IT" -GroupScope Global -Path "OU=IT,OU=Richmond,OU=BC,OU=Canada,OU=North America,$rootOU"
New-ADGroup -Name "fs_Executive" -GroupScope Global -Path "OU=Vancouver,OU=BC,OU=Canada,OU=North America,$rootOU"

# Add Users to Groups
Write-Host "Adding Users to Security Groups..."
Add-ADGroupMember -Identity "fs_IT" -Members "Billy.Kidd", "Monty.Ham", "Nancy.Keys", "Benny.Stairs"
Add-ADGroupMember -Identity "fs_Executive" -Members "Billy.Kidd"

Write-Host "Script Execution Completed Successfully."
