import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/urun.dart';
import '../models/sepet_item.dart';

// UrunDetayPage: Seçilen ürünün tüm detaylarını gösterir.
// Ana sayfadan 'urun' parametresi alır — sayfa arası veri aktarımı burada!
class UrunDetayPage extends StatefulWidget {
  final Urun urun;

  const UrunDetayPage({super.key, required this.urun});

  @override
  State<UrunDetayPage> createState() => _UrunDetayPageState();
}

class _UrunDetayPageState extends State<UrunDetayPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _adet = 1;
  bool _favoriMi = false;
  List<Map<String, dynamic>> _yorumlar = [];
  double _ortalamaPuan = 0;
  int _secilenPuan = 5;
  final _yorumController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _favoriDurumunuKontrolEt();
    _yorumlariYukle();
  }

  @override
  void dispose() {
    _yorumController.dispose();
    super.dispose();
  }

  Future<void> _yorumlariYukle() async {
    final yorumlar = await _dbHelper.yorumlariGetir(widget.urun.id!);
    final ortalama = await _dbHelper.ortalamaPuanGetir(widget.urun.id!);
    setState(() {
      _yorumlar = yorumlar;
      _ortalamaPuan = ortalama;
    });
  }

  Future<void> _yorumGonder() async {
    if (_yorumController.text.trim().isEmpty) return;
    await _dbHelper.yorumEkle(
      widget.urun.id!,
      'Misafir Kullanıcı',
      _yorumController.text.trim(),
      _secilenPuan,
    );
    _yorumController.clear();
    setState(() => _secilenPuan = 5);
    _yorumlariYukle();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Yorumunuz eklendi!'),
          backgroundColor: Color(0xFF006D77),
        ),
      );
    }
  }

  // Ürünün favori olup olmadığını kontrol eder
  Future<void> _favoriDurumunuKontrolEt() async {
    final favori = await _dbHelper.favoriMi(widget.urun.id!);
    setState(() => _favoriMi = favori);
  }

  // Favori durumunu değiştirir
  Future<void> _favoriToggle() async {
    if (_favoriMi) {
      await _dbHelper.favoriSil(widget.urun.id!);
    } else {
      await _dbHelper.favoriEkle(widget.urun.id!);
    }
    setState(() => _favoriMi = !_favoriMi);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _favoriMi ? '❤️ Favorilere eklendi!' : '💔 Favorilerden çıkarıldı',
          ),
          backgroundColor: _favoriMi ? Colors.red : Colors.grey,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _adetAzalt() {
    if (_adet > 1) setState(() => _adet--);
  }

  void _adetArtir() {
    if (_adet < widget.urun.stok) setState(() => _adet++);
  }

  Future<void> _sepeteEkle() async {
    final item = SepetItem(
      urunId: widget.urun.id!,
      urunAd: widget.urun.ad,
      fiyat: widget.urun.fiyat,
      adet: _adet,
    );
    await _dbHelper.sepeteEkle(item);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${widget.urun.ad} sepete eklendi! ($_adet adet)'),
          backgroundColor: const Color(0xFF006D77),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stokRengi = widget.urun.stok > 10
        ? Colors.green
        : widget.urun.stok > 0
        ? Colors.orange
        : Colors.red;

    final stokMetni = widget.urun.stok > 10
        ? 'Stokta Var (${widget.urun.stok})'
        : widget.urun.stok > 0
        ? 'Son ${widget.urun.stok} ürün!'
        : 'Stokta Yok';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.urun.ad),
        actions: [
          IconButton(
            icon: Icon(
              _favoriMi ? Icons.favorite : Icons.favorite_border,
              color: _favoriMi ? Colors.red : Colors.white,
            ),
            tooltip: 'Favorilere Ekle',
            onPressed: _favoriToggle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ürün görseli — URL'den yüklenir
            SizedBox(
              width: double.infinity,
              height: 280,
              child: Image.network(
                widget.urun.gorselUrl,
                fit: BoxFit.cover,
                errorBuilder: (ctx, error, stack) => Container(
                  height: 280,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF006D77), Color(0xFF83C5BE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shopping_bag,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 280,
                    color: const Color(0xFFE8E8E8),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF006D77),
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori etiketi
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF83C5BE).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.urun.kategori,
                      style: const TextStyle(
                        color: Color(0xFF006D77),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Ürün adı
                  Text(
                    widget.urun.ad,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Stok durumu
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: stokRengi.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: stokRengi),
                    ),
                    child: Text(
                      stokMetni,
                      style: TextStyle(
                        color: stokRengi,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Açıklama başlığı
                  const Text(
                    'Ürün Açıklaması',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.urun.aciklama,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Fiyat
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Fiyat',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (widget.urun.indirimVarMi)
                            Text(
                              '${widget.urun.fiyat.toStringAsFixed(2)} ₺',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (widget.urun.indirimVarMi)
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '%${widget.urun.indirimOrani} İndirim',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Text(
                                '${widget.urun.indirimliOfiyat.toStringAsFixed(2)} ₺',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF006D77),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Adet seçici
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Adet Seç:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Color(0xFF006D77),
                          size: 36,
                        ),
                        onPressed: _adetAzalt,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF006D77)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_adet',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Color(0xFF006D77),
                          size: 36,
                        ),
                        onPressed: _adetArtir,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Ara toplam
                  Center(
                    child: Text(
                      'Ara Toplam: ${(widget.urun.fiyat * _adet).toStringAsFixed(2)} ₺',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Sepete ekle butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.urun.stok == 0 ? null : _sepeteEkle,
                      icon: const Icon(Icons.shopping_cart_checkout, size: 22),
                      label: Text(
                        widget.urun.stok == 0 ? 'Stokta Yok' : 'Sepete Ekle',
                        style: const TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Yorumlar başlığı + ortalama puan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '💬 Yorumlar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_yorumlar.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_ortalamaPuan.toStringAsFixed(1)} (${_yorumlar.length})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Yorum yazma alanı
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Puanınız:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(5, (index) {
                            final yildizNo = index + 1;
                            return IconButton(
                              icon: Icon(
                                yildizNo <= _secilenPuan
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                              ),
                              onPressed: () {
                                setState(() => _secilenPuan = yildizNo);
                              },
                            );
                          }),
                        ),
                        TextField(
                          controller: _yorumController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Yorumunuzu yazın...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _yorumGonder,
                            child: const Text('Yorum Yap'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Yorum listesi
                  if (_yorumlar.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Henüz yorum yapılmamış.',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    )
                  else
                    ..._yorumlar.map((yorum) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  yorum['kullaniciAdi'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      i < (yorum['puan'] as int)
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              yorum['yorum'],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
