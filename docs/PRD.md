# PRD: Gacha Quest

Dokumen ini adalah sumber primer untuk proyek C11 terminal **Gacha Quest**: game gacha
dengan dungeon prosedural yang dibangun di atas satu set kontrak modul di `src/`.
Semua angka, nama fungsi, dan format file di seluruh dokumen panduan merujuk ke sini.
Kontrak antarmuka sendiri tinggal di `src/**/*.h`, data contoh di
`data/`, dan pengujian di `tests/`.

## 1. Ringkasan dan Tujuan

Gacha Quest adalah permainan teks untuk terminal. Pemain memberi nama pada karakternya,
lalu mendarat di sebuah hub yang menjadi pusat semua aktivitas: bertarung melawan monster
untuk mengumpulkan EXP dan gold, memutar gacha untuk mendapatkan senjata dan armor dengan
empat tingkat kelangkaan, mengelola inventori, membeli potion dan menjual item duplikat,
serta menyelami dungeon prosedural yang dibangkitkan dari sebuah seed. Dungeon itu tidak
pernah habis, karena setiap sel dunia dihitung secara deterministik dari seed dan posisi,
sehingga seed yang sama selalu menghasilkan dunia yang sama.

Proyek ini sekaligus menjadi wadah latihan materi kuliah Dasar Pemrograman. Enam belas
materi, mulai dari Pertemuan 1 sampai Pengujian dasar, masing-masing punya wujud nyata di
dalam kode. Batasannya sengaja ketat: tanpa alokasi dinamis, tanpa rekursi, array berukuran
tetap, sehingga yang dinilai adalah penguasaan dasar bahasa C, bukan kepandaian memakai
pustaka.

Alur demo singkat: jalankan `bin/game`, pilih **Game Baru**, masukkan nama dan seed dunia,
lalu dari Hub masuk ke Dungeon dan berjalan dengan tombol WASD. Ketemu monster membuka
layar Battle; menang memberi EXP dan gold, kalah membuka layar Game Over. Kembali ke Hub,
putar Gacha beberapa kali sampai dapat item Epic, pasang dari Inventory, lalu simpan ke
slot 1. Keluar, jalankan lagi, pilih **Load Game**, dan sesi sebelumnya kembali utuh
beserta posisi dungeon dan state RNG-nya.

## 2. Batasan Teknis

| Aspek | Ketentuan |
|---|---|
| Bahasa | C standar C11, satu kode sumber untuk semua platform |
| Flag kompilasi | `-std=c11 -Wall -Wextra -Wpedantic -D_POSIX_C_SOURCE=200809L`, tanpa satu pun warning |
| Memori | Tanpa `malloc`/`free`, tanpa struktur data dinamis |
| Rekursi | Dilarang; penelusuran dungeon memakai DFS/BFS dengan array eksplisit |
| Penyimpanan | Array berukuran tetap dari `config.h` (`MAX_ITEM`, `MAX_MONSTER`, dan seterusnya) |
| API sistem operasi | Hanya modul `src/platform` yang boleh memanggil API OS; modul lain murni C standar plus lapisan platform |
| Target | Windows (MSYS2/MinGW), Linux, dan WSL |
| Terminal | Minimal 50 kolom × 20 baris; di bawah itu program menolak masuk mode interaktif |
| Pengujian | Driver `tests/t_*.c` dan skenario `tests/run_tests.sh` harus lulus tanpa warning |

## 3. Pengguna dan Skenario

Ada dua peran pengguna. **Pemain** memainkan game lewat keyboard di terminal: memilih menu
dengan angka, bergerak di dungeon dengan WASD, dan mengonfirmasi aksi penting dengan y/n.
**Dosen atau penilai** tidak bermain, tetapi memeriksa pekerjaan: membaca kontrak modul,
menjalankan pengujian otomatis, dan menelusuri kode untuk memverifikasi pemetaan materi.

Untuk peran kedua itu program punya **mode pipa non-interaktif**. Seluruh input dapat
disalurkan dari file (`./bin/game < tests/in_s10.txt`), sehingga skenario penerimaan
dapat dijalankan berulang tanpa sentuhan manusia. Program mendeteksi sendiri bahwa input
bukan terminal interaktif, mematikan mode raw dan animasi, dan tetap mencetak keluaran
lengkap yang bisa digrepa oleh skrip uji.

## 4. Fitur dan Navigasi

**Menu Utama** adalah layar pertama, dengan pilihan: `1` Game Baru, `2` Load Game,
`3` Leaderboard, `0` Keluar. Keluar dari Menu Utama melewati konfirmasi y/n.

**Game Baru** meminta nama pemain (ditolak bila kosong, dipotong pada 29 karakter) lalu
seed dunia `0..4294967295`; menekan Enter tanpa mengisi mengambil seed dari jam. Sesudah
itu pemain berada di **Hub**, pusat navigasi dengan pilihan: `1` Battle, `2` Gacha,
`3` Inventory, `4` Shop, `5` Dungeon, `6` Status, `7` Save, `0` kembali ke Menu Utama.
Nomor-nomor ini adalah yang dipakai oleh berkas input skenario di `tests/`.

Fitur inti:

- **Battle** melawan monster dari katalog; menang memberi EXP dan gold, kalah berakhir
  dengan layar Game Over.
- **Gacha** dua mode: pull 1x seharga 100 gold dan pull 10x seharga 900 gold, dengan
  sistem pity dan penalti duplikat.
- **Inventory** menampung maksimal 36 item, bisa diurut tiga cara, dicari linear maupun
  binary, dan dipasang sebagai senjata atau armor.
- **Shop** menjual potion dan membeli kembali item dari inventori.
- **Dungeon** prosedural ber-seed: bergerak, menemukan treasure, peti, dan monster, membeli
  hint, semuanya deterministik terhadap seed.
- **Leaderboard** mencatat skor dan menampilkan lima terbaik dari maksimal sepuluh entri.
- **Save/Load** lima slot bernomor, ditambah autosave otomatis yang pulih saat sesi
  sebelumnya mati mendadak.

## 5. Layar dan Kontrol

| Layar | Tombol | Aksi |
|---|---|---|
| Menu Utama | `1`/`2`/`3`/`0` | Game Baru, Load Game, Leaderboard, Keluar (dengan konfirmasi) |
| Game Baru | ketik nama, ketik seed, atau Enter | nama disimpan, seed dunia diatur; Enter kosong berarti seed dari jam |
| Load Game | `1..5`, Esc | memuat slot terpilih; Esc membatalkan |
| Leaderboard | tombol apa pun | menampilkan daftar skor, lalu kembali |
| Hub | `1..7`, `0` | Battle, Gacha, Inventory, Shop, Dungeon, Status, Save, kembali |
| Battle | `1..4` | Serang, Bertahan, Potion, Kabur; hasil tiap ronde tercatat di log |
| Gacha | `1`/`2`, `0` | pull 1x (100 gold), pull 10x (900 gold), kembali |
| Inventory | `1..4`, `0` | urutkan, cari (termasuk `4` Cari item (binary)), pasang lewat pemilih baris |
| Shop | `1`/`2`, `0` | beli potion, jual item (pemilih baris + konfirmasi), kembali |
| Status | tombol apa pun | panel statistik lengkap, lalu kembali |
| Dungeon | `w/a/s/d`, `h`, `q` | bergerak empat arah, beli hint (30 gold), keluar run |
| Game Over | `1`/`2` | `Mulai ulang (reset run)` atau `Kembali ke menu utama` |

Aturan tombol Esc berlaku seragam: pada prompt apa pun, Esc membatalkan dan mengembalikan
nilai "batal" ke pemanggil (`readIntTry`, `readStringTry`, `promptWorldSeedTry` mengembalikan
0; `readLineEsc` mengembalikan -1), dan pada kotak konfirmasi Esc berarti Tidak. Aksi yang
merusak data selalu didahului konfirmasi y/n di dalam kotak: menimpa slot simpan yang sudah
ada, menjual item dari inventori, dan keluar dari program. Tanpa konfirmasi, aksi itu
ditolak.

## 6. Aturan Game

Angka di bagian ini final dan menjadi satu-satunya acuan. Semua sudah terikat pada konstanta
di `src/core/config.h`.

**Statistik awal pemain.** `hp 100`, `maxHp 100`, `atk 10`, `def 3`, `gold 200`, `potion 2`,
`level 1`, `exp 0`, `pity 0`, `score 0`, `seed 0`, `itemCount 0`, `weaponIndex -1`,
`armorIndex -1`.

**Damage.** Rumus dasar `calculateDamage(atk, def)` adalah `max(1, atk - def) + rand() % 4`.
Contoh uji: `(10, 3)` menghasilkan 7 sampai 10, dan `(2, 3)` menghasilkan 1 sampai 4.
Kritikal berpeluang 10% (`CRIT_CHANCE`) dengan pengali 2 (`CRIT_MULTIPLIER`); sumber
perhitungan crit hanya satu, di modul battle.

**Naik level.** EXP yang dibutuhkan untuk naik level adalah `level * 50`, dengan level
maksimum `MAX_LEVEL 10`. Saat naik level: `maxHp += 15`, `atk += 2`, `def += 1`,
`hp = maxHp`. Di level 10, EXP di-nol-kan.

**Gacha.** Pull 1x 100 gold (`PULL_COST`), pull 10x 900 gold (`PULL10_COST`). Roll
`1..100`: 98–100 Legendary, 86–97 Epic, 61–85 Rare, 1–60 Common. Pity: setiap roll yang
tidak menghasilkan Epic menaikkan counter pity; ketika pity mencapai 10 (`PITY_THRESHOLD`),
hasil dipaksa Epic dan pity kembali 0. Bila inventori penuh dan hasilnya duplikat, `pullOnce`
tetap membayar harga duplikat `DUPLICATE_PRICE_*` (Common 20, Rare 50, Epic 150,
Legendary 500) dan tidak menambah item; pemanggil yang mengembalikan uang bila pull
gagal total.

**Potion.** Harga 40 gold (`POTION_COST`), menyembuhkan 50 HP (`POTION_HEAL`) dengan batas
atas `maxHp`, stok maksimal 20 (`MAX_POTION`).

**Dungeon.** Treasure memberi 30 gold (`TREASURE_GOLD`). Peti (chest) memberi gold
40–120 (`CHEST_GOLD_MIN/MAX`) atau potion, isinya ditentukan secara deterministik per sel
dari seed. Hint berharga 30 gold (`HINT_COST`) dan maksimal 3 kali per run (`MAX_HINTS`).
Seed dunia berada di rentang `0..4294967295`; Enter pada prompt seed mengambil seed dari
jam. Kalah di dungeon mengakhiri run dan membuka layar Game Over.

**Leaderboard.** Maksimal 10 entri (`MAX_LEADERBOARD`), yang ditampilkan hanya 5 teratas
(`TOP_DISPLAY`), diurutkan menurun menurut skor.

**Simpan.** Lima slot (`SAVE_SLOTS`), berkas `save_1.txt` sampai `save_5.txt`. Slot 1 punya
jalur fallback ke `save.txt` legacy ketika berkas slot itu belum ada.

## 7. Desain Data dan Kontrak Modul

Kontrak antarmuka dibekukan di `src/`. Tabel di bawah menyalin prototipe apa
adanya; tanda tangan tidak boleh diubah tanpa persetujuan integrator. Semua modul menerima
`Player *p` atau `const Player *p`, sehingga pola pointer dasar terpakai di mana-mana.

Header dikelompokkan per folder modul. Letak inilah yang dipakai repo ini dan yang
menentukan pemilik folder pada dokumen pembagian tugas.

| Folder | Header |
|---|---|
| `src/core` | `config.h` |
| `src/util` | `util.h` |
| `src/ui` | `ui.h`, `term.h`, `caps.h`, `style.h`, `render.h`, `widgets.h` |
| `src/player` | `player.h` |
| `src/battle` | `battle.h` |
| `src/gacha` | `gacha.h` |
| `src/inventory` | `inventory.h` |
| `src/shop` | `shop.h` |
| `src/storage` | `storage.h` |
| `src/dungeon` | `dungeon.h` |
| `src/platform` | `rng.h`, `atomicfile.h`, `log.h`, `lock.h`, `sig.h`, `crash.h`, `autosave.h`, `platform.h` |

### 7.1 `core/config.h`: konstanta dan struct

| Konstanta | Nilai |
|---|---|
| `MAX_ITEM` | 36 |
| `MAX_MONSTER` | 12 |
| `MAX_NAME` | 30 |
| `CHUNK_SIZE` | 16 |
| `CACHED_CHUNKS` | 5 |
| `AREA_MAX` | `(CHUNK_SIZE * CACHED_CHUNKS)` = 80 |
| `MAX_PATH_CELLS` | `(AREA_MAX * AREA_MAX)` = 6400 |
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
| `TREASURE_GOLD` | 30 |
| `DUNGEON_GOLD_MIN` / `DUNGEON_GOLD_MAX` | 10 / 40 |
| `CHEST_GOLD_MIN` / `CHEST_GOLD_MAX` | 40 / 120 |
| `CHEST_POTION_COUNT` | 2 |
| `CHUNK_MONSTER_PCT` | 45 |
| `CHUNK_CHEST_PCT` | 35 |
| `CHUNK_GOLD_PCT` | 55 |
| `CHEST_EQUIPMENT_PCT` | 55 |
| `CHEST_POTION_PCT` | 25 |
| `RARITY_COMMON` … `RARITY_LEGENDARY` | 1, 2, 3, 4 |
| `DUPLICATE_PRICE_COMMON` / `_RARE` / `_EPIC` / `_LEGENDARY` | 20 / 50 / 150 / 500 |

Struct utama, semuanya didefinisikan di sini dan dipakai semua modul:

- `Item { int id; char name[MAX_NAME]; char type; int rarity; int power; }`: `type`
  berisi `'S'` untuk senjata atau `'A'` untuk armor.
- `Monster { int id; char name[MAX_NAME]; int hp, atk, def; int exp, gold, minLevel; }`
- `Player { char name[MAX_NAME]; int hp, maxHp, atk, def; int level, exp, gold, potion;
  int pity, totalPull, score; unsigned int seed; Item inventory[MAX_ITEM]; int itemCount;
  int weaponIndex, armorIndex; }`: indeks `-1` berarti kosong.
- `Point { int row, col; }`
- `DungeonState { unsigned int seed; int posX, posY; Point taken[MAX_TAKEN_CELLS];
  int takenCount; int originX, originY; }`: menyimpan posisi pemain dalam koordinat dunia
  dan daftar sel konten yang sudah dipakai, agar reload dungeon deterministik.

### 7.2 `util/util.h`

| Prototipe | Catatan |
|---|---|
| `int readLine(char *buf, int max);` | |
| `int readLineEsc(char *buf, int max);` | 1 baris terbaca, 0 EOF, -1 Esc |
| `int readInt(const char *prompt, int min, int max);` | Esc/EOF mengembalikan `min` |
| `int readIntTry(const char *prompt, int min, int max, int *out);` | 0 saat Esc/EOF |
| `int readStringTry(const char *prompt, char *out, int max);` | 0 saat Esc/EOF |
| `int confirmPrompt(const char *prompt);` | y/n, Esc berarti tidak |
| `void readString(const char *prompt, char *out, int max);` | |
| `void clearScreen(void);` | |
| `void printLine(void);` | |
| `void shutdownGame(void);` | |

### 7.3 `ui/ui.h`

| Prototipe | Catatan |
|---|---|
| `void ui_init(void);` | |
| `void ui_shutdown(void);` | |
| `int ui_interactive(void);` | |
| `void set_message(const char *fmt, ...);` | |
| `const char *last_message(void);` | |
| `void ui_log(const char *fmt, ...);` | |
| `void ui_log_style(Style st, const char *fmt, ...);` | |
| `void ui_log_clear(void);` | |
| `void ui_log_event(const char *actor, const char *action, const char *target, const char *value, Style actorSt, Style targetSt, Style valueSt);` | baris log kaya: aktor, aksi, sasaran, angka |
| `int ui_log_count(void);` | |
| `const char *ui_log_text(int i);` | |
| `Style ui_log_style_at(int i);` | |
| `int ui_log_part_count(int i);` | |
| `const char *ui_log_part_text(int i, int part);` | |
| `Style ui_log_part_style(int i, int part);` | |
| `void ui_log_draw(int row, int col, int maxW, int i);` | |
| `void ui_frame(const char *screen);` | |
| `void ui_flush(void);` | |
| `void ui_panel(int row, int col, int w, int h, const char *title);` | |
| `void ui_hp_bar(int row, int col, int w, int hp, int maxHp);` | |
| `void ui_hp_bar_n(int row, int col, int w, int hp, int maxHp);` | lebar persis |
| `void ui_bar(int row, int col, int w, int cur, int max, Style fill);` | |
| `void ui_menu_v(int row, int col, const char *const *items, const int *nums, int n, int sel);` | |
| `void ui_menu_h(int row, int col, const char *const *items, const int *nums, int n, int sel);` | |
| `void ui_footer(const char *extra);` | |
| `void ui_footer_line(const char *text);` | |
| `void ui_message(int row);` | |
| `void ui_status_panel_at(const Player *p, int row, int col, int w);` | |
| `int ui_menu_pick(const char *const *items, const int *nums, int n, int minNum, int maxNum, UiDrawFn draw, void *ctx);` | loop menu bersama, mengembalikan nomor terpilih |
| `int ui_confirm_box(const char *question);` | 1 Ya, 0 Tidak/Esc |
| `void ui_input_screen(const char *name);` | |
| `void ui_line_begin(const char *fmt, ...);` | |
| `void ui_line_end(void);` | |
| `void ui_line_prompt(void);` | |
| `void ui_line_error(const char *fmt, ...);` | |
| `void ui_line_note(const char *fmt, ...);` | |
| `int ui_line_read(char *buf, int max);` | 1 baris, 0 EOF, -1 Esc |
| `int lebar_tampil(const char *s);` | lebar tampil, glyph lebar dihitung dua kolom |
| `int wrap_teks(const char *text, int width, char rows[][192], int maxRows);` | |
| `void render_input_box(const char *question, const char *buffer);` | |
| `int ui_pick_row(int count, UiDrawFn draw, void *ctx);` | pemilih baris tabel, -1 bila batal |
| `int ui_utf8_enabled(void);` | API legacy |
| `void clear_screen(void);` | API legacy |
| `void draw_box_top(const char *title);` | API legacy |
| `void draw_box_bottom(void);` | API legacy |
| `void draw_box_line(const char *fmt, ...);` | API legacy |
| `void format_hp_bar(char *buf, int bufSize, int hp, int maxHp);` | API legacy |
| `void draw_header(const char *title, const Player *p);` | API legacy |
| `void draw_hp_bar(int hp, int maxHp);` | API legacy |
| `void draw_menu(int number, const char *label);` | API legacy |
| `const char *rarity_color(int rarity);` | API legacy |
| `const char *hp_color(int hp, int maxHp);` | API legacy |

Konstanta makro ANSI (`ANSI_RESET` dan kawan-kawan) juga dideklarasikan di header ini
untuk API legacy.

### 7.4 `ui/term.h`

Enum `TermKey` berisi `KEY_NONE`, `KEY_UP`, `KEY_DOWN`, `KEY_LEFT`, `KEY_RIGHT`,
`KEY_ENTER`, `KEY_ESC`, `KEY_RESIZE`, `KEY_EOF`, `KEY_CHAR`.

| Prototipe | Catatan |
|---|---|
| `void term_init(void);` | dipanggil setelah `caps_detect`; raw mode + alt screen |
| `void term_shutdown(void);` | idempoten: pulihkan cooked, kursor, warna, layar |
| `TermKey term_getkey(char *ch);` | blok untuk satu tombol; `KEY_NONE` saat timeout |
| `int term_saved_tio(struct termios *out);` | POSIX saja; 1 bila state cooked tersimpan |
| `void term_raw(void);` | paksa raw input (POSIX) |
| `void term_cooked(void);` | paksa cooked (POSIX), untuk prompt baris |
| `void term_cursor(int on);` | |
| `void term_alt(int on);` | alternate screen |
| `int term_size_query(void);` | segarkan ukuran; 1 bila berubah |
| `void term_poll_size(void);` | perbarui ukuran caps saat resize |

### 7.5 `ui/caps.h`

Enum `ColorMode`: `COLOR_MONO`, `COLOR_16`, `COLOR_256`, `COLOR_TRUE`. Struct `Glyphs`
menampung karakter tepi (`tl`, `tr`, `bl`, `br`, `hz`, `vr`), blok penuh/kosong, penanda
pilihan, dan panah naik-turun untuk footer.

| Prototipe | Catatan |
|---|---|
| `void caps_detect(void);` | |
| `ColorMode caps_color(void);` | |
| `int caps_unicode(void);` | |
| `int caps_interactive(void);` | |
| `int caps_cols(void);` | |
| `int caps_rows(void);` | |
| `void caps_set_size(int cols, int rows);` | |
| `const Glyphs *caps_glyphs(void);` | |

### 7.6 `ui/style.h`

Enum `Style` berisi token semantik: `ST_TEXT`, `ST_TITLE`, `ST_ACCENT`, `ST_BORDER`,
`ST_DIM`, `ST_GOLD`, `ST_DANGER`, `ST_SUCCESS`, `ST_RARITY_COMMON` sampai
`ST_RARITY_LEGENDARY`, `ST_BRONZE`, `ST_SELECTED`, `ST_FOG1..3`, basis biome dan gradien
HP, plus `ST_COUNT`. Makro turunannya: `ST_HP_GRAD(i)`, `ST_BIOME(i)`, `ST_FOG_LEVEL(i)`,
`ST_BIOME_FOG(tier, bi)`, dengan `BIOME_COUNT 8` dan `BIOME_FOG_TIERS 3`.

| Prototipe | Catatan |
|---|---|
| `void style_init(void);` | bangun string ANSI sesuai mode terdeteksi |
| `Style style_rarity(int rarity);` | kelangkaan 1..4 menjadi token |
| `Style style_hp(int hp, int maxHp);` | token ambang untuk mode 256/16/mono |
| `const char *style_fg(Style s);` | string kosong di mono |
| `const char *style_bg(Style s);` | string kosong di mono; terpilih memakai bg atau reverse |

### 7.7 `ui/render.h`

Konstanta: `UI_COLS 50`, `UI_ROWS 20`, `MIN_COLS 40`, `MIN_ROWS 18`, `GRID_MAX_ROWS 64`,
`GRID_MAX_COLS 200`. Struct `Cell { unsigned int cp; Style st; }` menyimpan satu sel
grid layar.

| Prototipe | Catatan |
|---|---|
| `void render_init(void);` | |
| `void render_clear(void);` | |
| `void render_text(int row, int col, Style s, const char *fmt, ...);` | |
| `void render_text_clipped(int row, int col, int maxW, Style s, const char *fmt, ...);` | |
| `int render_span(int row, int col, int maxW, Style base, Style alt, const char *text);` | `~` berganti gaya dasar/alt |
| `void render_char(int row, int col, Style s, unsigned int cp);` | |
| `void render_flush(void);` | interaktif: berwarna dan terpusat; fallback: baris polos |
| `int ui_visible_len(const char *s);` | |
| `int render_max_row(void);` | baris terbawah berisi, untuk menumpuk widget |
| `unsigned int render_cell_cp(int row, int col);` | 0 bila sel kosong |

### 7.8 `ui/widgets.h`

| Prototipe | Catatan |
|---|---|
| `void widget_panel(int row, int col, int w, int h, const char *title);` | |
| `void widget_hp_bar(int row, int col, int w, int hp, int maxHp);` | |
| `void widget_hp_bar_n(int row, int col, int w, int hp, int maxHp);` | lebar persis, warna ambang |
| `void widget_bar(int row, int col, int w, int cur, int max, Style fill);` | |
| `void widget_menu_v(int row, int col, const char *const *items, const int *nums, int n, int sel);` | |
| `void widget_menu_h(int row, int col, const char *const *items, const int *nums, int n, int sel);` | |
| `void widget_footer(const char *extra);` | |
| `void widget_footer_line(const char *text);` | footer khusus, tanpa tombol menu |
| `void widget_footer_reset(void);` | frame baru: footer boleh pilih baris baru |
| `void widget_msg(int row, int col, int w, const char *msg);` | |

### 7.9 `player/player.h`

| Prototipe | Catatan |
|---|---|
| `void initPlayer(Player *p, const char *name);` | |
| `void resetPlayer(Player *p);` | kembali ke nilai awal run; nama dan seed dipertahankan |
| `void addExp(Player *p, int exp);` | |
| `int totalAtk(const Player *p);` | |
| `int totalDef(const Player *p);` | |
| `void showStatus(const Player *p);` | |

### 7.10 `battle/battle.h`

| Prototipe | Catatan |
|---|---|
| `void startBattle(Player *p, const Monster m[], int count);` | |
| `void startBattleAgainst(Player *p, const Monster *enemy);` | musuh spesifik pilihan dungeon |
| `void resumeBattle(Player *p, Monster enemy, int enemyHp);` | |
| `int calculateDamage(int atk, int def);` | |
| `int battleRunAborted(void);` | 1 bila pemain meninggalkan game over ke menu utama |
| `void battleClearRunAbort(void);` | |
| `int battleRunEnded(void);` | 1 bila battle terakhir mengakhiri run (kalah) |
| `void battleClearRunEnded(void);` | |
| `int battleGameOverScreen(Player *p);` | 1 = run baru, 0 = ke menu utama |

### 7.11 `gacha/gacha.h`

| Prototipe | Catatan |
|---|---|
| `void gachaMenu(Player *p, const Item catalog[], int count);` | |
| `int rollRarity(int *pity);` | |
| `int findItemInInventory(const Player *p, int id);` | |
| `int duplicatePrice(int rarity);` | |
| `const char *rarityName(int rarity);` | |
| `int pullOnce(Player *p, const Item catalog[], int count, int rarity);` | 0 bila penuh: pemanggil mengembalikan uang |

### 7.12 `inventory/inventory.h`

| Prototipe | Catatan |
|---|---|
| `void inventoryMenu(Player *p);` | |
| `void sortInventory(Player *p, int mode);` | |
| `int searchItemByName(const Player *p, const char *word);` | |
| `void equipItem(Player *p, int index);` | |
| `void syncEquipped(Player *p, int oldWeaponId, int oldArmorId);` | |

### 7.13 `shop/shop.h`

| Prototipe | Catatan |
|---|---|
| `void shopMenu(Player *p);` | |

### 7.14 `storage/storage.h`

`SAVE_SLOTS` bernilai 5.

| Prototipe | Catatan |
|---|---|
| `int loadCatalog(const char *file, Item items[]);` | |
| `int loadMonsters(const char *file, Monster monsters[]);` | |
| `int saveGame(const Player *p);` | |
| `int saveGameSlot(const Player *p, int slot);` | |
| `int loadGame(Player *p, const Item items[], int count);` | |
| `int loadGameSlot(Player *p, const Item items[], int count, int slot);` | |
| `void saveSlotPath(int slot, char *out, int size);` | |
| `int saveSlotExists(int slot);` | |
| `int saveSlotName(int slot, char *out, int size);` | |
| `int saveSlotFirstFree(void);` | |
| `void recordScore(const Player *p);` | |
| `void showLeaderboard(void);` | |

### 7.15 `dungeon/dungeon.h`

| Prototipe | Catatan |
|---|---|
| `unsigned int cellHash(unsigned int seed, int x, int y);` | |
| `char dungeonCell(unsigned int seed, int x, int y);` | |
| `unsigned int randomWorldSeed(void);` | |
| `unsigned int promptWorldSeed(void);` | |
| `int promptWorldSeedTry(unsigned int *out);` | 0 bila pemain batal dengan Esc |
| `int dfsReachable(char area[][AREA_MAX], Point from, Point to);` | |
| `int bfsShortestPath(char area[][AREA_MAX], Point from, Point to, Point path[]);` | |
| `void runDungeon(Player *p, const Item catalog[], int catalogCount, const Monster monsters[], int monsterCount);` | |
| `void resumeDungeon(Player *p, const DungeonState *saved, int steps, int hints, const Item catalog[], int catalogCount, const Monster monsters[], int monsterCount);` | |

### 7.16 `platform/rng.h`

PRNG yang dapat diserialisasi: call site sama dengan `rand()`, tetapi state-nya bisa
disimpan dan dipulihkan sehingga sesi yang pulih melanjutkan urutan angka yang persis sama.

| Prototipe | Catatan |
|---|---|
| `void plat_srand(unsigned seed);` | |
| `unsigned plat_rand(void);` | |
| `unsigned long long plat_rng_state(void);` | |
| `void plat_rng_set(unsigned long long state);` | |

### 7.17 `platform/atomicfile.h`

| Prototipe | Catatan |
|---|---|
| `int file_write_atomic(const char *path, const void *data, size_t len);` | tulis ke `<path>.tmp.<pid>`, flush, lalu rename di atas `<path>`; 1 bila berhasil |
| `void file_cleanup_tmp(const char *dir);` | hapus sisa `<dir>/<file>.tmp.<pid>` dari crash sebelumnya |

### 7.18 `platform/log.h`

Log aplikasi ringan ke `data/game.log`; setiap baris langsung di-flush sehingga crash
meninggalkan peristiwa terakhirnya di disk.

| Prototipe | Catatan |
|---|---|
| `void log_init(void);` | |
| `void log_close(void);` | |
| `void log_event(const char *fmt, ...);` | |
| `void log_warn(const char *fmt, ...);` | |
| `void log_error(const char *fmt, ...);` | |
| `void log_crash(const char *fmt, ...);` | bisa dipanggil dari crash handler |

### 7.19 `platform/lock.h`

Kunci sesi eksklusif non-blocking pada `data/session.lock`, dipegang sepanjang umur
proses. Isinya `RUNNING pid=<pid> start=<epoch>` selama bermain dan `CLEAN` sesudah keluar
rapi; status RUNNING yang ditemukan saat start berarti proses sebelumnya crash atau
dipaksa mati.

| Prototipe | Catatan |
|---|---|
| `int lock_acquire(void);` | 1 berhasil, 0 gagal |
| `int lock_is_contention(void);` | 1 = instance lain memegangnya, 0 = galat berkas |
| `int lock_previous_running(void);` | 1 bila status sebelum akuisisi RUNNING |
| `void lock_mark_clean(void);` | langkah terakhir keluar rapi |

### 7.20 `platform/sig.h`

Penanganan sinyal shutdown: handler hanya menyalakan flag dan menyentuh self-pipe agar
`poll()` pada stdin langsung bangun. Watchdog memaksa keluar 3 detik kemudian bila jalur
pembersihan menggantung; sinyal kedua diabaikan.

| Prototipe | Catatan |
|---|---|
| `void sig_install(void);` | handler + self-pipe + watchdog |
| `int sig_requested(void);` | 1 setelah sinyal shutdown tiba |
| `void sig_cleanup_done(void);` | watchdog berhenti setelah CLEAN |
| `int sig_wake_fd(void);` | fd untuk poll selain stdin; -1 di Windows |

### 7.21 `platform/crash.h`

| Prototipe | Catatan |
|---|---|
| `void crash_install(void);` | handler sinyal fatal (POSIX): pulihkan terminal dari data statis, tambah `data/crash.log`, lalu re-raise; Windows mengandalkan kunci sesi |

### 7.22 `platform/autosave.h`

Enum layar: `AS_SCREEN_MENU`, `AS_SCREEN_HUB`, `AS_SCREEN_BATTLE`, `AS_SCREEN_DUNGEON`.
Struct `AutoSnapshot` menyimpan `Player`, layar aktif, state battle (aktif, musuh, HP
musuh), state dungeon (aktif, `DungeonState`, langkah, hint), dan state RNG.

| Prototipe | Catatan |
|---|---|
| `void autosave_start(void);` | thread latar: tidur di condvar, tulis snapshot terbaru dengan debounce, lewati CRC yang tidak berubah, coba ulang tulis gagal dengan backoff 1/2/4 s sampai 30 s |
| `void autosave_stop(void);` | flush snapshot tertunda, gabung thread |
| `void autosave_publish(const Player *p, int screen, const Monster *enemy, int enemyHp, const DungeonState *dst, int steps, int hints, int important);` | copy-on-publish di titik aman; `important=1` melewati debounce |
| `int autosave_load(AutoSnapshot *out);` | muat `data/autosave.dat` (fallback `autosave.bak`); validasi magic, versi, panjang, CRC32 |
| `int autosave_poll_error(char *buf, int len);` | drain galat non-blocking untuk panel pesan |

### 7.23 `platform/platform.h`

| Prototipe | Catatan |
|---|---|
| `void platform_init(void);` | pembersihan tmp yatim, kunci sesi, handler crash dan sinyal, thread autosave; mendaftarkan `platform_shutdown` via `atexit`; keluar dengan pesan bila terkunci |
| `int platform_previous_running(void);` | sesi terakhir RUNNING (crash/kill) |
| `int platform_shutdown_requested(void);` | sinyal shutdown tiba |
| `void platform_shutdown(void);` | idempoten; CLEAN ditulis terakhir |
| `void platform_sleep_ms(int ms);` | jeda singkat untuk pacing frame |

## 8. Format File

- `data/item.txt`: katalog item, format `id|nama|tipe|rarity|power`, tepat 36 baris:
  id 1–18 bertipe `S` (senjata) dan id 19–36 bertipe `A` (armor).
- `data/monster.txt`: katalog monster, format `id|nama|hp|atk|def|exp|gold|minLevel`,
  tepat 12 baris.
- `data/save_<n>.txt`: slot simpan. Baris pertama memuat 15 field berpipa:
  `nama|hp|maxHp|level|exp|gold|atk|def|potion|pity|totalPull|score|seed|weaponId|armorId`.
  Baris kedua berisi `itemCount`, lalu diikuti `itemCount` baris berisi id item.
- `data/leaderboard.txt`: satu baris per entri berformat `nama|level|skor`, maksimal 10.
- `data/autosave.dat`: biner: magic `GQAS`, versi, panjang, CRC32, lalu payload
  `AutoSnapshot`; cadangannya `autosave.bak`.
- `data/session.lock`: teks `RUNNING pid=<pid> start=<epoch>` selama bermain,
  `CLEAN` sesudah keluar rapi.

## 9. Pemetaan Materi Kuliah

Setiap materi punya wujud wajib di kode dan bukti pengujian. Kolom bukti menunjuk ID
skenario di bagian 11 atau driver `bin/t_*` yang memverifikasinya.

| Materi | Wujud wajib | Pemilik | Bukti |
|---|---|---|---|
| Pertemuan 1: lingkungan & struktur program | struktur repo + header guard, `main.c`, Makefile target `all/start/test/clean` | P1 | `make test` lulus; S01–S18 |
| Pertemuan 2: input, output, variabel, tipe data | `readLine/readInt/readString`, struct `Player`, tabel status/inventory | P1, P3 | S01, S02; `t_util`, `t_player` |
| Pertemuan 3: operator, ekspresi, konversi, tracing | `calculateDamage`, `totalAtk/totalDef`, `rollRarity`, konversi digit `char` ke `int` saat parsing | P3, P4, P5 | `t_battle`, `t_gacha`; S03 |
| Pertemuan 4: if / else-if / nested / switch | switch menu, rantai else-if roll rarity, hasil battle, validasi input | semua | S02, S05, S18 |
| Pertemuan 5: perulangan | loop menu, loop battle, pull 10x, loop validasi input | P3, P4 | S03, S05 |
| QUIZ | checkpoint evaluasi sesi 1–5; latihan tracing `addExp` dan `calculateDamage` | P1 | `t_player`, `t_battle` |
| UTS | checkpoint evaluasi sesi 1–7; soal tracing dan pembacaan kode modul yang sudah ada | P1 | `t_player`, `t_battle`, `t_dungeon` |
| Pertemuan 7: perulangan bersarang | `genMaze`/`connectChunk`, bubble dan selection sort, pemindaian chunk | P2, P4 | `t_dungeon`, `t_inventory` |
| Array satu dimensi | `Item inventory[MAX_ITEM]`, `Monster m[]`, `Point taken[]`, leaderboard | P4, P5 | `t_inventory`, `t_leaderboard` |
| Array dua dimensi | `char g[][CHUNK_SIZE]`, `char area[][AREA_MAX]`, `queue[][2]`, `opts[4][2]` | P2 | S12, S14 (`t_dungeon`) |
| Karakter & string | `char name[MAX_NAME]`, `strcmp/strncpy/sscanf`, lowercase, parsing pipa `\|` | P4, P5 | S10, S11; `t_storage` |
| Pointer dasar & parameter alamat | `Player *p` di semua modul, `int *pity`, `Point path[]`, buffer keluaran | semua | S06/S07 (`t_gacha`), S14 |
| struct, typedef, array of structs | `Item/Monster/Player/Point/DungeonState` di `config.h` | P1 (kontrak), semua (memakai) | semua driver |
| Searching & sorting | `findItemInInventory` (sequential), `sortInventory` mode 1/3 (bubble), mode 2 (selection), leaderboard top 10 | P4, P5 | S08, S15 |
| File teks & persistensi | `loadCatalog/loadMonsters`, `saveGameSlot/loadGameSlot`, `recordScore`, `file_write_atomic` | P5 | S10, S11, S15, S17 |
| Penanganan error file/input | pesan gagal muat/simpan, validasi angka dan nama, fallback non-interaktif | P5, P1 | S01, S02, S11 |
| Pengujian dasar | `tests/run_tests.sh`, driver `t_*` lulus tanpa warning | semua | seluruh S01–S18 |

## 10. Validasi dan Penanganan Error

Aturan dasarnya satu: input yang salah tidak boleh membuat program crash. Angka di luar
rentang menu, huruf pada tempat angka, dan baris kosong diperingati lalu diminta ulang
(`Input tidak valid`), dan semua pembacaan input punya jalur Esc/EOF yang rapi.

- **Nama pemain.** Nama kosong ditolak dan diminta ulang; nama lebih panjang dari 29
  karakter dipotong, sehingga `MAX_NAME 30` tetap aman dengan terminator nol.
- **Berkas hilang atau rusak.** Katalog, katalog monster, slot simpan, dan leaderboard yang
  hilang atau tak bisa diurai menghasilkan pesan yang jelas (`Gagal memuat` pada S11), bukan
  segmentasi memori. Autosave yang gagal CRC jatuh ke `autosave.bak`.
- **Gold tidak boleh negatif.** Semua pembelian memeriksa saldo lebih dulu dan menolak dengan
  pesan yang menyebut kekurangannya (`Gold kurang! Butuh 900 gold`, `Gold kurang, hint butuh
  30 gold`); pengurangan gold tidak pernah menembus nol.
- **Instance kedua ditolak.** Kunci sesi `data/session.lock` membuat proses kedua keluar
  dengan pesan saat proses pertama masih RUNNING.
- **Penulisan berkas selalu atomik.** Semua modul menulis lewat `file_write_atomic`, sehingga
  crash di tengah tulisan tidak pernah meninggalkan berkas setengah jadi.

## 11. Kriteria Penerimaan

Skenario berikut adalah definisi "selesai". Driver adalah program uji mandiri yang lulus
dengan kode keluar 0 dan tanpa keluaran; skenario memipakan input ke `bin/game` lalu
mencari penanda di keluarannya.

| ID | Skenario | Penanda output |
|---|---|---|
| S01 | nama kosong/terlalu panjang | `\| Pemain : AAAAAAAAAAAAAAAAAAAAAAAAAAAAA` |
| S02 | input huruf pada menu | `Input tidak valid` |
| S03 | battle sampai menang | `Hadiah:` |
| S04 | battle sampai kalah | `Kamu dikalahkan` |
| S05 | gacha 10x gold kurang | `Gold kurang! Butuh 900 gold` |
| S06/S07 | rarity, pity, duplikat (driver) | exit 0 `bin/t_gacha` |
| S08 | urut & cari inventory (driver) | exit 0 `bin/t_inventory` |
| S09 | jual item | `Terjual:` |
| S10 | simpan-lanjutkan | `Selamat datang kembali, UjiSv!` |
| S11 | save rusak | `Gagal memuat` |
| S12 | gerak ke tembok | `Tembok! Tidak bisa lewat.` |
| S13 | hint gold kurang | `Gold kurang, hint butuh 30 gold` |
| S14 | dungeon deterministik, DFS & BFS (driver) | exit 0 `bin/t_dungeon` |
| S15 | leaderboard tercatat/urut | `Skor UjiSkr`, exit 0 `bin/t_leaderboard` |
| S16 | seed dunia | `dibangun dari seed 777` (muncul 2 kali) |
| S17 | autosave atomik, CRC, `.bak`, kunci sesi | exit 0 `bin/t_platform` |
| S18 | kalah membuka game over | `Mulai ulang (reset run)` |

Cara menjalankannya: dari akar repo kerja yang sudah berisi `src/`, `data/`, `tests/`, dan
`main.c` plus `Makefile`, jalankan `sh tests/run_tests.sh`. Skrip mengompilasi sembilan
driver `bin/t_*` dan `bin/game` dengan flag `-std=c11 -Wall -Wextra -Wpedantic -D_POSIX_C_SOURCE=200809L`, menjalankan
semua driver dan 13 pemanggilan skenario (S16 diuji dua kali sehingga total 23 cek), lalu mencetak ringkasan
`=== Ringkasan: N lulus, M gagal ===`. Skrip berakhir dengan status keluar 0 hanya bila
semua lulus. Opsi sanitizer tambahan dapat diberikan sebagai argumen pertama, misalnya
`sh tests/run_tests.sh -fsanitize=address,undefined`.

## 12. Rencana Kerja

Pekerjaan dibagi lima peran (P1–P5, lihat `PEMBAGIAN-TUGAS.md`) dan berjalan dalam fase
bertag. Setiap fase punya pemilik tunggal dan satu tag git sebagai penanda selesai.

| Fase | Tag | Pemilik | Isi |
|---|---|---|---|
| F0 Kontrak | `contract-v1` | P1 | kontrak di `src/` dibekukan, Makefile dan stub `main.c` membuat `bin/game` ter-link |
| F1 UI dan platform | `ui-ready` | P1 | `src/util`, `src/ui`, `src/platform` selesai; `t_platform` lulus; Menu Utama, Game Baru, Load Game, Leaderboard, Hub tampil |
| F2 Modul paralel | `modul-dungeon`, `modul-battle-player`, `modul-gacha-inventory`, `modul-shop-storage` | P2, P3, P4, P5 | masing-masing di branch `feat/<modul>` miliknya |
| F3 Integrasi | `integrasi` | P1 | semua branch digabung ke `dev`, `make test` hijau penuh |
| F4 Rilis | `rilis` | semua | uji penuh S01–S18, demo, presentasi |
