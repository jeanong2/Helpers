
# Initialize 3-legged OAuth2 client
$FORGE_CLIENT_ID = ''  # Get from env or replace with your ID
$FORGE_CLIENT_SECRET = ''  # Get from env or replace with your secret
$FORGE_CALLBACK_URL = 'http://localhost:5000/callback'
$scopes = 'data:read data:write'

# Define the OAuth 2.0 authorization URL
$authorizationUrl = "https://developer.api.autodesk.com/authentication/v1/authorize?"
$authorizationUrl += "response_type=code"
$authorizationUrl += "&client_id=$FORGE_CLIENT_ID"
$authorizationUrl += "&redirect_uri=http://localhost:5000/callback"
#$([System.Web.HttpUtility]::UrlEncode($FORGE_CALLBACK_URL))
$authorizationUrl += "&scope=$([System.Web.HttpUtility]::UrlEncode($scopes))"

# Route /auth
# Redirect to Autodesk sign-in page for the end-user to log in
Start-Process $authorizationUrl

# Wait for the user to log in and get the authorization code
$authorizationCode = Read-Host "Enter the authorization code from the callback URL"

# Route /callback
# Get the access token from Autodesk
$tokenEndpoint = "https://developer.api.autodesk.com/authentication/v1/gettoken"
$tokenParams = @{
    client_id     = $FORGE_CLIENT_ID
    client_secret = $FORGE_CLIENT_SECRET
    grant_type    = "authorization_code"
    code          = $authorizationCode
    redirect_uri  = $FORGE_CALLBACK_URL
}
$tokenResponse = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -ContentType "application/x-www-form-urlencoded" -Body $tokenParams

# Check if the token request was successful
if ($tokenResponse.access_token) {
    # Success
    $access_token = $tokenResponse.access_token
    Write-Host "<p>Authentication success! Here is your token:</p> $access_token"
} else {
    # Failed
    Write-Host 'Failed to authenticate'
}
