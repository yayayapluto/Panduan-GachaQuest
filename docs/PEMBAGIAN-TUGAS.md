# Pembagian Tugas

Dokumen ini mengatur siapa mengerjakan apa, kapan batas waktunya, dan bagaimana pekerjaan dinilai selesai. Isinya dipakai bersama `PRD.md` (§7 dan §11) serta `PROJECT-OVERVIEW.md`; kalau ada perbedaan angka atau nama fungsi, PRD yang menang.

## Prinsip

Tiga kesepakatan ini berlaku sepanjang proyek dan tidak ditawar.

**Satu file satu pemilik.** Setiap file punya tepat satu orang yang boleh menulisnya. Pemilik lain boleh membaca, mengusulkan perubahan lewat pesan, tetapi tidak menyunting langsung. Aturan ini mencegah konflik merge yang tidak perlu, terutama karena P2–P5 bekerja paralel di branch masing-masing.

**Kontrak dibekukan sebelum coding.** Header di `src/` adalah janji antar modul. Setelah tag `contract-v1` dibuat, isi header tidak berubah tanpa persetujuan P1, dan setiap perubahan header harus disertai pemberitahuan ke semua pemilik yang memakainya. Modul yang belum jadi cukup memakai stub agar linker tetap jalan.

**Bukti berupa perintah dan output.** "Sudah selesai" tanpa bukti tidak dihitung. Setiap PR menyertakan perintah yang dijalankan beserta potongan outputnya: `make`, `make test`, atau nama driver `bin/t_*` yang lulus. Screenshot boleh ditambah, tetapi tidak menggantikan output teks.

## Peran

| Kode | Level | Peran | File milik |
|---|---|---|---|
| P1 | mahir | UI, platform, integrator | `Makefile`, `main.c`, `src/core/config.h`, `src/util/*`, `src/ui/*`, `src/platform/*`, `README.md` |
| P2 | mahir | Dungeon | `src/dungeon/dungeon.c`, `src/dungeon/dungeon.h`, `tests/t_dungeon.c` |
| P3 | awam | Battle dan player | `src/player/*`, `src/battle/*` |
| P4 | awam | Gacha dan inventory | `src/gacha/*`, `src/inventory/*` |
| P5 | awam | Shop, storage, leaderboard | `src/shop/*`, `src/storage/*` |

P1 memegang dua beban sekaligus: menyiapkan fondasi yang dipakai semua orang, lalu menyambung hasil kerja P2–P5 menjadi satu program. Karena itu P1 sebaiknya menyelesaikan tag `ui-ready` sebelum mengejar fitur tambahan.

## Fase dan Tag

Pekerjaan dibagi menjadi lima fase. Setiap fase ditutup dengan tag Git, sehingga kemajuan bisa dilihat dari riwayat repo, bukan dari cerita di grup chat.

**F0 — Kontrak (`contract-v1`), pemilik P1.** Menyalin header, data katalog, dan test ke repo kerja, lalu menulis `Makefile` dan `main.c` kerangka. Semua modul yang belum diimplementasikan diberi stub kosong supaya `make` menghasilkan `bin/game`. Tag `contract-v1` menandai bahwa nama fungsi, konstanta, dan struct sudah tidak berubah.

**F1 — UI (`ui-ready`), pemilik P1.** Mengerjakan `src/util`, `src/ui`, dan `src/platform`, lalu melengkapi `main.c` dengan Menu Utama, Game Baru, Load Game, Leaderboard, dan Hub. Setelah tag `ui-ready`, P2–P5 punya layar dan API yang stabil untuk dipanggil.

**F2 — Modul paralel, pemilik P2–P5.** Masing-masing bekerja di branch `feat/<modul>`, misalnya `feat/dungeon`, `feat/battle`, `feat/gacha`, `feat/shop`. Branch ini bercabang dari `dev` setelah `ui-ready`. Setiap branch hanya boleh menyentuh file miliknya sendiri.

**F3 — Integrasi (`integrasi`), pemilik P1.** Menggabungkan branch `feat/*` ke `dev`, memperbaiki pemanggilan yang tidak cocok, dan menjalankan `make test`. Tag `integrasi` dipasang setelah seluruh driver `t_*` lulus di `dev`.

**F4 — Uji penuh dan demo (`rilis`), pemilik P1 dengan seluruh tim.** Menjalankan skenario S01–S18 dari `tests/run_tests.sh`, mendemokan dua belas layar, dan berlatih presentasi. Tag `rilis` adalah versi yang dikumpulkan.

Urutan tag: `contract-v1` → `ui-ready` → `integrasi` → `rilis`. Tag tidak boleh melompati fase, karena tag berikutnya mengasumsikan tag sebelumnya sudah ada.

## Aturan File

Perubahan header bersama lewat P1. Header yang dimaksud adalah semua file di `src/core`, `src/util`, `src/ui`, dan `src/platform`. Kalau P3 butuh field baru di `Player` atau P4 butuh parameter tambahan di `pullOnce`, usulan dikirim ke P1, bukan ditambahkan sendiri. P1 yang memutuskan, menyunting header, lalu memberi tahu pemilik lain.

P3–P5 tidak memakai `printf` untuk menampilkan apa pun ke layar. Semua keluaran visual lewat `src/ui` (`ui_line_*`, `ui_menu_*`, `ui_message`, `set_message`). `printf` hanya boleh muncul di driver test, dan itu pun sebaiknya lewat `CHECK` yang sudah ada. Alasannya sederhana: layar punya grid karakter dan warna sendiri, sehingga `printf` langsung akan merusak tata letak.

P3–P5 tidak memakai `rand()`. Angka acak diambil dari `plat_rand()` di `src/platform/rng.h`, supaya seed dunia dan urutan gacha bisa direproduksi saat test. Ini juga yang membuat S14 dan S16 bisa diuji dengan hasil yang sama setiap kali dijalankan.

P3–P5 tidak mengedit `src/ui`. Kalau ada widget yang kurang, ajukan ke P1 lewat pesan singkat berisi nama fungsi, parameter, dan contoh pemakaian. Menunggu satu hari untuk widget baru lebih murah daripada dua branch yang sama-sama menambah fungsi berbeda dengan nama mirip.

## Pendampingan Anggota Awam

P3, P4, dan P5 bukan latar belakang C, jadi pendampingan masuk ke rencana kerja, bukan tindakan darurat saat menjelang deadline.

Review PR anggota awam dilakukan maksimal satu hari setelah PR dibuka. Review menyebut hal konkret: baris yang bermasalah, alasannya, dan perbaikan yang disarankan. Komentar "rapikan lagi" tidak dihitung sebagai review.

Satu sesi pair programming per fase. Formatnya bebas, yang penting P1 dan pemilik modul duduk (atau berbagi layar) selama 30–60 menit untuk membahas satu fungsi yang sedang macet. Sesi ini dicatat tanggalnya di PR atau di catatan tim.

Checklist "bisa menjelaskan" berlaku per fungsi publik yang dipegang. Sebelum PR boleh digabung, pemiliknya harus bisa menjawab tanpa membuka kode: apa masukannya, apa keluarannya, kapan mengembalikan nilai error, dan siapa yang memanggil fungsi itu. Kalau tidak bisa menjawab, fungsinya belum dianggap selesai meskipun test lulus.

## Jadwal

Empat minggu, dengan asumsi sekitar 8–10 jam kerja per orang per minggu.

| Minggu | Fokus | Keluaran |
|---|---|---|
| M1 | Kontrak dan scaffold | `contract-v1`, `Makefile`, `main.c` kerangka, semua stub kompilasi |
| M2 | UI dan modul awal | `ui-ready`, P2–P5 mulai branch `feat/*`, minimal satu fungsi publik per modul |
| M3 | Modul selesai dan integrasi | Semua branch `feat/*` digabung ke `dev`, tag `integrasi`, `make test` lulus |
| M4 | Uji penuh, demo, latihan presentasi | Skenario S01–S18 lulus, dua belas layar didemokan, tag `rilis` |

M2 adalah minggu paling padat karena P1 masih mengerjakan UI sementara P2–P5 baru mulai. Kalau jadwal mepet, yang dipotong adalah fitur tambahan, bukan test atau perbaikan bug.

## Definition of Done

Kriteria di bawah berlaku per fase. Fase belum boleh ditutup kalau ada satu butir yang belum terpenuhi.

**F0 — `contract-v1`.** Seluruh header ada di `src/`, `Makefile` punya target `all`, `start`, `test`, dan `clean`, `make` menghasilkan `bin/game` tanpa warning dengan `-Wall -Wextra -Wpedantic`, dan semua modul punya stub yang bisa dipanggil.

**F1 — `ui-ready`.** Menu Utama, Game Baru, Load Game 5 slot, Leaderboard, dan Hub bisa dibuka dan dikendalikan dengan tombol yang tertulis di PRD §5. Terminal kembali ke mode normal setelah keluar. `src/platform` lengkap dan `bin/t_platform` lulus.

**F2 — modul paralel.** Semua fungsi publik pada header milik modul sudah diimplementasikan, driver terkait lulus (`t_battle`, `t_gacha`, `t_inventory`, `t_dungeon`, `t_storage`, `t_leaderboard`, `t_player`), tidak ada `printf` layar dan tidak ada `rand()`, serta PR sudah direview.

**F3 — `integrasi`.** Branch `feat/*` sudah masuk `dev`, `make` bersih tanpa warning, seluruh driver `t_*` lulus di `dev`, dan tidak ada file milik orang lain yang ikut berubah di diff.

**F4 — `rilis`.** `run_tests.sh` lulus untuk S01–S18, dua belas layar berjalan sesuai PRD §5, `README.md` mencantumkan cara build dan menjalankan test, dan tim sudah melakukan satu kali latihan presentasi penuh.

## Pemetaan Materi ke Pemilik

Tabel ini memastikan setiap materi kuliah punya wujud nyata di kode dan ada orang yang bertanggung jawab menjelaskannya saat demo.

| Materi | Wujud wajib | Pemilik |
|---|---|---|
| Pertemuan 1: lingkungan dan struktur program | struktur repo, header guard, `main.c`, `Makefile` target `all/start/test/clean` | P1 |
| Pertemuan 2: input, output, variabel, tipe data | `readLine`/`readInt`/`readString`, `Player`, tabel status dan inventory | P1, P3 |
| Pertemuan 3: operator, ekspresi, konversi, tracing | `calculateDamage`, `totalAtk`/`totalDef`, `rollRarity`, konversi digit `char` ke `int` | P3, P4, P5 |
| Pertemuan 4: if, else-if, nested, switch | switch menu, roll rarity berantai, hasil battle, validasi input | semua |
| Pertemuan 5: perulangan | loop menu, loop battle, pull 10x, loop validasi | P3, P4 |
| QUIZ | checkpoint evaluasi sesi 1–5, latihan tracing `addExp` dan `calculateDamage` | P1 |
| Pertemuan 7: perulangan bersarang | `genMaze`/`connectChunk`, bubble dan selection sort, scan chunk | P2, P4 |
| Array satu dimensi | `Item inventory[MAX_ITEM]`, `Monster m[]`, `Point taken[]`, leaderboard | P4, P5 |
| Array dua dimensi | `char g[][CHUNK_SIZE]`, `char area[][AREA_MAX]`, `queue[][2]`, `opts[4][2]` | P2 |
| Karakter & string | `char name[MAX_NAME]`, `strcmp`/`strncpy`/`sscanf`, lowercase, parsing `\|` | P4, P5 |
| Pointer dasar & parameter alamat | `Player *p` di semua modul, `int *pity`, `Point path[]`, buffer keluaran | semua |
| struct, typedef, array of structs | `Item`, `Monster`, `Player`, `Point`, `DungeonState` di `config.h` | P1 (kontrak), semua (pakai) |
| Searching & sorting | `findItemInInventory` (sequential), `sortInventory` mode 1/3 (bubble), mode 2 (selection), leaderboard top 10 | P4, P5 |
| File teks & persistensi | `loadCatalog`/`loadMonsters`, `saveGameSlot`/`loadGameSlot`, `recordScore`, `file_write_atomic` | P5 |
| Penanganan error file/input | pesan gagal muat/simpan, validasi angka dan nama, fallback non-interaktif | P5, P1 |
| Pengujian dasar | `tests/run_tests.sh`, driver `t_*` lulus tanpa warning | semua |

Dua baris terakhir sengaja diberi dua pemilik. Penanganan error file ada di P5 karena dialah yang menulis `storage`, tetapi P1 juga menangani input nama dan angka di `src/util`. Pengujian menyentuh semua modul, jadi tanggung jawabnya kolektif meskipun yang merawat `run_tests.sh` adalah P1.
