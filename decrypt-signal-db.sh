#!/usr/bin/env bash

unset OPTIND

docker=
overwrite=
dryrun=
out=
signal=
while getopts "dDfno:s:" opt; do
  case $opt in
    d) docker=1 ;;
    D) docker=0 ;;
    f) overwrite=1 ;;
    n) dryrun=1 ;;
    o) out="$OPTARG" ;;
    s) signal="$OPTARG" ;;
    *) usage
  esac
done

if [ -z "$signal" ]; then
  uname="$(uname -s)"
  case "${uname}" in
      Linux*)     signal="$HOME/.config/Signal";;
      Darwin*)    signal="$HOME/Library/Application Support/Signal";;
      CYGWIN*)    signal="$HOME/AppData/Roaming/Signal";;
      *)          echo "Unrecognized uname: $uname" >&2; exit 1
  esac
fi

if [ ! -d "$signal" ]; then
  echo "Signal directory not found at: $signal" >&2
  exit 2
fi

config="$signal/config.json"
if [ ! -f "$config" ]; then
  echo "Signal config.json not found: $config" >&2
  exit 3
fi

key="$(jq -r '.key' "$config")"

in="$signal/sql/db.sqlite"
if ! [ -e "$in" ]; then
  echo "Input db not found: $in" >&2
  exit 4
fi

if [ -z "$out" ]; then
  out="$signal/sql/db-decrypted.sqlite"
fi

if [ -e "$out" ]; then
  if [ "$overwrite" ]; then
    echo "Overwriting: $out" >&2
  else
    echo "Refusing to overwrite: $out (use -f to override)" >&2
    exit 5
  fi
fi

args=()
if [ "$docker" == "1" ]; then
  args+=("-d")
elif [ "$docker" == "0" ]; then
  args+=("-D")
fi
if [ "$dryrun" == "1" ]; then
  args+=("-n")
fi
echo "$key" | decrypt-db.sh "${args[@]}" "$in" "$out"
