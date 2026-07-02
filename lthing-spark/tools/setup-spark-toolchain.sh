#!/bin/bash
# Install the SPARK proof toolchain (gnat, gprbuild, gnatprove, z3, cvc5)
# from the NixOS binary cache.
#
# Why Nix and not Alire: in Claude Code remote containers the GitHub
# integration intercepts ALL github.com traffic and scopes it to the
# session's repos, so every official gnatprove channel (Alire binaries,
# GNAT-FSF-builds releases, getada.dev) 403s regardless of the network
# policy. The Nix infrastructure (install.determinate.systems,
# channels.nixos.org, cache.nixos.org) is independent of github.com and
# serves everything prebuilt.
#
# Known limitation: nixpkgs ships gnatprove fsf-13 and its alt-ergo is not
# in the binary cache, so proofs run with z3+cvc5 only. On this codebase
# that leaves 9 "medium" checks undischarged (Parse_And_Verify offset
# arithmetic, Rej_NTT_Poly coefficient assembly) which gnatprove 14.1
# (Alire, as run by CI) proves. Treat CI as the reference for the
# 0-unproved gate; use this toolchain for local/agent iteration.
#
# Idempotent, non-interactive, safe to re-run.
set -uo pipefail

CHANNEL="${NIX_CHANNEL_URL:-https://channels.nixos.org/nixos-25.05/nixexprs.tar.xz}"

# TLS-intercepting egress proxies (Claude Code remote): trust the proxy CA.
if [ -z "${NIX_SSL_CERT_FILE:-}" ] && [ -f /root/.ccr/ca-bundle.crt ]; then
  export NIX_SSL_CERT_FILE=/root/.ccr/ca-bundle.crt
fi

# 1. Nix itself. The Determinate installer works without systemd
#    (--init none); as root the store is used directly, no daemon needed.
if [ ! -x /nix/var/nix/profiles/default/bin/nix ]; then
  curl -sSL https://install.determinate.systems/nix -o /tmp/nix-install.sh \
    && sh /tmp/nix-install.sh install linux --init none --no-confirm \
    || { echo "ERROR: Nix install failed" >&2; exit 1; }
fi
export PATH="/nix/var/nix/profiles/default/bin:$PATH"

# 2. Toolchain from the binary cache. Installed one by one so a single
#    uncached package (as alt-ergo is) cannot fail the rest.
for pkg in gnat gprbuild gnatprove z3 cvc5; do
  if ! nix-env -q 2>/dev/null | grep -qiE "(^|-)${pkg}(-|$)"; then
    nix-env -f "$CHANNEL" -iA "$pkg" \
      || echo "WARN: could not install $pkg from binary cache" >&2
  fi
done

# 3. PATH wiring. gprconfig detects nixpkgs' GNAT via the wrapper's
#    ../nix-support/gprconfig-gnat-unwrapped symlink, which exists only in
#    the gnat-wrapper store path — not in the merged profile. The wrapper's
#    own bin dir must therefore come first on PATH.
WRAPPER_BIN=""
if [ -e /root/.nix-profile/bin/gnatmake ]; then
  WRAPPER_BIN="$(dirname "$(readlink -f /root/.nix-profile/bin/gnatmake)")"
fi
TOOLCHAIN_PATH="${WRAPPER_BIN:+$WRAPPER_BIN:}/root/.nix-profile/bin"
export PATH="$TOOLCHAIN_PATH:$PATH"

# Persist for the rest of the Claude Code session, if run from a hook.
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"$TOOLCHAIN_PATH:\$PATH\"" >> "$CLAUDE_ENV_FILE"
  if [ -n "${NIX_SSL_CERT_FILE:-}" ]; then
    echo "export NIX_SSL_CERT_FILE=\"$NIX_SSL_CERT_FILE\"" >> "$CLAUDE_ENV_FILE"
  fi
fi

V="$(gnatprove --version 2>/dev/null | head -1)"; echo "gnatprove: ${V:-MISSING}"
V="$(z3 --version 2>/dev/null)";                 echo "z3       : ${V:-MISSING}"
V="$(cvc5 --version 2>/dev/null | head -1)";     echo "cvc5     : ${V:-MISSING}"
command -v gnatprove >/dev/null 2>&1
