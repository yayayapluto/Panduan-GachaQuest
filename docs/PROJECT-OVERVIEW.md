# Gambaran Proyek Gacha Quest

## Ringkasan

Gacha Quest adalah permainan petualangan berbasis teks yang berjalan di terminal. Pemain
memberi nama karakter, lalu menjelajah dungeon prosedural, bertarung melawan monster,
memutar gacha untuk mendapat item, mengelola tas, berbelanja potion, dan bersaing di papan
skor. Seluruh tampilan dibuat dari karakter biasa, tanpa grafis dan tanpa pustaka pihak
ketiga. Program ditulis dalam C11 dan hanya memakai pustaka standar, sehingga bisa
dikompilasi dengan gcc di Linux, WSL, maupun Windows lewat MSYS2.

Proyek ini disusun sebagai tugas besar mata kuliah Dasar Pemrograman. Setiap modul game
memetakan satu atau dua materi kuliah, mulai dari variabel dan percabangan sampai array,
struct, searching, sorting, dan pengolahan file. Repo ini sudah memuat seluruh bahan kerja
di akar: `src/` berisi 23 header dengan prototipe fungsi dan konstanta, `data/` berisi
katalog item dan monster contoh, dan `tests/` berisi skrip pengujian beserta driver. Header
itulah yang dibaca tim saat menulis kode, bukan ditulis ulang bebas. Rincian angka, aturan,
dan kriteria penerimaan ada di [PRD](PRD.md).

## Fitur Utama

- **Battle giliran** melawan 12 jenis monster. Pemain memilih Serang, Bertahan, Potion,
  atau Kabur, lalu kerusakan dihitung dari atk dikurangi def ditambah variasi acak.
  Serangan kritikal muncul dengan peluang 10 persen.
- **Gacha** dengan dua pilihan tarik, satu item seharga 100 gold atau sepuluh item
  seharga 900 gold. Peluang tiap tingkat kelangkaan diatur di [PRD](PRD.md), dan sistem pity
  menjamin hasil Epic setelah sepuluh tarikan tanpa Epic.
- **Inventory** berisi maksimal 36 item dengan mode urut berdasarkan power, kelangkaan,
  atau nama. Pencarian memakai pencarian linear substring yang tidak peka huruf besar-kecil.
- **Shop** untuk membeli potion seharga 40 gold dengan batas stok 20, serta menjual item
  duplikat dengan harga sesuai kelangkaannya.
- **Dungeon prosedural ber-seed**. Satu angka seed menentukan seluruh isi dunia, jadi
  seed yang sama selalu membangun peta yang sama. Peta disusun per chunk berukuran
  16x16, divalidasi dengan DFS, dan jarak terpendek antar titik dihitung dengan BFS.
- **Save lima slot** berformat teks dengan 15 field pada baris pertama. Slot pertama
  tetap membaca `save.txt` lama sebagai cadangan.
- **Autosave** menyimpan cuplikan keadaan terakhir ke berkas biner berciri CRC32, dengan
  salinan cadangan dan berkas kunci sesi supaya dua instance tidak berjalan bersamaan.
- **Leaderboard** menampung 10 skor tertinggi dan menampilkan lima teratas secara
  menurun.
- **Antarmuka terminal** dengan deteksi kemampuan terminal, warna, glyph Unicode, kotak
  panel, bilah HP, menu vertikal dan horizontal, serta layar masukan yang bisa menangani
  Escape dan ukuran terminal yang berubah.

## Prasyarat

| Kebutuhan | Keterangan |
|---|---|
| gcc | Versi yang mendukung `-std=c11`. Cek dengan `gcc --version`. |
| make | Untuk target `all`, `start`, `test`, dan `clean`. Cek dengan `make --version`. |
| Git Bash atau MSYS2 | Wajib di Windows, karena `make` dan skrip pengujian membutuhkan shell POSIX. |
| Terminal minimal 50x20 | Lebar 50 kolom, tinggi 20 baris. Di bawah itu program menampilkan peringatan dan tetap berjalan dalam mode terbatas. |

Tidak ada dependensi pihak ketiga. Semua fungsi sistem operasi dibungkus di dalam
`src/platform`, jadi bagian lain program tidak memanggil API OS secara langsung.

## Mulai Cepat

Jalankan dari akar repo kerja hasil `git clone`:

```sh
git clone https://github.com/yayayapluto/GachaQuest.git gacha-quest
cd gacha-quest
make
make start
make test
```

`Makefile` dan `main.c` ditulis P1 lebih dulu, jadi `make` baru bisa dipakai setelah
langkah pertama panduan P1 selesai; modul lain masih berupa stub pada tahap itu. `make`
membentuk `bin/game`, `make start` menjalankan permainan, dan `make test` menjalankan
seluruh skenario penerimaan. Langkah lengkap dari nol, termasuk pemeriksaan alat, `git
init`, dan pembuatan branch, ada di [panduan-0](panduan-0-git-dan-kompilasi.md).

## Struktur Repo

Pohon berikut adalah bentuk repo setelah seluruh modul selesai ditulis. Pada kondisi
awal, `src/` hanya berisi header `.h`; berkas `.c` ditambahkan satu per satu oleh pemilik
tiap modul, dan `Makefile`, `main.c`, serta `bin/` muncul setelah P1 bekerja.

```text
.
├── README.md
├── .gitignore
├── docs/                           (panduan dan spesifikasi)
├── Makefile                        (ditulis P1)
├── main.c                          (ditulis P1)
├── data/
│   ├── item.txt
│   ├── monster.txt
│   ├── save_1.txt ... save_5.txt   (dibuat saat bermain)
│   ├── leaderboard.txt             (dibuat saat bermain)
│   ├── autosave.dat
│   └── session.lock
├── bin/                            (hasil build)
│   ├── game
│   └── t_*                         (driver pengujian)
├── src/
│   ├── core/config.h
│   ├── util/util.h
│   ├── ui/{ui,term,caps,style,render,widgets}.h
│   ├── player/player.h
│   ├── battle/battle.h
│   ├── gacha/gacha.h
│   ├── inventory/inventory.h
│   ├── shop/shop.h
│   ├── storage/storage.h
│   ├── dungeon/dungeon.h
│   └── platform/{rng,atomicfile,log,lock,sig,crash,autosave,platform}.h
└── tests/
    ├── run_tests.sh
    ├── t_battle.c ... t_util.c
    └── in_*.txt
```

## Peta Modul

Sebelas modul, masing-masing dengan satu pemilik yang menulis berkas `.c`-nya. Header
bersama hanya boleh diubah lewat P1.

| Modul | Pemilik | Tanggung jawab |
|---|---|---|
| `src/core` | P1 | Konstanta dan struct bersama: `Item`, `Monster`, `Player`, `Point`, `DungeonState`. Tidak berisi kode. |
| `src/util` | P1 | Masukan baris dan angka, konfirmasi, pembersihan layar, penghentian program yang rapi. |
| `src/ui` | P1 | Terminal mentah, deteksi kemampuan, warna, grid render, panel, menu, bilah HP, layar masukan, footer, log. |
| `src/platform` | P1 | Pembungkus OS: RNG, tulis berkas atomik, log, kunci sesi, penanganan sinyal, penangkap crash, autosave, tidur. |
| `src/player` | P3 | Statistik pemain, pengalaman, naik level, total atk dan def, tampilan status. |
| `src/battle` | P3 | Perhitungan kerusakan, kritikal, loop pertarungan, hadiah, kalah, layar game over. |
| `src/gacha` | P4 | Undian kelangkaan, pity, tarik satu dan sepuluh, harga duplikat, pencarian item untuk pull. |
| `src/inventory` | P4 | Urut bubble dan selection, pencarian linear dan binary, pemasangan item, sinkronisasi item terpasang. |
| `src/shop` | P5 | Beli potion dengan batas stok, jual item duplikat dengan konfirmasi. |
| `src/storage` | P5 | Muat katalog dan monster, simpan dan muat lima slot, papan skor, pengelolaan berkas. |
| `src/dungeon` | P2 | Pembangkitan dunia per seed, chunk, validasi DFS, jalur BFS, kamera, gerak, treasure, hint, chest. |

## Alur Runtime

Kendali program berpindah dari titik masuk ke modul game, lalu ke lapisan penyimpanan.
Modul game tidak pernah menulis berkas sendiri; semua persistensi lewat `storage`, dan
semua operasi sistem lewat `platform`.

```text
                    ┌──────────────────────────────┐
                    │            main.c            │
                    │  platform_init, ui_init      │
                    └──────────────┬───────────────┘
                                   │
                    ┌──────────────▼───────────────┐
                    │        Menu Utama            │
                    │ Game Baru / Load / Papan /   │
                    │ Keluar                       │
                    └──────────────┬───────────────┘
                                   │ nama + seed
                    ┌──────────────▼───────────────┐
                    │             Hub              │
                    │ Battle  Gacha  Inventory     │
                    │ Shop    Dungeon  Status      │
                    └──┬───┬───┬───┬───┬───┬───────┘
                       │   │   │   │   │   │
        ┌──────────────┘   │   │   │   │   └──────────────┐
        ▼                  ▼   ▼   ▼   ▼                  ▼
   ┌─────────┐      ┌───────────┐ ┌──────────┐      ┌──────────┐
   │ battle  │      │  gacha    │ │ inventory│      │  shop    │
   └────┬────┘      └─────┬─────┘ └────┬─────┘      └────┬─────┘
        │                 │            │                 │
        │                 └────────────┼─────────────────┘
        │                              │
        │                        ┌─────▼──────┐
        │                        │  dungeon   │
        │                        │ startBattle│
        │                        └─────┬──────┘
        │                              │
        └──────────────┬───────────────┘
                       ▼
              ┌──────────────────┐        ┌──────────────────┐
              │     storage      │───────▶│     platform     │
              │ katalog, slot,   │        │ rng, atomicfile, │
              │ leaderboard      │        │ log, lock, sig,  │
              └──────────────────┘        │ crash, autosave  │
                                          └──────────────────┘
```

Urutan pemanggilan tipikal untuk satu aksi: modul game menyiapkan data, memanggil
`ui_*` untuk menggambar, membaca masukan lewat `util`, lalu bila keadaan berubah
memanggil `autosave_publish`. Saat pemain keluar, `main.c` memanggil `saveGameSlot`,
`recordScore` bila perlu, lalu `platform_shutdown` untuk mengembalikan terminal dan
menutup log.

## File Runtime

Semua berkas yang dibuat atau dibaca saat permainan berjalan berada di `data/`.

| Berkas | Isi |
|---|---|
| `data/item.txt` | Katalog 36 item, satu baris per item: `id|nama|tipe|rarity|power`. |
| `data/monster.txt` | 12 monster, satu baris per monster: `id|nama|hp|atk|def|exp|gold|minLevel`. |
| `data/save_<n>.txt` | Slot simpan 1 sampai 5. Baris pertama 15 field pipa, baris kedua jumlah item, lalu daftar id item. |
| `data/save.txt` | Berkas lama yang tetap dibaca sebagai isi slot 1 bila `save_1.txt` belum ada. |
| `data/leaderboard.txt` | Papan skor, maksimal 10 baris berisi `nama|level|skor`. |
| `data/autosave.dat` | Cuplikan keadaan terakhir: magic `GQAS`, versi, panjang, CRC32, lalu payload. |
| `data/autosave.bak` | Salinan autosave sebelumnya, dipakai bila berkas utama rusak. |
| `data/session.lock` | Penanda sesi: `RUNNING pid=<pid> start=<epoch>` saat bermain, `CLEAN` setelah keluar rapi. |
| `data/game.log` | Catatan peristiwa dan peringatan dari `log_event`. |
| `data/crash.log` | Jejak bila program berhenti mendadak, ditulis oleh `crash_install`. |

Nama berkas simpan, papan skor, dan autosave dibentuk oleh `saveSlotPath` dan kawan-kawan
di `src/storage`, jadi jangan menulis path sendiri di modul lain. Format lengkap tiap
berkas ada di [PRD](PRD.md) bagian 8.

## Standar Kualitas

- Kompilasi bersih dengan `-std=c11 -Wall -Wextra -Wpedantic`. Satu warning pun
  dianggap gagal.
- Seluruh driver di `tests/` keluar dengan kode 0, dan `make test` menjalankan semua
  skenario penerimaan tanpa kegagalan.
- Tidak ada `printf` untuk layar di luar `src/ui` dan `src/util`. Modul game menulis
  teks lewat API UI supaya tata letak dan warna tetap seragam.
- Tidak ada pemanggilan `rand()` atau `srand()` di luar `src/platform`. Semua keacakan
  lewat `plat_rand` dan `plat_srand` agar urutan undian bisa diulang saat pengujian.
- Tidak ada `malloc` dan tidak ada rekursi. Semua wadah memakai array berukuran tetap
  dari `config.h`.
- Semua penulisan berkas lewat `file_write_atomic`, supaya pemutusan daya di tengah
  penulisan tidak meninggalkan berkas setengah jadi.
- Terminal selalu dikembalikan ke mode semula saat keluar, termasuk lewat Ctrl+C.

Aturan main, angka pasti, dan daftar skenario uji tidak diulang di sini; semuanya ada di
[PRD](PRD.md).
