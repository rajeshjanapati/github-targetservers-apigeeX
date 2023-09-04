# write-output Apigee Artifacts
$token = $env:TOKEN
$org = $env:ORG
# $baseURL = "https://apigee.googleapis.com/v1/organizations/"
# $headers = @{Authorization = "Bearer $token"}

# Set your GitHub repository information
$repositoryOwner = "rajeshjanapati@gmail.com"
$repositoryName = "github-kvm-apigeex"
$branchName = "main"

# Clone the repository
git clone https://github.com/rajeshjanapati/github-kvm-apigeex.git
cd $repositoryName
cd kvms

# Read JSON files
$jsonFiles = Get-ChildItem -Filter *.json -Recurse

# Loop through each JSON file and make POST requests
foreach ($jsonFile in $jsonFiles) {
    $jsonContent = Get-Content -Path $jsonFile -Raw
    # Parse the JSON content
    $jsonData = ConvertFrom-Json $jsonContent

    # Extract the value of the "name" key from the JSON data
    $kvmName = $jsonData.name

    # Print the extracted value
    # Write-Host "KVM Name: $kvmName"

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $token")
    $headers.Add("Content-Type", "application/json")


    $kvmget = Invoke-RestMethod 'https://apigee.googleapis.com/v1/organizations/esi-apigee-x-394004/environments/eval/keyvaluemaps' -Method 'GET' -Headers $headers
    $kvmget | ConvertTo-Json
    # Write-Host $kvmget

    $url = "https://apigee.googleapis.com/v1/organizations/esi-apigee-x-394004/environments/eval/keyvaluemaps/$kvmName/entries"

    $kvmgetentries = Invoke-RestMethod -Uri $url -Method 'GET' -Headers $headers
    $kvmgetentriesvalues = $kvmgetentries | ConvertTo-Json
    # Write-Host $kvmgetentriesvalues
    
    
    # # Output the KVM entries for debugging
    $kvmgetentriesvalues | Format-Table

    # Your array
    $array = $kvmget
    
    foreach ($valueToCheck in $array) {
        if ($array -contains $valueToCheck) {
            Write-Host "$valueToCheck is present in the array."
            $entries = $jsonData.entry
            Write-Host "Values: $vlaues"
        
            foreach ($entry in $entries) {
                Write-Host "step-2"
                $name = $entry.key
                $value = $entry.value
                Write-Host "Key: $name, Value: $value"
                $body2 = @{
                    "name" = $name;
                    "value" = $value;
                }
                Write-Host "body2: $body2"
                
                try {
                    
                    # Make the API request
                    $response = Invoke-RestMethod -Uri "https://apigee.googleapis.com/v1/organizations/esi-apigee-x-394004/environments/eval/keyvaluemaps/$kvmName/entries" -Method 'POST' -Headers $headers -Body ($body2 | ConvertTo-Json)
                
                    # Get and print the status code
                    $statuscode = $response.StatusCode
                    Write-Host "Status Code: $statuscode"
                } catch [System.Net.HttpStatusCode] {
                    # Handle the specific error (HTTP status code 409) gracefully
                    Write-Host "Conflict (409) error occurred, but the script will continue."
                } catch {
                    # Handle any other exceptions that may occur
                    Write-Host "An error occurred: $_"
                }

            }
        } else {
            $body1 =@{
                "name"=$kvmName;
                "encrypted"=true;
                }
            Write-Host $body1
            Write-Host "$valueToCheck is not present in the array."
            $kvmcreate = Invoke-RestMethod 'https://apigee.googleapis.com/v1/organizations/esi-apigee-x-394004/environments/eval/keyvaluemaps' -Method 'POST' -Headers $headers -Body ($body1|ConvertTo-Json)
            $kvmcreate | ConvertTo-Json
        }
    }
    
    }
