import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/urun.dart';
import 'urun_detay_page.dart';

// FavorilerPage: Kullanıcının favoriye eklediği ürünleri listeler.
class FavorilerPage extends StatefulWidget {
  const FavorilerPage({super.key});

  @override
  State<FavorilerPage> createState() => _FavorilerPageState();
}

class _FavorilerPageState extends State<FavorilerPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Urun> _favoriler = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _favorileriYukle();
  }

  // Veritabanından favori ürünleri çeker
  Future<void> _favorileriYukle() async {
    setState(() => _yukleniyor = true);
    final liste = await _dbHelper.favoriUrunleriGetir();
    setState(() {
      _favoriler = liste;
      _yukleniyor = false;
    });
  }

  // Ürünü favorilerden çıkarır
  Future<void> _favoridenCikar(Urun urun) async {
    await _dbHelper.favoriSil(urun.id!);
    _favorileriYukle();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${urun.ad} favorilerden çıkarıldı'),
          backgroundColor: Colors.grey,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '❤️ Favorilerim',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : _favoriler.isEmpty
          // Boş durum ekranı
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 90,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Favori ürününüz yok.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Beğendiğiniz ürünlere ❤️ ekleyin.',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _favorileriYukle,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _favoriler.length,
                itemBuilder: (ctx, index) {
                  final urun = _favoriler[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UrunDetayPage(urun: urun),
                          ),
                        ).then((_) => _favorileriYukle());
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
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, e, s) => Container(
                                width: 90,
                                height: 90,
                                color: const Color(0xFF83C5BE),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          // Ürün bilgileri
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                    '${urun.indirimliOfiyat.toStringAsFixed(2)} ₺',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF006D77),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Favoriden çıkar butonu
                          IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () => _favoridenCikar(urun),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
