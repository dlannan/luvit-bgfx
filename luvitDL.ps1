$LUVI_VERSION = "2.7.6"
$LIT_VERSION = "3.5.2"

if (test-path env:LUVI_ARCH) {
  $LUVI_ARCH = $env:LUVI_ARCH
} else {
  $LUVI_ARCH = "Windows-amd64"
}
$LUVI_URL = "https://github.com/luvit/luvi/releases/download/v$LUVI_VERSION/luvi-regular-$LUVI_ARCH.exe"
$LIT_URL = "https://lit.luvit.io/packages/luvit/lit/v$LIT_VERSION.zip"

function Download-File {
param (
  [string]$url,
  [string]$file
 )
  Write-Host "Downloading $url to $file"
  $downloader = new-object System.Net.WebClient
  $downloader.Proxy.Credentials=[System.Net.CredentialCache]::DefaultNetworkCredentials;
  $downloader.DownloadFile($url, $file)
}

# Download Files
Download-File $LUVI_URL "luvi.exe"
Download-File $LIT_URL "lit.zip"

# Create lit.exe using lit
Start-Process "luvi.exe" -ArgumentList "lit.zip -- make lit.zip lit.exe luvi.exe" -Wait -NoNewWindow
# Cleanup
Remove-Item "lit.zip"
# Create luvit using lit
Start-Process "lit.exe" -ArgumentList "make lit://luvit/luvit luvit.exe luvi.exe" -Wait -NoNewWindow