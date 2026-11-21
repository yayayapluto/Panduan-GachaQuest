# Panduan P5 — Shop, Storage, dan Leaderboard

## Peran

Kamu P5, anggota dengan level paling dasar. Tugas utamamu tiga: toko di dalam game (`shopMenu`), semua urusan baca-tulis file (`storage`), dan papan skor (`recordScore`/`showLeaderboard`). Kebetulan ketiganya berkumpul di satu tema yang sama, yaitu file teks: katalog item dan monster dibaca dari file, hasil permainan disimpan ke file, dan skor juga ditulis ke file. Kalau kamu paham cara memecah satu baris `nama|hp|level` dengan `sscanf` atau `strtok`, separuh pekerjaanmu sudah selesai.

Posisi kamu di tim: kamu anggota awam, jadi berhak (dan disarankan) bertanya ke P1 kapan pun terbengkalai. Kamu tidak boleh menyentuh `src/ui` dan tidak boleh mencetak ke layar sendiri; semua tampilan lewat fungsi UI yang sudah disiapkan P1. Untuk angka acak, jangan pernah memanggil `rand()` — pakai `plat_rand()` dari `platform/rng.h` supaya hasilnya bisa direproduksi saat pengujian.

## File Milik

Hanya folder berikut yang boleh kamu ubah:

- `src/shop/*` — implementasi `shop.h` (satu fungsi publik: `shopMenu`).
- `src/storage/*` — implementasi `storage.h`: katalog, save/load, helper slot, leaderboard.

Header `src/storage/storage.h` dan `src/shop/shop.h` ada di kontrak dan tidak boleh diubah. Kalau kamu merasa butuh fungsi tambahan, diskusikan dengan P1; jangan menambah deklarasi sendiri. Kamu juga boleh membuat file `.c` pendukung di dalam folder milikmu, tapi mulailah dengan `storage.c` dan `shop.c` saja.

## Jalur Mahir

Untuk P5 yang sudah nyaman C dan operasi file. Format data dan kontrak tidak
berubah; panduan rinci di bawah tetap menjadi acuan.

- Baca dulu: `src/shop/shop.h`, `src/storage/storage.h`, `src/platform/atomicfile.h`, `src/core/config.h`, `tests/t_storage.c`, `tests/t_leaderboard.c`, `docs/PRD.md` §6 dan §8.
- Urutan: katalog dan monster, save/load 15 field, helper slot dan picker, leaderboard, menu toko, audit tulis atomik.
- Bukti diterima: `bin/t_storage` dan `bin/t_leaderboard` lulus, S09/S10/S11/S15 lulus, save hasil simpan bisa dimuat kembali tanpa kehilangan data.
- Jebakan: urutan 15 field adalah kontrak; semua penulisan lewat tulis atomik; leaderboard dipotong 10 dan urut menurun; item terpasang tidak boleh dijual.

## Konteks untuk AI

Bagian ini untuk ditempel bersama panduan saat meminta bantuan AI. Isinya meringkas lingkup kerjamu, batasan yang tidak boleh dilanggar, format berkas, dan prototipe fungsi yang harus ada.

### Ringkas tugas

Kamu mengerjakan dua folder saja: `src/shop/*` dan `src/storage/*`. Isinya: membaca katalog `data/item.txt` dan `data/monster.txt`, menyimpan serta memuat pemain lewat 5 slot, mencatat dan menampilkan leaderboard, melayani menu toko (beli potion, jual item), dan memastikan semua penulisan berkas berjalan atomik.

### Batasan keras

- Bahasa C11, dikompilasi dengan `-Wall -Wextra -Wpedantic` dan harus bersih dari warning.
- Tanpa `malloc` dan tanpa rekursi; semua buffer berukuran tetap.
- Tanpa `printf` ke layar; semua tampilan lewat API UI (`ui_*`).
- `rand()` dilarang; angka acak memakai `plat_rand()`.
- Semua penulisan berkas lewat `file_write_atomic`; `fopen(..., "w")` langsung dilarang.
- Jangan mengubah test di `tests/` maupun header kontrak.

### Format berkas

```text
data/item.txt
id|nama|tipe|rarity|power
36 baris; id 1-18 bertipe S, id 19-36 bertipe A.
Contoh: 1|Pedang Kayu|weapon|1|5

data/monster.txt
id|nama|hp|atk|def|exp|gold|minLevel
12 baris.

data/save_<n>.txt  (slot 1..5, file: save_1.txt .. save_5.txt)
Baris 1: nama|hp|maxHp|level|exp|gold|atk|def|potion|pity|totalPull|score|seed|weaponId|armorId
         (15 field, urutan tidak boleh berubah)
Baris 2: itemCount
Baris 3..(2+itemCount): satu id item per baris
Slot 1 memakai fallback save.txt bila save_1.txt tidak ada.

data/leaderboard.txt
nama|level|skor
maksimal 10 entri (MAX_LEADERBOARD); yang ditampilkan top 5 (TOP_DISPLAY) urut skor menurun.
```

### Angka tetap

|Konstanta|Nilai|Arti|
|---|---|---|
|`POTION_COST`|40|harga satu potion di toko|
|`MAX_POTION`|20|stok potion maksimum|
|`POTION_HEAL`|50|heal saat potion dipakai (di-cap `maxHp`)|
|`MAX_LEADERBOARD`|10|entri leaderboard yang disimpan|
|`TOP_DISPLAY`|5|entri leaderboard yang ditampilkan|
|`DUPLICATE_PRICE_COMMON`|20|harga jual item Common|
|`DUPLICATE_PRICE_RARE`|50|harga jual item Rare|
|`DUPLICATE_PRICE_EPIC`|150|harga jual item Epic|
|`DUPLICATE_PRICE_LEGENDARY`|500|harga jual item Legendary|

### Prototipe wajib (`src/storage/storage.h`)

|Prototipe|
|---|
|`int loadCatalog(const char *file, Item items[]);`|
|`int loadMonsters(const char *file, Monster monsters[]);`|
|`#define SAVE_SLOTS 5`|
|`int saveGame(const Player *p);`|
|`int saveGameSlot(const Player *p, int slot);`|
|`int loadGame(Player *p, const Item items[], int count);`|
|`int loadGameSlot(Player *p, const Item items[], int count, int slot);`|
|`void saveSlotPath(int slot, char *out, int size);`|
|`int saveSlotExists(int slot);`|
|`int saveSlotName(int slot, char *out, int size);`|
|`int saveSlotFirstFree(void);`|
|`void recordScore(const Player *p);`|
|`void showLeaderboard(void);`|

### Prototipe wajib (`src/shop/shop.h`)

|Prototipe|
|---|
|`void shopMenu(Player *p);`|

### Prompt siap tempel

```text
Saya mengerjakan peran P5 pada proyek Gacha Quest (C11, terminal).
Lampiran: panduan-P5-shop-storage.md, storage.h, shop.h.
Lingkup saya hanya src/shop/* dan src/storage/*.

Aturan:
- Format save 15 field tidak boleh diubah urutannya:
  nama|hp|maxHp|level|exp|gold|atk|def|potion|pity|totalPull|score|seed|weaponId|armorId
- Jangan memakai fopen langsung untuk menulis; gunakan file_write_atomic.
- Jangan memakai printf layar, rand(), malloc, atau rekursi.
- Error baca dilaporkan sebagai pesan "Gagal memuat".
- Jangan mengubah test atau header kontrak.

Bantu saya pada fungsi yang saya sebutkan saja.
```

### Skenario yang harus lolos

|ID|Penanda|Arti|
|---|---|---|
|S09|`Terjual:`|menjual satu item di toko berhasil dan gold bertambah|
|S10|`Selamat datang kembali, UjiSv!`|simpan lalu muat kembali slot yang sama|
|S11|`Gagal memuat`|file save rusak ditolak dengan pesan, bukan crash|
|S15|`Skor UjiSkr`, driver `bin/t_leaderboard`|skor tercatat dan papan skor urut menurun|

## Prasyarat

- Selesaikan `docs/panduan-0-git-dan-kompilasi.md` lebih dulu: repo kerja siap, repo sudah di-clone sehingga `src/`, `data/`, dan `tests/` ada di root, `make` jalan.
- P1 sudah menyelesaikan Langkah 2 (stub semua modul) sehingga proyek bisa dikompilasi walau modulmu masih kosong. Kalau belum, koordinasikan lewat PR di `dev`.
- `src/core/config.h` bisa dibaca; di situ ada konstanta yang akan kamu pakai terus: `MAX_ITEM`, `MAX_MONSTER`, `MAX_POTION`, `POTION_COST`, `MAX_LEADERBOARD`, `TOP_DISPLAY`, `DUPLICATE_PRICE_*`, dan struct `Item`/`Monster`/`Player`.
- Baca `tests/` untuk `t_storage` dan `t_leaderboard` supaya kamu tahu bentuk input dan output yang diharapkan sebelum menulis kode.

## Langkah Kerja

Kerjakan milestone berikut berurutan. Setiap milestone berakhir dengan satu bukti berupa perintah dan outputnya; jangan lanjut sebelum bukti milestone sebelumnya lolos.

### Milestone 1 — loadCatalog dan loadMonsters

Tulis `src/storage/storage.c` dengan dua fungsi pertama:

- `int loadCatalog(const char *file, Item items[])` — membaca `data/item.txt` berformat `id|nama|tipe|rarity|power`, tepat 36 baris (id 1–18 bertipe `S`, 19–36 bertipe `A`). Isi ke array `items` dan kembalikan jumlah baris yang berhasil dibaca.
- `int loadMonsters(const char *file, Monster monsters[])` — membaca `data/monster.txt` berformat `id|nama|hp|atk|def|exp|gold|minLevel`, tepat 12 baris.

Aturan validasinya: jumlah baris harus pas (36 dan 12). Kalau file hilang, ada baris yang formatnya koyak, atau jumlahnya tidak sesuai, kembalikan nilai yang menandakan gagal (misalnya 0 atau -1, ikuti yang dipakai test) dan biarkan pemanggil yang menampilkan pesan error. Parsing pipa cukup dengan `sscanf` berformat `%d|%[^|]|...` atau pemecahan manual dengan `strchr`; pilih yang paling kamu pahami.

```sh
make test
```

**Expected:** driver `bin/t_storage` lulus (exit 0, tanpa output). Kalau gagal, baca pesan testnya — biasanya format pipa yang salah atau field tertukar.

### Milestone 2 — saveGameSlot dan loadGameSlot

Sekarang bagian paling rawan: format file save. Tulis dengan persis urutan ini:

Baris 1 — lima belas field dipisah pipa, urutannya tidak boleh berubah:

```
nama|hp|maxHp|level|exp|gold|atk|def|potion|pity|totalPull|score|seed|weaponId|armorId
```

Baris 2 — satu angka `itemCount`. Sisanya — sebanyak `itemCount` baris, masing-masing satu id item.

Catatan penting: `weaponId` dan `armorId` adalah id item yang sedang terpasang, bukan indeks array. Simpan `-1` kalau tidak ada yang terpasang.

Implementasi:

- `int saveGameSlot(const Player *p, int slot)` — menulis file slot sesuai format di atas.
- `int loadGameSlot(Player *p, const Item items[], int count, int slot)` — membaca kembali. `items` dan `count` dipakai untuk menerjemahkan id item jadi data lengkap.
- `int saveGame(const Player *p)` dan `int loadGame(Player *p, const Item items[], int count)` — wrapper yang mendelegasikan ke slot 1.
- Fallback legacy: kalau `save_1.txt` tidak ada tapi `save.txt` ada, `loadGameSlot` untuk slot 1 membaca `save.txt`. Ini untuk kompatibilitas data lama; jangan dihapus.

Data rusak harus ditangani dengan pesan `Gagal memuat`, bukan crash. "Rusak" artinya: file hilang, baris pertama tidak punya 15 field, angka bukan angka, atau `itemCount` melebihi `MAX_ITEM`. Uji sendiri dengan menyunting file save secara manual (tambah huruf di tengah, hapus satu field) lalu jalankan load.

**Expected:** skenario S10 dan S11 lulus di `make test`. S10 menyimpan lalu memuat kembali dan menampilkan `Selamat datang kembali, UjiSv!`; S11 memberi file rusak dan mengharapkan `Gagal memuat`. Bandingkan isi file hasil simpanmu dengan contoh format di atas, field demi field.

### Milestone 3 — Helper slot dan picker

Empat fungsi kecil, tapi dipakai UI untuk menu Load/Save:

- `void saveSlotPath(int slot, char *out, int size)` — mengisi `out` dengan path file slot, misalnya `data/save_3.txt`.
- `int saveSlotExists(int slot)` — 1 kalau file slot ada, 0 kalau tidak.
- `int saveSlotName(int slot, char *out, int size)` — mengisi `out` dengan nama pemain yang tersimpan di slot itu (baca baris pertama, ambil field pertama); berguna untuk menampilkan daftar slot di menu.
- `int saveSlotFirstFree(void)` — nomor slot kosong pertama, atau nilai yang menyatakan penuh kalau kelima slot terisi.

Lalu buka jalur picker 5 slot: fungsi save/load di menu akan menampilkan lima slot beserta nama pemainnya, dan pemain memilih lewat `ui_menu_v` atau `ui_pick_row` dari P1. Kamu tidak menulis UI-nya — tugas kamu memastikan keempat helper itu benar sehingga P1 tinggal memanggil. Koordinasikan lewat PR bila tanda tangan panggilannya perlu dibahas.

**Expected:** tulis program uji sementara (atau pakai driver test yang ada) yang memanggil keempat helper: buat file `data/save_2.txt` kosong-baris-pertama-berisi-nama, panggil `saveSlotExists(2)` → 1, `saveSlotName(2)` mengembalikan nama itu, `saveSlotFirstFree()` melompati slot 2, dan `saveSlotPath(5)` menghasilkan string yang benar. Hapus program uji sementara itu setelah selesai — jangan ikut dikomit.

### Milestone 4 — recordScore dan showLeaderboard

Dua fungsi terakhir di `storage.h`:

- `void recordScore(const Player *p)` — menambah satu baris `nama|level|skor` ke `data/leaderboard.txt`. Batasnya `MAX_LEADERBOARD` (10) entri; kalau penuh, buang yang skornya paling rendah setelah baris baru masuk.
- `void showLeaderboard(void)` — menampilkan papan skor, maksimal `TOP_DISPLAY` (5) baris teratas, diurutkan menurun berdasarkan skor.

Cara paling sederhana: baca seluruh file ke array of struct kecil (nama, level, skor), tambahkan entri baru, urutkan menurun dengan Bubble Sort sederhana, pangkas ke 10, tulis ulang file. Untuk menampilkan, panggil fungsi UI dari P1 — jangan `printf` langsung. Urutan menurun wajib; test akan memeriksanya.

**Expected:** `bin/t_leaderboard` lulus di `make test`, dan skenario S15 lolos: setelah beberapa kali main, output memuat `Skor UjiSkr` dan papan skornya terurut menurun. Buka `data/leaderboard.txt` dan hitung barisnya sendiri — maksimal 10.

### Milestone 5 — shopMenu

Tulis `src/shop/shop.c` dengan `void shopMenu(Player *p)`. Menu toko punya dua aksi:

1. **Beli potion.** Harga `POTION_COST` (40 gold) per botol, heal `POTION_HEAL` (50, di-cap ke `maxHp` saat dipakai — itu urusan battle, bukan urusanmu). Stok maksimal `MAX_POTION` (20); kalau penuh, tolak pembelian dengan pesan yang jelas. Gold kurang juga ditolak, tanpa mengubah gold.
2. **Jual item.** Harga jual mengikuti rarity item, sama dengan tabel harga duplikat `DUPLICATE_PRICE_*` (Common 20, Rare 50, Epic 150, Legendary 500). Sebelum menjual: tampilkan konfirmasi, dan tolak bila item sedang terpasang (indeksnya sama dengan `weaponIndex` atau `armorIndex`). Setelah jual, item hilang dari inventory dan gold bertambah. Jangan lupa `syncEquipped` tidak diperlukan di sini karena item yang terpasang memang tidak boleh dijual — tapi indeks setelah item lain dihapus adalah urusan P4 saat sort; kamu cukup menolak penjualan item terpasang.

Semua tampilan lewat fungsi UI (`ui_panel`, `ui_menu_v`, `ui_message`, dan seterusnya). Gold tidak boleh pernah jadi negatif; periksa dulu, baru kurangi.

**Expected:** skenario S09 lulus: menjual satu item menghasilkan output dengan `Terjual:` dan gold bertambah sesuai rarity. Beli potion sampai stok 20 lalu coba beli lagi — harus ditolak dengan pesan, bukan crash.

### Milestone 6 — Semua tulis file lewat file_write_atomic

Audit seluruh kode tulis-file milikmu: save slot, leaderboard, dan penulisan apa pun ke `data/` wajib lewat `file_write_atomic` dari `platform/atomicfile.h`. Fungsi itu menulis ke file sementara lalu mengganti file tujuan dalam satu langkah, sehingga game tidak menyisakan file setengah jadi kalau proses mati di tengah jalan. Panggil juga `file_cleanup_tmp` di tempat yang sesuai kalau kontrak menyediakannya. Pembacaan file (`loadCatalog`, `loadMonsters`, `loadGameSlot`) tidak perlu atomic — hanya penulisan.

**Expected:** `grep -n "fopen" src/storage/*.c src/shop/*.c` tidak menampilkan `fopen(..., "w")` langsung untuk penulisan data — semua rutenya lewat `file_write_atomic`. `make test` tetap lulus penuh dan `bin/t_platform` tidak terganggu.

## Definition of Done

- `make` dan `make test` lulus tanpa warning; driver `bin/t_storage`, `bin/t_leaderboard` exit 0.
- Skenario S09, S10, S11, S15 lolos di `run_tests.sh`.
- Format save 15 field persis urutannya; file save hasil simpanmu bisa dimuat kembali tanpa kehilangan data (uji: simpan, keluar, muat, bandingkan status pemain).
- Tidak ada `printf` ke layar, tidak ada `rand()`, semua penulisan file atomic.
- PR ke `dev` dibuka, review P1 selesai, dan kode di-merge.

## Larangan

- Dilarang memakai `printf` untuk menampilkan sesuatu ke layar. Semua tampilan lewat API UI milik P1.
- Dilarang memakai `rand()`; gunakan `plat_rand()` supaya hasil bisa direproduksi.
- Dilarang menulis file tanpa `file_write_atomic`.
- Dilarang mengubah isi test di `tests` agar test lulus. Kalau test menemukan bug, betulkan kodenya, bukan testnya.
- Dilarang menyentuh file di luar `src/shop/*` dan `src/storage/*`, termasuk header kontrak.
- Dilarang menambah fungsi publik baru tanpa persetujuan P1.

## Rujukan

- `src/storage/storage.h` dan `src/shop/shop.h` — daftar fungsi yang wajib ada.
- `src/core/config.h` — konstanta `MAX_ITEM`, `MAX_MONSTER`, `MAX_POTION`, `POTION_COST`, `MAX_LEADERBOARD`, `TOP_DISPLAY`, `DUPLICATE_PRICE_*`, serta struct `Item`, `Monster`, `Player`.
- `src/platform/atomicfile.h` — `file_write_atomic`, `file_cleanup_tmp`.
- `data/item.txt`, `data/monster.txt` — contoh data yang harus bisa dibaca kodenya.
- `tests/run_tests.sh` — skenario S09, S10, S11, S15 dan cara driver dikompilasi.
- `docs/PRD.md` bagian 6 (Aturan Game) dan bagian 8 (Format File) — angka dan format resmi.
- `docs/panduan-0-git-dan-kompilasi.md` — alur git, branch, dan PR.
