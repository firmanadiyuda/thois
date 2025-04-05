#!/bin/bash

while true; do
  # Jalankan pgsync
  pgsync --db dbprod "*" "where updated_at > NOW() - INTERVAL '1 day'" --defer-constraints

  # Tambahkan log untuk debugging (opsional)
  # echo "$(date) - pgsync executed" >> /Users/tholee/pgsync.log

  # Tunggu 5 detik sebelum menjalankan ulang
  sleep 5
done