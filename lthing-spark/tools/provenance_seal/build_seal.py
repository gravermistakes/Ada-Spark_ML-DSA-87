#!/usr/bin/env python3
"""
Assemble the Provenance Seal (License sec 5A.3) as a canonical LTHING
document: 4-space indent, tabs forbidden, double-quoted strings, CRLF line
endings, deterministic (alphabetical) key ordering.

Order of operations (non-circular):
  1. build doc with every field except seal_id and signature
  2. seal_id = SHAKE512(canonical bytes of doc w/o seal_id, w/o signature)
  3. insert seal_id
  4. signature = ML-DSA-65 sign(canonical bytes of doc w/ seal_id, w/o signature)
  5. insert signature -> final document
"""
import os
import sys
import subprocess
import json
import argparse

# Build shake512_file / sign_seal65 (this directory's .adb files) with:
#   gnatmake -q -D obj -aI. -o bin/shake512_file shake512_file.adb
#   gnatmake -q -D obj -aI. -o bin/sign_seal65 sign_seal65.adb
# then point SEAL_TOOLS_BIN at that bin/ dir (defaults to ./bin next to this script).
SEAL_TOOLS_BIN = os.environ.get(
    "SEAL_TOOLS_BIN", os.path.join(os.path.dirname(os.path.abspath(__file__)), "bin")
)


def canonical_render(obj, indent=0):
    """Render a dict/list/scalar as canonical LTHING (YAML-derivative) text:
    4 spaces/level, double-quoted strings, keys sorted, LF internally
    (converted to CRLF at the very end for the file written to disk)."""
    pad = "    " * indent
    lines = []
    if isinstance(obj, dict):
        for k in sorted(obj.keys()):
            v = obj[k]
            if isinstance(v, (dict, list)) and v not in ({}, []):
                lines.append(f'{pad}"{k}":')
                lines.append(canonical_render(v, indent + 1))
            elif v == {}:
                lines.append(f'{pad}"{k}": {{}}')
            elif v == []:
                lines.append(f'{pad}"{k}": []')
            elif isinstance(v, bool):
                lines.append(f'{pad}"{k}": {"true" if v else "false"}')
            elif isinstance(v, int):
                lines.append(f'{pad}"{k}": {v}')
            else:
                lines.append(f'{pad}"{k}": "{v}"')
    elif isinstance(obj, list):
        for item in obj:
            if isinstance(item, dict):
                lines.append(f'{pad}-')
                lines.append(canonical_render(item, indent + 1))
            else:
                lines.append(f'{pad}- "{item}"')
    return "\n".join(lines)


def to_crlf(text: str) -> bytes:
    return text.replace("\n", "\r\n").encode("utf-8")


def shake512_bytes(data: bytes) -> str:
    import tempfile, os
    with tempfile.NamedTemporaryFile(delete=False) as f:
        f.write(data)
        path = f.name
    try:
        out = subprocess.run([f"{SEAL_TOOLS_BIN}/shake512_file", path],
                              capture_output=True, text=True, check=True)
        return out.stdout.strip()
    finally:
        os.unlink(path)


def sign65_bytes(data: bytes):
    import tempfile, os
    with tempfile.NamedTemporaryFile(delete=False) as f:
        f.write(data)
        path = f.name
    try:
        out = subprocess.run([f"{SEAL_TOOLS_BIN}/sign_seal65", path],
                              capture_output=True, text=True, check=True)
        pk, sig = out.stdout.strip().split("\n")
        return pk, sig
    finally:
        os.unlink(path)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--fields-json", required=True,
                     help="JSON file with all seal fields except seal_id/signature")
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    with open(args.fields_json) as f:
        doc = json.load(f)

    assert "seal_id" not in doc and "signature" not in doc

    # Step 2: seal_id over canonical bytes without seal_id/signature
    canon_no_id = canonical_render(doc)
    seal_id = shake512_bytes(to_crlf(canon_no_id))
    doc["seal_id"] = seal_id

    # Step 4: signature over canonical bytes WITH seal_id, WITHOUT signature
    canon_with_id = canonical_render(doc)
    pk, sig = sign65_bytes(to_crlf(canon_with_id))
    doc["signature"] = sig
    # Non-normative (not in the sec 5A.3(a)-(j) required-field list, and NOT
    # covered by the signature bytes above -- the license spec does not
    # require the verifying public key to travel with the seal, but without
    # it the detached signature is unverifiable, so it is published here for
    # convenience). Fresh, ephemeral per-seal ML-DSA-65 keypair; the private
    # seed was never persisted or disclosed.
    doc["seal_signer_public_key"] = pk

    final_text = canonical_render(doc)
    with open(args.out, "wb") as f:
        f.write(to_crlf(final_text))

    print(f"seal_id={seal_id}")
    print(f"signer_public_key={pk}")
    print(f"signature={sig}")


if __name__ == "__main__":
    main()
