### Auto-generate genre-based playlists in Spotify ###
### For tips see https://www.pdq.com/blog/create-a-hipster-playlist-using-powershell/ ###

# Choose a genre
$PlaylistGenre = "Classical"

# Set up some constants
$ClientId = "6c0ccee4314e43358a559c9027f88cb7"
$ClientSecret = "dc716980faf14139975e81ea34d7041"
$RedirectUrl = "http://www.google.com/"

# Get auth from Spotify
$AccessRequestUri = `    "https://accounts.spotify.com/authorize?" + `    "client_id=" + $ClientId + `    "&response_type=token" + `    "&redirect_uri=$RedirectUrl" + `
    "&scope=user-library-read playlist-read-public playlist-modify-public playlist-read-private playlist-modify-private" + `
    "&show_dialog=false"

# "Access Request Uri: " + $AccessRequestUri# open browser window to loginAdd-Type -AssemblyName System.Windows.Forms
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
# "Access Token: " + $AccessToken
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
