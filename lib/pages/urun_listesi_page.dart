import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/urun.dart';
import 'urun_detay_page.dart';
import 'sepet_page.dart';
import 'urun_yonetim_page.dart';
import 'login_page.dart';
import 'profil_page.dart';
import 'favoriler_page.dart';

// UrunListesiPage: Uygulamanın ana sayfası.
// Tüm ürünleri listeler, arama ve kategori filtreleme sunar.
class UrunListesiPage extends StatefulWidget {
  final String kullaniciAdi;
  final String adSoyad;

  const UrunListesiPage({
    super.key,
    required this.kullaniciAdi,
    required this.adSoyad,
  });

  @override
  State<UrunListesiPage> createState() => _UrunListesiPageState();
}

class _UrunListesiPageState extends State<UrunListesiPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Urun> _urunler = [];
  String _aramaMetni = '';
  String _secilenKategori = 'Tümü';
  int _sepetSayisi = 0;
  bool _yukleniyor = true;
  List<String> _aramaGecmisi = [];

  final List<String> _kategoriler = [
    'Tümü',
    'Elektronik',
    'Giyim',
    'Aksesuar',
    'Spor',
    'Kozmetik',
    'Kitap',
    'Oyuncak',
    'Ev & Yaşam',
    'Gıda',
  ];

  @override
  void initState() {
    super.initState();
    _verileriYukle();
    _aramaGecmisiniYukle();
  }

  Future<void> _aramaGecmisiniYukle() async {
    final gecmis = await _dbHelper.aramaGecmisiGetir();
    setState(() => _aramaGecmisi = gecmis);
  }

  Future<void> _verileriYukle() async {
    setState(() => _yukleniyor = true);
    List<Urun> liste;
    if (_aramaMetni.isNotEmpty) {
      liste = await _dbHelper.urunAra(_aramaMetni);
    } else if (_secilenKategori == 'Tümü') {
      liste = await _dbHelper.tumUrunleriGetir();
    } else {
      liste = await _dbHelper.kategoriyeGoreGetir(_secilenKategori);
    }
    final sepetSayisi = await _dbHelper.sepetUrunSayisi();
    setState(() {
      _urunler = liste;
      _sepetSayisi = sepetSayisi;
      _yukleniyor = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '🛍️ Mağaza',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Hoş geldin, ${widget.adSoyad}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          // Favoriler butonu
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favorilerim',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavorilerPage()),
              ).then((_) => _verileriYukle());
            },
          ),
          // Profil butonu
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profilim',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilPage(
                    kullaniciAdi: widget.kullaniciAdi,
                    adSoyad: widget.adSoyad,
                  ),
                ),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SepetPage()),
                  ).then((_) => _verileriYukle());
                },
              ),
              if (_sepetSayisi > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_sepetSayisi',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Çıkış butonu
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Çıkış Yap'),
                  content: const Text(
                    'Hesabınızdan çıkış yapmak istiyor musunuz?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('İptal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: const Text('Çıkış Yap'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Ürün Yönetimi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UrunYonetimPage()),
              ).then((_) => _verileriYukle());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Ürün ara...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF006D77)),
                filled: true,
                fillColor: const Color(0xFFE8E8E8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (deger) {
                setState(() => _aramaMetni = deger);
                _verileriYukle();
              },
              onSubmitted: (deger) async {
                if (deger.trim().isNotEmpty) {
                  await _dbHelper.aramaKaydet(deger.trim());
                  _aramaGecmisiniYukle();
                }
              },
            ),
          ),

          // Arama geçmişi çipleri (arama kutusu boşken gösterilir)
          if (_aramaMetni.isEmpty && _aramaGecmisi.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _aramaGecmisi.length,
                  itemBuilder: (ctx, index) {
                    final kelime = _aramaGecmisi[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        avatar: const Icon(Icons.history, size: 16),
                        label: Text(kelime),
                        onPressed: () {
                          setState(() => _aramaMetni = kelime);
                          _verileriYukle();
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

          // Kategori filtreleme çipleri
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _kategoriler.length,
              itemBuilder: (ctx, index) {
                final kategori = _kategoriler[index];
                final secili = kategori == _secilenKategori;
                return Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8),
                  child: FilterChip(
                    label: Text(kategori),
                    selected: secili,
                    onSelected: (_) {
                      setState(() => _secilenKategori = kategori);
                      _verileriYukle();
                    },
                    selectedColor: const Color(0xFF83C5BE),
                    checkmarkColor: const Color(0xFF006D77),
                  ),
                );
              },
            ),
          ),

          // Ürün listesi
          Expanded(
            child: _yukleniyor
                ? const Center(child: CircularProgressIndicator())
                : _urunler.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 72,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Ürün bulunamadı.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _verileriYukle,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _urunler.length,
                      itemBuilder: (ctx, index) {
                        return _urunKartiOlustur(_urunler[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Her ürün için görselll kart widget'ı oluşturur
  Widget _urunKartiOlustur(Urun urun) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UrunDetayPage(urun: urun)),
          ).then((_) => _verileriYukle());
        },
        child: Row(
          children: [
            // Ürün görseli
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                urun.gorselUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (ctx, error, stack) => Container(
                  width: 100,
                  height: 100,
                  color: const Color(0xFF83C5BE),
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: 100,
                    height: 100,
                    color: const Color(0xFFE8E8E8),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF006D77),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Ürün bilgileri
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori etiketi
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF83C5BE).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        urun.kategori,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF006D77),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      urun.ad,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      urun.aciklama,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (urun.indirimVarMi)
                              Text(
                                '${urun.fiyat.toStringAsFixed(2)} ₺',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Row(
                              children: [
                                Text(
                                  '${urun.indirimliOfiyat.toStringAsFixed(2)} ₺',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF006D77),
                                  ),
                                ),
                                if (urun.indirimVarMi) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '%${urun.indirimOrani}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        Text(
                          'Stok: ${urun.stok}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right, color: Color(0xFF006D77)),
            ),
          ],
        ),
      ),
    );
  }
}
