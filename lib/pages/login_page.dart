import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'urun_listesi_page.dart';

// LoginPage: Kullanıcının uygulamaya giriş yaptığı sayfa.
// Kullanıcı adı ve şifre kontrolü DatabaseHelper üzerinden yapılır.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Form alanları için controller'lar
  final _kullaniciAdiController = TextEditingController();
  final _sifreController = TextEditingController();

  // Şifre görünürlüğü
  bool _sifreGoster = false;

  // Yükleniyor durumu
  bool _yukleniyor = false;

  // Kayıt mı giriş mi gösteriliyor
  bool _kayitModu = false;

  // Kayıt için ad soyad controller
  final _adSoyadController = TextEditingController();

  @override
  void dispose() {
    _kullaniciAdiController.dispose();
    _sifreController.dispose();
    _adSoyadController.dispose();
    super.dispose();
  }

  // Giriş işlemini gerçekleştirir
  Future<void> _girisYap() async {
    if (_kullaniciAdiController.text.trim().isEmpty ||
        _sifreController.text.trim().isEmpty) {
      _mesajGoster('Kullanıcı adı ve şifre boş bırakılamaz!', Colors.red);
      return;
    }

    setState(() => _yukleniyor = true);

    final kullanici = await _dbHelper.kullaniciGiris(
      _kullaniciAdiController.text.trim(),
      _sifreController.text.trim(),
    );

    setState(() => _yukleniyor = false);

    if (kullanici != null) {
      // Giriş başarılı — ana sayfaya yönlendir
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UrunListesiPage(
              kullaniciAdi: kullanici['kullaniciAdi'],
              adSoyad: kullanici['adSoyad'],
            ),
          ),
        );
      }
    } else {
      _mesajGoster('Kullanıcı adı veya şifre hatalı!', Colors.red);
    }
  }

  // Kayıt işlemini gerçekleştirir
  Future<void> _kayitOl() async {
    if (_adSoyadController.text.trim().isEmpty ||
        _kullaniciAdiController.text.trim().isEmpty ||
        _sifreController.text.trim().isEmpty) {
      _mesajGoster('Tüm alanları doldurun!', Colors.red);
      return;
    }

    setState(() => _yukleniyor = true);

    final basarili = await _dbHelper.kullaniciKayit(
      _kullaniciAdiController.text.trim(),
      _sifreController.text.trim(),
      _adSoyadController.text.trim(),
    );

    setState(() => _yukleniyor = false);

    if (basarili) {
      _mesajGoster('Kayıt başarılı! Giriş yapabilirsiniz.', Colors.green);
      setState(() => _kayitModu = false);
    } else {
      _mesajGoster('Bu kullanıcı adı zaten kullanılıyor!', Colors.red);
    }
  }

  // SnackBar mesajı gösterir
  void _mesajGoster(String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj),
        backgroundColor: renk,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF006D77), Color(0xFF83C5BE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo ve başlık
                  const Icon(Icons.shopping_bag, size: 80, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'E-Ticaret',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Alışverişin yeni adresi',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 40),

                  // Giriş/Kayıt kartı
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Başlık
                        Text(
                          _kayitModu ? 'Hesap Oluştur' : 'Hoş Geldiniz',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF006D77),
                          ),
                        ),
                        Text(
                          _kayitModu
                              ? 'Yeni hesap oluşturun'
                              : 'Hesabınıza giriş yapın',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 24),

                        // Ad Soyad (sadece kayıt modunda)
                        if (_kayitModu) ...[
                          TextField(
                            controller: _adSoyadController,
                            decoration: _inputDecoration(
                              'Ad Soyad',
                              Icons.person,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Kullanıcı adı
                        TextField(
                          controller: _kullaniciAdiController,
                          decoration: _inputDecoration(
                            'Kullanıcı Adı',
                            Icons.account_circle,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Şifre
                        TextField(
                          controller: _sifreController,
                          obscureText: !_sifreGoster,
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Color(0xFF006D77),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _sifreGoster
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF006D77),
                              ),
                              onPressed: () =>
                                  setState(() => _sifreGoster = !_sifreGoster),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF006D77),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Giriş/Kayıt butonu
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _yukleniyor
                                ? null
                                : (_kayitModu ? _kayitOl : _girisYap),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _yukleniyor
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    _kayitModu ? 'Kayıt Ol' : 'Giriş Yap',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Mod değiştirme butonu
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _kayitModu = !_kayitModu;
                                _kullaniciAdiController.clear();
                                _sifreController.clear();
                                _adSoyadController.clear();
                              });
                            },
                            child: Text(
                              _kayitModu
                                  ? 'Zaten hesabın var mı? Giriş Yap'
                                  : 'Hesabın yok mu? Kayıt Ol',
                              style: const TextStyle(color: Color(0xFF006D77)),
                            ),
                          ),
                        ),

                        // Demo bilgisi
                        if (!_kayitModu)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF83C5BE).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF006D77),
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Demo: admin / 1234',
                                  style: TextStyle(
                                    color: Color(0xFF006D77),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData ikon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(ikon, color: const Color(0xFF006D77)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF006D77), width: 2),
      ),
    );
  }
}
