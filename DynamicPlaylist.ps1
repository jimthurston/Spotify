### Auto-generate genre-based playlists in Spotify ###
### For tips see https://www.pdq.com/blog/create-a-hipster-playlist-using-powershell/ ###

# Set up some constants
$ClientId = "6c0ccee4314e43358a559c9027f88cb7"
$ClientSecret = "dc716980faf14139975e81ea34d7041"

# Get auth from Spotify
$AccessRequestUri = `    "https://accounts.spotify.com/authorize?" + `    "client_id=" + $ClientId + `    "&response_type=token" + `    "&redirect_uri=//www.pdq.com/aa/img/jonathan-lindgren-hipster-220x247-lossy30.gif"

# $AccessRequestHeaders = @{}
# $AccessRequestHeaders.Add("client_id", $ClientId)# $AccessRequestHeaders.Add("response_type", "token")$AccessRequestUri# open browser window to loginAdd-Type -AssemblyName System.Windows.Forms
$FormProperties =
@{
    Size = New-Object System.Drawing.Size(850, 675)
    StartPosition = "CenterScreen"
}

$Form = New-Object System.Windows.Forms.Form -Property $FormProperties

$BrowserProperties =
@{
    Dock = "Fill"
}

$Browser = New-Object System.Windows.Forms.WebBrowser -Property $BrowserProperties
$Form.Controls.Add($Browser)
$Browser.Navigate($AccessRequestUri)
$Form.Add_Shown({$Form.Activate()})
$Form.ShowDialog()If ($Browser.url.Fragment -match "access_token=(.*)&token") {$AccessToken = $Matches[1]}
#$AccessToken = `#    Invoke-WebRequest `#    -Method Get `
#    -Uri $AccessRequestUri
  #  -Headers $AccessRequestHeaders

#$AccessToken.Content


#$Token = "BQBqSUFivCcEOSXDy3aPp16oXt8H1ly7mG2C1VX_LhSyySm0u8NC9-Vgd9G6yrSpKE0_jRTGeQ-WuJYKiA_Elfzog7XZtlCA6ZEVoTqcN7znOJzD0RBdLb5hB4-D0-3ePllnyrT4GjpHNHOhZSkIfo_D2yaNXkdgA-QI5Q"

$SpotifyApiUrl = "https://api.spotify.com/v1/"
$CurrentUserTracksEndpoint = "me/tracks"

$Headers = @{}
$Headers.Add("Authorization", "Bearer " + $AccessToken)
$Headers.Add("Accept", "application/json")
$Headers.Add("Content-Type", "application/json")

$TrackList = `
    Invoke-WebRequest `
    -Method Get `
    -Uri ($SpotifyApiUrl + $CurrentUserTracksEndpoint) `
    -Headers $Headers

$TrackList.Content
