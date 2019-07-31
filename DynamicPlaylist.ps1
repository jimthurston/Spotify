﻿### Auto-generate genre-based playlists in Spotify ###
### For tips see https://www.pdq.com/blog/create-a-hipster-playlist-using-powershell/ ###

# Variables
$Mode = "Fresh"
$PlaylistGenre = "Classical"
$TrackCount = 10

# Constants
$ClientId = "6c0ccee4314e43358a559c9027f88cb7"
$ClientSecret = "dc716980faf14139975e81ea34d7041c"
$RedirectUrl = "http://www.google.com/"
$SpotifyApiUrl = "https://api.spotify.com/v1/"
$AccessToken = "BQCf0uWvqD0Nxb350XWSL1JIxSe4UY64SVopNivKQmSSk7fT-zfnfY0ipbEyDNjx6byoRAYM0Jpq2sgKx3f5hFPyPbS51GNWBqTwWswL-mf9nNGvEmQQBcm0HrsOzE9Idp9qP27gKjZpjfkxOU0d1MSQSHOoxo-rXmSsZ0kPbwmibQsIApSPojOGsc0SoWPLskr5U67DPuq62Blk9zB6HUjT8MiMOJFlkH4NyC__2HWRAA"

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
        $Form.ShowDialog()        If ($Browser.url.Fragment -match "access_token=(.*)&token") {$AccessToken = $Matches[1]}
        "Access Token: " + $AccessToken

        # try authenticating again
        Invoke-WebRequest -Method Get -Uri ($SpotifyApiUrl + "me") -Headers $Headers
    }
}


# Genre Playlist
If ($Mode -eq "Genre")
{
    $CurrentUserTracksEndpoint = "me/tracks"
    $AlbumEndpoint = "albums/"
    $LimitSuffix = "?limit=50"
    $OffsetSuffix = "&offset="
    $Offset = "0"

    $TrackList = `
        Invoke-WebRequest `
        -Method Get `
        -Uri ($SpotifyApiUrl + $CurrentUserTracksEndpoint + $LimitSuffix + $OffsetSuffix + $Offset) `
        -Headers $Headers

    $TrackListJson = $TrackList.Content | ConvertFrom-Json

    $TrackListJson `
        | Select -expand items `
        | Select -expand track `
        | Select    id, `
                    name, `
                    @{Name = 'artists'; Expression = {$_.artists.name}}, `
                    @{Name = 'album'; Expression = {$_.album.name}}

    #$TracksWithAlbums = `
    $TrackListJson `
        | Select -expand items `
        | Select -expand track `
        | Select -expand album `
        | Select id
    $AlbumId = "3rXXjwi61u1Sh3ax42T5SV"

    $AlbumExample = `
        Invoke-WebRequest `
        -Method Get `
        -Uri ($SpotifyApiUrl + $AlbumEndpoint + $AlbumId) `
        -Headers $Headers

    ($AlbumExample.Content | ConvertFrom-Json) | Select genres
}

# Freshen up Playlist
ElseIf ($Mode -eq "Fresh")
{
    
}
