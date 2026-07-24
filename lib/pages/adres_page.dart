import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../models/sepet_item.dart';
import 'siparis_gecmisi_page.dart';

// Türkiye illeri ve ilçeleri
const Map<String, List<String>> ilVeIlceler = {
  'Adana': [
    'Aladağ',
    'Ceyhan',
    'Çukurova',
    'Feke',
    'İmamoğlu',
    'Karaisalı',
    'Karataş',
    'Kozan',
    'Pozantı',
    'Saimbeyli',
    'Sarıçam',
    'Seyhan',
    'Tufanbeyli',
    'Yumurtalık',
    'Yüreğir',
  ],
  'Ankara': [
    'Altındağ',
    'Ayaş',
    'Bala',
    'Beypazarı',
    'Çamlıdere',
    'Çankaya',
    'Çubuk',
    'Elmadağ',
    'Etimesgut',
    'Evren',
    'Gölbaşı',
    'Güdül',
    'Haymana',
    'Kalecik',
    'Kazan',
    'Keçiören',
    'Kızılcahamam',
    'Mamak',
    'Nallıhan',
    'Polatlı',
    'Pursaklar',
    'Sincan',
    'Şereflikoçhisar',
    'Yenimahalle',
  ],
  'İstanbul': [
    'Adalar',
    'Arnavutköy',
    'Ataşehir',
    'Avcılar',
    'Bağcılar',
    'Bahçelievler',
    'Bakırköy',
    'Başakşehir',
    'Bayrampaşa',
    'Beşiktaş',
    'Beykoz',
    'Beylikdüzü',
    'Beyoğlu',
    'Büyükçekmece',
    'Çatalca',
    'Çekmeköy',
    'Esenler',
    'Esenyurt',
    'Eyüpsultan',
    'Fatih',
    'Gaziosmanpaşa',
    'Güngören',
    'Kadıköy',
    'Kağıthane',
    'Kartal',
    'Küçükçekmece',
    'Maltepe',
    'Pendik',
    'Sancaktepe',
    'Sarıyer',
    'Silivri',
    'Sultanbeyli',
    'Sultangazi',
    'Şile',
    'Şişli',
    'Tuzla',
    'Ümraniye',
    'Üsküdar',
    'Zeytinburnu',
  ],
  'İzmir': [
    'Aliağa',
    'Balçova',
    'Bayındır',
    'Bayraklı',
    'Bergama',
    'Beydağ',
    'Bornova',
    'Buca',
    'Çeşme',
    'Çiğli',
    'Dikili',
    'Foça',
    'Gaziemir',
    'Güzelbahçe',
    'Karabağlar',
    'Karaburun',
    'Karşıyaka',
    'Kemalpaşa',
    'Kınık',
    'Kiraz',
    'Konak',
    'Menderes',
    'Menemen',
    'Narlıdere',
    'Ödemiş',
    'Seferihisar',
    'Selçuk',
    'Tire',
    'Torbalı',
    'Urla',
  ],
  'Balıkesir': [
    'Altıeylül',
    'Ayvalık',
    'Balya',
    'Bandırma',
    'Bigadiç',
    'Burhaniye',
    'Dursunbey',
    'Edremit',
    'Erdek',
    'Gömeç',
    'Gönen',
    'Havran',
    'İvrindi',
    'Karesi',
    'Kepsut',
    'Manyas',
    'Marmara',
    'Savaştepe',
    'Sındırgı',
    'Susurluk',
  ],
  'Bursa': [
    'Büyükorhan',
    'Gemlik',
    'Gürsu',
    'Harmancık',
    'İnegöl',
    'İznik',
    'Karacabey',
    'Keles',
    'Kestel',
    'Mudanya',
    'Mustafakemalpaşa',
    'Nilüfer',
    'Orhaneli',
    'Orhangazi',
    'Osmangazi',
    'Yenişehir',
    'Yıldırım',
  ],
  'Antalya': [
    'Akseki',
    'Aksu',
    'Alanya',
    'Demre',
    'Döşemealtı',
    'Elmalı',
    'Finike',
    'Gazipaşa',
    'Gündoğmuş',
    'İbradı',
    'Kaş',
    'Kemer',
    'Kepez',
    'Konyaaltı',
    'Korkuteli',
    'Kumluca',
    'Manavgat',
    'Muratpaşa',
    'Serik',
  ],
  'Konya': [
    'Ahırlı',
    'Akören',
    'Akşehir',
    'Altınekin',
    'Beyşehir',
    'Bozkır',
    'Cihanbeyli',
    'Çeltik',
    'Çumra',
    'Derbent',
    'Derebucak',
    'Doğanhisar',
    'Emirgazi',
    'Ereğli',
    'Güneysınır',
    'Hadim',
    'Halkapınar',
    'Hüyük',
    'Ilgın',
    'Kadınhanı',
    'Karapınar',
    'Karatay',
    'Kulu',
    'Meram',
    'Sarayönü',
    'Selçuklu',
    'Seydişehir',
    'Taşkent',
    'Tuzlukçu',
    'Yalıhüyük',
    'Yunak',
  ],
  'Kayseri': [
    'Akkışla',
    'Bünyan',
    'Develi',
    'Felahiye',
    'Hacılar',
    'İncesu',
    'Kocasinan',
    'Melikgazi',
    'Özvatan',
    'Pınarbaşı',
    'Sarıoğlan',
    'Sarız',
    'Talas',
    'Tomarza',
    'Yahyalı',
    'Yeşilhisar',
  ],
  'Gaziantep': [
    'Araban',
    'İslahiye',
    'Karkamış',
    'Nizip',
    'Nurdağı',
    'Oğuzeli',
    'Şahinbey',
    'Şehitkamil',
    'Yavuzeli',
  ],
  'Mersin': [
    'Akdeniz',
    'Anamur',
    'Aydıncık',
    'Bozyazı',
    'Çamlıyayla',
    'Erdemli',
    'Gülnar',
    'Mezitli',
    'Mut',
    'Silifke',
    'Tarsus',
    'Toroslar',
    'Yenişehir',
  ],
  'Trabzon': [
    'Akçaabat',
    'Araklı',
    'Arsin',
    'Beşikdüzü',
    'Çarşıbaşı',
    'Çaykara',
    'Dernekpazarı',
    'Düzköy',
    'Hayrat',
    'Köprübaşı',
    'Maçka',
    'Of',
    'Ortahisar',
    'Sürmene',
    'Şalpazarı',
    'Tonya',
    'Vakfıkebir',
    'Yomra',
  ],
  'Samsun': [
    '19 Mayıs',
    'Alaçam',
    'Asarcık',
    'Atakum',
    'Ayvacık',
    'Bafra',
    'Canik',
    'Çarşamba',
    'Havza',
    'İlkadım',
    'Kavak',
    'Ladik',
    'Ondokuzmayıs',
    'Salıpazarı',
    'Tekkeköy',
    'Terme',
    'Vezirköprü',
    'Yakakent',
  ],
  'Eskişehir': [
    'Alpu',
    'Beylikova',
    'Çifteler',
    'Günyüzü',
    'Han',
    'İnönü',
    'Mahmudiye',
    'Mihalgazi',
    'Mihallıçcık',
    'Odunpazarı',
    'Sarıcakaya',
    'Seyitgazi',
    'Sivrihisar',
    'Tepebaşı',
  ],
  'Denizli': [
    'Acıpayam',
    'Babadağ',
    'Baklan',
    'Bekilli',
    'Beyağaç',
    'Bozkurt',
    'Buldan',
    'Çal',
    'Çameli',
    'Çardak',
    'Çivril',
    'Güney',
    'Honaz',
    'Kale',
    'Merkezefendi',
    'Pamukkale',
    'Sarayköy',
    'Serinhisar',
    'Tavas',
  ],
};

class AdresPage extends StatefulWidget {
  final List<SepetItem> sepetItems;
  final double toplamTutar;

  const AdresPage({
    super.key,
    required this.sepetItems,
    required this.toplamTutar,
  });

  @override
  State<AdresPage> createState() => _AdresPageState();
}

class _AdresPageState extends State<AdresPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  final _adSoyadController = TextEditingController();
  final _telefonController = TextEditingController();
  final _mahalleController = TextEditingController();
  final _adresController = TextEditingController();
  final _postaKoduController = TextEditingController();

  // Seçili il ve ilçe
  String? _secilenIl;
  String? _secilenIlce;

  String _secilenOdeme = 'Kredi Kartı';
  bool _yukleniyor = false;

  final List<Map<String, dynamic>> _odemeYontemleri = [
    {'ad': 'Kredi Kartı', 'ikon': Icons.credit_card},
    {'ad': 'Havale/EFT', 'ikon': Icons.account_balance},
    {'ad': 'Kapıda Ödeme', 'ikon': Icons.money},
  ];

  @override
  void dispose() {
    _adSoyadController.dispose();
    _telefonController.dispose();
    _mahalleController.dispose();
    _adresController.dispose();
    _postaKoduController.dispose();
    super.dispose();
  }

  Future<void> _siparisOnayla() async {
    if (_adSoyadController.text.trim().isEmpty ||
        _telefonController.text.trim().isEmpty ||
        _secilenIl == null ||
        _secilenIlce == null ||
        _adresController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm zorunlu alanları doldurun!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_telefonController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Telefon numarası en az 10 haneli olmalıdır!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _yukleniyor = true);

    final urunlerJson = widget.sepetItems
        .map((i) => '${i.urunAd} x${i.adet}')
        .join(', ');

    final adresBilgisi =
        '${_adSoyadController.text} | ${_telefonController.text} | '
        '$_secilenIl/$_secilenIlce | '
        '${_adresController.text} | Ödeme: $_secilenOdeme';

    await _dbHelper.siparisEkle(
      widget.toplamTutar,
      '$urunlerJson | Adres: $adresBilgisi',
    );

    await _dbHelper.stoklariGuncelle(widget.sepetItems);
    await _dbHelper.sepetiTemizle();

    setState(() => _yukleniyor = false);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text(
                'Siparişiniz Alındı!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Toplam: ${widget.toplamTutar.toStringAsFixed(2)} ₺',
                style: const TextStyle(fontSize: 18, color: Color(0xFF006D77)),
              ),
              const SizedBox(height: 8),
              Text(
                'Ödeme: $_secilenOdeme',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const SiparisGecmisiPage(),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                  child: const Text('Siparişlerimi Gör'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Ana sayfaya dön
                    Navigator.of(ctx).pop();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Ana Sayfaya Dön'),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '📦 Teslimat Bilgileri',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sipariş özeti
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF006D77).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF006D77)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sipariş Özeti',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006D77),
                        ),
                      ),
                      Text(
                        '${widget.sepetItems.length} çeşit ürün',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Text(
                    '${widget.toplamTutar.toStringAsFixed(2)} ₺',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006D77),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Alıcı bilgileri
            _bolumBasligi('👤 Alıcı Bilgileri'),
            const SizedBox(height: 12),
            _textField(_adSoyadController, 'Ad Soyad *', Icons.person),
            const SizedBox(height: 12),
            _textField(
              _telefonController,
              'Telefon * (10 hane)',
              Icons.phone,
              klavye: TextInputType.number,
              sadeceSayi: true,
              maxUzunluk: 10,
            ),
            const SizedBox(height: 24),

            // Adres bilgileri
            _bolumBasligi('📍 Teslimat Adresi'),
            const SizedBox(height: 12),

            // İl seçimi - Dropdown
            DropdownButtonFormField<String>(
              value: _secilenIl,
              decoration: InputDecoration(
                labelText: 'İl *',
                prefixIcon: const Icon(
                  Icons.location_city,
                  color: Color(0xFF006D77),
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
              hint: const Text('İl seçin'),
              items: ilVeIlceler.keys
                  .map((il) => DropdownMenuItem(value: il, child: Text(il)))
                  .toList(),
              onChanged: (deger) {
                setState(() {
                  _secilenIl = deger;
                  _secilenIlce = null; // İl değişince ilçeyi sıfırla
                });
              },
            ),
            const SizedBox(height: 12),

            // İlçe seçimi - Dropdown
            DropdownButtonFormField<String>(
              value: _secilenIlce,
              decoration: InputDecoration(
                labelText: 'İlçe *',
                prefixIcon: const Icon(Icons.map, color: Color(0xFF006D77)),
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
              hint: Text(_secilenIl == null ? 'Önce il seçin' : 'İlçe seçin'),
              items: _secilenIl == null
                  ? []
                  : ilVeIlceler[_secilenIl]!
                        .map(
                          (ilce) =>
                              DropdownMenuItem(value: ilce, child: Text(ilce)),
                        )
                        .toList(),
              onChanged: _secilenIl == null
                  ? null
                  : (deger) {
                      setState(() => _secilenIlce = deger);
                    },
            ),
            const SizedBox(height: 12),

            _textField(_mahalleController, 'Mahalle', Icons.home),
            const SizedBox(height: 12),
            _textField(
              _adresController,
              'Açık Adres *',
              Icons.edit_location,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _textField(
              _postaKoduController,
              'Posta Kodu',
              Icons.markunread_mailbox,
              klavye: TextInputType.number,
              sadeceSayi: true,
              maxUzunluk: 5,
            ),
            const SizedBox(height: 24),

            // Ödeme yöntemi
            _bolumBasligi('💳 Ödeme Yöntemi'),
            const SizedBox(height: 12),
            ..._odemeYontemleri.map((yontem) {
              final secili = _secilenOdeme == yontem['ad'];
              return GestureDetector(
                onTap: () => setState(() => _secilenOdeme = yontem['ad']),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: secili
                        ? const Color(0xFF006D77).withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: secili
                          ? const Color(0xFF006D77)
                          : Colors.grey[300]!,
                      width: secili ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        yontem['ikon'] as IconData,
                        color: secili ? const Color(0xFF006D77) : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        yontem['ad'],
                        style: TextStyle(
                          fontWeight: secili
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: secili
                              ? const Color(0xFF006D77)
                              : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      if (secili)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF006D77),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 32),

            // Siparişi tamamla butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _yukleniyor ? null : _siparisOnayla,
                icon: _yukleniyor
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Siparişi Tamamla',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green,
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

  Widget _textField(
    TextEditingController controller,
    String label,
    IconData ikon, {
    TextInputType klavye = TextInputType.text,
    int maxLines = 1,
    bool sadeceSayi = false,
    int? maxUzunluk,
  }) {
    return TextField(
      controller: controller,
      keyboardType: klavye,
      maxLines: maxLines,
      maxLength: maxUzunluk,
      inputFormatters: sadeceSayi
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        prefixIcon: Icon(ikon, color: const Color(0xFF006D77)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF006D77), width: 2),
        ),
      ),
    );
  }
}
