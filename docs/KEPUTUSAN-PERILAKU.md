# Keputusan Perilaku Gacha Quest

Dokumen ini membekukan hal yang tidak diatur eksplisit di PRD. Semua poin
berlaku sebagai syarat hasil akhir. Kalau implementasi tim berbeda di salah
satu poin, ubah implementasinya, bukan dokumen ini.

## Input dan navigasi

1. **EOF pada prompt.** Pembaca angka yang kehabisan input memakai nilai
   minimum dan bergerak ke jalur keluar yang aman. Menu bernilai 0 keluar,
   battle berhenti saat input habis, dan tidak ada loop abadi.
2. **Nama kosong.** Nama kosong ditolak dan diminta ulang. Nama lebih dari 29
   karakter dipotong.
3. **Esc membatalkan input.** Esc mengembalikan penanda batal, bukan nilai
   sentinel yang bisa bentrok dengan input sah. Pemanggil cukup berhenti.
4. **Aksi merusak minta konfirmasi.** Jual item, pull 10x, timpa slot save, dan
   keluar dungeon lewat Esc memakai prompt `(y/n)`.

## Pemain, item, dan toko

5. **Beli potion.** Satu transaksi boleh membeli beberapa potion. Jumlah
   divalidasi terhadap sisa stok (maksimal 20) dan gold.
6. **Potion saat HP penuh.** Tetap boleh dipakai, heal dibatasi ke maxHp.
   Potion 0 ditolak tanpa memakai giliran.
7. **EXP di level 10.** EXP direset ke 0 dan tidak dihitung lagi. Level maksimal
   10.
8. **Jual item terpasang.** Ditolak dengan pesan. Setelah sort atau jual, item
   terpasang dicocokkan ulang lewat ID item, bukan indeks array.
9. **Gacha penuh mengembalikan gold.** Pull yang tidak mendapat tempat
   mengembalikan biaya tarikan, termasuk 90 gold per item pada pull 10x.
10. **Pity pada pull 10x.** Pity diproses per tarikan berurutan. Tarikan yang
    dijamin pity menghasilkan Epic, kecuali roll acak memberi Legendary.
11. **Aturan crit satu sumber.** Peluang dan pengali crit hanya diambil dari
    konstanta bersama, termasuk untuk aksi bertahan, sehingga angka di log
    selalu sama dengan damage yang masuk.

## Dungeon

12. **Dungeon prosedural, bukan peta dari file.** Dunia dihitung per sel dari
    seed. Tidak ada file peta. Seed yang sama selalu menghasilkan dunia yang
    sama.
13. **Seed dunia.** Seed diminta sekali saat game baru dan disimpan di save.
    Enter kosong memakai seed dari jam sistem lalu menampilkannya. Rentang sah
    0 sampai 4294967295. Seed 0 sah.
14. **Terrain per chunk.** Setiap chunk memilih varian terrain dari hash seed:
    maze, ruang, gua, atau aula berpilar. Gate di tiap sisi dihitung dari sisi
    bersama agar dua chunk bersebelahan membuka sel yang sama. Pass konektivitas
    menambal gate ke tengah dan menutup kantong lantai yang tak terjangkau.
15. **Isi dungeon per chunk.** Monster, chest, dan gold di-roll per chunk, bukan
    per sel, agar kepadatan merata.
16. **Hasil chest deterministik.** Isi chest diturunkan dari hash seed dan
    posisi, bukan dari RNG. Membuka chest yang sama setelah reload memberi isi
    yang sama.
17. **Cache area dan kamera.** Area 5x5 chunk (80x80 sel) di sekitar pemain
    dihitung dan digeser saat pemain pindah chunk. Kamera menampilkan jendela
    25x15 dengan pemain di tengah. Ukuran tetap, tanpa alokasi dinamis.
18. **Batas treasure per run.** Maksimal 64 posisi treasure dicatat per
    kunjungan. Lewat batas itu treasure tetap memberi gold, hanya tidak dicatat
    lagi.
19. **Keluar dungeon.** Q keluar tanpa bonus. Treasure yang sudah diambil tetap
    dihitung.
20. **Hint BFS.** Hint mencari treasure terdekat di dalam cache, bukan pintu
    keluar. Jalur `*` hanya tampil pada layar saat itu dan hilang setelah
    langkah berikutnya. Biaya 30 gold, maksimal 3 kali.
21. **Kalah berakhir di layar game over.** HP tidak diisi ulang otomatis. Pemain
    memilih reset run atau kembali ke menu utama. Reset mengembalikan level, HP,
    gold, potion, dan item ke kondisi awal, tetapi mempertahankan nama dan seed.
    Kekalahan di dungeon ikut menghentikan run.

## Simpan, muat, dan sesi

22. **Lima slot save.** Slot bernomor `save_1` sampai `save_5`. `save.txt` lama
    hanya dibaca sebagai slot 1 selama `save_1` belum ada. Autosave
    terpisah karena tujuannya memulihkan sesi, bukan memilih progres.
23. **Save menyimpan ID item terpasang.** Field senjata dan armor berisi ID item,
    lalu dipetakan kembali ke indeks inventory saat dimuat.
24. **Format save 15 field.** Field seed disisipkan sebelum ID senjata. Save
    lama 14 field ditolak dengan pesan format rusak, dan pemain memulai game
    baru sekali.
25. **Leaderboard penuh.** Jika sudah 10 entri, entri baru menggantikan skor
    terendah. File selalu urut menurun dan dipotong 10.
26. **Autosave snapshot biner.** Autosave terpisah dari save teks. Snapshot
    menyimpan magic, versi, panjang, CRC, dan payload. Hanya snapshot terbaru
    yang ditulis, dengan jeda debounce 1500 ms yang bisa diatur lewat
    `GACHA_AUTOSAVE_MS` (minimal 200). Kejadian penting langsung ditulis.
27. **Rotasi cadangan.** Sebelum mengganti snapshot, file lama dijadikan
    cadangan. Saat memuat, magic, versi, panjang, dan CRC divalidasi, lalu
    cadangan dipakai bila snapshot utama rusak.
28. **Kunci sesi.** Hanya satu instance boleh berjalan. File kunci berisi status
    berjalan beserta PID dan waktu mulai, lalu ditandai bersih saat keluar rapi.
    Proses kedua ditolak dengan pesan yang jelas.
29. **RNG ikut tersimpan.** State RNG masuk snapshot, sehingga sesi yang
    dipulihkan melanjutkan urutan acak yang sama.
30. **Titik publish autosave.** Setelah tiap aksi dan sebelum redraw memakai
    debounce. Kejadian yang tidak boleh hilang langsung ditulis: akhir battle,
    hasil gacha, jual atau beli, equip, treasure, dan keluar dungeon.
31. **Shutdown rapi.** Keluar normal lewat satu jalur. Sinyal hanya menyetel
    flag, loop UI berhenti di titik aman, autosave terakhir ditulis, lalu status
    kunci ditandai bersih. Sinyal kedua diabaikan, watchdog keluar setelah 3
    detik. Crash memulihkan terminal dan menambah satu baris di `data/crash.log`
    tanpa menulis state game.

## Tampilan dan pipeline

32. **`make start` hanya menjalankan biner.** Deteksi kemampuan terminal
    dilakukan program, bukan Makefile.
33. **Log aksi sebagai segmen bergaya.** Log menyimpan aktor, aksi, target, dan
    nilai beserta gayanya. Penanda dalam teks tidak dipakai karena bisa bentrok
    dengan nama pemain atau item.
34. **Picker bisa dipakai lewat pipa.** Pemilih baris menggambar sekali lalu
    membaca nomor baris saat stdin bukan terminal, sehingga skenario uji pipa
    bisa memilih slot seperti jalur interaktif.
35. **Animasi tidak memperlambat mode pipa.** Mode non-interaktif langsung
    mencetak hasil. Animasi hanya memakai jalur render yang sudah ada.
36. **Palet biome disimpan di token gaya.** Setiap sel menyimpan gayanya sendiri,
    dan lapisan render tahu kapan mengeluarkan warna latar.
37. **Autosave tidak memakai antrean berkas.** Setiap publish menyalin snapshot
    ke memori, dan thread latar membuang versi lama bila ada snapshot lebih
    baru selama debounce.
38. **Modul platform terpisah.** Akses sistem operasi (RNG, tulis atomik, kunci,
    sinyal, crash, autosave) dipisah dari logika game dan dipanggil sebelum UI
    dimulai.
39. **PRNG terserialisasi.** Angka acak memakai PRNG 64 bit dengan keluaran 31
    bit agar rentang hasil mirip `rand() % N`. `long` tidak dipakai karena hanya
    4 byte di Windows.
40. **Debug Windows.** Karena runtime sanitizer gcc MSYS2 tidak tersedia,
    target debug memakai clang64. Di Linux tetap memakai gcc.
41. **Kalah tidak diulang otomatis.** Layar game over tampil tanpa jeda Enter,
    dan hasil battle diteruskan ke hub serta dungeon lewat flag hasil.
