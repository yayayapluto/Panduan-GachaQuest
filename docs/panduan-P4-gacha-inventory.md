# Panduan P4 — Gacha dan Inventory

## Peran

Kamu P4, anggota dengan level awam. Tugas utamamu dua modul: gacha (sistem undian
item) dan inventory (tas item pemain). Keduanya modul yang paling sering disentuh
pemain, jadi kesalahan kecil di sini langsung terasa saat bermain. Kabar baiknya,
aturan angkanya sudah dibekukan di `docs/PRD.md` bagian Aturan Game, dan test
driver-nya sudah disiapkan di `tests/`, jadi kamu tidak perlu menebak.

Yang kamu tulis hanya berkas `.c` untuk kedua modul ini. Antarmuka fungsinya sudah
ada di header kontrak, kamu tinggal mengisinya. Kalau kamu butuh menampilkan sesuatu
ke layar, pakai fungsi dari `ui.h` dan `util.h` yang disiapkan P1 — jangan pernah
memanggil `printf` sendiri.

## File Milik

|Folder|Isi|
|---|---|
|`src/gacha/`|`gacha.c` — logika undian, pity, duplikat, menu gacha|
|`src/inventory/`|`inventory.c` — daftar item, urut, cari, pasang perlengkapan|

Header `gacha.h` dan `inventory.h` ada di kontrak dan tidak boleh kamu ubah. Kalau
kamu merasa butuh fungsi publik baru, ajukan ke P1; perubahan header bersama hanya
lewat P1.

## Jalur Mahir

Untuk P4 yang sudah nyaman C. Aturan angka dan algoritma tetap beku; bagian ini
hanya memangkas pengantar.

- Baca dulu: `src/gacha/gacha.h`, `src/inventory/inventory.h`, `src/core/config.h`, `tests/t_gacha.c`, `tests/t_inventory.c`, `docs/PRD.md` §6 dan §7.
- Urutan: rarity dan pity, pull 1x/10x dan duplikat, menu gacha, sort tiga mode, cari linear, equip dan sinkronisasi.
- Bukti diterima: `bin/t_gacha` dan `bin/t_inventory` lulus, S05 dan S09 lulus, menu Inventory memuat `Urutkan`, `Cari item`, `Equip item`, `Kembali`.
- Jebakan: algoritma per mode sort tidak boleh ditukar; pity diproses per tarikan; pull yang tidak dapat tempat mengembalikan gold; pencarian linear substring, bukan binary.

## Konteks untuk AI

Bagian ini untuk kamu yang menempel panduan ke asisten AI. Isinya merangkum tugas
P4 dan aturan yang tidak boleh dilanggar, supaya asisten tidak menebak angka atau
menukar algoritma. Rujukan resminya tetap `docs/PRD.md` §6–§8.

**Tugas.** Isi dua berkas. `src/gacha/gacha.c` memuat undian rarity, pity, pull
1x dan 10x, serta penanganan duplikat saat tas penuh. `src/inventory/inventory.c`
memuat pengurutan isi tas, pencarian item, dan pemasangan perlengkapan. Header
`src/gacha/gacha.h` dan `src/inventory/inventory.h` sudah beku; jangan menambah
prototipe.

**Batasan keras.**

- C11, dikompilasi dengan `-Wall -Wextra -Wpedantic`; nol warning.
- Tanpa `malloc`, tanpa rekursi. Semua data memakai array tetap dari `config.h`.
- Tanpa `printf` ke layar. Keluaran lewat `ui_*`, `set_message`, dan `ui_log_*`.
- Angka acak hanya dari `plat_rand()` (`src/platform/rng.h`), tidak pernah
  `rand()`.
- Jangan mengubah `tests/*` supaya lulus, dan jangan menyentuh modul lain
  (`src/ui`, `src/player`, `src/battle`, `src/shop`, `src/storage`,
  `src/dungeon`, `main.c`, `Makefile`).

**Aturan gacha.**

|Hal|Aturan|
|---|---|
|Pull 1x|100 gold (`PULL_COST`)|
|Pull 10x|900 gold (`PULL10_COST`)|
|Roll|satu angka `1..100` dari `plat_rand()`|
|Legendary|98–100|
|Epic|86–97|
|Rare|61–85|
|Common|1–60|
|Pity|roll non-Epic menaikkan `*pity`; saat mencapai `PITY_THRESHOLD` (10) hasil dipaksa Epic lalu pity kembali 0|
|Duplikat saat tas penuh|`pullOnce` mengembalikan 0, pemain membayar `duplicatePrice(rarity)` sebesar 20/50/150/500 sesuai rarity, dan item tidak bertambah|

**Pengurutan dan pencarian.**

|Operasi|Algoritma|Hasil / prasyarat|
|---|---|---|
|`sortInventory(p, 1)`|Bubble Sort, stabil|rarity menaik|
|`sortInventory(p, 2)`|Selection Sort|power menurun|
|`sortInventory(p, 3)`|Bubble Sort, stabil|nama A–Z, case-insensitive|
|`searchItemByName`|linear|substring, case-insensitive|

Menu Inventory memakai pilihan berlabel `Cari item` untuk memanggil
`searchItemByName`.

**Prototipe.** Disalin apa adanya dari header kontrak; jangan mengubah nama,
tipe, atau urutan parameter.

`src/gacha/gacha.h`:

```c
void gachaMenu(Player *p, const Item catalog[], int count);
int rollRarity(int *pity);
int findItemInInventory(const Player *p, int id);
int duplicatePrice(int rarity);
const char *rarityName(int rarity);
int pullOnce(Player *p, const Item catalog[], int count, int rarity);   /* 0 when full: caller refunds */
```

`src/inventory/inventory.h`:

```c
void inventoryMenu(Player *p);
void sortInventory(Player *p, int mode);
int searchItemByName(const Player *p, const char *word);
void equipItem(Player *p, int index);
void syncEquipped(Player *p, int oldWeaponId, int oldArmorId);
```

**Prompt siap tempel.** Kirim blok berikut bersama lampiran panduan ini,
`src/gacha/gacha.h`, `src/inventory/inventory.h`, dan `src/core/config.h`.

```text
Lampirkan: docs/panduan-P4-gacha-inventory.md, src/gacha/gacha.h,
src/inventory/inventory.h, src/core/config.h.

Kerjakan hanya src/gacha/gacha.c dan src/inventory/inventory.c sesuai kontrak.
- C11, -Wall -Wextra -Wpedantic, tanpa malloc dan rekursi.
- Tanpa printf layar; pakai ui_* dan set_message. Angka acak hanya plat_rand().
- sortInventory: mode 1 Bubble Sort (rarity menaik), mode 2 Selection Sort
  (power menurun), mode 3 Bubble Sort (nama A-Z). Algoritma per mode tidak
  boleh ditukar.
- searchItemByName memakai pencarian linear substring yang tidak peka huruf besar-kecil.
- Jangan mengubah tests/* agar lulus dan jangan menyentuh modul lain.
```

**Skenario yang menyentuh modul ini.**

|ID|Yang dibuktikan|Penanda|
|---|---|---|
|S05|pull 10x saat gold kurang|`Gold kurang! Butuh 900 gold`|
|S08|urut dan cari inventory (driver `bin/t_inventory`)|exit 0, tanpa output|
|S09|jual item memakai `weaponIndex`/`armorIndex` yang benar|`Terjual:`|

## Prasyarat

- Panduan-0 sudah diikuti sampai repo kerja siap dan `make` jalan.
- P1 sudah menyelesaikan scaffold sampai tag `contract-v1`, sehingga `main.c`,
  stub semua modul, dan `Makefile` sudah ada. Pekerjaanmu dimulai dari mengganti
  isi stub `gacha.c` dan `inventory.c`.
- Kamu sudah membaca `src/gacha/gacha.h`,
  `src/inventory/inventory.h`, dan `src/core/config.h` (struct
  `Player` dan `Item`, konstanta `MAX_ITEM`, `PULL_COST`, `PULL10_COST`,
  `PITY_THRESHOLD`, `DUPLICATE_PRICE_*`, dan `RARITY_*`).
- Kamu paham aturan gacha di `docs/PRD.md` §6.

## Langkah Kerja

### Langkah 1 — `rollRarity` dan pity

Mulai dari fungsi paling kecil: `int rollRarity(int *pity)`. Ambil angka acak
1 sampai 100 dengan `plat_rand()`, lalu petakan:

|Angka roll|Rarity|
|---|---|
|98–100|Legendary (`RARITY_LEGENDARY`)|
|86–97|Epic (`RARITY_EPIC`)|
|61–85|Rare (`RARITY_RARE`)|
|1–60|Common (`RARITY_COMMON`)|

Aturan pity: setiap roll yang hasilnya bukan Epic menaikkan nilai `*pity` satu.
Begitu pity mencapai `PITY_THRESHOLD` (10), hasil roll dipaksa Epic dan pity
dikembalikan ke 0. Pity disimpan di `Player`, jadi ia bertahan antar sesi bermain.

> **Expected:** kompilasi driver `bin/t_gacha` tanpa warning, lalu `make test`
> menampilkan driver `t_gacha` lulus (exit 0). Driver ini menguji pemetaan roll
> dan perilaku pity, termasuk pemaksaan Epic pada pity ke-10.

### Langkah 2 — `pullOnce`, pencarian sequential, dan duplikat

`pullOnce(Player *p, const Item catalog[], int count, int rarity)` menerima
hasil rarity dari `rollRarity`, memilih satu item acak dengan rarity itu dari
katalog, lalu mencoba memasukkannya ke inventory.

Gunakan `findItemInInventory(const Player *p, int id)` — pencarian berurutan
(sequential search) sederhana: telusuri `inventory` dari indeks 0 sampai
`itemCount - 1`, bandingkan `id`, kembalikan indeks jika ketemu atau -1 jika tidak.

Dua kasus yang harus ditangani `pullOnce`:

1. Inventory masih ada tempat (`itemCount < MAX_ITEM`): item baru masuk. Kalau
   item dengan id yang sama sudah ada, naikkan level/power item lama sesuai aturan
   duplikat di PRD.
2. Inventory penuh: item tidak ditambahkan sama sekali. Pemain tetap membayar
   harga duplikat lewat `duplicatePrice(int rarity)` yang mengembalikan
   `DUPLICATE_PRICE_COMMON/EPIC/RARE/LEGENDARY` (20/50/150/500) sesuai rarity.
   Fungsi mengembalikan 0 saat penuh agar pemanggil (menu gacha) tahu harus
   mengembalikan sebagian gold.

Lengkapi juga `rarityName(int rarity)` yang mengembalikan nama teks rarity untuk
ditampilkan.

> **Expected:** `bin/t_gacha` tetap lulus setelah perubahan ini, karena driver
> menguji `pullOnce` pada kasus inventory penuh dan kasus masih ada ruang.

### Langkah 3 — `gachaMenu`

Buat menu gacha dengan dua pilihan: pull 1x seharga `PULL_COST` (100 gold) dan
pull 10x seharga `PULL10_COST` (900 gold). Sebelum melakukan pull, periksa gold.
Kalau tidak cukup, tampilkan pesan kesalahan dan kembali ke menu tanpa mengurangi
gold — pesan untuk pull 10x harus persis `Gold kurang! Butuh 900 gold` karena
skenario S05 mencarinya.

Untuk pull 10x, panggil `rollRarity` dan `pullOnce` sepuluh kali dalam satu loop.
Kalau di tengah jalan inventory penuh dan `pullOnce` mengembalikan 0, kembalikan
gold untuk pull yang gagal itu (refund), lalu lanjutkan atau berhenti sesuai
keputusan desainmu — yang penting pemain tidak membayar pull yang tidak
mendapatkan item.

Semua tampilan lewat `ui_*` dan `set_message`, bukan `printf`.

> **Expected:** skenario S05 (`tests/in_s05.txt`) dijalankan lewat
> `run_tests.sh` dan outputnya memuat `Gold kurang! Butuh 900 gold`. Gold pemain
> di akhir skenario tidak berubah.

### Langkah 4 — `sortInventory` dan `syncEquipped`

`sortInventory(Player *p, int mode)` punya tiga mode:

|Mode|Urutan|Algoritma|
|---|---|---|
|1|rarity menaik|Bubble Sort|
|2|power menurun|Selection Sort|
|3|nama A–Z (case-insensitive)|Bubble Sort|

Mode 1 dan 3 wajib Bubble Sort karena keduanya harus stabil — item dengan id sama
atau nama sama tidak boleh tertukar urutan relatifnya. Mode 2 memakai Selection
Sort; di sini stabilitas tidak dituntut test, dan Selection Sort dipilih supaya
kamu mempraktikkan dua algoritma sorting sekaligus sesuai materi kuliah. Keduanya
bekerja di atas `Item inventory[MAX_ITEM]` tanpa alokasi tambahan.

Setelah sorting selesai, panggil `syncEquipped(p, oldWeaponId, oldArmorId)`.
Alasannya: `weaponIndex` dan `armorIndex` menyimpan indeks, bukan id. Setelah item
berpindah posisi, indeks lama bisa menunjuk item yang salah. `syncEquipped`
mencari ulang posisi item berdasarkan id lama dan memperbarui indeksnya. Simpan
id lama sebelum sort, lalu sinkronkan setelahnya.

> **Expected:** `bin/t_inventory` lulus (exit 0, tanpa output) saat `make test`.
> Driver menguji ketiga mode sort dan memastikan item terpasang tetap menunjuk
> item yang benar setelah inventory diurutkan.

### Langkah 5 — `searchItemByName` (linear, substring)

`int searchItemByName(const Player *p, const char *word)` mencari item yang
namanya mengandung kata kunci. Aturannya:

- Pencarian linear: telusuri satu per satu dari awal.
- Pencocokan substring: kata kunci boleh hanya sebagian nama, misalnya "pedang"
  menemukan "Pedang Besi".
- Case-insensitive: samakan dulu huruf besar-kecilnya sebelum membandingkan.
- Kembalikan indeks item pertama yang cocok, atau -1 kalau tidak ada.

Ini materi Pertemuan tentang karakter dan string: kamu akan memakai perbandingan
karakter per karakter atau `strstr` setelah menurunkan case kedua string ke buffer
sementara.

> **Expected:** pemanggilan contoh seperti mencari "alp" pada inventory yang
> memuat "Alpha" mengembalikan indeks item itu; pencarian kata yang tidak ada
> mengembalikan -1. Perilaku ini tercakup oleh driver `t_inventory`.

### Langkah 6 — Menu Inventory

Sambungkan fungsi pencarian ke `inventoryMenu`. Menu menampilkan empat pilihan:
`Urutkan`, `Cari item`, `Equip item`, dan `Kembali`.

Alur `Cari item`: minta kata kunci lewat helper input yang disiapkan P1, panggil
`searchItemByName`, lalu tampilkan hasilnya (nama, rarity, power) atau pesan
tidak ditemukan. Pencarian tetap linear substring, jadi tidak perlu mengurutkan
inventory lebih dulu.

Alur `Urutkan`: tawarkan tiga mode yang sudah dibekukan, yaitu rarity menaik
(mode 1), power menurun (mode 2), dan nama A-Z (mode 3). Jangan menukar
algoritma antar mode.

> **Expected:** dari menu Inventory, `Cari item` menemukan item dengan kata
> kunci sebagian, dan `Urutkan` mengubah urutan daftar sesuai mode. Perilaku
> pencarian dan pengurutan juga diuji oleh `bin/t_inventory`.

### Langkah 7 — `equipItem`

`void equipItem(Player *p, int index)` memasang item pada `index` sebagai
perlengkapan. Logikanya:

- Cek tipe item (`Item` punya field tipe): senjata masuk ke `weaponIndex`,
  armor masuk ke `armorIndex`.
- Item yang bukan senjata atau armor tidak bisa dipasang; tampilkan pesan.
- Item yang sedang terpasang boleh dilepas atau ditukar dengan item lain dari
  tipe yang sama.

Setelah ini, `totalAtk` dan `totalDef` milik P3 akan otomatis menghitung bonus
dari item terpasang, jadi kamu tidak perlu menghitungnya di modul inventory.
Pemakaian item potion juga bukan wilayahmu — itu bagian battle (P3) dan shop (P5).

> **Expected:** dari menu Inventory, memasang senjata lalu membuka layar Status
> menunjukkan nilai ATK naik sesuai power item. Skenario S09 (jual item) lewat
> `run_tests.sh` menghasilkan output yang memuat `Terjual:` — jalur jual ada di
> modul shop milik P5, tetapi jual hanya boleh terjadi untuk item yang tidak
> sedang terpasang, dan itu tergantung `weaponIndex`/`armorIndex` yang kamu
> kelola benar.

## Definition of Done

- `src/gacha/gacha.c` dan `src/inventory/inventory.c` lengkap, tidak ada stub.
- `make` menghasilkan `bin/game` tanpa warning.
- Dua driver lulus: `bin/t_gacha` dan `bin/t_inventory`.
- Skenario S05 dan S09 menghasilkan output sesuai tabel skenario di PRD §11.
- Kamu bisa menjelaskan ke anggota lain cara kerja pity, kenapa mode 1/3 harus
  Bubble Sort, dan kenapa mode 3 memakai Bubble Sort yang stabil.
- Tidak ada `printf` di kedua berkas milikmu, dan tidak ada pemanggilan `rand()`.

## Larangan

- Dilarang memakai `printf` untuk tampilan layar. Semua keluaran lewat API UI
  (`ui_*`, `set_message`) agar tampilan konsisten dan test bisa memeriksa output.
- Dilarang memakai `rand()` dari pustaka standar. Pakai `plat_rand()` dari
  `platform/rng.h` supaya hasil acak bisa direproduksi dan sesi tersimpan tetap
  konsisten.
- Dilarang mengubah berkas test (`tests/*`) supaya test lulus. Kalau
  test gagal, yang salah biasanya implementasimu — baca ulang aturan di PRD.
- Dilarang menyentuh `src/ui`, `src/player`, `src/battle`, `src/shop`,
  `src/storage`, `src/dungeon`, `main.c`, atau `Makefile`. Itu milik anggota lain.
- Dilarang menambah fungsi publik baru tanpa persetujuan P1.

## Rujukan

- `docs/PRD.md` §6 (Aturan Game) dan §7 (kontrak modul gacha dan inventory).
- `src/gacha/gacha.h`, `src/inventory/inventory.h`,
  `src/core/config.h`.
- `tests/t_gacha.c`, `tests/t_inventory.c`, dan `tests/run_tests.sh`.
- `docs/panduan-0-git-dan-kompilasi.md` untuk alur branch, commit, dan PR ke `dev`.
- `docs/PEMBAGIAN-TUGAS.md` untuk fase, tag, dan aturan kerja bersama.
