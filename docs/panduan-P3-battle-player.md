# Panduan P3 — Battle dan Player

## Peran

Kamu adalah P3, anggota dengan level awam. Tugasmu dua modul yang saling terkait erat: player dan battle. Modul player menyimpan segala yang menempel pada pemain, mulai dari statistik, level, sampai inventory. Modul battle mengurus pertarungan, mulai dari hitungan damage sampai layar game over. Keduanya jantung dari gameplay, dan hampir semua modul lain memanggil kodemu.

Sebagai anggota awam, kamu tidak diharapkan sudah pernah menulis program C sebesar ini. Panduan ini disusun supaya kamu bisa mengerjakan milestone demi milestone tanpa harus menebak. Kalau ada bagian yang belum paham, tanyakan ke P1 atau P2 lebih dulu sebelum menulis kode, jangan setelah kode jadi.

## File Milik

| File | Isi |
|---|---|
| `src/player/player.c` | Implementasi modul player |
| `src/battle/battle.c` | Implementasi modul battle |

Header `player.h` dan `battle.h` sudah ada di kontrak dan tidak boleh kamu ubah sendiri. Kalau kamu merasa butuh fungsi atau field baru, ajukan ke P1. Driver test `t_player.c` dan `t_battle.c` juga bukan milikmu; kamu hanya menjalankannya.

## Jalur Mahir

Untuk P3 yang sudah nyaman C. Kamu tetap memegang dua modul dan wajib memenuhi
angka yang dibekukan; panduan rinci di bawah menjelaskan tiap milestone.

- Baca dulu: `src/player/player.h`, `src/battle/battle.h`, `src/core/config.h`, `tests/t_player.c`, `tests/t_battle.c`, `docs/PRD.md` §6.
- Urutan: statistik awal, EXP dan level, damage dan crit, loop battle, game over dan flag, panel status.
- Bukti diterima: `bin/t_player` dan `bin/t_battle` lulus, S03/S04/S18 lulus, log crit sama dengan damage yang masuk.
- Jebakan: crit hanya dihitung di satu jalur; level maksimal 10 dengan EXP direset; reset run mempertahankan nama dan seed; flag hasil battle dibersihkan setelah dibaca.

## Konteks untuk AI

Bagian ini untuk kamu yang mengerjakan panduan ini bersama AI. Tempelkan bagian ini apa adanya supaya AI tidak menebak. Kalau AI hanya membaca panduan ini dan dua header modul, isinya sudah cukup untuk mulai menulis kode.

### Tugas

Kamu memegang dua modul: `src/player/*` dan `src/battle/*`. Modul player mengisi statistik pemain, menambah EXP dan menaikkan level, menghitung stat efektif dari item terpasang, dan menampilkan panel status. Modul battle menghitung damage, menjalankan alur pertarungan giliran demi giliran, membagikan hadiah, dan menangani layar game over beserta flag yang dibaca pemanggil. Keduanya dipanggil hampir semua modul lain, jadi angka dan nama fungsi harus persis seperti kontrak.

### Batasan keras

- Bahasa C11, dikompilasi dengan `-Wall -Wextra -Wpedantic` dan harus bersih dari warning.
- Tanpa `malloc`, tanpa alokasi dinamis, tanpa rekursi. Semua data memakai array tetap dan struct yang sudah ada di `config.h`.
- Tanpa `printf` ke layar. Semua keluaran lewat API `ui.h`, termasuk log pertarungan lewat `ui_log*`.
- Angka acak hanya lewat `plat_rand()` dari `platform/rng.h`. `rand()` bawaan C dilarang.
- Jangan menyentuh file modul lain, `main.c`, `Makefile`, header kontrak, atau file test.
- Jangan mengubah test agar lulus. Kalau test gagal, perbaiki implementasinya.

### Angka yang dibekukan

| Hal | Nilai |
|---|---|
| Statistik awal | `hp 100`, `maxHp 100`, `atk 10`, `def 3`, `gold 200`, `potion 2`, `level 1`, `exp 0` |
| Field run awal | `pity 0`, `score 0`, `seed 0`, `itemCount 0`, `weaponIndex -1`, `armorIndex -1` |
| Rumus damage | `calculateDamage(atk, def) = max(1, atk - def) + plat_rand() % 4` |
| Contoh damage | `(10, 3)` menghasilkan 7..10; `(2, 3)` menghasilkan 1..4 |
| Crit | peluang 10 persen, pengali 2, diputuskan di satu tempat saja |
| Syarat naik level | EXP yang dibutuhkan `level * 50` |
| Efek naik level | `maxHp += 15`, `atk += 2`, `def += 1`, `hp = maxHp` |
| Batas level | `MAX_LEVEL 10`; di level 10 `exp` diset `0` |
| Potion | `POTION_HEAL 50`, dipulihkan dengan batas atas `maxHp`; `MAX_POTION 20` |

Rumus damage dan aturan crit tidak boleh diubah, termasuk angka `4` pada `rand() % 4`. Pengurangan HP berhenti di 0, tidak pernah negatif.

### Prototipe dari `src/player/player.h`

| Prototipe |
|---|
| `void initPlayer(Player *p, const char *name);` |
| `void resetPlayer(Player *p);` |
| `void addExp(Player *p, int exp);` |
| `int totalAtk(const Player *p);` |
| `int totalDef(const Player *p);` |
| `void showStatus(const Player *p);` |

`resetPlayer` mengembalikan nilai run ke awal tetapi mempertahankan nama pemain dan `seed`.

### Prototipe dari `src/battle/battle.h`

| Prototipe |
|---|
| `void startBattle(Player *p, const Monster m[], int count);` |
| `void startBattleAgainst(Player *p, const Monster *enemy);` |
| `void resumeBattle(Player *p, Monster enemy, int enemyHp);` |
| `int calculateDamage(int atk, int def);` |
| `int battleRunAborted(void);` |
| `void battleClearRunAbort(void);` |
| `int battleRunEnded(void);` |
| `void battleClearRunEnded(void);` |
| `int battleGameOverScreen(Player *p);` |

### Prompt siap tempel

```text
Kamu membantu saya mengerjakan modul player dan battle pada proyek game
terminal C11. Lampiran saya: docs/panduan-P3-battle-player.md,
src/player/player.h, dan src/battle/battle.h. Baca ketiganya sebelum menulis.

Aturan yang tidak boleh dilanggar:
- Nama dan tanda tangan fungsi harus persis seperti dua header itu. Jangan
  mengarang fungsi, field struct, atau konstanta baru.
- Rumus damage persis: calculateDamage(atk, def) = max(1, atk - def) +
  plat_rand() % 4. Contoh: (10, 3) menghasilkan 7..10; (2, 3) menghasilkan 1..4.
  Crit berpeluang 10 persen dengan pengali 2, diputuskan di satu tempat saja.
- Semua angka acak lewat plat_rand(). Jangan pakai rand() atau srand() bawaan C.
- Tanpa malloc, tanpa rekursi, tanpa printf layar. Tampilan lewat API ui.h,
  log pertarungan lewat ui_log*.
- Jangan mengubah header, file test, Makefile, main.c, atau modul lain.
- Kompilasi bersih dengan -std=c11 -Wall -Wextra -Wpedantic -D_POSIX_C_SOURCE=200809L.

Kerjakan milestone demi milestone sesuai panduan, tunjukkan kode yang
berubah, dan berhenti kalau ada bagian panduan yang tidak jelas.
```

### Skenario yang harus lulus

| Skenario | Penanda | Cara jalan |
|---|---|---|
| S03 battle sampai menang | `Hadiah:` | `tests/run_tests.sh` |
| S04 battle sampai kalah | `Kamu dikalahkan` | `tests/run_tests.sh` |
| S18 kalah membuka game over | `Mulai ulang (reset run)` | `tests/run_tests.sh` |
| Driver player | exit 0 `bin/t_player` tanpa FAIL | `make test` |
| Driver battle | exit 0 `bin/t_battle` tanpa FAIL | `make test` |

## Prasyarat

Pastikan semua ini siap sebelum milestone pertama:

- Repo kerja sudah disiapkan mengikuti `panduan-0-git-dan-kompilasi.md`, repo hasil clone sudah berisi `src/` (header saja), `data/`, dan `tests/` di root.
- Build P1 sudah jalan: `make` menghasilkan `bin/game` dari scaffold berisi stub. Kamu butuh build ini supaya driver-mu bisa dikompilasi dan dijalankan.
- `src/player/player.h` dan `src/battle/battle.h` sudah kamu baca sampai selesai. Nama fungsi di kodemu harus persis sama dengan yang ada di sana.
- Kamu paham konstanta yang relevan dari `config.h`: `MAX_LEVEL 10`, `CRIT_CHANCE 10`, `CRIT_MULTIPLIER 2`, `POTION_HEAL 50`, dan struct `Player` beserta `Monster`.
- Kamu tahu cara memakai `plat_rand()` dari `platform/rng.h`, karena semua angka acak di modulmu wajib lewat situ.
- Kamu tahu cara memakai API UI dari `ui.h` untuk semua tampilan, karena `printf` ke layar dilarang.

## Langkah Kerja

Kerjakan milestone berurutan. Setiap milestone menumpuk di yang sebelumnya, jadi jangan lompat. Setiap milestone punya blok `Expected` sebagai tanda selesai.

### Milestone 1 — `initPlayer` dan `resetPlayer`

Mulai dari fondasi. `initPlayer` mengisi struct `Player` dengan nilai awal untuk pemain baru, sedangkan `resetPlayer` mengembalikan nilai-nilai run ke awal tanpa mengubah nama dan seed dunia. Nilai awalnya sudah dibekukan, dan driver `t_player.c` menguji semuanya satu per satu:

- `hp 100`, `maxHp 100`, `atk 10`, `def 3`
- `gold 200`, `potion 2`, `level 1`, `exp 0`
- `pity 0`, `totalPull 0`, `score 0`, `seed 0`
- `itemCount 0`, `weaponIndex -1`, `armorIndex -1`

Perhatikan perbedaan keduanya. `resetPlayer` dipakai saat pemain memilih `Mulai ulang (reset run)` di layar game over, jadi nama dan seed harus tetap. Kalau kamu mengosongkan nama di situ, run baru kehilangan identitas pemainnya dan test save-muat akan gagal di tempat lain.

```text
Expected
bin/t_player lulus: semua CHECK pada nilai awal terpenuhi, driver keluar
tanpa mencetak FAIL dan exit code 0. Kompilasi tanpa warning.
```

### Milestone 2 — `addExp` dan naik level

Sekarang pemain bisa bertumbuh. `addExp` menambahkan exp, lalu menaikkan level selama exp yang terkumpul mencukupi. Aturannya:

- Butuh exp untuk naik level adalah `level * 50`.
- Setiap naik level: `maxHp += 15`, `atk += 2`, `def += 1`, dan `hp = maxHp` (pemain pulih penuh).
- Level maksimum `MAX_LEVEL 10`. Di level 10, exp tidak lagi menumpuk dan langsung diset `0`.

Driver `t_player.c` menguji beberapa kasus sekaligus, misalnya `addExp(&p, 100)` dari level 1 harus menghasilkan level 2 dengan sisa exp 50, dan stat yang ikut naik. Ada juga kasus pemain level 9 yang diberi exp sangat besar: dia harus berhenti di level 10 dengan exp 0, bukan meluber ke level 11.

Kasus banyak level sekaligus (naik dari level 1 langsung ke level 4 karena exp besar) adalah jebakan yang paling sering dilewatkan. Naik level harus diproses berulang dalam satu pemanggilan `addExp`, bukan sekali saja.

```text
Expected
bin/t_player tetap lulus penuh, termasuk kasus naik beberapa level dalam
satu pemanggilan dan kasus level 10 yang exp-nya terkunci di 0.
```

### Milestone 3 — `calculateDamage` dan crit

Formula damage sudah dibekukan:

```c
max(1, atk - def) + plat_rand() % 4
```

Bagian `max(1, ...)` menjaga damage tidak pernah nol atau negatif walaupun pertahanan lawan lebih tinggi dari serangan. Driver `t_battle.c` memanggil fungsi ini seribu kali dan memeriksa rentang hasilnya: `(10, 3)` harus menghasilkan 7 sampai 10, dan `(5, 20)` harus menghasilkan 1 sampai 4.

Untuk crit, aturannya satu sumber saja. Peluang crit adalah `CRIT_CHANCE 10` persen dan pengalinya `CRIT_MULTIPLIER 2`. Tulis satu fungsi atau satu tempat di `battle.c` yang memutuskan crit, lalu semua jalur serangan memanggil tempat itu. Jangan biarkan ada dua tempat yang masing-masing melempar dadanya sendiri, karena hasilnya tidak konsisten dan sulit dilacak.

Semua angka acak lewat `plat_rand()`. Jangan menyentuh `rand()` bawaan C sama sekali, karena seed dunia dan hasil test bergantung pada urutan angka dari `plat_rand()`.

```text
Expected
bin/t_battle lulus: seribu pemanggilan calculateDamage semuanya berada
dalam rentang yang diharapkan, exit code 0, kompilasi tanpa warning.
```

### Milestone 4 — Loop battle

Sekarang bagian yang dilihat pemain. `startBattle` menjalankan pertarungan acak sesuai level pemain dari katalog monster, dan `startBattleAgainst` menjalankan pertarungan terhadap satu monster tertentu, dipakai oleh dungeon yang sudah menentukan lawannya dari seed. `resumeBattle` melanjutkan pertarungan yang tertunda karena pemain keluar atau autosave, dengan sisa HP lawan yang disimpan.

Loop battle menampilkan menu dengan pilihan `Serang`, `Bertahan`, `Potion`, dan `Kabur`. Perilaku tiap pilihan:

- `Serang`: hitung damage lewat `calculateDamage` (termasuk peluang crit), kurangi HP lawan, catat di log pertarungan.
- `Bertahan`: damage yang diterima pemain di giliran lawan berkurang. Besaran pengurangannya kamu putuskan sendiri selama konsisten dan wajar.
- `Potion`: memakai satu potion, memulihkan `POTION_HEAL 50` HP dengan batas atas `maxHp`. Potion habis berarti pilihan ini ditolak.
- `Kabur`: mengakhiri battle tanpa hadiah. Pertimbangkan peluang gagal kabur dengan `plat_rand()`; yang penting perilakunya jelas bagi pemain lewat log.

Setiap giliran lawan membalas memakai `calculateDamage` juga, kali ini dengan atk lawan dan def pemain. HP keduanya tidak pernah negatif; berhenti di 0.

Hadiah saat menang diambil dari field `Monster`: `exp` masuk lewat `addExp`, `gold` masuk ke kantong pemain. Keduanya ditampilkan dengan kata `Hadiah:` di output, karena itu penanda skenario S03. Saat pemain kalah, HP pemain mencapai 0 dan layar menampilkan pesan yang memuat `Kamu dikalahkan`, penanda skenario S04.

Seluruh tampilan lewat API UI dari P1, termasuk log pertarungan lewat `ui_log*`. Tidak ada `printf` ke layar di file-mu.

```text
Expected
Skenario S03 lulus lewat run_tests.sh: battle sampai menang dan output
memuat "Hadiah:". Skenario S04 lulus: battle sampai kalah dan output
memuat "Kamu dikalahkan". Keduanya dijalankan dengan input dari tests/.
```

### Milestone 5 — Game over dan flag battle

Kekalahan tidak langsung mengembalikan pemain ke menu. Ada layar game over dengan dua pilihan: `Mulai ulang (reset run)` yang memanggil `resetPlayer` lalu memulai run baru, atau `Kembali ke menu utama` yang keluar dari run.

Karena battle kadang terjadi di dalam layar lain (dungeon memanggil `startBattleAgainst`), hasil pilihan pemain harus sampai ke pemanggil. Di situlah flag dan fungsi pendukung dari `battle.h` bekerja:

- `battleRunEnded` bernilai 1 kalau battle terakhir mengakhiri run karena kekalahan. Pemanggil membaca ini lalu menghentikan run-nya. Setelah dibaca, panggil `battleClearRunEnded` supaya flag tidak tertinggal menyala.
- `battleRunAborted` bernilai 1 kalau pemain keluar dari layar game over menuju menu utama. Bersihkan dengan `battleClearRunAbort`.
- `battleGameOverScreen` menjalankan layar game over itu sendiri dan mengembalikan 1 bila pemain memilih run baru, 0 bila kembali ke menu. Fungsi ini dipakai encounter yang selesai di dalam layar modul lain.

`resumeBattle` melengkapi gambar: saat run disimpan di tengah battle, HP lawan ikut tersimpan, dan pemanggilan `resumeBattle` dari dungeon memulihkan pertarungan dari keadaan itu.

```text
Expected
Skenario S18 lulus lewat run_tests.sh: kekalahan membuka layar game over
dan output memuat "Mulai ulang (reset run)". Memilih run baru memanggil
resetPlayer dengan benar, nama dan seed tetap, stat kembali ke awal.
```

### Milestone 6 — Status panel dan stat efektif

Terakhir, pemain butuh melihat dirinya. `showStatus` menampilkan panel status lewat API UI: nama, HP saat ini dibanding `maxHp`, level, exp, gold, jumlah potion, pity, dan skor. Item yang terpasang ikut terlihat, karena stat efektifnya dihitung dari sana.

`totalAtk` dan `totalDef` menjumlahkan stat dasar dengan power item yang terpasang. Field `weaponIndex` dan `armorIndex` bernilai `-1` kalau tidak ada yang terpasang, jadi keduanya wajib diperiksa sebelum mengakses `inventory`. Driver `t_player.c` menguji kasus tanpa item terpasang (hasil sama dengan stat dasar) dan kasus senjata power 7 dengan armor power 4 (hasil stat dasar ditambah keduanya).

Fungsi ini dipakai hampir semua modul lain untuk menghitung damage, jadi pastikan benar sebelum menyatakan selesai.

```text
Expected
bin/t_player lulus penuh, termasuk CHECK totalAtk dan totalDef dengan
senjata serta armor terpasang. Panel showStatus tampil rapi di layar
game tanpa keluar dari batas 50x20.
```

## Definition of Done

Pekerjaanmu selesai kalau semua ini terpenuhi:

- `bin/t_player` dan `bin/t_battle` lulus tanpa warning saat dikompilasi dengan flag standar repo.
- Skenario S03, S04, dan S18 lulus lewat `run_tests.sh`.
- Crit diputuskan di satu tempat saja, dan semua angka acak lewat `plat_rand()`.
- Tidak ada `printf` layar di `src/player/` dan `src/battle/`; semua tampilan lewat API UI.
- `resetPlayer` menjaga nama dan seed; `battleRunEnded` dan `battleRunAborted` selalu dibersihkan setelah dibaca.
- Kamu bisa menjelaskan fungsi apa pun di file-mu ke P1 saat review.
- Commit dengan format `feat(battle): ...` atau `feat(player): ...` dan PR dibuka ke branch `dev`.

## Larangan

- Jangan memakai `printf` untuk tampilan layar. Semua keluaran lewat API UI dari `ui.h`.
- Jangan memakai `rand()`. Semua keacakan lewat `plat_rand()` supaya seed tetap berarti.
- Jangan menyentuh file milik modul lain, termasuk `src/ui`, `main.c`, `src/dungeon`, `src/gacha`, dan `src/inventory`. Kebutuhan lintas modul bicarakan ke P1.
- Jangan mengubah `player.h`, `battle.h`, atau file test supaya test lulus. Kalau test menemukan bug, perbaiki implementasinya.
- Jangan menambah fungsi publik baru tanpa persetujuan P1.

## Rujukan

- `src/player/player.h` dan `src/battle/battle.h` — daftar fungsi dan konvensi nilai kembali.
- `src/core/config.h` — konstanta `MAX_LEVEL`, `CRIT_CHANCE`, `CRIT_MULTIPLIER`, `POTION_HEAL`, struct `Player` dan `Monster`.
- `tests/t_player.c` dan `tests/t_battle.c` — driver yang menjadi spesifikasi perilaku.
- `tests/run_tests.sh` — cara skenario S03, S04, dan S18 dijalankan.
- `docs/PRD.md` bagian 6 dan 7 — aturan game battle dan kontrak modul.
- `docs/PEMBAGIAN-TUGAS.md` — aturan kepemilikan file dan alur PR.
- `docs/panduan-0-git-dan-kompilasi.md` — setup repo, branch, dan build.
