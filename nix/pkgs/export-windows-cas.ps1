$ErrorActionPreference = 'Stop'
$now = Get-Date
$blocked = @{}
$certificates = @{}

foreach ($location in @('CurrentUser', 'LocalMachine')) {
    foreach ($name in @('Disallowed', 'Root', 'CA')) {
        $store = [System.Security.Cryptography.X509Certificates.X509Store]::new($name, $location)
        try {
            $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
            foreach ($cert in $store.Certificates) {
                if ($name -eq 'Disallowed') {
                    $blocked[$cert.Thumbprint] = $true
                    continue
                }
                $constraints = $cert.Extensions |
                    Where-Object { $_.Oid.Value -eq '2.5.29.19' } |
                    Select-Object -First 1
                if ($null -eq $constraints -or -not $constraints.CertificateAuthority) { continue }
                if ($cert.NotBefore -gt $now -or $cert.NotAfter -le $now) { continue }
                $certificates[$cert.Thumbprint] = $cert.RawData
            }
        }
        finally {
            $store.Close()
        }
    }
}

$count = 0
foreach ($thumbprint in ($certificates.Keys | Sort-Object)) {
    if ($blocked.ContainsKey($thumbprint)) { continue }
    [Console]::Out.WriteLine('-----BEGIN CERTIFICATE-----')
    [Console]::Out.WriteLine([Convert]::ToBase64String(
        $certificates[$thumbprint], [Base64FormattingOptions]::InsertLineBreaks))
    [Console]::Out.WriteLine('-----END CERTIFICATE-----')
    $count++
}
if ($count -eq 0) { throw 'No valid Windows CA certificates found.' }
[Console]::Error.WriteLine("Exported $count public CA certificates (no private keys).")
