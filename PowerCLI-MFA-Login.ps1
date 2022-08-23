### Power-CLI-MFA-Login.ps1
### Author: Bill Hill - VMware (TAM Services)
### Description: Used as part of TAM Lab 113 (https://www.youtube.com/watch?v=lsY4tyGq3D4&ab_channel=VMwareTAMLab)
### Disclaimer: This script is not an official product of VMware. Use at your own risk.
### Customization Requirements: 
###   Replace <ADFS_SERVER_FQDN> with the FQDN of your ADFS server
###   Replace <POWERCLI_MFA_NATIVE_APPLICATION_ID> with the application ID you created in ADFS for PowerCLI usage. See 3:26 of TAM Lab 113 - Part 4
###   Replace <VSPHERE_MFA_APPLICATION_ID> with the vSphere client ID created in ADFS. See 4:23 of TAM Lab 113 - Part 4
###   Replace <VCENTER_SERVER_FQDN> with the FQDN of your vCenter server
###   This script assumes that tcp/8844 on localhost is not in use and is not being blocked by a firewall. If this is an issue, be sure to replace the RedirectUrl localhost port to a port that is available on localhost and is allowed through local firewalls. 

### Resources used to create this script
### * https://developer.vmware.com/docs/powercli/latest/vmware.vimautomation.common/commands/new-oauthsecuritycontext/#AuthorizationCode
### * PowerCLI - get-help new-oauthsecuritycontext -examples
### * PowerCLI - get-help new-visamlsecuritycontext -examples
### * http://www.projecthamel.com/2021/10/15/vcenter-7-0-with-adfs-idp-connecting-with-powercli/



### Create OAuthSecurityContext - This will redirect to MFA provider as configured in ADFS
Write-Host "Creating OAuth Security context - Connecting to ADFS and MFA"
$OAuthContext = New-OAuthSecurityContext `
-AuthorizationEndpointUrl "https://<ADFS_SERVER_FQDN>/adfs/oauth2/authorize/" `
-TokenEndpointUrl "https://<ADFS_SERVER_FQDN>/adfs/oauth2/token/" `
-RedirectUrl "http://localhost:8844/auth" `
-ClientId "<POWERCLI_MFA_NATIVE_APPLICATION_ID>" `
-OtherArguments @{ "resource" = "<VSPHERE_MFA_APPLICATION_ID>" }


### Create SAML Security Context that can be used to authenticate against vCenter
Write-Host "Creating SAML Security Context to authenticate against vCenter"
$SamlContext = New-VISamlSecurityContext `
-VCenterServer <VCENTER_SERVER_FQDN> `
-OAuthSecurityContext $OAuthContext `
-IgnoreSslValidationErrors

### Login to vCenter and capture as an object
Write-Host "Logging into vCenter"
$vCenterConnection = Connect-VIServer `
-Server "<VCENTER_SERVER_FQDN>" `
-SamlSecurityContext $SamlContext

Write-Host "vCenter Server connection: " $vCenterConnection.Name

$SamlContext | get-member
