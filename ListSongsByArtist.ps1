# Variables
$Artist = "Ozric Tentacles"

# Constants
$ClientId = "6c0ccee4314e43358a559c9027f88cb7"
$ClientSecret = "dc716980faf14139975e81ea34d7041c"
$RedirectUrl = "http://www.google.com/"
$SpotifyApiUrl = "https://api.spotify.com/v1/"
$AccessToken = "BQAk77P5XbGW5isukMRwmxci7E5h6chMT_93TRr61g2s0g-dfO3htoCOx4jd-1JXKnOVaEl8QbonTr89Pp7Mel2wy4u7reTrSTt-PE40Ge_bWk7U7e-AaizVq9n2C2fYUNSeQ-FHI_BblZ8kC19lJvs9_M6OK-SiwoxhtbbixIP5lIJVFzTDjtRUhQ418ofDNPQj99RMYda1R6bbcHJvRwr_vycBsv5bVV28Sx_bRB61pw"

# Headers used in all requests (except renewing access token)
$Headers = @{}
$Headers.Add("Authorization", "Bearer " + $AccessToken)
$Headers.Add("Accept", "application/json")
$Headers.Add("Content-Type", "application/json")

# Renew access token if expired
try
{
    Invoke-WebRequest -Method Get -Uri ($SpotifyApiUrl + "me") -Headers $Headers
}
catch
{
    "Access token expired.  Renewing..."
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($ClientId + ":" + $ClientSecret)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $RenewHeaders = @{}
    $RenewHeaders.Add("Authorization", "Basic " + $base64)

    try
    {
        Invoke-WebRequest -Method Post -Uri ("https://accounts.spotify.com/api/token?grant_type=refresh_token&refresh_token=" + $AccessToken) -Headers $RenewHeaders
    }
    catch
    {
        "New token required."

        $AccessRequestUri = `            "https://accounts.spotify.com/authorize?" + `            "client_id=" + $ClientId + `            "&response_type=token" + `            "&redirect_uri=" + [uri]::EscapeDataString($RedirectUrl) + `
            "&scope=" + [uri]::EscapeUriString("user-library-read playlist-read-collaborative playlist-modify-public playlist-read-private playlist-modify-private") + `
            "&show_dialog=false"

        "Access Request Uri: " + $AccessRequestUri
        # open browser window to login        Add-Type -AssemblyName System.Windows.Forms
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
        $Form.ShowDialog()        "Browser URL: " + $Browser.url        "Browser URL fragment: " + $Browser.url.Fragment        If ($Browser.url.Fragment -match "access_token=(.*)&token") {$AccessToken = $Matches[1]}
        "Access Token: " + $AccessToken

        # try authenticating again
        Invoke-WebRequest -Method Get -Uri ($SpotifyApiUrl + "me") -Headers $Headers
    }
}


# Start by getting a count of all saved tracks for looping
$CurrentUserTracksEndpoint = "me/tracks"
$LimitSuffix = "?limit=50"
$OffsetSuffix = "&offset="
$Offset = 0
$TrackListJson = @()

$TrackList = `
    Invoke-WebRequest `
    -Method Get `
    -Uri ($SpotifyApiUrl + $CurrentUserTracksEndpoint + $LimitSuffix + $OffsetSuffix + $Offset) `
    -Headers $Headers

$TrackListJson += $TrackList.Content | ConvertFrom-Json
$TrackCount = $TrackListJson.total

# Go fetch all saved tracks
While ($Offset -le $TrackCount)
{
    $Offset = $Offset + 50
    "Offset: " + $Offset

    $TrackList = `
    Invoke-WebRequest `
    -Method Get `
    -Uri ($SpotifyApiUrl + $CurrentUserTracksEndpoint + $LimitSuffix + $OffsetSuffix + $Offset) `
    -Headers $Headers

    $TrackListJson += $TrackList.Content | ConvertFrom-Json

    Continue
}

$AllTracks =
$TrackListJson `
    | Select -expand items `
    | Select -expand track `
    | Select    id, `
                name, `
                @{Name = 'artists'; Expression = {$_.artists.name}}, `
                @{Name = 'album'; Expression = {$_.album.name}}

# Now filter tracks by artist
$AllTracks | Where-Object artists -EQ $Artist | Select-Object album, name | Sort-Object album, name
