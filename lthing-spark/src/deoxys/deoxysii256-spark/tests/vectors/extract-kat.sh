#!/usr/bin/env bash
# Mechanical extraction from the pinned deoxysii256v141 verbose KAT traces.
# Emits (1) a compact AEAD KAT file and (2) the raw Deoxys-BC-384 block-cipher
# calls (P1 single-block TBC vectors). Derivation is lossless reformatting of
# the pinned reference file — never edit outputs by hand; re-run this instead.
set -euo pipefail
SRC=deoxysii256v141-verbose-kat.txt

hexval () { # strip label, colon, spaces; "empty" -> ""
  local v="${1#*:}"; v="${v// /}"; [ "$v" = "empty" ] && v=""; printf '%s' "$v"
}

awk '
  /TEST VECTOR/ && !/END/ { n=$4 }
  /^Associated data/ { sub(/^[^:]*:/,""); gsub(/ /,""); ad=($0=="empty"?"":$0) }
  /^Message +\(/     { sub(/^[^:]*:/,""); gsub(/ /,""); msg=($0=="empty"?"":$0) }
  /^Key +\(/         { sub(/^[^:]*:/,""); gsub(/ /,""); key=$0 }
  /^Nonce +\(/       { sub(/^[^:]*:/,""); gsub(/ /,""); nonce=$0 }
  /^Ciphertext +\(/  { sub(/^[^:]*:/,""); gsub(/ /,""); ct=$0 }
  /^Tag +\(/         { sub(/^[^:]*:/,""); gsub(/ /,""); tag=$0
                       printf "COUNT = %d\nKEY = %s\nNONCE = %s\nAD = %s\nMSG = %s\nCT = %s\nTAG = %s\n\n",
                              n, key, nonce, ad, msg, ct, tag }
' "$SRC" > deoxysii256v141-aead-kat.txt

awk '
  /TEST VECTOR/ && !/END/ { n=$4 }
  /^Plaintext +:/            { sub(/^[^:]*:/,""); gsub(/ /,""); pt=$0 }
  /^Tweakey \(Key Tweak\)/   { sub(/^[^:]*:/,""); sub(/^ */,"");
                               split($0, w, " "); key=w[1]; tweak=w[2] }
  /^Ciphertext +:/           { sub(/^[^:]*:/,""); gsub(/ /,""); ct=$0
                               printf "VEC = %d\nKEY = %s\nTWEAK = %s\nPT = %s\nCT = %s\n\n",
                                      n, key, tweak, pt, ct }
' "$SRC" > deoxysii256v141-tbc-calls.txt

echo "aead vectors: $(grep -c '^COUNT' deoxysii256v141-aead-kat.txt)"
echo "tbc calls   : $(grep -c '^VEC'   deoxysii256v141-tbc-calls.txt)"
