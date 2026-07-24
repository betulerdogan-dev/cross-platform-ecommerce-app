// Urun sınıfı: Bir ürünün tüm özelliklerini tanımlar.
class Urun {
  final int? id;
  final String ad;
  final String aciklama;
  final String kategori;
  final double fiyat;
  final int stok;
  final String gorselUrl;
  final int indirimOrani; // İndirim yüzdesi (0-100 arası, 0 = indirim yok)

  Urun({
    this.id,
    required this.ad,
    required this.aciklama,
    required this.kategori,
    required this.fiyat,
    required this.stok,
    required this.gorselUrl,
    this.indirimOrani = 0,
  });

  // İndirimli fiyatı hesaplar
  double get indirimliOfiyat {
    if (indirimOrani <= 0) return fiyat;
    return fiyat * (1 - indirimOrani / 100);
  }

  // İndirim var mı?
  bool get indirimVarMi => indirimOrani > 0;

  // toMap(): Ürün nesnesini veritabanına yazılabilir formata çevirir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ad': ad,
      'aciklama': aciklama,
      'kategori': kategori,
      'fiyat': fiyat,
      'stok': stok,
      'gorselUrl': gorselUrl,
      'indirimOrani': indirimOrani,
    };
  }

  // fromMap(): Veritabanından gelen veriyi Urun nesnesine çevirir
  factory Urun.fromMap(Map<String, dynamic> map) {
    return Urun(
      id: map['id'],
      ad: map['ad'],
      aciklama: map['aciklama'],
      kategori: map['kategori'],
      fiyat: map['fiyat'],
      stok: map['stok'],
      gorselUrl: map['gorselUrl'] ?? '',
      indirimOrani: map['indirimOrani'] ?? 0,
    );
  }
}
