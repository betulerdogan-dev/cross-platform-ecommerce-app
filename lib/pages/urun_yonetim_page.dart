import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/urun.dart';

// UrunYonetimPage: Admin paneli — ürün ekleme, düzenleme ve silme işlemleri.
class UrunYonetimPage extends StatefulWidget {
  const UrunYonetimPage({super.key});

  @override
  State<UrunYonetimPage> createState() => _UrunYonetimPageState();
}

class _UrunYonetimPageState extends State<UrunYonetimPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Urun> _urunler = [];
  bool _yukleniyor = true;

  final List<String> _kategoriler = [
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
    _urunleriYukle();
  }

  Future<void> _urunleriYukle() async {
    setState(() => _yukleniyor = true);
    final liste = await _dbHelper.tumUrunleriGetir();
    setState(() {
      _urunler = liste;
      _yukleniyor = false;
    });
  }

  // Yeni ürün ekleme veya mevcut ürün düzenleme diyaloğunu açar
  void _urunDialogAc({Urun? duzenlenecekUrun}) {
    final adController = TextEditingController(
      text: duzenlenecekUrun?.ad ?? '',
    );
    final aciklamaController = TextEditingController(
      text: duzenlenecekUrun?.aciklama ?? '',
    );
    final fiyatController = TextEditingController(
      text: duzenlenecekUrun?.fiyat.toString() ?? '',
    );
    final stokController = TextEditingController(
      text: duzenlenecekUrun?.stok.toString() ?? '',
    );
    final gorselController = TextEditingController(
      text: duzenlenecekUrun?.gorselUrl ?? '',
    );

    String secilenKategori = duzenlenecekUrun?.kategori ?? _kategoriler.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            duzenlenecekUrun == null ? 'Yeni Ürün Ekle' : 'Ürünü Düzenle',
            style: const TextStyle(color: Color(0xFF006D77)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: adController,
                  decoration: _inputDecoration('Ürün Adı', Icons.label),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: aciklamaController,
                  decoration: _inputDecoration('Açıklama', Icons.description),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: fiyatController,
                  decoration: _inputDecoration('Fiyat (₺)', Icons.attach_money),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stokController,
                  decoration: _inputDecoration('Stok Adedi', Icons.inventory),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: gorselController,
                  decoration: _inputDecoration('Görsel URL', Icons.image),
                ),
                const SizedBox(height: 12),
                // Kategori seçim dropdown'ı
                DropdownButtonFormField<String>(
                  value: secilenKategori,
                  decoration: _inputDecoration('Kategori', Icons.category),
                  items: _kategoriler
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (deger) {
                    setDialogState(() => secilenKategori = deger!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Zorunlu alan kontrolü
                if (adController.text.trim().isEmpty ||
                    fiyatController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ürün adı ve fiyat zorunludur!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final urun = Urun(
                  id: duzenlenecekUrun?.id,
                  ad: adController.text.trim(),
                  aciklama: aciklamaController.text.trim(),
                  kategori: secilenKategori,
                  fiyat: double.tryParse(fiyatController.text) ?? 0,
                  stok: int.tryParse(stokController.text) ?? 0,
                  gorselUrl: gorselController.text.trim(),
                );

                if (duzenlenecekUrun == null) {
                  await _dbHelper.urunEkle(urun);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Ürün başarıyla eklendi!'),
                        backgroundColor: Color(0xFF006D77),
                      ),
                    );
                  }
                } else {
                  await _dbHelper.urunGuncelle(urun);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Ürün güncellendi!'),
                        backgroundColor: Color(0xFF006D77),
                      ),
                    );
                  }
                }

                Navigator.pop(ctx);
                _urunleriYukle();
              },
              child: Text(duzenlenecekUrun == null ? 'Ekle' : 'Güncelle'),
            ),
          ],
        ),
      ),
    );
  }

  // TextField dekorasyonunu tekrar kullanılabilir şekilde oluşturur
  InputDecoration _inputDecoration(String label, IconData ikon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(ikon, color: const Color(0xFF006D77)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF006D77), width: 2),
      ),
    );
  }

  // Ürün silme işlemi
  Future<void> _urunSil(Urun urun) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ürünü Sil'),
        content: Text('"${urun.ad}" ürünü kalıcı olarak silinsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (onay == true) {
      await _dbHelper.urunSil(urun.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🗑️ ${urun.ad} silindi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _urunleriYukle();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '⚙️ Ürün Yönetimi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : _urunler.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 90,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz ürün yok.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _urunDialogAc(),
                    icon: const Icon(Icons.add),
                    label: const Text('İlk Ürünü Ekle'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _urunler.length,
              itemBuilder: (ctx, index) {
                final urun = _urunler[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    // Ürün küçük görseli
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        urun.gorselUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, e, s) => Container(
                          width: 56,
                          height: 56,
                          color: const Color(0xFF83C5BE),
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      urun.ad,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${urun.kategori}  •  ${urun.fiyat.toStringAsFixed(2)} ₺  •  Stok: ${urun.stok}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFF006D77),
                          ),
                          onPressed: () =>
                              _urunDialogAc(duzenlenecekUrun: urun),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _urunSil(urun),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _urunDialogAc(),
        backgroundColor: const Color(0xFF006D77),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Yeni Ürün', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
