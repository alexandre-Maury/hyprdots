#!/bin/bash
# Surveille les logs nftables avec journald et filtre les entrées "nft-drop:"
journalctl -f -o cat -t nftables-log | grep --line-buffered "nft-drop:"