# Panduan P1: Scaffold, UI, dan Platform

## Peran

Kamu adalah P1, anggota dengan level mahir, sekaligus integrator proyek. Tiga pekerjaan besar ada di pundakmu: menyiapkan kerangka build, membangun seluruh lapisan tampilan dan platform, lalu menyatukan modul milik empat anggota lain sampai jadi satu program.

Peran integrator menuntut satu kebiasaan yang tidak dimiliki peran lain. Kamu harus sering membuka `bin/game` di antara dua penyerahan modul, bukan menunggu semuanya selesai. Kalau antarmuka antar modul bergeser, kamu yang pertama tahu dan kamu yang menyampaikan ke pemiliknya. Karena itu, kamu juga pemegang keputusan untuk `src/core/config.h` dan setiap header bersama.

Semua anggota lain menumpang pada scaffold-mu. Kalau `make` belum jalan, P2 sampai P5 tidak bisa menguji apa pun. Kerjakan Milestone 1 dan 2 lebih dulu, umumkan ke grup bahwa build sudah hijau, baru lanjut ke UI.

## File Milik

| File | Isi |
|---|---|
| `Makefile` | Target `all`, `start`, `test`, `clean` |
| `main.c` | Menu Utama, Game Baru, Load Game, Leaderboard, Hub, integrasi layar |
| `src/core/config.h` | Konstanta dan struct bersama (sudah ada di kontrak) |
| `src/util/util.c` | `readLine`, `readInt`, dan kawan-kawan |
| `src/ui/term.c`, `caps.c`, `style.c`, `render.c`, `widgets.c`, `ui.c` | Seluruh lapisan tampilan terminal |
| `src/platform/*.c` | RNG, tulis atomik, log, lock sesi, sinyal, crash, autosave |
| `README.md` | Petunjuk menjalankan dan daftar kemampuan |

Header di `src/core`, `src/util`, `src/ui`, dan `src/platform` sudah tersedia lewat kontrak. Kamu boleh mengubah isinya, tetapi setiap perubahan yang memengaruhi modul lain wajib kamu kabari sebelum di-commit. File implementasi modul lain sama sekali bukan milikmu.

## Jalur Mahir

Untuk P1 yang sudah nyaman C, git, terminal, dan testing. Panduan rinci di bawah
tetap menjadi acuan angka; bagian ini hanya memangkas pengantar.

- Baca dulu: `docs/PRD.md` §5 dan §7, `docs/UI.md` untuk tampilan target, `docs/screens.md` untuk hasil visual, dan semua header di `src/`.
- Urutan: scaffold + stub, `contract-v1`, util, UI, platform, `main.c` sampai `ui-ready`, lalu integrasi.
- Kontrak bukti: `make` tanpa warning, sembilan driver lulus, S01-S18 lulus, Ctrl+C memulihkan terminal, instance kedua ditolak, autosave dan `.bak` tervalidasi.
- Jebakan: akses OS hanya di `src/platform`; logika game tidak boleh masuk `src/ui`; jangan menambah target Makefile di luar `all`, `start`, `test`, `clean`; jangan menimpa file modul anggota lain.

## Konteks untuk AI

Proyek ini adalah game terminal berbahasa C11 tanpa dependensi luar. Sebagai P1 kamu menulis `Makefile`, `main.c`, `src/core/config.h`, seluruh `src/util`, seluruh `src/ui`, dan seluruh `src/platform`; modul `player`, `battle`, `gacha`, `inventory`, `shop`, `storage`, dan `dungeon` hanya kamu stub sampai pemiliknya menyerahkan implementasi. Bagian ini merangkum fakta yang wajib dipakai apa adanya. Kalau kamu diminta menulis kode P1, jangan menebak nama fungsi, angka, atau format di luar daftar ini.

Batasan keras yang berlaku untuk semua kode P1:

- C11 murni, dikompilasi dengan `-std=c11 -Wall -Wextra -Wpedantic -D_POSIX_C_SOURCE=200809L` dan nol warning.
- Tanpa `malloc`, `calloc`, `realloc`, `free`, dan tanpa fungsi rekursif. Semua penyimpanan memakai array tetap.
- Hanya `src/platform` yang memanggil API sistem operasi: file, sinyal, thread, waktu, konsol, dan socket.
- Angka acak selalu lewat `plat_rand()`, tidak pernah `rand()` atau `srand()`.
- `printf` ke layar hanya boleh muncul di `src/util` dan `src/platform`; `src/ui` menggambar lewat grid `Cell`.
- Tampilan penuh butuh terminal minimal 50 kolom kali 20 baris; di bawah 40 kali 18 aplikasi menolak mode penuh.

Konstanta dari `src/core/config.h`:

| Konstanta | Nilai |
|---|---|
| `MAX_ITEM` | 36 |
| `MAX_MONSTER` | 12 |
| `MAX_NAME` | 30 |
| `CHUNK_SIZE` | 16 |
| `CACHED_CHUNKS` | 5 |
| `AREA_MAX` | 80 |
| `MAX_PATH_CELLS` | 6400 |
| `MAX_TAKEN_CELLS` | 128 |
| `MAX_LEVEL` | 10 |
| `MAX_POTION` | 20 |
| `MAX_LEADERBOARD` | 10 |
| `TOP_DISPLAY` | 5 |
| `PULL_COST` | 100 |
| `PULL10_COST` | 900 |
| `POTION_COST` | 40 |
| `HINT_COST` | 30 |
| `CRIT_CHANCE` | 10 |
| `CRIT_MULTIPLIER` | 2 |
| `POTION_HEAL` | 50 |
| `MAX_HINTS` | 3 |
| `PITY_THRESHOLD` | 10 |

`AREA_MAX` dan `MAX_PATH_CELLS` adalah makro turunan di header, jadi nilainya tetap 80 dan 6400.

Prototipe publik yang menjadi tanggung jawabmu, disalin verbatim dari header:

| Header | Prototipe |
|---|---|
| `util.h` | `int readLine(char *buf, int max);` |
| `util.h` | `int readLineEsc(char *buf, int max);` |
| `util.h` | `int readInt(const char *prompt, int min, int max);` |
| `util.h` | `int readIntTry(const char *prompt, int min, int max, int *out);` |
| `util.h` | `int readStringTry(const char *prompt, char *out, int max);` |
| `util.h` | `int confirmPrompt(const char *prompt);` |
| `util.h` | `void readString(const char *prompt, char *out, int max);` |
| `util.h` | `void clearScreen(void);` |
| `util.h` | `void printLine(void);` |
| `util.h` | `void shutdownGame(void);` |
| `platform.h` | `void platform_init(void);` |
| `platform.h` | `int platform_previous_running(void);` |
| `platform.h` | `int platform_shutdown_requested(void);` |
| `platform.h` | `void platform_shutdown(void);` |
| `platform.h` | `void platform_sleep_ms(int ms);` |
| `rng.h` | `void plat_srand(unsigned seed);` |
| `rng.h` | `unsigned plat_rand(void);` |
| `rng.h` | `unsigned long long plat_rng_state(void);` |
| `rng.h` | `void plat_rng_set(unsigned long long state);` |
| `atomicfile.h` | `int file_write_atomic(const char *path, const void *data, size_t len);` |
| `atomicfile.h` | `void file_cleanup_tmp(const char *dir);` |
| `log.h` | `void log_init(void);` |
| `log.h` | `void log_close(void);` |
| `log.h` | `void log_event(const char *fmt, ...);` |
| `log.h` | `void log_warn(const char *fmt, ...);` |
| `log.h` | `void log_error(const char *fmt, ...);` |
| `log.h` | `void log_crash(const char *fmt, ...);` |
| `lock.h` | `int lock_acquire(void);` |
| `lock.h` | `int lock_is_contention(void);` |
| `lock.h` | `int lock_previous_running(void);` |
| `lock.h` | `void lock_mark_clean(void);` |
| `sig.h` | `void sig_install(void);` |
| `sig.h` | `int sig_requested(void);` |
| `sig.h` | `void sig_cleanup_done(void);` |
| `sig.h` | `int sig_wake_fd(void);` |
| `crash.h` | `void crash_install(void);` |
| `autosave.h` | `void autosave_start(void);` |
| `autosave.h` | `void autosave_stop(void);` |
| `autosave.h` | `void autosave_publish(const Player *p, int screen, const Monster *enemy, int enemyHp, const DungeonState *dst, int steps, int hints, int important);` |
| `autosave.h` | `int autosave_load(AutoSnapshot *out);` |
| `autosave.h` | `int autosave_poll_error(char *buf, int len);` |

`autosave.h` juga mendefinisikan `enum` layar `AS_SCREEN_MENU`, `AS_SCREEN_HUB`, `AS_SCREEN_BATTLE`, `AS_SCREEN_DUNGEON`, dan `struct AutoSnapshot` yang berisi `Player player`, `int screen`, `int battleActive`, `Monster battleEnemy`, `int battleEnemyHp`, `int dungeonActive`, `DungeonState dungeon`, `int dungeonSteps`, `int dungeonHints`, dan `unsigned long long rng`.

Prompt siap tempel ke AI. Lampirkan `docs/panduan-P1-scaffold-ui.md` beserta header yang relevan dari `src/core`, `src/util`, `src/ui`, dan `src/platform` sebelum mengirim:

```text
Kamu mengerjakan peran P1 pada proyek game terminal C11. File yang kamu sentuh hanya Makefile, main.c, src/core/config.h, src/util/*, src/ui/*, dan src/platform/*. Jangan menyentuh src/player, src/battle, src/gacha, src/inventory, src/shop, src/storage, atau src/dungeon; file itu milik peran lain dan hanya boleh kamu stub.

Aturan yang tidak boleh dilanggar: kode harus lolos -std=c11 -Wall -Wextra -Wpedantic -D_POSIX_C_SOURCE=200809L tanpa warning; tanpa malloc/free dan tanpa rekursi; semua penyimpanan array tetap; hanya src/platform yang memanggil API OS; semua angka acak lewat plat_rand, tidak pernah rand atau srand; tidak ada printf layar di luar src/util dan src/platform.

Pakai hanya fungsi publik dan konstanta yang sudah ada di header yang dilampirkan. Jangan menambah fungsi publik baru, jangan mengganti nama, jangan mengubah tipe parameter, dan jangan mengarang fungsi di luar daftar di panduan. Kalau butuh fungsi baru, berhenti dan tanyakan.

Setelah selesai, jalankan make lalu make test dan laporkan keluaran aslinya.
```

Expected: `make test` berakhir `=== Ringkasan: <jumlah> lulus, 0 gagal ===`.

## Prasyarat

- Repo sudah di-clone dan berisi `src/` (header saja), `data/`, `tests/` di root, mengikuti `panduan-0-git-dan-kompilasi.md`.
- `gcc` dan `make` tersedia di `PATH`. Di Windows, pakai Git Bash atau shell MSYS2.
- Terminal minimal 50 kolom kali 20 baris saat menguji tampilan. Di bawah 40 kali 18, aplikasi memang menolak tampilan penuh.
- Kamu sudah membaca `src/core/config.h`, `src/util/util.h`, `src/ui/ui.h`, `src/platform/autosave.h`, dan `tests/run_tests.sh`. Nama fungsi dan konstanta yang kamu tulis harus persis sama dengan isi header itu.
- Kamu paham urutan dependensi lapisan: `util` tidak boleh bergantung pada `ui`; `ui` tidak boleh menyentuh `platform`; hanya `src/platform` yang memanggil API sistem operasi.
- Branch kerja `feat/scaffold-ui` sudah dibuat, dan semua pekerjaanmu masuk ke sana.

## Langkah Kerja

Tujuh milestone di bawah dikerjakan berurutan. Jangan mulai UI sebelum linker bersih, karena kegagalan link di tengah penulisan `ui.c` sangat sulit dilacak.

### Milestone 1: Periksa struktur dan tulis Makefile

Pastikan dulu isi repo sudah lengkap seperti hasil `git clone`:

```sh
ls src/core src/ui data tests
mkdir -p bin
```

Lalu tulis `Makefile` dengan empat target. Bentuk minimalnya seperti ini:

```make
CC      ?= gcc
CFLAGS  ?= -std=c11 -Wall -Wextra -Wpedantic -D_POSIX_C_SOURCE=200809L
INC      = -Isrc/core -Isrc/util -Isrc/ui -Isrc/player -Isrc/battle \
           -Isrc/gacha -Isrc/inventory -Isrc/shop -Isrc/storage \
           -Isrc/dungeon -Isrc/platform
SRC      = main.c $(wildcard src/*/*.c)
BIN      = bin/game

all: $(BIN)

$(BIN): $(SRC)
	@mkdir -p bin
	$(CC) $(CFLAGS) $(INC) -o $@ $(SRC)

start: $(BIN)
	./$(BIN)

test: $(BIN)
	sh tests/run_tests.sh

clean:
	rm -rf bin tests/out_last.txt

.PHONY: all start test clean
```

Target `preview` tidak dipakai di proyek ini, jadi jangan ditambahkan. Perhatikan bahwa `run_tests.sh` mengompilasi driver dengan daftar sumbernya sendiri; Makefile hanya perlu membangun `bin/game`. Daftar `-I` di Makefile harus sama dengan `INC` di `run_tests.sh`, kalau tidak, hasil `make` dan hasil uji bisa berbeda.

Pada titik ini file `main.c` belum ada. Selama `main.c` belum dibuat, `make` dan `make -n all` akan berhenti dengan `No rule to make target 'main.c'`; itu tanda Makefile sudah terbaca dan hanya menunggu berkas sumbernya. Untuk memeriksa sintaks dan perintah kompilasinya sekarang, buat `main.c` kosong lebih dulu.

```sh
touch main.c
make -n all
```

Expected: baris perintah `gcc`/`cc` dengan seluruh flag `-I...` dan `-o bin/game` tercetak, tanpa error sintaks Makefile. Tanpa `main.c`, expected-nya justru `make: *** No rule to make target 'main.c', needed by 'bin/game'.  Stop.`

### Milestone 2: `main.c` skeleton, stub modul, tag `contract-v1`

Tulis `main.c` minimal yang memanggil `platform_init()` di awal dan `platform_shutdown()` di akhir, lalu keluar dengan kode 0. Sesudah itu buat file `.c` kosong yang tetap mendefinisikan setiap fungsi publik dari header, supaya linker punya simbol. Stub cukup mengembalikan nilai netral: `0`, `-1`, `NULL`, atau tidak melakukan apa pun.

Modul yang perlu stub beserta fungsi wajibnya:

| File stub | Fungsi yang harus ada |
|---|---|
| `src/player/player.c` | `initPlayer`, `resetPlayer`, `addExp`, `totalAtk`, `totalDef`, `showStatus` |
| `src/battle/battle.c` | `startBattle`, `startBattleAgainst`, `resumeBattle`, `calculateDamage`, `battleRunAborted`, `battleClearRunAbort`, `battleRunEnded`, `battleClearRunEnded`, `battleGameOverScreen` |
| `src/gacha/gacha.c` | `gachaMenu`, `rollRarity`, `findItemInInventory`, `duplicatePrice`, `rarityName`, `pullOnce` |
| `src/inventory/inventory.c` | `inventoryMenu`, `sortInventory`, `searchItemByName`, `equipItem`, `syncEquipped` |
| `src/shop/shop.c` | `shopMenu` |
| `src/storage/storage.c` | `loadCatalog`, `loadMonsters`, `saveGame`, `saveGameSlot`, `loadGame`, `loadGameSlot`, `saveSlotPath`, `saveSlotExists`, `saveSlotName`, `saveSlotFirstFree`, `recordScore`, `showLeaderboard` |
| `src/dungeon/dungeon.c` | `cellHash`, `dungeonCell`, `randomWorldSeed`, `promptWorldSeed`, `promptWorldSeedTry`, `dfsReachable`, `bfsShortestPath`, `runDungeon`, `resumeDungeon` |

Tiga file lapisan bawah juga wajib ada pada tahap ini, karena `main.c` sudah memanggil `platform_init()` dan `platform_shutdown()`:

| File stub | Fungsi yang harus ada |
|---|---|
| `src/platform/platform.c` | `platform_init`, `platform_previous_running`, `platform_shutdown_requested`, `platform_shutdown`, `platform_sleep_ms` |
| `src/util/util.c` | `readLine`, `readLineEsc`, `readInt`, `readIntTry`, `readStringTry`, `confirmPrompt`, `readString`, `clearScreen`, `printLine`, `shutdownGame` (isi sementara boleh kosong; digarap di Milestone 3) |
| `src/ui/ui.c` | `ui_init`, `ui_shutdown`, `ui_interactive`, `set_message`, `last_message` (sisanya menyusul di Milestone 4, tambahkan bila linker memintanya) |

Sisa file `src/platform/*.c` (`rng`, `atomicfile`, `log`, `lock`, `sig`, `crash`, `autosave`) belum perlu ditulis sekarang. Buat saat Milestone 5; selama belum ada, jangan memanggil fungsinya dari `main.c`.

Tanda tangan stub diambil apa adanya dari header. Jangan mengubah `const`, tipe pointer, atau urutan parameter, karena P2 sampai P5 akan menimpa isinya nanti.

```sh
make
./bin/game; echo "exit=$?"
```

Expected: `make` selesai tanpa warning dan membentuk `bin/game`; program keluar dengan `exit=0`. Setelah itu kunci kontraknya:

```sh
git add -A
git commit -m "feat(scaffold): makefile, main skeleton, stub modul"
git tag -a contract-v1 -m "kontrak beku: header, data, test, scaffold"
```

Expected: `git tag` menampilkan `contract-v1`, dan `git show --stat contract-v1` memuat `Makefile`, `main.c`, dan semua file stub. Umumkan tag ini ke grup. Sejak sekarang, perubahan tanda tangan fungsi publik harus lewat persetujuanmu.

### Milestone 3: `src/util` sesuai `util.h`

Implementasikan sepuluh fungsi berikut, semuanya di `src/util/util.c`:

- `readLine(buf, max)` membaca satu baris dari `stdin`, membuang `\r` dan `\n`, memotong isi ke `max - 1` karakter, lalu mengembalikan jumlah karakter. EOF menghasilkan 0.
- `readLineEsc(buf, max)` sama, tetapi membedakan tiga hasil: 1 bila satu baris terbaca, 0 saat EOF, dan -1 saat Esc.
- `readInt(prompt, min, max)` menampilkan prompt, membaca angka, dan mengulang selama masukan bukan angka atau di luar rentang. Esc dan EOF mengembalikan `min` sebagai nilai aman.
- `readIntTry(prompt, min, max, out)` mengisi `*out` dan mengembalikan 1 bila berhasil, 0 saat Esc atau EOF.
- `readStringTry(prompt, out, max)` mengisi nama dan mengembalikan 1, atau 0 saat Esc dan EOF.
- `readString(prompt, out, max)` membungkus `readStringTry` dalam perulangan sampai nama tidak kosong. Nama sepanjang 30 karakter atau lebih dipotong jadi 29, sesuai `MAX_NAME`.
- `confirmPrompt(prompt)` mengembalikan 1 untuk `y` atau `Y`, 0 untuk `n`, `N`, dan Esc.
- `clearScreen()` memakai kode ANSI hanya bila terminal interaktif; di mode pipa cukup mencetak satu baris kosong.
- `printLine()` mencetak pemisah selebar layar.
- `shutdownGame()` menjadi satu pintu keluar: matikan autosave, kembalikan terminal, lalu keluar.

`readInt` tidak boleh memakai `scanf("%d")` mentah, karena sisa baris setelah masukan salah akan menggeser seluruh input berikutnya. Baca satu baris penuh dengan `readLine`, baru konversi.

Uji di luar program utama dengan driver sementara:

```sh
cat > /tmp/uji_util.c <<'EOF'
#include <stdio.h>
#include <string.h>
#include "config.h"
#include "util.h"
int main(void) {
    char nama[MAX_NAME];
    printf("angka=%d\n", readInt("Angka: ", 1, 5));
    readString("Nama: ", nama, MAX_NAME);
    printf("panjang=%d\n", (int)strlen(nama));
    printf("nama=%s\n", nama);
    return 0;
}
EOF
gcc -std=c11 -Wall -Wextra -Wpedantic -D_POSIX_C_SOURCE=200809L -Isrc/core -Isrc/util \
    -o /tmp/uji_util /tmp/uji_util.c src/util/util.c
printf 'abc\n9\n3\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\n' | /tmp/uji_util
```

Expected: tidak ada warning saat kompilasi, `readInt` mencetak `angka=3` setelah menolak `abc` dan `9`, lalu `panjang=29` dan nama berisi tepat 29 karakter `A`. Berkas `tests/in_util.txt` memuat pola masukan yang sama, jadi perilakumu harus cocok dengannya.

### Milestone 4: `src/ui` dari `term` sampai `ui`

Kerjakan berurutan, karena tiap lapisan memakai lapisan sebelumnya:

1. `src/ui/term.c` untuk `term.h`: raw mode, pembacaan tombol, alt screen, dan pemulihan terminal. `term_getkey` mengembalikan `KEY_UP`, `KEY_DOWN`, `KEY_LEFT`, `KEY_RIGHT`, `KEY_ENTER`, `KEY_ESC`, `KEY_RESIZE`, `KEY_EOF`, atau `KEY_CHAR`. Di Windows, gunakan API konsol; di POSIX, `termios` dan `poll` pada `sig_wake_fd()`.
2. `src/ui/caps.c` untuk `caps.h`: deteksi warna, unicode, ukuran, dan glyph. Terminal tanpa dukungan unicode mendapat glyph ASCII; `COLOR_MONO` membuat semua urutan warna kosong.
3. `src/ui/style.c` untuk `style.h`: `style_init` membangun string ANSI sekali, lalu `style_fg`, `style_bg`, `style_rarity`, dan `style_hp` hanya mengembalikan pointer ke tabel. Token `ST_HP_GRAD`, `ST_BIOME`, dan `ST_BIOME_FOG` dipakai dungeon lewat `style_fg`.
4. `src/ui/render.c` untuk `render.h`: grid `Cell` berukuran `GRID_MAX_ROWS` kali `GRID_MAX_COLS`, `render_text`, `render_text_clipped`, `render_span`, `render_char`, lalu `render_flush` yang menulis satu kali ke terminal. Mode non-interaktif mencetak baris polos.
5. `src/ui/widgets.c` untuk `widgets.h`: panel, bar, menu, footer, dan kotak pesan. Semua widget menggambar ke grid, tidak langsung ke layar.
6. `src/ui/ui.c` untuk `ui.h`: `ui_frame`, `ui_flush`, `ui_panel`, `ui_menu_v`, `ui_menu_h`, `ui_footer`, `ui_message`, `ui_status_panel_at`, `ui_menu_pick`, `ui_confirm_box`, `ui_input_screen`, `ui_line_begin`, `ui_line_end`, `ui_line_prompt`, `ui_line_error`, `ui_line_note`, `ui_line_read`, dan `ui_pick_row`. Log aksi memakai `ui_log`, `ui_log_event`, dan keluarga `ui_log_part_*`.

Layar baku memakai ukuran `UI_COLS 50` dan `UI_ROWS 20`. `ui_menu_pick` adalah satu-satunya loop menu: ia memanggil callback `UiDrawFn` setiap kali pilihan berubah, lalu mengembalikan nomor pilihan, bukan indeks. Esc tidak boleh keluar dari program; Esc berarti batal di tingkat layar.

Uji dengan layar sementara di `main.c`: satu frame, satu panel, satu menu dua pilihan, dan satu baris footer.

```sh
make && ./bin/game
TERM=dumb ./bin/game; echo "exit=$?"
```

Expected: frame tampil terpusat, menu bisa digerakkan dengan panah atas dan bawah, Enter memilih, Esc membatalkan, dan terminal kembali normal setelah keluar. Pada `TERM=dumb`, tidak ada kode escape yang bocor ke layar dan program tetap keluar dengan `exit=0`.

### Milestone 5: `src/platform` dan `bin/t_platform`

Ikuti urutan ini, karena tiap file memakai yang sebelumnya:

1. `src/platform/rng.c`: `plat_srand`, `plat_rand`, `plat_rng_state`, `plat_rng_set`. Pakai generator yang bisa diserialisasi, bukan `rand()`, karena state harus ikut tersimpan di autosave.
2. `src/platform/atomicfile.c`: `file_write_atomic` menulis ke `<path>.tmp.<pid>`, melakukan flush, lalu rename. `file_cleanup_tmp` menghapus sisa file tmp dari proses yang mati.
3. `src/platform/log.c`: `log_init`, `log_event`, `log_warn`, `log_error`, `log_close`, dan `log_crash` ke `data/game.log`. Setiap baris langsung di-flush.
4. `src/platform/lock.c`: kunci eksklusif non-blocking pada `data/session.lock`, isi `RUNNING pid=<pid> start=<epoch>` selama bermain dan `CLEAN` setelah keluar rapi.
5. `src/platform/sig.c`: handler hanya menaikkan flag dan membangunkan `poll` lewat self-pipe. `sig_wake_fd` mengembalikan -1 di Windows.
6. `src/platform/crash.c`: `crash_install` memulihkan terminal lalu menulis `data/crash.log` sebelum meneruskan sinyal.
7. `src/platform/autosave.c`: thread latar dengan debounce, CRC32, cadangan `autosave.bak`, dan `autosave_publish` yang menyalin snapshot milik pemanggil. UI tidak boleh menyentuh file.
8. `src/platform/platform.c`: `platform_init` merangkai semuanya, lalu mendaftarkan `platform_shutdown` lewat `atexit`.

Bentuk file `data/autosave.dat` sudah ditentukan: magic `GQAS`, versi, panjang, CRC32, lalu payload `AutoSnapshot`. Jangan mengubah urutan itu, karena `autosave_load` harus menolak file terpotong dan file yang CRC-nya tidak cocok.

```sh
make
gcc -std=c11 -Wall -Wextra -Wpedantic -D_POSIX_C_SOURCE=200809L \
    -Isrc/core -Isrc/util -Isrc/ui -Isrc/player -Isrc/battle \
    -Isrc/gacha -Isrc/inventory -Isrc/shop -Isrc/storage \
    -Isrc/dungeon -Isrc/platform \
    -o bin/t_platform tests/t_platform.c \
    src/platform/*.c src/ui/*.c src/player/player.c
./bin/t_platform
```

Expected: kompilasi tanpa warning, lalu setiap baris diawali `LULUS` dan diakhiri `--- 12 dari 12`. Tiga cek autosave membutuhkan `initPlayer` yang benar-benar menyalin nama pemain; kalau `player.c` masih stub milikmu, cek itu akan gagal dan harus diulang setelah P3 menyerahkan modulnya.

### Milestone 6: `main.c` penuh dan tag `ui-ready`

Sekarang sambungkan layar yang sudah ada menjadi alur game:

- Menu Utama: Game Baru, Load Game, Leaderboard, Keluar.
- Game Baru: minta nama lewat `ui_input_screen` dan `ui_line_read`, lalu minta seed dunia lewat `promptWorldSeed`. Enter kosong berarti seed diambil dari jam.
- Load Game: daftar lima slot dengan `saveSlotName` dan `saveSlotExists`, termasuk slot kosong yang tidak bisa dipilih. Slot 1 tetap membaca `data/save.txt` lama bila `data/save_1.txt` belum ada.
- Leaderboard: panggil `showLeaderboard` dengan sepuluh entri tersimpan dan tampilkan lima teratas.
- Hub: Status, Battle, Dungeon, Gacha, Inventory, Shop, Simpan, Keluar ke Menu Utama.

Setiap kali pemain masuk ke Hub, panggil `autosave_publish` dengan snapshot terkini. Sebelum keluar rapi, panggil `platform_shutdown`, yang menutup autosave dan menandai sesi `CLEAN`.

Uji alur seed, karena skenario S16 bergantung padanya:

```sh
rm -f data/save_1.txt
printf '%s\n' 'UjiSeed' '777' '8' | ./bin/game
```

Expected: pesan `dibangun dari seed 777` muncul saat dunia dibuat, dan dunia yang sama dibangun lagi setelah permainan dimuat dari save. Terminal kembali normal setelah keluar dari menu. Setelah itu kunci tampilannya:

```sh
git add -A
git commit -m "feat(ui): menu utama, game baru, load game, leaderboard, hub"
git tag -a ui-ready -m "lapisan UI dan platform siap dipakai modul"
```

Expected: tag `ui-ready` ada, dan P2 sampai P5 sudah bisa memanggil `ui_menu_pick` serta `ui_frame` dari modul masing-masing.

### Milestone 7: Integrasi semua modul dan `make test`

Saatnya mencabut stub. Ganti pemanggilan layar di `main.c` dengan fungsi asli: `startBattle` dan `resumeBattle` untuk battle, `runDungeon` dan `resumeDungeon` untuk dungeon, `gachaMenu`, `inventoryMenu`, dan `shopMenu` untuk tiga layar lainnya. Pastikan setiap layar memakai pola yang sama: `ui_frame`, gambar isi, `ui_flush`, lalu `ui_menu_pick`.

Periksa juga tiga hal yang mudah terlewat saat integrasi. Pertama, `set_message` dipanggil sebelum `ui_message`, bukan sesudahnya. Kedua, `ui_line_begin` dan `ui_line_read` harus memasang `term_cooked` selama input baris dan mengembalikan `term_raw` setelahnya, karena input baris tidak jalan di raw mode. Ketiga, semua angka acak di modul mana pun lewat `plat_rand`, bukan `rand`.

```sh
make clean
make
make test
```

Expected: `make` bersih tanpa warning, lalu `run_tests.sh` mengompilasi sembilan driver dan menjalankan 13 skenario S01 sampai S18, total 23 cek (S16 diuji dua kali). Baris terakhir berbunyi `=== Ringkasan: <jumlah> lulus, <jumlah> gagal ===`. Target akhir setelah semua modul selesai adalah `=== Ringkasan: 23 lulus, 0 gagal ===`. Kalau ada baris `GAGAL`, baca `tests/out_last.txt`; berkas itu menyimpan keluaran terakhir dari driver atau skenario yang gagal.

## Definition of Done

Pekerjaanmu selesai kalau semua poin ini benar:

- `make` menghasilkan `bin/game` tanpa satu pun warning dengan `-Wall -Wextra -Wpedantic`.
- `make test` menjalankan 23 cek (sembilan driver + 13 skenario, S16 diuji dua kali) dan berakhir `23 lulus, 0 gagal` setelah semua modul selesai.
- Terminal kembali ke kondisi normal setelah keluar, baik lewat menu Keluar, Ctrl+C, maupun saat crash buatan. Kursor terlihat lagi dan layar tidak penuh sisa karakter.
- Instance kedua ditolak dengan pesan yang jelas, karena `lock_acquire` gagal dan game keluar tanpa merusak `data/session.lock`.
- Autosave bisa dimuat ulang dengan `autosave_load`, dan file yang dipotong atau diubah isinya ditolak.
- Menu Utama sampai Hub bisa dimainkan tanpa input yang membuat program berhenti mendadak.
- Tag `contract-v1` dan `ui-ready` ada di branch `dev`, dan `README.md` memuat cara build serta cara menjalankan test.

## Larangan

- Jangan menimpa file modul milik P2, P3, P4, atau P5. Kalau butuh perubahan di sana, minta pemiliknya yang mengerjakan.
- Jangan memakai `rand()` atau `srand()` di mana pun. Semua angka acak lewat `plat_srand` dan `plat_rand`.
- Jangan memanggil API sistem operasi langsung dari `main.c`, `src/util`, `src/ui`, atau modul game. Semua akses OS, termasuk file, sinyal, thread, dan waktu, hanya boleh ada di `src/platform`.
- Jangan menambah fungsi publik baru tanpa kesepakatan dengan pemilik modul. Header yang sudah dibekukan di `contract-v1` hanya berubah lewat satu commit terpisah yang kamu umumkan.
- Jangan menambahkan target `preview` atau target lain di luar `all`, `start`, `test`, dan `clean`.
- Jangan menaruh logika game di `src/ui`. Lapisan itu hanya menggambar dan membaca tombol.

## Rujukan

- `src/core/config.h` untuk semua konstanta dan struct bersama.
- `src/util/util.h`, `src/ui/ui.h`, `tests/t_util.c` untuk perilaku util yang diuji.
- `src/ui/ui.h`, `term.h`, `caps.h`, `style.h`, `render.h`, `widgets.h` untuk lapisan tampilan.
- `src/platform/*.h` dan `tests/t_platform.c` untuk lapisan platform.
- `tests/run_tests.sh` untuk daftar driver dan skenario penerimaan.
- `docs/PRD.md` bagian 6, 7, dan 11 untuk aturan game, kontrak modul, serta kriteria penerimaan.
- `docs/PROJECT-OVERVIEW.md` untuk peta modul dan alur runtime.
- `docs/PEMBAGIAN-TUGAS.md` untuk pembagian fase dan aturan file.
- `docs/panduan-0-git-dan-kompilasi.md` untuk urutan git dan kompilasi.
