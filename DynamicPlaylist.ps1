$AccessRequestHeaders = @{}
$AccessRequestHeaders.Add("client_id", "6c0ccee4314e43358a559c9027f88cb7")$AccessRequestHeaders.Add("response_type", "code")$AccessToken = `    Invoke-WebRequest `    -Method Get `
    -Uri "https://accounts.spotify.com/authorize" `
    -Headers $AccessRequestHeaders

$AccessToken


$Token = "BQBqSUFivCcEOSXDy3aPp16oXt8H1ly7mG2C1VX_LhSyySm0u8NC9-Vgd9G6yrSpKE0_jRTGeQ-WuJYKiA_Elfzog7XZtlCA6ZEVoTqcN7znOJzD0RBdLb5hB4-D0-3ePllnyrT4GjpHNHOhZSkIfo_D2yaNXkdgA-QI5Q"

$SpotifyApiUrl = "https://api.spotify.com/v1/"
$CurrentUserTracksEndpoint = "me/tracks"

$Headers = @{}
$Headers.Add("Authorization", "Bearer " + $Token)
$Headers.Add("Accept", "application/json")
$Headers.Add("Content-Type", "application/json")

$TrackList = `
    Invoke-WebRequest `
    -Method Get `
    -Uri ($SpotifyApiUrl + $CurrentUserTracksEndpoint) `
    -Headers $Headers

$TrackList.Content
