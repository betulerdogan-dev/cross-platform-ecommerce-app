import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'login_page.dart';

// ProfilPage: Kullanıcı bilgilerini ve istatistiklerini gösterir.
class ProfilPage extends StatefulWidget {
  final String kullaniciAdi;
  final String adSoyad;

  const ProfilPage({
    super.key,
    required this.kullaniciAdi,
    required this.adSoyad,
  });

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _yukleniyor = true;
  int _siparisSayisi = 0;
  double _toplamHarcama = 0;
  String _favoriKategori = '-';

  @override
  void initState() {
    super.initState();
    _istatistikleriYukle();
  }

  // Sipariş geçmişinden istatistikleri hesaplar
  Future<void> _istatistikleriYukle() async {
    setState(() => _yukleniyor = true);

    final siparisler = await _dbHelper.tumSiparisleriGetir();

    double toplam = 0;
    final Map<String, int> kategoriSayaci = {};

    for (final siparis in siparisler) {
      toplam += siparis['toplamTutar'] as double;

      // Sipariş içindeki ürün adlarını ayrıştırıp kategori tahmini yap
      final urunlerStr = siparis['urunler'] as String;
      final urunBolumu = urunlerStr.split('|').first;
      final urunler = urunBolumu.split(',');

      for (final urunStr in urunler) {
        final ad = urunStr.split('x').first.trim();
        if (ad.isNotEmpty) {
          kategoriSayaci[ad] = (kategoriSayaci[ad] ?? 0) + 1;
        }
      }
    }

    // En çok geçen ürünü favori olarak göster
    String favori = '-';
    if (kategoriSayaci.isNotEmpty) {
      favori = kategoriSayaci.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    setState(() {
      _siparisSayisi = siparisler.length;
      _toplamHarcama = toplam;
      _favoriKategori = favori;
      _yukleniyor = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '👤 Profilim',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Üst profil kartı
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF006D77), Color(0xFF83C5BE)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Avatar — ad soyadın baş harfleri
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: Text(
                            _baslHarfleriAl(widget.adSoyad),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF006D77),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.adSoyad,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '@${widget.kullaniciAdi}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // İstatistik kartları
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _istatistikKarti(
                            ikon: Icons.shopping_bag,
                            baslik: 'Sipariş',
                            deger: '$_siparisSayisi',
                            renk: const Color(0xFF006D77),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _istatistikKarti(
                            ikon: Icons.payments,
                            baslik: 'Toplam Harcama',
                            deger: '${_toplamHarcama.toStringAsFixed(0)} ₺',
                            renk: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _istatistikKarti(
                      ikon: Icons.star,
                      baslik: 'En Çok Sipariş Edilen Ürün',
                      deger: _favoriKategori,
                      renk: Colors.orange,
                      genis: true,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bilgi listesi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.person,
                              color: Color(0xFF006D77),
                            ),
                            title: const Text('Ad Soyad'),
                            subtitle: Text(widget.adSoyad),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(
                              Icons.account_circle,
                              color: Color(0xFF006D77),
                            ),
                            title: const Text('Kullanıcı Adı'),
                            subtitle: Text(widget.kullaniciAdi),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Çıkış yap butonu
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'Çıkış Yap',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // İstatistik kartı widget'ı
  Widget _istatistikKarti({
    required IconData ikon,
    required String baslik,
    required String deger,
    required Color renk,
    bool genis = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: genis
          ? Row(
              children: [
                Icon(ikon, color: renk, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        baslik,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        deger,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(ikon, color: renk, size: 28),
                const SizedBox(height: 8),
                Text(
                  deger,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  baslik,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
    );
  }

  // Ad soyaddan baş harfleri çıkarır (örn: "Ahmet Yılmaz" -> "AY")
  String _baslHarfleriAl(String adSoyad) {
    final parcalar = adSoyad.trim().split(' ');
    if (parcalar.length >= 2) {
      return '${parcalar[0][0]}${parcalar[1][0]}'.toUpperCase();
    } else if (parcalar.isNotEmpty && parcalar[0].isNotEmpty) {
      return parcalar[0][0].toUpperCase();
    }
    return '?';
  }
}
