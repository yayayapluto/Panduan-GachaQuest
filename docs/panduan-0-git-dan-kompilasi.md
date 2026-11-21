# Panduan 0: Git dan Kompilasi

Panduan ini dipakai semua anggota sebelum membuka panduan peran. Isinya menyiapkan
repo kerja, membiasakan alur git yang sama, dan memastikan proyek bisa dikompilasi
sebelum satu baris kode ditulis. Kerjakan berurutan, jangan melompat.

## Peran

Panduan bersama. Tidak ada peran khusus di sini: P1 sampai P5 mengikuti langkah yang
sama, dengan nama branch dan modul yang berbeda. P1 memakai panduan ini paling awal
karena harus menyiapkan `Makefile` dan `main.c` sebelum anggota lain bisa membangun
proyek. Anggota lain memakai panduan ini untuk menyiapkan repo masing-masing, lalu
langsung masuk ke panduan peran.

## File Milik

Tidak ada file proyek yang ditulis di sini. Panduan ini hanya menyiapkan repo kerja
pribadi hasil clone: folder `.git`, `.gitignore`, serta `src/`, `data/`, dan `tests/`
yang sudah ada di root repo. Semua file itu milik masing-masing anggota di mesinnya
sendiri, bukan milik bersama.

## Jalur Mahir

Bagian ini untuk anggota yang sudah nyaman dengan C, git, terminal, dan testing.
Lewati penjelasan alat, tetapi jangan lewati bukti.

- Prasyarat yang diasumsikan sudah ada: `gcc`, `make`, `sh`, `git`, dan MSYS2 di `PATH`.
- Baca: [PRD §2](PRD.md), [PEMBAGIAN-TUGAS](PEMBAGIAN-TUGAS.md), dan bagian branch kerja di panduan ini.
- Urutan: cek alat, atur identitas git, buat branch, commit kecil, kirim branch, buka PR ke `dev`.
- Bukti diterima: `git branch --show-current` menampilkan branch kerja, `make` tanpa warning, `make test` menampilkan 0 gagal.
- Jebakan: build hanya dari root repo; `make clean` gagal bila game masih berjalan; jangan rebase branch orang lain; jangan memaksa kirim ke remote.
- Kalau ragu soal perintah git yang menghapus pekerjaan, berhenti dan tanya P1.

## Prasyarat

- `gcc` versi 9 atau lebih baru, `make`, dan `git` sudah terpasang.
- Windows: pakai MSYS2 atau Git Bash. Jangan memakai `cmd.exe` polos karena `make`
  dan perintah POSIX lain tidak tersedia di sana.
- Terminal minimal 50 kolom x 20 baris. Layar game memakai ukuran itu sebagai acuan.
- Akses baca ke repo Git ini (URL-nya diminta ke tim) untuk di-clone.

## Langkah Kerja

### Langkah 1. Periksa alat yang tersedia

Jalankan ketiga perintah ini di terminal yang akan dipakai seterusnya.

```sh
gcc --version
make --version
git --version
```

**Expected**

```text
gcc (Rev...) 13.2.0        <- nomor versi apa pun, asal 9 ke atas
GNU Make 4.3               <- versi 3.81 ke atas
git version 2.4x.x         <- versi apa pun yang masih dirawat
```

Kalau salah satu perintah tidak dikenal, pasang dulu sebelum lanjut. Di Windows,
buka *MSYS2 UCRT64* dan jalankan `pacman -S mingw-w64-ucrt-x86_64-gcc make git`,
lalu pastikan folder `ucrt64/bin` masuk `PATH`.

### Langkah 2. Pilih folder kerja dan atur identitas git

Pilih satu folder tetap, misalnya `~/proyek`. Repo kerja dibuat di sana pada langkah
berikutnya sebagai hasil clone, jadi `git init` tidak diperlukan.

```sh
mkdir -p ~/proyek
cd ~/proyek
```

**Expected**

```text
(kosong; perintah selesai tanpa keluaran)
```

Setelah itu atur identitas sekali saja, supaya commit tidak ditolak:

```sh
git config user.name "Nama Kamu"
git config user.email "kamu@contoh.id"
```

### Langkah 3. Clone repo dan periksa struktur

Repo ini adalah scaffold utuh: header `.h`, data katalog, dan seluruh test sudah ada
di dalamnya, dan tidak ada kode solusi. Clone repo itu sebagai repo kerja, lalu masuk
ke foldernya.

```sh
git clone https://github.com/yayayapluto/GachaQuest.git
cd GachaQuest
```

**Expected**

```text
Cloning into 'GachaQuest'...
done.
```

Lalu periksa struktur repo:

```sh
find src -name '*.c' -print
ls data tests
```

**Expected**

```text
(kosong; baris pertama tidak mengeluarkan apa pun)

data:
item.txt  monster.txt

tests:
run_tests.sh  t_battle.c  t_dungeon.c  t_gacha.c  ...
```

`find` harus kosong karena `src/` hanya berisi header. Kalau ada `.c` di sana, berarti
yang di-clone bukan repo scaffold ini: hapus folder hasilnya, lalu ulangi `git clone`
dengan URL yang benar.

### Langkah 4. Periksa `.gitignore`

`.gitignore` sudah ikut ter-clone di root repo. Isinya harus memuat pola berikut.
Kalau ada yang hilang, tambahkan di baris yang sesuai, jangan menghapus pola lain.

```gitignore
# Hasil kompilasi
bin/

# Keluaran pengujian
tests/out_last.txt

# Berkas runtime (dibuat saat game berjalan)
data/save.txt
data/save_*.txt
data/leaderboard.txt
data/autosave.dat
data/autosave.bak
data/session.lock
data/crash.log
data/game.log
data/game.log.1
data/*.tmp.*
```

**Expected**

```sh
git status --short
```

```text
(tidak ada baris untuk data/save*.txt, data/leaderboard.txt, atau berkas runtime lain)
```

Berkas runtime tidak boleh muncul di daftar itu. Kalau muncul, artinya polanya belum
tertulis benar.

### Langkah 5. Buat branch kerja

Satu branch untuk satu modul. Nama branch memakai pola `feat/<modul>`.

```sh
git checkout -b feat/scaffold-ui
git branch --show-current
```

**Expected**

```text
feat/scaffold-ui
```

Gunakan nama modul yang sesuai panduan peran: `feat/scaffold-ui` untuk P1,
`feat/dungeon` untuk P2, `feat/battle-player` untuk P3, `feat/gacha-inventory` untuk P4, dan
`feat/shop-storage` untuk P5.

### Langkah 6. Commit dengan format tetap

Format pesan commit: `feat(modul): ...` untuk fitur, `docs: ...` untuk dokumen, dan
`fix(modul): ...` untuk perbaikan. Commit pertama cukup menandai repo kerja siap.

```sh
git add .gitignore
git commit -m "chore: siapkan repo kerja dari scaffold"
git log --oneline
```

**Expected**

```text
a1b2c3d chore: siapkan repo kerja dari scaffold
```

Kalau `.gitignore` ikut ter-clone tanpa perubahan, commit itu kosong. Lewati saja dan
pakai pesan yang sama pada commit kerja pertama.

Setiap commit berikutnya harus kecil dan jelas, misalnya
`feat(player): tambah initPlayer dan resetPlayer`.

### Langkah 7. Buka pull request ke `dev`

Branch `dev` adalah jalur integrasi; `main` hanya menerima hasil yang sudah lulus uji.

```sh
git push -u origin feat/scaffold-ui
```

**Expected**

```text
 * [new branch]      feat/scaffold-ui -> feat/scaffold-ui
branch 'feat/scaffold-ui' set up to track 'origin/feat/scaffold-ui'.
```

Buka PR ke `dev` di halaman repo, isi judul dengan pesan commit terakhir, dan
cantumkan perintah uji yang sudah dijalankan beserta hasilnya. PR ditinjau P1
sebelum digabung.

### Langkah 8. Tag rilis

Tag dipasang pada commit yang sudah digabung ke `dev` dan lulus uji. Empat tag yang
dipakai: `contract-v1`, `ui-ready`, `modul-*`, dan `rilis`.

```sh
git checkout dev
git pull
git tag -a contract-v1 -m "kontrak dan kerangka build selesai"
git tag --list
```

**Expected**

```text
contract-v1
```

Untuk tag lanjutan, ganti namanya saja, misalnya `ui-ready`, `modul-dungeon`, atau
`rilis`. Kirim tag ke server dengan `git push origin --tags`.

### Langkah 9. Build, uji, dan jalankan

Tiga target `Makefile` yang harus tersedia: `all`, `test`, dan `clean`.

```sh
make
```

**Expected**

```text
gcc -std=c11 -Wall -Wextra -Wpedantic -D_POSIX_C_SOURCE=200809L ... -o bin/game
```

Lalu jalankan pengujian:

```sh
make test
```

**Expected**

```text
S01 nama kosong atau terlalu panjang ... lulus
...
Semua skenario lulus
```

Terakhir, jalankan game:

```sh
make start
```

**Expected**

```text
+------------------------------------------------+
|                 GACHA QUEST                    |
+------------------------------------------------+
```

Tekan `Esc` atau pilih keluar; terminal harus kembali normal tanpa warna yang
tertinggal. Kalau build sudah bersih, `make` kedua kali seharusnya tidak
mengompilasi ulang:

```sh
make
```

**Expected**

```text
make: Nothing to be done for 'all'.
```

### Langkah 10. Menangani masalah yang sering muncul

Empat gangguan berikut paling sering terjadi. Perbaiki satu per satu, jangan
menambal dengan mengubah header.

**Warning kompilasi.** Proyek ini wajib bersih dari warning. Jangan menaikkan
`-w` atau membuang `-Wall`; perbaiki penyebabnya.

```sh
make clean && make
```

**Expected**

```text
(build ulang berjalan dan tidak ada baris "warning:")
```

**`make` tidak ditemukan.** Di Windows ini hampir selalu soal `PATH`.

```sh
which make
```

**Expected**

```text
/mingw64/bin/make
```

Kalau keluarannya kosong, buka terminal MSYS2 yang benar atau tambahkan folder
`bin` MSYS2 ke `PATH`.

**Terminal kurang dari 50x20.** Game memakai lebar 50 dan tinggi 20.

```sh
stty size
```

**Expected**

```text
30 100
```

Angka pertama baris, kedua kolom. Kalau di bawah 20 dan 50, perbesar jendela
terminal atau kurangi ukuran font sebelum menjalankan `make start`.

**Folder `data/` hilang.** Tanpa `data/`, katalog item dan monster tidak termuat.
Gejalanya pesan gagal muat saat game dijalankan.

```sh
ls data
```

**Expected**

```text
item.txt  monster.txt
```

Kalau tidak ada, ambil ulang dari git: `git checkout -- data/item.txt data/monster.txt`.
Jangan membuat ulang isinya dengan tangan, karena jumlah barisnya sudah ditentukan
kontrak: 36 item dan 12 monster.

## Definition of Done

- `gcc`, `make`, dan `git` terpasang dan versinya tercatat.
- Repo kerja hasil `git clone`, dengan `.git`, `.gitignore`, serta `src/`, `data/`,
  dan `tests/` di root.
- `find src -name '*.c'` kosong, jadi tidak ada kode solusi di dalam repo.
- Tidak ada folder `contract` maupun `scaffold` di repo kerja; semuanya sudah di root.
- Branch kerja aktif dengan pola `feat/<modul>`, dan minimal satu commit memakai
  format `feat(modul): ...` atau `docs: ...`.
- `make` membentuk `bin/game` tanpa warning.
- `make test` menjalankan seluruh skenario dan semuanya lulus begitu modul sudah
  terisi; selama modul masih kosong, test yang belum relevan boleh gagal.
- `make start` menampilkan layar game dan keluar dengan terminal yang kembali
  normal.

## Larangan

- Jangan membuat repo kerja dengan `git init` lalu menyalin isi repo ini dengan
  tangan. Selalu mulai dari `git clone`.
- Jangan menaruh `Makefile` atau `main.c` di dalam `src/`; keduanya tinggal di root
  repo.
- Jangan memakai `rand()` di modul game. Semua angka acak lewat `plat_rand()`.
- Jangan memakai `printf` untuk menggambar layar. Semua keluaran layar lewat
  `src/ui`.
- Jangan mengubah header di `src/` tanpa persetujuan P1, termasuk menambah fungsi
  publik baru.
- Jangan mengubah test agar lulus. Kalau test gagal, perbaiki kodenya.
- Jangan memakai `git push --force` ke `dev` atau `main`.
- Jangan memakai `make` target di luar `all`, `start`, `test`, dan `clean`.

## Push ke Repo Bersama

Repo bersama kelompok ada di satu tempat, dan semuanya clone dari URL itu:

```text
https://github.com/yayayapluto/GachaQuest.git
```

Repo ini **publik**, jadi siapa pun bisa clone dan membaca. Yang bisa push hanya
akun yang sudah diberi izin tulis oleh pemilik repo.

### Langkah 1. Periksa remote di repo kerja

`origin` harus menunjuk repo bersama, bukan repo pribadi.

```sh
git remote -v
```

**Expected**

```text
origin  https://github.com/yayayapluto/GachaQuest.git (fetch)
origin  https://github.com/yayayapluto/GachaQuest.git (push)
```

Kalau `origin` masih menunjuk URL lain, arahkan ulang tanpa mengulang clone:

```sh
git remote set-url origin https://github.com/yayayapluto/GachaQuest.git
```

### Langkah 2. Minta izin tulis

Repo publik tetap menolak push dari akun asing. Kirim username GitHub ke pemilik
repo, lalu pemilik menambahkanmu sebagai collaborator:

```sh
gh api repos/yayayapluto/GachaQuest/collaborators/<username> -X PUT -f permission=push
```

**Expected**

```text
{"message":"Repository invitation added"}
```

Setelah undangan diterima, `git push` dari akunmu tidak lagi ditolak dengan
`403`.

### Langkah 3. Push branch kerja

Selalu push branch sendiri, jangan push ke `dev` atau `main`.

```sh
git push -u origin feat/<modul>
```

**Expected**

```text
 * [new branch]      feat/<modul> -> feat/<modul>
branch 'feat/<modul>' set up to track 'origin/feat/<modul>'.
```

### Langkah 4. Buka PR ke `dev`

```sh
gh pr create --base dev --head feat/<modul> \
  --title "feat(<modul>): <ringkasan>" \
  --body "Mengerjakan <modul> sesuai docs/panduan-<peran>. Semua test lulus."
```

**Expected**

```text
https://github.com/yayayapluto/GachaQuest/pull/<nomor>
```

P1 meninjau lalu menggabungkan. Sesudah PR gabung, seluruh anggota menarik versi
baru:

```sh
git checkout dev
git pull origin dev
```

### Aturan push

- `git push --force` dilarang, termasuk ke branch fitur sendiri.
- Jangan commit langsung ke `dev` atau `main`; keduanya hanya diisi lewat PR.
- Kalau push ditolak `403`, izin tulis belum aktif: ulangi Langkah 2.
- Kalau push ditolak `fetch first`, tarik dulu: `git pull --rebase origin dev`.

## Alur Git per Anggota

Alur dasarnya sama untuk semua orang: branch dari `dev`, commit kecil, push, lalu PR
ke `dev`. Yang berbeda hanya nama branch dan tugas tambahan P1. Jangan membuat branch
dari `main`; `main` hanya menerima hasil yang sudah lulus uji penuh.

### P1: `feat/scaffold-ui`

P1 juga memegang `dev`. Artinya P1 yang meninjau PR, menggabungkannya, dan memasang
tag pada commit hasil gabungan.

```sh
git checkout dev
git pull origin dev
git checkout -b feat/scaffold-ui
# ... kerja ...
git add Makefile main.c src/core src/util src/ui src/platform
git commit -m "feat(ui): siapkan Makefile, main.c, dan modul ui"
git push -u origin feat/scaffold-ui
```

**Expected**

```text
 * [new branch]      feat/scaffold-ui -> feat/scaffold-ui
branch 'feat/scaffold-ui' set up to track 'origin/feat/scaffold-ui'.
```

Setelah PR P1 sendiri digabung (boleh digabung sendiri karena P1 pemilik `dev`),
tag dipasang berurutan:

```sh
git checkout dev
git pull
git tag -a contract-v1 -m "kontrak dan kerangka build"
git push origin contract-v1
```

**Expected**

```text
 * [new tag]         contract-v1 -> contract-v1
```

Tiga tag berikutnya dipasang dengan cara yang sama pada saat yang tepat:
`ui-ready` setelah layar dasar tampil, `integrasi` setelah semua modul bergabung,
dan `rilis` setelah uji penuh lulus. Setelah `rilis`, `main` disamakan dengan `dev`:

```sh
git checkout main
git merge --ff-only dev
git push origin main
```

**Expected**

```text
Fast-forward
```

Kalau `--ff-only` menolak, berarti `main` sudah bergerak sendiri. Hentikan, jangan
memaksa merge. Tanyakan dulu ke tim.

Tugas review P1: buka PR anggota, jalankan `make test` pada branch itu di mesin
sendiri, baca diff-nya, lalu gabung dengan `git merge --no-ff feat/<modul>`.

### P2: `feat/dungeon`

```sh
git checkout dev
git pull origin dev
git checkout -b feat/dungeon
# ... kerja di src/dungeon dan tests/t_dungeon.c ...
git commit -m "feat(dungeon): tambah cellHash dan dungeonCell"
git push -u origin feat/dungeon
```

**Expected**

```text
 * [new branch]      feat/dungeon -> feat/dungeon
```

### P3: `feat/battle-player`

```sh
git checkout dev
git pull origin dev
git checkout -b feat/battle-player
# ... kerja di src/player dan src/battle ...
git commit -m "feat(battle): hitung damage dan crit"
git push -u origin feat/battle-player
```

**Expected**

```text
 * [new branch]      feat/battle-player -> feat/battle-player
```

### P4: `feat/gacha-inventory`

```sh
git checkout dev
git pull origin dev
git checkout -b feat/gacha-inventory
# ... kerja di src/gacha dan src/inventory ...
git commit -m "feat(inventory): urutkan dengan bubble dan selection sort"
git push -u origin feat/gacha-inventory
```

**Expected**

```text
 * [new branch]      feat/gacha-inventory -> feat/gacha-inventory
```

### P5: `feat/shop-storage`

```sh
git checkout dev
git pull origin dev
git checkout -b feat/shop-storage
# ... kerja di src/shop dan src/storage ...
git commit -m "feat(storage): simpan dan muat lima slot"
git push -u origin feat/shop-storage
```

**Expected**

```text
 * [new branch]      feat/shop-storage -> feat/shop-storage
```

### Aturan tambahan untuk P3, P4, dan P5

Tiga hal ini yang paling sering bikin repot, jadi diperiksa sebelum setiap commit.

**Selalu tarik `dev` sebelum mulai kerja.** Branch yang tertinggal membuat PR
bertabrakan dengan pekerjaan orang lain.

```sh
git checkout dev
git pull origin dev
git checkout feat/battle-player
git merge dev
```

**Expected**

```text
Already up to date.
```

Kalau keluarannya bukan itu, ada perubahan baru di `dev` yang ikut masuk. Jalankan
`make test` sekali lagi sebelum lanjut.

**Jangan commit file milik orang lain.** Periksa daftar file sebelum commit, dan
pastikan hanya folder modul sendiri yang muncul.

```sh
git status --short
```

**Expected** (contoh untuk P3)

```text
 M src/battle/battle.c
 M tests/t_battle.c
```

Kalau `src/ui` atau `src/dungeon` ikut muncul, jangan lanjut. Batalkan dengan
`git checkout -- <file>` dan lapor ke P1.

**Kalau terjadi konflik, berhenti.** Jangan menyalakan `--force` dan jangan
menghapus penanda konflik dengan menebak.

```sh
git merge dev
```

**Expected** (saat konflik)

```text
CONFLICT (content): Merge conflict in src/battle/battle.h
Automatic merge failed; fix conflicts and then commit the result.
```

Langkah yang benar: jalankan `git merge --abort`, kirim potongan konflik ke P1, dan
tunggu arahan. Konflik pada header hampir selalu berarti header bersama diubah tanpa
persetujuan, dan itu urusan P1.

## Rujukan

- `../README.md` untuk daftar dokumen dan urutan membacanya.
- `PRD.md` bagian 2 dan 8 untuk batasan teknis serta format file.
- `PROJECT-OVERVIEW.md` untuk struktur repo dan perintah mulai cepat.
- `PEMBAGIAN-TUGAS.md` untuk fase, tag, dan kepemilikan file.
- `panduan-P1-scaffold-ui.md` sampai `panduan-P5-shop-storage.md` untuk pekerjaan
  per peran.
