import 'package:flutter/material.dart';

// SiparisDetayPage: Tek bir siparişin tüm detaylarını gösterir.
// Sipariş geçmişi sayfasından sipariş verisi parametre olarak alınır.
class SiparisDetayPage extends StatelessWidget {
  final Map<String, dynamic> siparis;
  final int siparisNo;

  const SiparisDetayPage({
    super.key,
    required this.siparis,
    required this.siparisNo,
  });

  // Tarihi okunabilir formata çevirir
  String _tarihFormati(String tarih) {
    final dt = DateTime.parse(tarih);
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final tamVeri = siparis['urunler'] as String;

    // "Ürünler | Adres: ..." şeklinde ayrıştır
    final parcalar = tamVeri.split('| Adres: ');
    final urunlerStr = parcalar[0].trim();
    final adresStr = parcalar.length > 1 ? parcalar[1] : '';

    // Ürün listesini ayır (virgülle ayrılmış)
    final urunler = urunlerStr
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Adres bilgisini parçala: "Ad Soyad | Telefon | İl/İlçe | Açık Adres | Ödeme: Yöntem"
    final adresParcalari = adresStr.split('|').map((e) => e.trim()).toList();

    String adSoyad = adresParcalari.isNotEmpty ? adresParcalari[0] : '-';
    String telefon = adresParcalari.length > 1 ? adresParcalari[1] : '-';
    String ilIlce = adresParcalari.length > 2 ? adresParcalari[2] : '-';
    String acikAdres = adresParcalari.length > 3 ? adresParcalari[3] : '-';
    String odeme = adresParcalari.length > 4
        ? adresParcalari[4].replaceFirst('Ödeme: ', '')
        : '-';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sipariş #$siparisNo',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst durum kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF006D77),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Sipariş Tamamlandı',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '#$siparisNo',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _tarihFormati(siparis['tarih']),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Ürünler bölümü
            _bolumBasligi('🛍️ Sipariş Edilen Ürünler'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: urunler
                      .map(
                        (urun) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.shopping_bag_outlined,
                                size: 18,
                                color: Color(0xFF006D77),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  urun,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Teslimat bilgileri
            _bolumBasligi('📍 Teslimat Bilgileri'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bilgiSatiri(Icons.person, 'Alıcı', adSoyad),
                    const Divider(),
                    _bilgiSatiri(Icons.phone, 'Telefon', telefon),
                    const Divider(),
                    _bilgiSatiri(Icons.location_city, 'İl/İlçe', ilIlce),
                    const Divider(),
                    _bilgiSatiri(Icons.edit_location, 'Açık Adres', acikAdres),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Ödeme bilgileri
            _bolumBasligi('💳 Ödeme Bilgileri'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _bilgiSatiri(Icons.payment, 'Ödeme Yöntemi', odeme),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Toplam Tutar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(siparis['toplamTutar'] as double).toStringAsFixed(2)} ₺',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF006D77),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _bolumBasligi(String baslik) {
    return Text(
      baslik,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF006D77),
      ),
    );
  }

  Widget _bilgiSatiri(IconData ikon, String baslik, String deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, size: 18, color: const Color(0xFF006D77)),
          const SizedBox(width: 10),
          Text(
            '$baslik: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(child: Text(deger, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
