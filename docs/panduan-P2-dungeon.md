# Panduan P2 — Dungeon

## Peran

Kamu adalah P2, anggota dengan level mahir. Tugasmu satu modul yang agak berbeda dari yang lain: dungeon. Modul ini yang membuat dunia bisa dijelajahi, dari pembangkitan labirin sampai gerak pemain di dalamnya. Karena hasil kerjamu dipakai langsung oleh pemain lewat layar yang dibuat P1, kamu harus rajin komunikasi dengan P1 soal bentuk data dan urutan pemanggilan.

Kebanyakan modul lain cuma memproses data. Modulmu beda: dunia yang kamu bangkitkan harus sama persis setiap kali seed-nya sama. Kalau pemain menyimpan permainan lalu memuatnya lagi, lorong dan ruangan harus ada di tempat yang sama. Determinisme ini bukan pilihan, melainkan syarat yang diuji langsung oleh skenario S16.

## File Milik

| File | Isi |
|---|---|
| `src/dungeon/dungeon.c` | Seluruh implementasi modul dungeon |
| `src/dungeon/dungeon.h` | Header modul (sudah ada di kontrak, jangan diubah tanpa persetujuan P1) |
| `tests/t_dungeon.c` | Driver pengujian determinisme dan pencarian jalur |

Tiga file itu cuma milikmu. Modul lain tidak boleh menyentuhnya, dan kamu juga tidak boleh menyentuh file milik orang lain. Kalau kamu butuh perubahan pada header bersama seperti `config.h`, ajukan ke P1.

## Jalur Mahir

Untuk P2 yang sudah nyaman C dan struktur data. Bagian ini mengasumsikan kamu
sudah membaca kontrak dan test; panduan rinci di bawah tetap berlaku.

- Baca dulu: `src/dungeon/dungeon.h`, `src/core/config.h`, `tests/t_dungeon.c`, `docs/PRD.md` §6 dan §7, `docs/KEPUTUSAN-PERILAKU.md` bagian Dungeon.
- Urutan: hash sel, terrain per chunk, gate bersama, pass konektivitas, DFS, BFS, loop dungeon, resume.
- Bukti diterima: `bin/t_dungeon` lulus, S12/S13/S14/S16 lulus, seed sama menghasilkan peta sama setelah simpan dan muat.
- Jebakan: gate harus dihitung dari sisi bersama agar dua chunk cocok; isi dungeon di-roll per chunk; hint BFS mencari treasure; tanpa `malloc`, rekursi, `rand()`, atau `printf` layar.

## Konteks untuk AI

Bagian ini ada supaya siapa pun bisa menempelkan file ini ke AI dan langsung mendapat pekerjaan yang sesuai kontrak, tanpa perlu menebak angka atau nama fungsi.

### Ringkasan tugas

Kamu mengerjakan modul dungeon: dunia prosedural yang deterministik per seed. Dunia dibangkitkan dari `unsigned int seed`, bukan disimpan sebagai peta, sehingga seed yang sama harus menghasilkan isi sel yang sama persis kapan pun dan di mana pun. Hasil kerjamu hidup di `src/dungeon/dungeon.c` dan `src/dungeon/dungeon.h`, dengan `tests/t_dungeon.c` sebagai penguji utama. Semua tampilan dipanggil lewat API `ui.h`, dan monster atau chest dipecahkan dengan memanggil modul `battle` dan `gacha`, bukan dengan menyalin logikanya.

### Batasan keras

- Bahasa C11, wajib bersih pada `-Wall -Wextra -Wpedantic`.
- Dilarang `malloc` dan turunannya. Dilarang rekursi. DFS dan BFS memakai stack/queue berupa array statis.
- Dilarang `printf` ke layar. Semua keluaran lewat fungsi dari `src/ui/ui.h`.
- Dilarang `rand()` dan `srand()`. Semua keacakan lewat `plat_rand()` dan `plat_srand()` dari `src/platform/rng.h`.
- Dilarang mengubah `src/ui`, `main.c`, `src/battle`, dan `src/gacha`.
- Angka di bawah ini diambil dari `src/core/config.h`; jangan mengarang nilai lain.

### Konstanta yang dipakai

| Konstanta | Nilai | Arti |
|---|---|---|
| `CHUNK_SIZE` | 16 | Sisi satu chunk dalam sel |
| `CACHED_CHUNKS` | 5 | Jumlah chunk per sisi area kerja |
| `AREA_MAX` | 80 | `CHUNK_SIZE * CACHED_CHUNKS`, sisi area kerja |
| `MAX_PATH_CELLS` | 6400 | `AREA_MAX * AREA_MAX`, kapasitas `Point path[]` |
| `MAX_TAKEN_CELLS` | 128 | Kapasitas `Point taken[]` |
| `TREASURE_GOLD` | 30 | Gold dari satu sel treasure |
| `DUNGEON_GOLD_MIN` | 10 | Batas bawah gold dari monster |
| `DUNGEON_GOLD_MAX` | 40 | Batas atas gold dari monster |
| `CHEST_GOLD_MIN` | 40 | Batas bawah gold dari chest |
| `CHEST_GOLD_MAX` | 120 | Batas atas gold dari chest |
| `CHEST_POTION_COUNT` | 2 | Jumlah potion dari chest |
| `HINT_COST` | 30 | Harga satu hint |
| `MAX_HINTS` | 3 | Hint maksimum per run |
| `CHUNK_MONSTER_PCT` | 45 | Peluang chunk berisi monster |
| `CHUNK_CHEST_PCT` | 35 | Peluang chunk berisi chest |
| `CHUNK_GOLD_PCT` | 55 | Peluang chunk berisi gold |
| `CHEST_EQUIPMENT_PCT` | 55 | Peluang chest berisi equipment |
| `CHEST_POTION_PCT` | 25 | Peluang chest berisi potion |

### Prototipe dari `src/dungeon/dungeon.h`

Salin apa adanya. Nama, urutan parameter, dan tipe kembali tidak boleh berubah.

```c
unsigned int cellHash(unsigned int seed, int x, int y);
char dungeonCell(unsigned int seed, int x, int y);
unsigned int randomWorldSeed(void);
unsigned int promptWorldSeed(void);
int promptWorldSeedTry(unsigned int *out);   /* 0 when the player cancels with Esc */
int dfsReachable(char area[][AREA_MAX], Point from, Point to);
int bfsShortestPath(char area[][AREA_MAX], Point from, Point to, Point path[]);
void runDungeon(Player *p, const Item catalog[], int catalogCount,
                const Monster monsters[], int monsterCount);
void resumeDungeon(Player *p, const DungeonState *saved, int steps, int hints,
                   const Item catalog[], int catalogCount,
                   const Monster monsters[], int monsterCount);
```

Dua struct pendukung dari `src/core/config.h`, juga apa adanya:

```c
typedef struct { int row, col; } Point;

/* Procedural dungeon: every cell is derived from the seed, so the world is infinite */
typedef struct {
    unsigned int seed;
    int posX, posY;             /* player position in world coordinates */
    Point taken[MAX_TAKEN_CELLS];   /* content cells already used up */
    int takenCount;
    int originX, originY;       /* top-left corner of the cached area (world coordinates) */
} DungeonState;
```

### Aturan dunia

- Seed adalah `unsigned int` dengan rentang `0..4294967295`. `promptWorldSeed()` menanyakan seed ke pemain; Enter kosong berarti seed diambil dari jam lewat `randomWorldSeed()`.
- `promptWorldSeedTry()` mengembalikan `0` bila pemain menekan Esc, dan `1` bila seed berhasil diisi. Esc tidak boleh membuat program keluar paksa.
- Kamera berukuran 25x15 sel dan mengikuti posisi pemain di dunia besar.
- Sel start `(1,1)` selalu lantai (`'.'`), untuk seed apa pun. Dipaksa di `dungeonCell`, bukan kebetulan.
- Isi setiap sel hanya bergantung pada seed dan koordinatnya. Tidak boleh ada urutan pemanggilan `plat_rand()` yang memengaruhi hasil sel, karena itu `cellHash` harus murni.
- `bfsShortestPath` mengembalikan panjang jalur, atau `-1` bila tujuan tidak tercapai. `dfsReachable` mengembalikan `1` bila terhubung dan `0` bila tidak.

### Prompt siap tempel

```text
Saya mengerjakan modul dungeon untuk proyek game terminal berbahasa C11.
Lampiran: panduan-P2-dungeon.md, src/dungeon/dungeon.h, src/core/config.h.

Tolong implementasikan src/dungeon/dungeon.c sesuai header itu, tanpa mengubah
header. Aturan yang tidak boleh dilanggar:
- Hanya pakai fungsi yang sudah dideklarasikan di dungeon.h, ui.h, rng.h, dan
  header platform lain yang sudah ada. Jangan mengarang fungsi publik baru.
- Tanpa malloc dan tanpa rekursi; DFS dan BFS memakai stack/queue array statis.
- Tanpa printf ke layar; semua keluaran lewat API ui.h.
- Tanpa rand()/srand(); semua angka acak lewat plat_rand()/plat_srand().
- Jangan mengubah src/ui, main.c, src/battle, src/gacha, atau file test.
- Dunia harus deterministik per seed, dan sel (1,1) selalu lantai.

Setelah selesai, sebutkan hasil kompilasi driver dan skenario yang terkait:
make && make test, dengan fokus pada bin/t_dungeon serta skenario S12, S13,
S14, dan S16.
```

### Skenario terkait

| ID | Skenario | Penanda |
|---|---|---|
| S12 | gerak ke tembok | `Tembok! Tidak bisa lewat.` |
| S13 | hint dengan gold kurang | `Gold kurang, hint butuh 30 gold` |
| S14 | dungeon deterministik, DFS dan BFS | `bin/t_dungeon` keluar dengan kode 0 |
| S16 | seed dunia | `dibangun dari seed 777` muncul dua kali |

## Prasyarat

Sebelum mulai, pastikan semua ini sudah terpenuhi:

- Repo kerja sudah disiapkan mengikuti `panduan-0-git-dan-kompilasi.md`, repo hasil clone sudah berisi `src/` (header saja), `data/`, dan `tests/` di root.
- `make` di root repo sudah jalan dan menghasilkan `bin/game` dari scaffold P1. Kamu butuh build yang jalan supaya bisa menguji driver-mu sendiri.
- File `src/dungeon/dungeon.h` dan `tests/t_dungeon.c` sudah kamu baca sampai selesai. Semua nama fungsi dan konstanta yang kamu pakai harus persis sama dengan yang ada di sana.
- Kamu sudah paham konstanta yang relevan dari `config.h`: `CHUNK_SIZE 16`, `CACHED_CHUNKS 5`, `AREA_MAX 80`, `MAX_PATH_CELLS`, `MAX_TAKEN_CELLS 128`, `TREASURE_GOLD 30`, `DUNGEON_GOLD_MIN 10`, `DUNGEON_GOLD_MAX 40`, `CHEST_GOLD_MIN 40`, `CHEST_GOLD_MAX 120`, `CHEST_POTION_COUNT 2`, `HINT_COST 30`, dan `MAX_HINTS 3`.
- Kamu tahu cara kerja `plat_rand()` dari `platform/rng.h`, karena semua angka acak di modulmu wajib lewat situ.

## Langkah Kerja

Kerjakan milestone berurutan. Jangan lompat, karena tiap milestone menumpuk di yang sebelumnya. Setiap milestone punya blok `Expected` sebagai tanda selesai.

### Milestone 1 — Baca kontrak dan test

Baca `dungeon.h` dan `tests/t_dungeon.c` sampai kamu bisa menjawab pertanyaan ini tanpa membuka file lagi:

- Fungsi apa saja yang wajib ada? Daftarnya: `cellHash`, `dungeonCell`, `randomWorldSeed`, `promptWorldSeed`, `promptWorldSeedTry`, `dfsReachable`, `bfsShortestPath`, `runDungeon`, `resumeDungeon`.
- `t_dungeon.c` memanggil fungsi mana dan dengan urutan bagaimana? Driver itu adalah spesifikasi perilakumu yang paling jujur.
- Struct `DungeonState` di `config.h` menyimpan apa saja? Kamu yang mengisinya selama run berjalan, jadi pahami setiap fieldnya.

```text
Expected
Kamu bisa menuliskan daftar fungsi di atas dari ingatan, dan tahu baris mana
di t_dungeon.c yang menguji masing-masing fungsi.
```

### Milestone 2 — Determinisme inti: `cellHash` dan `dungeonCell`

Mulai dari fondasinya. `cellHash` menerima seed dan koordinat sel, lalu mengembalikan angka yang selalu sama untuk masukan yang sama. `dungeonCell` memakai hash itu untuk memutuskan jenis sel: lantai, tembok, pintu, atau apa pun yang diminta header.

Aturan yang harus dipatuhi:

- Start `(1,1)` selalu lantai, apa pun seed-nya. Paksa sel ini di `dungeonCell`, jangan andalkan kebetulan.
- Tidak ada pemanggilan `plat_rand()` yang urutannya tergantung jalur eksekusi. Hash harus murni dari seed dan koordinat, sehingga sel `(x,y)` hasilnya sama walaupun dibangkitkan dengan urutan berbeda.
- Semua angka acak lewat `plat_rand()`, bukan `rand()`.

Uji dengan driver `t_dungeon.c`: dia membangun dunia dari seed tertentu dua kali dan membandingkan hasilnya.

```text
Expected
bin/t_dungeon pada bagian determinisme lulus: dunia dari seed yang sama
dibangun dua kali menghasilkan peta identik, dan sel (1,1) selalu lantai
untuk semua seed yang diuji.
```

### Milestone 3 — Terrain per chunk dan konektivitas

Sekarang dunia diberi watak. Bagi area menjadi chunk berukuran `CHUNK_SIZE 16`, dan tiap chunk dapat salah satu terrain: maze, ruang terbuka, gua, atau pilar. Pilihan terrain-nya juga deterministik per seed. Antara chunk dipasang gate dua sel sebagai pintu masuk dan keluar.

Aturan penting di milestone ini:

- Tanpa `malloc` dan tanpa rekursi. Semua buffer statis, semua algoritma iteratif. Kalau kamu tergoda menulis fungsi yang memanggil dirinya sendiri, ubah jadi loop dengan stack milikmu sendiri.
- Setelah terrain jadi, jalankan pass konektivitas: pastikan setiap chunk punya jalur ke chunk lain lewat gate. Chunk yang terisolasi harus disambung, dan cara penyambungannya pun harus deterministik.
- Gunakan `CACHED_CHUNKS 5` sesuai kontrak untuk keputusan caching chunk; jangan mengarang jumlah lain.

```text
Expected
Dunia dari seed mana pun tidak punya chunk terisolasi. Jalan dari (1,1)
mencapai semua area yang ditandai bisa dijelajahi, dan hasilnya tetap sama
setiap kali seed yang sama dipakai.
```

### Milestone 4 — `dfsReachable` dan `bfsShortestPath`

Dua algoritma pencarian di atas peta. Keduanya memakai `char area[][AREA_MAX]` sebagai wadah kerja dan array queue/stack statis sebagai struktur bantu.

- `dfsReachable`: penelusuran mendalam untuk memastikan dua titik terhubung. Dipakai untuk validasi konektivitas dari milestone 3, dan driver `t_dungeon.c` mengujinya langsung.
- `bfsShortestPath`: pencarian jalur terpendek, mengisi `Point path[]` dengan maksimum `MAX_PATH_CELLS` langkah. Dipakai fitur hint di milestone 5.

Perhatikan batas array. Queue dan stack harus punya kapasitas yang cukup untuk `AREA_MAX 80` kali `AREA_MAX 80` sel, tapi jangan lebih boros dari kontrak. Kalau jalur tidak ada, kembalikan nilai gagal sesuai konvensi header, bukan mengisi path dengan sampah.

```text
Expected
bin/t_dungeon lulus penuh: driver menguji dfsReachable pada peta yang
dipastikan terhubung dan terputus, lalu bfsShortestPath mengembalikan
panjang jalur yang benar untuk seed yang diuji.
```

### Milestone 5 — `runDungeon` dan `resumeDungeon`

Sekarang bagian yang dilihat pemain. `runDungeon` menjalankan sesi jelajah baru, `resumeDungeon` melanjutkan run yang tersimpan. Keduanya berbagi logika inti, jadi tulis sekali dan panggil dari dua pintu.

Fitur yang wajib ada:

- Gerak pemain dengan kamera 25x15 mengikuti posisi pemain di peta besar.
- Sel tembok menolak gerakan dan menampilkan pesan `Tembok! Tidak bisa lewat.` (skenario S12).
- Sel treasure memberi `TREASURE_GOLD 30` gold, sekali ambil per sel. Jejak sel yang sudah diambil disimpan di array maksimum `MAX_TAKEN_CELLS 128`.
- Monster di sel memicu `startBattleAgainst` dari modul battle. Kamu hanya memanggil, tidak menyentuh isinya.
- Chest memicu alur gacha: hadiahnya gold acak `CHEST_GOLD_MIN 40` sampai `CHEST_GOLD_MAX 120` atau potion sebanyak `CHEST_POTION_COUNT 2`, isinya deterministik per sel.
- Hint: pemain membayar `HINT_COST 30` gold untuk melihat petunjuk arah dari `bfsShortestPath`, maksimal `MAX_HINTS 3` kali per run. Gold kurang menghasilkan pesan `Gold kurang, hint butuh 30 gold` (skenario S13).
- Monster yang dikalahkan memberi gold acak `DUNGEON_GOLD_MIN 10` sampai `DUNGEON_GOLD_MAX 40`, tapi hadiah battle itu urusan modul battle; kamu hanya menyediakan pemicunya.

Semua tampilan lewat API UI dari P1. Kamu tidak boleh memakai `printf` ke layar sama sekali.

```text
Expected
Skenario S12 lulus: gerak ke tembok menampilkan pesan penolakan dan pemain
tetap di sel semula. Skenario S13 lulus: hint dengan gold di bawah 30
ditolak dengan pesan yang benar dan hint tidak terpakai. Kedua skenario
dijalankan lewat run_tests.sh dengan input dari tests/.
```

### Milestone 6 — Determinisme setelah reload

Ujian terakhir: dunia harus sama setelah simpan dan muat. Simpan seed di `DungeonState` lewat jalur save P5, keluar dari run, muat lagi dengan `resumeDungeon`, lalu bandingkan peta.

Cara mengujinya:

- Jalankan game dengan seed tertentu, jalan beberapa langkah, simpan, keluar.
- Muat save tersebut, lanjutkan run, dan pastikan sel di sekitar pemain sama dengan sebelum keluar.
- Skenario S16 membangun dunia dari seed 777 dua kali dan mengharapkan output `dibangun dari seed 777` muncul dua kali dengan peta identik.

```text
Expected
Seed sama menghasilkan dunia sama setelah reload: peta saat resume identik
dengan peta sebelum save. Skenario S16 lulus dengan penanda
"dibangun dari seed 777" muncul dua kali, dan run_tests.sh keluar tanpa
kegagalan pada seluruh skenario yang menyentuh dungeon.
```

## Definition of Done

Pekerjaanmu selesai kalau semua ini terpenuhi:

- `bin/t_dungeon` lulus tanpa warning saat dikompilasi dengan flag standar repo.
- Skenario S12, S13, S14, dan S16 lulus lewat `run_tests.sh`.
- Seed sama selalu menghasilkan dunia sama, termasuk setelah simpan dan muat.
- Tidak ada `malloc`, rekursi, `rand()`, atau `printf` layar di `src/dungeon/`.
- Semua angka acak lewat `plat_rand()`, semua tampilan lewat API UI.
- Kamu bisa menjelaskan fungsi apa pun di file-mu ke P1 atau P3 saat review.
- Commit dengan format `feat(dungeon): ...` dan PR dibuka ke branch `dev`.

## Larangan

- Jangan mengubah `src/ui`, `main.c`, `src/battle`, atau `src/gacha`. Kalau ada kebutuhan lintas modul, bicara ke P1.
- Jangan memakai `printf` untuk tampilan layar. Semua keluaran lewat API UI.
- Jangan memakai `rand()`. Semua keacakan lewat `plat_rand()` supaya seed tetap berarti.
- Jangan memakai `malloc` atau rekursi di modul ini.
- Jangan mengubah `dungeon.h` atau file test supaya test lulus. Kalau test menemukan bug, perbaiki implementasinya.
- Jangan menambah fungsi publik baru tanpa persetujuan P1.

## Rujukan

- `src/dungeon/dungeon.h` — daftar fungsi dan konvensi nilai kembali.
- `src/core/config.h` — konstanta `CHUNK_SIZE`, `AREA_MAX`, `MAX_PATH_CELLS`, `MAX_TAKEN_CELLS`, struct `Point` dan `DungeonState`.
- `tests/t_dungeon.c` — driver yang menjadi spesifikasi perilaku.
- `tests/run_tests.sh` — cara seluruh skenario dijalankan.
- `docs/PRD.md` bagian 6 dan 7 — aturan game dungeon dan kontrak modul.
- `docs/PEMBAGIAN-TUGAS.md` — aturan kepemilikan file dan alur PR.
- `docs/panduan-0-git-dan-kompilasi.md` — setup repo, branch, dan build.
