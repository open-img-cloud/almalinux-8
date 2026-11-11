#!/usr/bin/env bash
# Prints the latest upstream AlmaLinux 8 GenericCloud image version on stdout.
#
# Parses the directory listing at
#   https://repo.almalinux.org/almalinux/8/cloud/x86_64/images/
# for versioned image names and prints the highest version
# (e.g. 8.10-20261026). Runs in the upstream-watch reusable workflow
# (no KVM needed): keep it portable bash + curl + grep + sort only.

set -euo pipefail

URL='https://repo.almalinux.org/almalinux/8/cloud/x86_64/images/'

listing=$(curl -fsL "$URL")
if [[ -z "$listing" ]]; then
  echo "::error::could not fetch $URL" >&2
  exit 1
fi

latest=$(printf '%s\n' "$listing" \
  | grep -oE 'AlmaLinux-8-GenericCloud-(8\.[0-9]+-[0-9]{8})\.x86_64\.qcow2' \
  | sed -E 's#AlmaLinux-8-GenericCloud-(8\.[0-9]+-[0-9]{8})\.x86_64\.qcow2#\1#' \
  | sort -uV \
  | tail -n1)

if [[ -z "$latest" ]]; then
  echo "::error::no versioned AlmaLinux 8 GenericCloud image found in $URL" >&2
  exit 1
fi

printf '%s\n' "$latest"
