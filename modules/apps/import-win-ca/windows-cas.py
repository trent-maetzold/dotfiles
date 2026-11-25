# /// script
# requires-python = ">=3.12"
# dependencies = []
# ///
"""Runs on Windows (via uv.exe): print the certificate stores as JSON lists of
base64 DER. Stdlib only, so uv needs no packages on the Windows side."""

import base64
import json
import ssl

print(
    json.dumps(
        {
            store: [
                base64.b64encode(der).decode()
                for der, _encoding, _trust in ssl.enum_certificates(store)
            ]
            for store in ("ROOT", "CA", "Disallowed")
        }
    )
)
