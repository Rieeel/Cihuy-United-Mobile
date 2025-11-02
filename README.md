1. Widget tree pada Flutter adalah struktur hierarki yang menggambarkan susunan seluruh widget dalam sebuah aplikasi. Setiap elemen dalam antarmuka pengguna Flutter merupakan widget, dan widget-widget ini tersusun secara berlapis dari widget induk (parent) hingga widget anak (child). Hubungan parent-child ini berarti widget induk dapat membungkus atau mengatur tampilan dan perilaku widget anak di dalamnya. Misalnya, widget Column sebagai parent bisa memiliki beberapa Text dan Button sebagai child. Hubungan ini membentuk pohon (tree) di mana setiap node adalah widget yang saling terkait dalam membangun UI aplikasi.

2. Beberapa widget yang umum digunakan dalam proyek Flutter antara lain:
    MaterialApp: berfungsi sebagai root aplikasi berbasis Material Design.
    Scaffold: menyediakan struktur dasar halaman seperti app bar, body, dan floating action button.
    AppBar: menampilkan bagian atas aplikasi berupa judul atau tombol navigasi.
    Column dan Row: mengatur tata letak widget secara vertikal atau horizontal.
    Text: menampilkan teks di layar.
    Container: digunakan untuk mengatur padding, margin, warna, dan ukuran widget.
    ElevatedButton: menampilkan tombol yang dapat ditekan pengguna.
    Center: memposisikan widget ke tengah layar.
    Masing-masing widget ini berfungsi membentuk tampilan yang terstruktur dan responsif sesuai kebutuhan aplikasi.

3. Widget MaterialApp berfungsi sebagai wadah utama yang mengatur tema, navigasi, serta konfigurasi global dari aplikasi berbasis Material Design. Widget ini sering digunakan sebagai widget root karena menyediakan konteks global untuk seluruh bagian aplikasi, seperti pengaturan route, tema warna, dan localizations. Tanpa MaterialApp, banyak widget Material lain seperti Scaffold atau AppBar tidak dapat berfungsi dengan benar karena bergantung pada konteks Material yang disediakan olehnya.

4. StatelessWidget adalah widget yang tidak memiliki keadaan (state) yang dapat berubah setelah dibuat; tampilannya hanya bergantung pada data awal yang diberikan. Sedangkan StatefulWidget memiliki state yang bisa berubah selama siklus hidup widget, misalnya ketika pengguna berinteraksi dengan aplikasi. StatefulWidget menggunakan kelas tambahan State untuk menyimpan dan memperbarui data dinamis. Kita memilih StatelessWidget saat UI bersifat statis, seperti menampilkan teks atau gambar tetap, dan StatefulWidget saat UI harus berubah, seperti menampilkan hasil input pengguna atau animasi.

5. BuildContext adalah objek yang merepresentasikan lokasi posisi sebuah widget di dalam widget tree. BuildContext penting karena memungkinkan widget untuk berinteraksi dengan widget lain di atasnya (ancestor) dalam tree, seperti mengakses tema, media query, atau melakukan navigasi. Dalam metode build, BuildContext digunakan untuk membangun tampilan widget berdasarkan posisi dan konteksnya di aplikasi. Dengan BuildContext, Flutter dapat menjaga hubungan antar widget secara efisien saat melakukan pembaruan tampilan.

6. Konsep hot reload di Flutter adalah fitur yang memungkinkan pengembang memperbarui kode dan langsung melihat hasilnya tanpa kehilangan state aplikasi yang sedang berjalan. Ini mempercepat proses pengembangan karena perubahan pada UI atau logika kecil dapat langsung terlihat. Sementara itu, hot restart me-restart seluruh aplikasi dari awal dan menghapus state yang tersimpan, mirip dengan menjalankan ulang aplikasi secara penuh. Dengan demikian, hot reload digunakan untuk mempercepat iterasi tampilan, sedangkan hot restart digunakan ketika perubahan besar pada struktur kode memerlukan inisialisasi ulang seluruh aplikasi.