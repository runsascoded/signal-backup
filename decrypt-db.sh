#!/bin/bash

usage() {
  echo "Usage: echo <key> | $0 [-d|-D] <db file> [out file path]" >&2
  exit 1
}

docker=
dryrun=
while getopts "dDn" opt; do
  case $opt in
    d) docker=1 ;;
    D) docker=0 ;;
    n) dryrun=1 ;;
    *) usage
  esac
done

#echo "docker: $docker, dryrun: $dryrun"
#exit 0

if [ $# -lt 1 ]; then
  usage
fi
in="$1"; shift

key="$(cat)"
if [ -z "$key" ]; then
  usage
fi

if [ $# -gt 0 ]; then
  out="$1"; shift
  if [ $# -gt 0 ]; then
    usage
  fi
else
  name="${out%.*}"
  xtn="${out##*.}"
  out="$name-decrypted.$xtn"
fi

if [ -z "$docker" ]; then
  if which sqlcipher &>/dev/null; then
    docker=0
  else
    docker=1
  fi
fi

if [ "$docker" == "1" ]; then
  cmd=(docker run -i yspreen/sqlcipher)
else
  cmd=(sqlcipher)
fi

if [ -n "$dryrun" ]; then
  echo "Dry run; would decrypt $in to $out; cmd: ${cmd[*]}"
else
  echo "Decrypting $in to $out; cmd: ${cmd[*]}"
  echo "PRAGMA key=\"x'$key'\";select count(*) from sqlite_master;ATTACH DATABASE '$out' AS plaintext KEY '';SELECT sqlcipher_export('plaintext');DETACH DATABASE plaintext;" | "${cmd[@]}" "$in"
  echo "Done."
fi
