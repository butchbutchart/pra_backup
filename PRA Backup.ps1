#region Define Variables
$tokenUrl = "https://[yourURL]/oauth2/token"
$baseUrl = "https://[yourURL]/api" #note the backup api URL is different to config API URL
$client_id = "--"   # Replace with your actual client ID
$secret = "--"         # Replace with your actual secret
$backupUrl = "$baseUrl/backup"  # Assuming this is the endpoint to initiate the backup
$downloadUrl = "$baseUrl/backup/download" # Placeholder URL for downloading the backup file
$backupFolder = "C:\PRA Backups"  # Replace with the path where you want to save the backup
#endregion


#region Authenticate
# Create a client_id:secret pair
$credPair = "$($client_id):$($secret)"
# Encode the pair to Base64 string
$encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($credPair))
# Form the header and add the Authorization attribute to it
$headersCred = @{ Authorization = "Basic $encodedCredentials" }
# Make the request and get the token
$responsetoken = Invoke-RestMethod -Uri "$tokenUrl" -Method Post -Body "grant_type=client_credentials" -Headers $headersCred
$token = $responsetoken.access_token
# Prepare the header for future requests
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Accept", "application/json")
$headers.Add("Authorization", "Bearer $token")
#endregion

#region Request and Download Backup
# Construct the backup file path without an extension
$backupFileName = "backup_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".nsb"
$backupFilePath = Join-Path -Path $backupFolder -ChildPath $backupFileName

# Initiate the backup request and download the file
Invoke-WebRequest -Uri $backupUrl -Method Get -Headers $headers -OutFile $backupFilePath

# Check if the backup file was downloaded successfully
if (Test-Path -Path $backupFilePath) {
    Write-Output "Backup completed successfully. File saved to: $backupFilePath"
} else {
    Write-Output "Backup request did not return a valid file."
}
#endregion