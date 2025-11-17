1. Kita perlu membuat model Dart ketika mengambil atau mengirim data JSON karena model memberikan struktur data yang jelas, tipe yang kuat, dan dukungan null-safety. Dengan model, setiap data yang diterima atau dikirim akan tervalidasi secara tipe sebelum digunakan sehingga mengurangi risiko runtime error. Model juga meningkatkan maintainability karena seluruh proses parsing dan serialisasi JSON dilakukan di satu tempat (fromJson/toJson) sehingga kode lebih bersih, mudah dibaca, dan mudah diubah bila API berganti. Jika langsung memakai Map<String, dynamic>, maka seluruh data menjadi serba dinamis — tipe tidak terjamin, semua nilai dianggap nullable, rawan NoSuchMethodError, dan kesalahan baru terlihat saat runtime, membuat debugging jauh lebih sulit dan kode jadi lebih berantakan.

2. Package http berfungsi untuk melakukan HTTP request biasa (GET/POST/PUT/DELETE) tanpa menangani sesi atau cookie. Ini cocok untuk endpoint publik atau request sederhana. Sementara itu, CookieRequest (dari pbp_django_auth) digunakan untuk komunikasi dengan Django menggunakan autentikasi session-based. CookieRequest menyimpan dan mengirim cookie sesi secara otomatis sehingga Django dapat mengenali user yang sudah login. Peran http adalah requester umum tanpa session, sedangkan CookieRequest adalah requester khusus yang menyimpan autentikasi dan sesi login.

3. Instance CookieRequest perlu dibagikan ke seluruh komponen Flutter karena session login harus konsisten di seluruh aplikasi. Jika setiap halaman membuat instance baru, cookie tidak terbawa, sehingga Django menganggap user tidak lagi terautentikasi. Akibatnya, user akan “logout” setiap kali berpindah halaman. Dengan menggunakan Provider untuk menyebarkan satu instance CookieRequest yang sama, semua halaman memakai cookie yang sama dan session tetap hidup selama aplikasi berjalan.

4. Agar Flutter dapat berkomunikasi dengan Django, beberapa konfigurasi konektivitas diperlukan. Menambahkan 10.0.2.2 pada ALLOWED_HOSTS penting karena Android emulator menggunakan alamat tersebut untuk mengakses localhost komputer host. Tanpa itu, Django akan memunculkan error DisallowedHost. Aktivasi CORS diperlukan agar request dari Flutter (yang dianggap berasal dari domain berbeda) tidak diblokir oleh kebijakan browser/server. Pengaturan SameSite dan cookie diperlukan agar cookie session dapat dikirim bolak-balik antara Flutter dan Django, sementara izin akses internet pada Android (INTERNET permission) wajib agar Flutter dapat melakukan request HTTP. Jika salah satu konfigurasi ini tidak benar, maka Flutter tidak akan bisa login, tidak bisa mengambil data, atau request-nya akan ditolak oleh Django atau sistem Android.

5. Mekanisme pengiriman data berlangsung sebagai berikut: pengguna mengisi form di Flutter, lalu Flutter mengirim data tersebut ke Django menggunakan CookieRequest atau http. Django menerima request, melakukan validasi, menyimpan data ke database bila valid, lalu mengirim response dalam bentuk JSON. Flutter menerima JSON tersebut, mengubahnya menjadi objek model Dart melalui fromJson, lalu menampilkan hasilnya ke UI menggunakan widget seperti Text, Card, atau ListView.

6. Mekanisme autentikasi bekerja dari login → register → logout sebagai berikut. Pada register, Flutter mengirim data akun ke Django yang kemudian menyimpan user baru ke database. Untuk login, Flutter mengirim username dan password melalui CookieRequest; Django memvalidasi dan mengirim cookie session kembali. CookieRequest menyimpan cookie tersebut, sehingga pada request berikutnya Flutter dikenali sebagai user yang sudah login. Semua request yang memerlukan autentikasi akan otomatis menyertakan cookie session ini. Saat logout, Flutter memanggil endpoint logout Django yang menghapus sesi di server dan CookieRequest menghapus cookie lokal. UI Flutter kemudian kembali ke halaman login. Dengan mekanisme ini, alur autentikasi berlangsung aman, konsisten, dan state login terjaga selama aplikasi digunakan.
```

7. **1. Setup Django Backend (Prerequisites):**
```bash
# Django sudah deployed dan running
# Endpoints tersedia:
# - /auth/login/
# - /auth/register/
# - /auth/logout/
# - /json/  (returns products filtered by user)
# - /create-flutter/
```

**2. Flutter Dependencies:**
```bash
flutter pub add provider
flutter pub add pbp_django_auth
flutter pub add http
```

**3. Provider Setup di main.dart (Tanpa config.dart):**
```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => CookieRequest(),
      child: MaterialApp(
        home: const LoginPage(),
        // Tidak ada lagi config.dart; base URL di-inline di tiap file yang perlu.
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/menu': (context) => const MenuPage(),
        },
      ),
    );
  }
}
```

**4. Model Kustom (ProductEntry):**
- Generate model dari JSON menggunakan Quicktype/JSON to Dart
- Buat `lib/models/product_entry.dart`
- Include semua field dari Django model: id, name, price, description, thumbnail, category, is_featured, user, created_at, dll

**5. Authentication Screens:**

**LoginPage (`lib/screens/login.dart`):**
- TextField untuk username & password
- ElevatedButton yang call `request.login()`
- Navigate ke MenuPage on success
- Link ke RegisterPage

**RegisterPage (`lib/screens/register.dart`):**
- TextField untuk username, password, confirm password
- ElevatedButton yang call `request.postJson()` ke `/auth/register/`
- Navigate ke LoginPage on success

**6. Product List dengan Filter User:**

**ProductListPage (`lib/screens/product_list.dart`):**
```dart
Future<List<ProductEntry>> fetchProducts(CookieRequest request) async {
  // Django endpoint /json/ sudah filter by request.user
  final response = await request.get('$baseUrl/json/');
  return response.map((d) => ProductEntry.fromJson(d)).toList();
}

@override
Widget build(BuildContext context) {
  return FutureBuilder<List<ProductEntry>>(
    future: fetchProducts(request),
    builder: (context, snapshot) {
      // Handle loading, error, empty states
      // Display ListView dengan ProductCard
    }
  );
}
```

**Django Side Filter:**
```python
def show_json(request):
    # Filter products by logged-in user
    products = Product.objects.filter(user=request.user)
    return HttpResponse(serializers.serialize("json", products))
```

**7. Product Detail Page:**

**ProductDetailPage (`lib/screens/product_detail.dart`):**
- Menerima ProductEntry via constructor
- Display semua atribut: name, price, description, thumbnail (via proxy), category, is_featured, stock, views, created_at, user
- Back button ke list page

**8. Product Form Integration:**

**ProductFormPage update:**
```dart
ElevatedButton(
  onPressed: () async {
    if (_formKey.currentState!.validate()) {
      final response = await request.postJson(
        "$baseUrl/create-flutter/",
        jsonEncode({
          "name": _name,
          "price": _price,
          "description": _description,
          "thumbnail": _thumbnail,
          "category": _category,
          "is_featured": _isFeatured,
        }),
      );
      
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Product saved!"))
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuPage())
        );
      }
    }
  }
)
```

**9. Logout Functionality:**

**Menu dengan Logout Button:**
```dart
else if (item.name == "Logout") {
  final response = await request.logout("$baseUrl/auth/logout/");
  if (response['status']) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage())
    );
  }
}
```
- Drawer dengan menu: Home, My Products, Add Product, News List
- Home grid cards: All Products, My Products, Create Product, Logout
- Semua navigation handle dengan Navigator.push/pushReplacement
