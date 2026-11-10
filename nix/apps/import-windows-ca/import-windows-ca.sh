# import-windows-ca OUT: export the Windows Root/intermediate CAs (from WSL) to a PEM bundle.
out=${1:?usage: import-windows-ca OUT.pem}
ps=$(command -v powershell.exe || echo /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe)
dest=$(realpath -m -- "$out")
tmp=$(mktemp -- "$dest.XXXXXX")
trap 'rm -f -- "$tmp"' EXIT
"$ps" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass \
  -File "$(wslpath -w "$PS1_SCRIPT")" >"$tmp"
[[ -s $tmp ]] || {
  echo "Windows returned an empty CA bundle." >&2
  exit 1
}
mv -- "$tmp" "$dest"
echo "Saved Windows CA bundle to $dest" >&2
