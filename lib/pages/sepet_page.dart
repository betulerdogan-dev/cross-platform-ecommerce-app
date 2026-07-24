import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/sepet_item.dart';
import 'siparis_gecmisi_page.dart';
import 'adres_page.dart';

// SepetPage: Kullanıcının sepetini gösteren sayfa.
class SepetPage extends StatefulWidget {
  const SepetPage({super.key});

  @override
  State<SepetPage> createState() => _SepetPageState();
}

class _SepetPageState extends State<SepetPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<SepetItem> _sepetItems = [];
  bool _yukleniyor = true;

  final _promoKodController = TextEditingController();
  double _indirimYuzdesi = 0.0;
  String _promoMesaj = '';

  @override
  void initState() {
    super.initState();
    _sepetYukle();
  }

  @override
  void dispose() {
    _promoKodController.dispose();
    super.dispose();
  }

  void _promoKoduUygula() {
    final kod = _promoKodController.text.trim().toUpperCase();
    print('Girilen kod: $kod');

    double yeniIndirim = 0.0;
    String yeniMesaj = '';

    if (kod == 'FLUTTER10') {
      yeniIndirim = 10.0;
      yeniMesaj = '🎉 %10 indirim uygulandı!';
    } else if (kod == 'INDIRIM20') {
      yeniIndirim = 20.0;
      yeniMesaj = '🎉 %20 indirim uygulandı!';
    } else if (kod == 'HOSGELDIN') {
      yeniIndirim = 15.0;
      yeniMesaj = '🎉 %15 hoş geldin indirimi uygulandı!';
    } else {
      yeniIndirim = 0.0;
      yeniMesaj = '❌ Geçersiz promosyon kodu!';
    }

    print('Yeni indirim: $yeniIndirim');
    print('Ham toplam: $_hamToplam');

    setState(() {
      _indirimYuzdesi = yeniIndirim;
      _promoMesaj = yeniMesaj;
    });

    print('İndirim sonrası toplam: $_toplamTutar');
  }

  Future<void> _sepetYukle() async {
    setState(() => _yukleniyor = true);
    final items = await _dbHelper.sepetGetir();
    setState(() {
      _sepetItems = items;
      _yukleniyor = false;
    });
  }

  double get _hamToplam {
    return _sepetItems.fold(
      0,
      (toplam, item) => toplam + (item.fiyat * item.adet),
    );
  }

  double get _toplamTutar {
    if (_indirimYuzdesi <= 0.0) return _hamToplam;
    final indirim = _hamToplam * _indirimYuzdesi / 100.0;
    return _hamToplam - indirim;
  }

  double get _indirimTutari => _hamToplam - _toplamTutar;

  Future<void> _adetGuncelle(SepetItem item, int yeniAdet) async {
    if (yeniAdet < 1) return;
    await _dbHelper.sepetAdetGuncelle(item.id!, yeniAdet);
    _sepetYukle();
  }

  Future<void> _urunSil(SepetItem item) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ürünü Kaldır'),
        content: Text('${item.urunAd} sepetten kaldırılsın mı?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kaldır', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (onay == true) {
      await _dbHelper.sepettenSil(item.id!);
      _sepetYukle();
    }
  }

  Future<void> _siparisVer() async {
    if (_sepetItems.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AdresPage(sepetItems: _sepetItems, toplamTutar: _toplamTutar),
      ),
    ).then((_) => _sepetYukle());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🛒 Sepetim',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Sipariş Geçmişi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SiparisGecmisiPage()),
              );
            },
          ),
        ],
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : _sepetItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 90,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sepetiniz boş!',
                    style: TextStyle(fontSize: 20, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ürün listesinden eklemeye başlayın.',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Alışverişe Devam Et'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _sepetItems.length,
                    itemBuilder: (ctx, index) {
                      final item = _sepetItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.urunAd,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _urunSil(item),
                                  ),
                                ],
                              ),
                              Text(
                                'Birim Fiyat: ${item.fiyat.toStringAsFixed(2)} ₺',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Color(0xFF006D77),
                                        ),
                                        onPressed: () =>
                                            _adetGuncelle(item, item.adet - 1),
                                      ),
                                      Text(
                                        '${item.adet}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          color: Color(0xFF006D77),
                                        ),
                                        onPressed: () =>
                                            _adetGuncelle(item, item.adet + 1),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${(item.fiyat * item.adet).toStringAsFixed(2)} ₺',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF006D77),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Alt panel
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Promosyon kodu
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _promoKodController,
                              decoration: InputDecoration(
                                hintText: 'Promosyon kodu girin...',
                                prefixIcon: const Icon(
                                  Icons.local_offer,
                                  color: Color(0xFF006D77),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF006D77),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              print('BUTON BASILDI');
                              _promoKoduUygula();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 16,
                              ),
                            ),
                            child: const Text('Uygula'),
                          ),
                        ],
                      ),

                      // Promosyon mesajı
                      if (_promoMesaj.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _promoMesaj,
                            style: TextStyle(
                              color: _indirimYuzdesi > 0
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                      const SizedBox(height: 12),

                      // İndirim tutarı
                      if (_indirimYuzdesi > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'İndirim (%${_indirimYuzdesi.toInt()})',
                              style: const TextStyle(color: Colors.green),
                            ),
                            Text(
                              '-${_indirimTutari.toStringAsFixed(2)} ₺',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 8),

                      // Toplam tutar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_sepetItems.length} çeşit ürün',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (_indirimYuzdesi > 0)
                                Text(
                                  '${_hamToplam.toStringAsFixed(2)} ₺',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                '${_toplamTutar.toStringAsFixed(2)} ₺',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF006D77),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Sipariş ver butonu
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _siparisVer,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text(
                            'Sipariş Ver',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
