// SepetItem sınıfı: Sepete eklenen her bir ürünü temsil eder.
// Hangi ürün olduğunu, kaç adet eklendiğini ve fiyatını tutar.
class SepetItem {
  final int? id; // Veritabanındaki benzersiz kayıt numarası
  final int urunId; // Hangi ürünle ilişkili olduğunu gösteren numara
  final String urunAd; // Görüntüleme için ürün adının kopyası
  final double fiyat; // Sepete eklendiği andaki fiyat
  int adet; // Sepetteki adet (güncellenebilir olduğu için final değil)

  SepetItem({
    this.id,
    required this.urunId,
    required this.urunAd,
    required this.fiyat,
    required this.adet,
  });

  // toMap(): SepetItem nesnesini veritabanına yazılabilir formata çevirir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'urunId': urunId,
      'urunAd': urunAd,
      'fiyat': fiyat,
      'adet': adet,
    };
  }

  // fromMap(): Veritabanından gelen veriyi SepetItem nesnesine çevirir
  factory SepetItem.fromMap(Map<String, dynamic> map) {
    return SepetItem(
      id: map['id'],
      urunId: map['urunId'],
      urunAd: map['urunAd'],
      fiyat: map['fiyat'],
      adet: map['adet'],
    );
  }
}
