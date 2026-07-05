#!/usr/bin/env bash
# build_seal.sh — Assemble a Provenance Seal (License §5A.3) as a canonical
# LTHING document: 4-space indent, tabs forbidden, double-quoted strings,
# CRLF line endings, deterministic (alphabetical) key ordering.
#
# Order of operations (non-circular):
#   1. build doc with every field except seal_id and signature
#   2. seal_id = SHAKE512(canonical bytes of doc w/o seal_id, w/o signature)
#   3. insert seal_id
#   4. signature = ML-DSA-65 sign(canonical bytes w/ seal_id, w/o signature)
#   5. insert signature + public key -> final document
#
# Requires: jq, and the Ada binaries shake512_file / sign_seal65 built per
#           README.md (SEAL_TOOLS_BIN defaults to ./bin next to this script).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEAL_TOOLS_BIN="${SEAL_TOOLS_BIN:-${SCRIPT_DIR}/bin}"

# ── Canonical LTHING renderer (jq filter) ────────────────────────────────
#
# Matches build_seal.py's canonical_render exactly: sorted keys, 4-space
# indent, double-quoted strings, CRLF conversion applied afterward.
JQ_CANONICAL='
def pad(n): if n <= 0 then "" else "    " + pad(n - 1) end;
def canonical(indent):
  if type == "object" then
    [ to_entries | sort_by(.key)[] |
      if   (.value | type) == "object" and (.value | length) > 0 then
        "\(pad(indent))\"\(.key)\":\n\(.value | canonical(indent + 1))"
      elif (.value | type) == "array"  and (.value | length) > 0 then
        "\(pad(indent))\"\(.key)\":\n\(.value | canonical(indent + 1))"
      elif (.value | type) == "object" and (.value | length) == 0 then
        "\(pad(indent))\"\(.key)\": {}"
      elif (.value | type) == "array"  and (.value | length) == 0 then
        "\(pad(indent))\"\(.key)\": []"
      elif (.value | type) == "boolean" then
        "\(pad(indent))\"\(.key)\": \(if .value then "true" else "false" end)"
      elif (.value | type) == "number" then
        "\(pad(indent))\"\(.key)\": \(.value)"
      else
        "\(pad(indent))\"\(.key)\": \"\(.value)\""
      end
    ] | join("\n")
  elif type == "array" then
    [ .[] |
      if type == "object" then
        "\(pad(indent))-\n\(. | canonical(indent + 1))"
      else
        "\(pad(indent))- \"\(.)\""
      end
    ] | join("\n")
  else
    empty
  end;
canonical(0)
'

# Render a JSON file as canonical LTHING text (LF line endings, no trailing LF).
canonical_render() {
    jq -rj "$JQ_CANONICAL" "$1"
}

# Convert LF→CRLF in-place on a byte stream (matching Python's
# text.replace("\n", "\r\n") — no trailing CRLF is added).
to_crlf() {
    awk '{if(NR>1) printf "\r\n"; printf "%s", $0}'
}

# ── Argument parsing ─────────────────────────────────────────────────────
FIELDS_JSON=""
OUT_FILE=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --fields-json) FIELDS_JSON="$2"; shift 2 ;;
        --out)         OUT_FILE="$2";    shift 2 ;;
        *)             echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

if [[ -z "$FIELDS_JSON" || -z "$OUT_FILE" ]]; then
    echo "Usage: build_seal.sh --fields-json <file> --out <file>" >&2
    exit 1
fi

for tool in jq "${SEAL_TOOLS_BIN}/shake512_file" "${SEAL_TOOLS_BIN}/sign_seal65"; do
    if ! command -v "$tool" &>/dev/null && [[ ! -x "$tool" ]]; then
        echo "Error: required tool not found: $tool" >&2
        exit 1
    fi
done

if jq -e 'has("seal_id") or has("signature")' "$FIELDS_JSON" >/dev/null 2>&1; then
    echo "Error: fields JSON must not contain seal_id or signature" >&2
    exit 1
fi

# ── Temporary workspace ──────────────────────────────────────────────────
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Step 2: seal_id = SHAKE512(canonical CRLF bytes without seal_id/signature)
canonical_render "$FIELDS_JSON" | to_crlf > "$TMPDIR/canon_no_id.bin"
SEAL_ID=$("${SEAL_TOOLS_BIN}/shake512_file" "$TMPDIR/canon_no_id.bin")

# Step 3: insert seal_id
jq --arg sid "$SEAL_ID" '. + {"seal_id": $sid}' "$FIELDS_JSON" \
    > "$TMPDIR/with_id.json"

# Step 4: sign canonical bytes with seal_id (without signature)
canonical_render "$TMPDIR/with_id.json" | to_crlf > "$TMPDIR/canon_with_id.bin"
SIGN_OUTPUT=$("${SEAL_TOOLS_BIN}/sign_seal65" "$TMPDIR/canon_with_id.bin")
PK=$(echo "$SIGN_OUTPUT" | head -1)
SIG=$(echo "$SIGN_OUTPUT" | tail -1)

# Step 5: insert signature + public key, render final document
jq --arg sig "$SIG" --arg pk "$PK" \
   '. + {"signature": $sig, "seal_signer_public_key": $pk}' \
   "$TMPDIR/with_id.json" > "$TMPDIR/final.json"

canonical_render "$TMPDIR/final.json" | to_crlf > "$OUT_FILE"

echo "seal_id=${SEAL_ID}"
echo "signer_public_key=${PK}"
echo "signature=${SIG}"
