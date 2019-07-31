Remove-Item "C:\Program Files (x86)\Spotify\Update" -Recurse
Move-Item -Path "C:\Users\thurstja\AppData\Local\Spotify\Update" -Destination "C:\Program Files (x86)\Spotify"
(Get-Content "C:\Program Files (x86)\Spotify\Update\update.json").Replace("C:\\Users\\thurstja\\AppData\\Local\\Spotify", "C:\\Program Files (x86)\\Spotify") | Set-Content "C:\Program Files (x86)\Spotify\Update\update.json"
