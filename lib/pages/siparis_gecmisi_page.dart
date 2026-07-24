import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'siparis_detay_page.dart';

// SiparisGecmisiPage: Kullanıcının verdiği tüm siparişleri listeler.
// Siparişler en yeniden eskiye doğru sıralanır.
class SiparisGecmisiPage extends StatefulWidget {
  const SiparisGecmisiPage({super.key});

  @override
  State<SiparisGecmisiPage> createState() => _SiparisGecmisiPageState();
}

class _SiparisGecmisiPageState extends State<SiparisGecmisiPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Siparişlerin tutulduğu liste
  // Siparişlerin tutulduğu liste
  // Siparişlerin tutulduğu liste
  List<Map<String, dynamic>> _siparisler = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _siparisleriYukle();
  }

  // Veritabanından tüm siparişleri çeker
  Future<void> _siparisleriYukle() async {
    setState(() => _yukleniyor = true);
    final liste = await _dbHelper.tumSiparisleriGetir();
    setState(() {
      _siparisler = liste;
      _yukleniyor = false;
    });
  }

  // Tarihi okunabilir formata çevirir
  String _tarihFormati(String tarih) {
    final dt = DateTime.parse(tarih);
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // Siparişi siler
  Future<void> _siparisSil(int id) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Siparişi Sil'),
        content: const Text('Bu sipariş kaydı silinsin mi?'),
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
      await _dbHelper.siparisSil(id);
      _siparisleriYukle();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '📋 Sipariş Geçmişi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : _siparisler.isEmpty
          // Boş durum ekranı
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 90,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz sipariş vermediniz.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sepetten sipariş verdikçe burada görünür.',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _siparisler.length,
              itemBuilder: (ctx, index) {
                final siparis = _siparisler[index];
                final siparisNo = _siparisler.length - index;

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
                          builder: (_) => SiparisDetayPage(
                            siparis: siparis,
                            siparisNo: siparisNo,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sipariş no ve silme butonu
                          // Sipariş no ve silme butonu
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF006D77),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '#$siparisNo',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Sipariş Tamamlandı',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _siparisSil(siparis['id']),
                              ),
                            ],
                          ),
                          const Divider(),

                          // Sipariş tarihi
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _tarihFormati(siparis['tarih']),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Sipariş edilen ürünler
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.shopping_bag_outlined,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  siparis['urunler'],
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Toplam tutar
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF006D77).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF006D77),
                                ),
                              ),
                              child: Text(
                                '${(siparis['toplamTutar'] as double).toStringAsFixed(2)} ₺',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF006D77),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
