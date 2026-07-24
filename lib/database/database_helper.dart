import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/urun.dart';
import '../models/sepet_item.dart';

// DatabaseHelper: Uygulamanın tüm veritabanı işlemlerini yöneten sınıf.
// Singleton tasarım deseni kullanılır — uygulama boyunca tek bir
// veritabanı bağlantısı açık tutulur, böylece kaynak israfı önlenir.
class DatabaseHelper {
  // Sınıfın tek örneği (instance) burada saklanır
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // Dışarıdan new DatabaseHelper() yazıldığında hep aynı örnek döner
  factory DatabaseHelper() => _instance;

  // Sınıf içinden çağrılan özel constructor
  DatabaseHelper._internal();

  // Veritabanı nesnesi; ilk kullanımda oluşturulur, sonra tekrar kullanılır
  static Database? _database;
  // Veritabanına erişim noktası: yoksa oluştur, varsa mevcut olanı döndür
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Veritabanını cihazda fiziksel olarak oluşturan metod
  Future<Database> _initDatabase() async {
    // getDatabasesPath(): Cihazda veritabanı için uygun klasör yolunu verir
    final dbPath = await getDatabasesPath();
    // join(): Klasör yolu ile dosya adını birleştirerek tam yolu oluşturur
    final path = join(dbPath, 'eticaret.db');

    return await openDatabase(
      path,
      version: 9,
      onCreate: _createTables,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS urunler');
        await db.execute('DROP TABLE IF EXISTS sepet');
        await db.execute('DROP TABLE IF EXISTS siparisler');
        await db.execute('DROP TABLE IF EXISTS kullanicilar');
        await db.execute('DROP TABLE IF EXISTS favoriler');
        await db.execute('DROP TABLE IF EXISTS aramaGecmisi');
        await db.execute('DROP TABLE IF EXISTS yorumlar');
        await _createTables(db, newVersion);
      },
    );
  }

  // Veritabanı ilk oluşturulduğunda tabloları hazırlayan metod
  Future<void> _createTables(Database db, int version) async {
    // Ürünler tablosu
    await db.execute('''
CREATE TABLE urunler (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ad TEXT NOT NULL,
        aciklama TEXT NOT NULL,
        kategori TEXT NOT NULL,
        fiyat REAL NOT NULL,
        stok INTEGER NOT NULL,
        gorselUrl TEXT NOT NULL,
        indirimOrani INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Sepet tablosu
    await db.execute('''
      CREATE TABLE sepet (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        urunId INTEGER NOT NULL,
        urunAd TEXT NOT NULL,
        fiyat REAL NOT NULL,
        adet INTEGER NOT NULL
      )
    ''');

    // Siparişler tablosu
    await db.execute('''
      CREATE TABLE siparisler (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        toplamTutar REAL NOT NULL,
        tarih TEXT NOT NULL,
        urunler TEXT NOT NULL
      )
    ''');
    // Kullanıcılar tablosu
    await db.execute('''
      CREATE TABLE kullanicilar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kullaniciAdi TEXT NOT NULL UNIQUE,
        sifre TEXT NOT NULL,
        adSoyad TEXT NOT NULL
      )
    ''');

    // Varsayılan admin kullanıcısı ekle
    await db.insert('kullanicilar', {
      'kullaniciAdi': 'admin',
      'sifre': '1234',
      'adSoyad': 'Admin Kullanıcı',
    });
    // Favoriler tablosu
    await db.execute('''
      CREATE TABLE favoriler (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        urunId INTEGER NOT NULL UNIQUE
      )
    ''');
    // Arama geçmişi tablosu
    await db.execute('''
      CREATE TABLE aramaGecmisi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kelime TEXT NOT NULL,
        tarih TEXT NOT NULL
      )
    ''');

    // Yorumlar tablosu
    await db.execute('''
      CREATE TABLE yorumlar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        urunId INTEGER NOT NULL,
        kullaniciAdi TEXT NOT NULL,
        yorum TEXT NOT NULL,
        puan INTEGER NOT NULL,
        tarih TEXT NOT NULL
      )
    ''');

    // İlk açılışta örnek ürünleri ekle
    await _ornekUrunleriEkle(db);
  }

  // Uygulama ilk kurulduğunda veritabanına örnek ürünler ekler
  Future<void> _ornekUrunleriEkle(Database db) async {
    final ornekUrunler = [
      // ELEKTRONİK
      {
        'ad': 'Sony WH-1000XM5 Kulaklık',
        'aciklama': 'Gürültü engelleme, 30 saat pil, Bluetooth 5.2',
        'kategori': 'Elektronik',
        'fiyat': 4299.99,
        'stok': 15,
        'gorselUrl':
            'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&fit=crop',
      },
      {
        'ad': 'Akıllı Saat',
        'aciklama': 'GPS, kalp ritmi, kan oksijeni ölçer',
        'kategori': 'Elektronik',
        'fiyat': 12999.99,
        'stok': 8,
        'gorselUrl':
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&fit=crop',
      },
      {
        'ad': 'Samsung 4K Monitor',
        'aciklama': '27 inç, 144Hz, HDR400, IPS panel',
        'kategori': 'Elektronik',
        'fiyat': 8499.99,
        'stok': 6,
        'gorselUrl':
            'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=400&fit=crop',
      },
      {
        'ad': 'Mekanik Klavye',
        'aciklama': 'RGB aydınlatmalı, Cherry MX switch',
        'kategori': 'Elektronik',
        'fiyat': 1299.99,
        'stok': 20,
        'gorselUrl':
            'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=400&fit=crop',
      },
      {
        'ad': 'Oyuncu Mouse',
        'aciklama': '16000 DPI, 7 programlanabilir tuş',
        'kategori': 'Elektronik',
        'fiyat': 649.99,
        'stok': 18,
        'gorselUrl':
            'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400&fit=crop',
      },
      {
        'ad': 'Tablet 10 inç',
        'aciklama': '128GB, 8GB RAM, kalem destekli',
        'kategori': 'Elektronik',
        'fiyat': 8999.99,
        'stok': 5,
        'gorselUrl':
            'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400&fit=crop',
      },
      {
        'ad': 'Drone Kamera',
        'aciklama': '4K video, 34 dk uçuş, katlanabilir',
        'kategori': 'Elektronik',
        'fiyat': 18999.99,
        'stok': 4,
        'gorselUrl':
            'https://images.unsplash.com/photo-1473968512647-3e447244af8f?w=400&fit=crop',
      },
      {
        'ad': 'Aksiyon Kamera',
        'aciklama': 'Su geçirmez, 5.3K video, HyperSmooth',
        'kategori': 'Elektronik',
        'fiyat': 9499.99,
        'stok': 7,
        'gorselUrl':
            'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=400&fit=crop',
      },
      {
        'ad': 'Bluetooth Hoparlör',
        'aciklama': 'Su geçirmez, 20 saat pil',
        'kategori': 'Elektronik',
        'fiyat': 3299.99,
        'stok': 12,
        'gorselUrl':
            'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400&fit=crop',
      },
      {
        'ad': 'E-Kitap Okuyucu',
        'aciklama': '6.8 inç, aydınlatmalı, su geçirmez',
        'kategori': 'Elektronik',
        'fiyat': 4799.99,
        'stok': 10,
        'gorselUrl':
            'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&fit=crop',
      },
      {
        'ad': 'Oyun Konsolu',
        'aciklama': '4K oyun, SSD, çift kontrolcü',
        'kategori': 'Elektronik',
        'fiyat': 19999.99,
        'stok': 3,
        'gorselUrl':
            'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=400&fit=crop',
      },
      {
        'ad': 'Robot Süpürge',
        'aciklama': 'Lazer navigasyon, 4000Pa emme',
        'kategori': 'Elektronik',
        'fiyat': 7499.99,
        'stok': 9,
        'gorselUrl':
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&fit=crop',
      },
      {
        'ad': 'Webcam 4K',
        'aciklama': '4K 60fps, geniş açı, otomatik netleme',
        'kategori': 'Elektronik',
        'fiyat': 2799.99,
        'stok': 14,
        'gorselUrl':
            'https://images.unsplash.com/photo-1587826080692-f439cd0b70da?w=400&fit=crop',
      },
      {
        'ad': 'USB-C Hub',
        'aciklama': '10 port, 4K HDMI, 100W PD şarj',
        'kategori': 'Elektronik',
        'fiyat': 1299.99,
        'stok': 22,
        'gorselUrl':
            'https://images.unsplash.com/photo-1625842268584-8f3296236761?w=400&fit=crop',
      },
      {
        'ad': 'Harici SSD 1TB',
        'aciklama': 'USB 3.2, 1050MB/s, şok dayanıklı',
        'kategori': 'Elektronik',
        'fiyat': 2499.99,
        'stok': 16,
        'gorselUrl':
            'https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=400&fit=crop',
      },
      {
        'ad': 'Kablosuz Şarj Aleti',
        'aciklama': '15W hızlı şarj, Qi uyumlu',
        'kategori': 'Elektronik',
        'fiyat': 499.99,
        'stok': 30,
        'gorselUrl':
            'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400&fit=crop',
      },
      {
        'ad': 'Akıllı Ampul Seti',
        'aciklama': 'RGB, ses kontrolü, uygulama yönetimi',
        'kategori': 'Elektronik',
        'fiyat': 599.99,
        'stok': 28,
        'gorselUrl':
            'https://images.unsplash.com/photo-1558002038-1055907df827?w=400&fit=crop',
      },
      {
        'ad': 'Powerbank 20000mAh',
        'aciklama': '65W hızlı şarj, 3 çıkış',
        'kategori': 'Elektronik',
        'fiyat': 1499.99,
        'stok': 20,
        'gorselUrl':
            'https://images.unsplash.com/photo-1585338447937-7082f8fc763d?w=400&fit=crop',
      },
      {
        'ad': 'Akıllı Kapı Zili',
        'aciklama': '1080p kamera, gece görüşü, WiFi',
        'kategori': 'Elektronik',
        'fiyat': 2199.99,
        'stok': 11,
        'gorselUrl':
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&fit=crop',
      },
      {
        'ad': 'Lazer Yazıcı',
        'aciklama': 'WiFi, dubleks, 30 sayfa/dk',
        'kategori': 'Elektronik',
        'fiyat': 5999.99,
        'stok': 6,
        'gorselUrl':
            'https://images.unsplash.com/photo-1612815154858-60aa4c59eaa6?w=400&fit=crop',
      },

      // GİYİM
      {
        'ad': 'Slim Fit Takım Elbise',
        'aciklama': 'Yün karışımlı, slim fit, lacivert',
        'kategori': 'Giyim',
        'fiyat': 4999.99,
        'stok': 10,
        'gorselUrl':
            'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=400&fit=crop',
      },
      {
        'ad': 'Kışlık Mont',
        'aciklama': 'Su geçirmez, polar astarlı, kapüşonlu',
        'kategori': 'Giyim',
        'fiyat': 2199.99,
        'stok': 12,
        'gorselUrl':
            'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=400&fit=crop',
      },
      {
        'ad': 'Spor Ayakkabı',
        'aciklama': 'Hafif taban, nefes alan kumaş',
        'kategori': 'Giyim',
        'fiyat': 1499.99,
        'stok': 25,
        'gorselUrl':
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&fit=crop',
      },
      {
        'ad': 'Slim Fit Jean',
        'aciklama': 'Esnek kumaş, beş cepli, koyu mavi',
        'kategori': 'Giyim',
        'fiyat': 699.99,
        'stok': 30,
        'gorselUrl':
            'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400&fit=crop',
      },
      {
        'ad': 'Oversize Hoodie',
        'aciklama': 'Pamuklu, kanguru cepli, unisex',
        'kategori': 'Giyim',
        'fiyat': 549.99,
        'stok': 35,
        'gorselUrl':
            'https://images.unsplash.com/photo-1556821840-3a63f15732ce?w=400&fit=crop',
      },
      {
        'ad': 'Deri Ceket',
        'aciklama': 'Hakiki deri, biker model, siyah',
        'kategori': 'Giyim',
        'fiyat': 3999.99,
        'stok': 8,
        'gorselUrl':
            'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400&fit=crop',
      },
      {
        'ad': 'Trençkot',
        'aciklama': 'Çift sıra düğmeli, kemer detaylı, bej',
        'kategori': 'Giyim',
        'fiyat': 2799.99,
        'stok': 10,
        'gorselUrl':
            'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400&fit=crop',
      },
      {
        'ad': 'Polo Yaka T-Shirt',
        'aciklama': 'Pima pamuk, slim fit, 5 renk',
        'kategori': 'Giyim',
        'fiyat': 399.99,
        'stok': 40,
        'gorselUrl':
            'https://images.unsplash.com/photo-1586790170083-2f9ceadc732d?w=400&fit=crop',
      },
      {
        'ad': 'Koşu Taytı',
        'aciklama': 'Kompresyon, nem uzaklaştırıcı',
        'kategori': 'Giyim',
        'fiyat': 649.99,
        'stok': 20,
        'gorselUrl':
            'https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=400&fit=crop',
      },
      {
        'ad': 'Keten Gömlek',
        'aciklama': '%100 keten, regular fit, açık mavi',
        'kategori': 'Giyim',
        'fiyat': 799.99,
        'stok': 18,
        'gorselUrl':
            'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=400&fit=crop',
      },
      {
        'ad': 'Blazer Ceket',
        'aciklama': 'Viskon karışım, tek düğme, lacivert',
        'kategori': 'Giyim',
        'fiyat': 1899.99,
        'stok': 12,
        'gorselUrl':
            'https://images.unsplash.com/photo-1593030761757-71fae45fa0e7?w=400&fit=crop',
      },
      {
        'ad': 'Şort',
        'aciklama': 'Çabuk kuruyan, elastik bel, 4 cep',
        'kategori': 'Giyim',
        'fiyat': 349.99,
        'stok': 45,
        'gorselUrl':
            'https://images.unsplash.com/photo-1591195853828-11db59a44f43?w=400&fit=crop',
      },
      {
        'ad': 'Babet Ayakkabı',
        'aciklama': 'Süet, yuvarlak burun, topuksuz',
        'kategori': 'Giyim',
        'fiyat': 899.99,
        'stok': 15,
        'gorselUrl':
            'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=400&fit=crop',
      },
      {
        'ad': 'Kazak',
        'aciklama': 'Merino yün, balıkçı yaka, krem',
        'kategori': 'Giyim',
        'fiyat': 1199.99,
        'stok': 16,
        'gorselUrl':
            'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=400&fit=crop',
      },
      {
        'ad': 'Spor Bra',
        'aciklama': 'Yüksek destek, nem uzaklaştırıcı',
        'kategori': 'Giyim',
        'fiyat': 449.99,
        'stok': 30,
        'gorselUrl':
            'https://images.unsplash.com/photo-1571945153237-4929e783af4a?w=400&fit=crop',
      },
      {
        'ad': 'Oxford Ayakkabı',
        'aciklama': 'Hakiki deri, klasik model, siyah',
        'kategori': 'Giyim',
        'fiyat': 2499.99,
        'stok': 9,
        'gorselUrl':
            'https://images.unsplash.com/photo-1533867617858-e7b97e060509?w=400&fit=crop',
      },
      {
        'ad': 'Parka',
        'aciklama': 'Su geçirmez, çıkarılabilir iç mont',
        'kategori': 'Giyim',
        'fiyat': 3299.99,
        'stok': 7,
        'gorselUrl':
            'https://images.unsplash.com/photo-1548126032-079a0fb0099d?w=400&fit=crop',
      },
      {
        'ad': 'Elbise',
        'aciklama': 'Midi boy, çiçek desenli, V yaka',
        'kategori': 'Giyim',
        'fiyat': 1299.99,
        'stok': 14,
        'gorselUrl':
            'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400&fit=crop',
      },
      {
        'ad': 'Eşofman Takımı',
        'aciklama': 'Pamuk karışım, loose fit, gri',
        'kategori': 'Giyim',
        'fiyat': 999.99,
        'stok': 22,
        'gorselUrl':
            'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400&fit=crop',
      },
      {
        'ad': 'Bere & Atkı Seti',
        'aciklama': 'Akrilik örgü, 8 renk, unisex',
        'kategori': 'Giyim',
        'fiyat': 299.99,
        'stok': 50,
        'gorselUrl':
            'https://images.unsplash.com/photo-1510598969022-c4c6c5d05769?w=400&fit=crop',
      },

      // AKSESUAR
      {
        'ad': 'Deri Sırt Çantası',
        'aciklama': 'Hakiki deri, laptop bölmeli',
        'kategori': 'Aksesuar',
        'fiyat': 2499.99,
        'stok': 10,
        'gorselUrl':
            'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=400&fit=crop',
      },
      {
        'ad': 'Güneş Gözlüğü',
        'aciklama': 'UV400 koruma, polarize cam',
        'kategori': 'Aksesuar',
        'fiyat': 1299.99,
        'stok': 20,
        'gorselUrl':
            'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=400&fit=crop',
      },
      {
        'ad': 'Deri Kemer',
        'aciklama': 'Hakiki deri, otomatik toka',
        'kategori': 'Aksesuar',
        'fiyat': 449.99,
        'stok': 25,
        'gorselUrl':
            'https://images.unsplash.com/photo-1624222247344-550fb60583dc?w=400&fit=crop',
      },
      {
        'ad': 'Şapka',
        'aciklama': 'Pamuk kanvas, ayarlanabilir, 6 renk',
        'kategori': 'Aksesuar',
        'fiyat': 299.99,
        'stok': 35,
        'gorselUrl':
            'https://images.unsplash.com/photo-1521369909029-2afed882baee?w=400&fit=crop',
      },
      {
        'ad': 'Deri Cüzdan',
        'aciklama': 'Hakiki deri, 8 kart bölmeli',
        'kategori': 'Aksesuar',
        'fiyat': 349.99,
        'stok': 22,
        'gorselUrl':
            'https://images.unsplash.com/photo-1627123424574-724758594e93?w=400&fit=crop',
      },
      {
        'ad': 'Kol Saati',
        'aciklama': 'Mekanik, safir cam, deri kordon',
        'kategori': 'Aksesuar',
        'fiyat': 5999.99,
        'stok': 6,
        'gorselUrl':
            'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=400&fit=crop',
      },
      {
        'ad': 'Clutch Çanta',
        'aciklama': 'Saten, altın zincir askılı',
        'kategori': 'Aksesuar',
        'fiyat': 899.99,
        'stok': 12,
        'gorselUrl':
            'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?w=400&fit=crop',
      },
      {
        'ad': 'Bileklik Seti',
        'aciklama': 'Paslanmaz çelik, 5li set',
        'kategori': 'Aksesuar',
        'fiyat': 399.99,
        'stok': 30,
        'gorselUrl':
            'https://images.unsplash.com/photo-1611085583191-a3b181a88401?w=400&fit=crop',
      },
      {
        'ad': 'Laptop Çantası',
        'aciklama': '15.6 inç, su geçirmez, gri',
        'kategori': 'Aksesuar',
        'fiyat': 799.99,
        'stok': 18,
        'gorselUrl':
            'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&fit=crop',
      },
      {
        'ad': 'Bavul 28"',
        'aciklama': 'ABS gövde, 4 tekerlekli, TSA kilit',
        'kategori': 'Aksesuar',
        'fiyat': 2999.99,
        'stok': 8,
        'gorselUrl':
            'https://images.unsplash.com/photo-1565026057447-bc90a3dceb87?w=400&fit=crop',
      },
      {
        'ad': 'Plaj Çantası',
        'aciklama': 'Hasır, büyük boy, fermuarlı',
        'kategori': 'Aksesuar',
        'fiyat': 499.99,
        'stok': 20,
        'gorselUrl':
            'https://images.unsplash.com/photo-1544816565-aa8c1166648f?w=400&fit=crop',
      },
      {
        'ad': 'Yüzük Seti',
        'aciklama': 'Altın kaplama, 3lü set',
        'kategori': 'Aksesuar',
        'fiyat': 299.99,
        'stok': 40,
        'gorselUrl':
            'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=400&fit=crop',
      },
      {
        'ad': 'Küpe Seti',
        'aciklama': 'Gümüş, 5 çift, geometrik tasarım',
        'kategori': 'Aksesuar',
        'fiyat': 249.99,
        'stok': 45,
        'gorselUrl':
            'https://images.unsplash.com/photo-1630019852942-f89202989a59?w=400&fit=crop',
      },
      {
        'ad': 'Kolye',
        'aciklama': 'İnce zincir, minimalist, altın',
        'kategori': 'Aksesuar',
        'fiyat': 349.99,
        'stok': 28,
        'gorselUrl':
            'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=400&fit=crop',
      },
      {
        'ad': 'Şemsiye',
        'aciklama': 'Otomatik açılır, rüzgar dayanıklı',
        'kategori': 'Aksesuar',
        'fiyat': 399.99,
        'stok': 22,
        'gorselUrl':
            'https://images.unsplash.com/photo-1559181567-c3190e3a8f1e?w=400&fit=crop',
      },
      {
        'ad': 'Bel Çantası',
        'aciklama': 'Su geçirmez naylon, 3 bölme',
        'kategori': 'Aksesuar',
        'fiyat': 449.99,
        'stok': 16,
        'gorselUrl':
            'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&fit=crop',
      },
      {
        'ad': 'Eldiven',
        'aciklama': 'Dokunmatik ekran uyumlu, polar',
        'kategori': 'Aksesuar',
        'fiyat': 199.99,
        'stok': 35,
        'gorselUrl':
            'https://images.unsplash.com/photo-1545311630-21c4c2f8fc73?w=400&fit=crop',
      },
      {
        'ad': 'Kaşkol',
        'aciklama': 'Kaşmir karışım, 180cm, ekose',
        'kategori': 'Aksesuar',
        'fiyat': 599.99,
        'stok': 18,
        'gorselUrl':
            'https://images.unsplash.com/photo-1520903920243-00d872a2d1c9?w=400&fit=crop',
      },
      {
        'ad': 'Anahtarlık',
        'aciklama': 'Deri + metal, kişiselleştirilebilir',
        'kategori': 'Aksesuar',
        'fiyat': 149.99,
        'stok': 50,
        'gorselUrl':
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&fit=crop',
      },
      {
        'ad': 'Kartlık',
        'aciklama': 'Alüminyum, RFID korumalı, 6 kart',
        'kategori': 'Aksesuar',
        'fiyat': 299.99,
        'stok': 32,
        'gorselUrl':
            'https://images.unsplash.com/photo-1627123424574-724758594e93?w=400&fit=crop',
      },

      // SPOR
      {
        'ad': 'Yoga Matı',
        'aciklama': 'Kaymaz yüzey, 6mm kalınlık',
        'kategori': 'Spor',
        'fiyat': 299.99,
        'stok': 30,
        'gorselUrl':
            'https://images.unsplash.com/photo-1601925228989-db7f1c2d5e69?w=400&fit=crop',
      },
      {
        'ad': 'Protein Tozu 2kg',
        'aciklama': 'Whey protein, çikolata aromalı',
        'kategori': 'Spor',
        'fiyat': 1199.99,
        'stok': 20,
        'gorselUrl':
            'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=400&fit=crop',
      },
      {
        'ad': 'Dambıl Seti 20kg',
        'aciklama': 'Kauçuk kaplı, 5 çift, raf dahil',
        'kategori': 'Spor',
        'fiyat': 2499.99,
        'stok': 8,
        'gorselUrl':
            'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&fit=crop',
      },
      {
        'ad': 'Koşu Bandı',
        'aciklama': '16km/h, katlanabilir, 12 program',
        'kategori': 'Spor',
        'fiyat': 12999.99,
        'stok': 4,
        'gorselUrl':
            'https://images.unsplash.com/photo-1576678927484-cc907957088c?w=400&fit=crop',
      },
      {
        'ad': 'Bisiklet Kaskı',
        'aciklama': 'CE sertifikalı, 12 hava kanalı',
        'kategori': 'Spor',
        'fiyat': 899.99,
        'stok': 15,
        'gorselUrl':
            'https://images.unsplash.com/photo-1557803175-b9ab1d6f6b57?w=400&fit=crop',
      },
      {
        'ad': 'Futbol Topu',
        'aciklama': 'FIFA onaylı, size 5',
        'kategori': 'Spor',
        'fiyat': 499.99,
        'stok': 25,
        'gorselUrl':
            'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=400&fit=crop',
      },
      {
        'ad': 'Tenis Raketi',
        'aciklama': 'Grafit gövde, 290gr, orta seviye',
        'kategori': 'Spor',
        'fiyat': 1299.99,
        'stok': 10,
        'gorselUrl':
            'https://images.unsplash.com/photo-1551951650-5ca83e023e79?w=400&fit=crop',
      },
      {
        'ad': 'Yüzme Gözlüğü',
        'aciklama': 'Anti-fog, UV korumalı',
        'kategori': 'Spor',
        'fiyat': 249.99,
        'stok': 35,
        'gorselUrl':
            'https://images.unsplash.com/photo-1560090995-0e9a92b8a7a8?w=400&fit=crop',
      },
      {
        'ad': 'Spor Şişe 1L',
        'aciklama': 'Tritan, sızdırmaz, motivasyon baskılı',
        'kategori': 'Spor',
        'fiyat': 199.99,
        'stok': 45,
        'gorselUrl':
            'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400&fit=crop',
      },
      {
        'ad': 'Atlama İpi',
        'aciklama': 'Hız ipi, çelik halat, ayarlanabilir',
        'kategori': 'Spor',
        'fiyat': 149.99,
        'stok': 40,
        'gorselUrl':
            'https://images.unsplash.com/photo-1434596922112-19c563067271?w=400&fit=crop',
      },
      {
        'ad': 'Direnç Bandı Seti',
        'aciklama': '5 farklı direnç, çanta dahil',
        'kategori': 'Spor',
        'fiyat': 349.99,
        'stok': 28,
        'gorselUrl':
            'https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=400&fit=crop',
      },
      {
        'ad': 'Basketbol Topu',
        'aciklama': 'Deri kaplama, size 7',
        'kategori': 'Spor',
        'fiyat': 699.99,
        'stok': 18,
        'gorselUrl':
            'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=400&fit=crop',
      },
      {
        'ad': 'Fitness Eldiveni',
        'aciklama': 'Neopren, bilek desteği, unisex',
        'kategori': 'Spor',
        'fiyat': 299.99,
        'stok': 22,
        'gorselUrl':
            'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400&fit=crop',
      },
      {
        'ad': 'Pilates Topu',
        'aciklama': '65cm, anti-burst, pompa dahil',
        'kategori': 'Spor',
        'fiyat': 399.99,
        'stok': 20,
        'gorselUrl':
            'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400&fit=crop',
      },
      {
        'ad': 'Spor Çantası',
        'aciklama': '40L, ayakkabı bölmeli, su geçirmez',
        'kategori': 'Spor',
        'fiyat': 799.99,
        'stok': 15,
        'gorselUrl':
            'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&fit=crop',
      },
      {
        'ad': 'Foam Roller',
        'aciklama': 'Yüksek yoğunluk, 33cm',
        'kategori': 'Spor',
        'fiyat': 449.99,
        'stok': 25,
        'gorselUrl':
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&fit=crop',
      },
      {
        'ad': 'Kafa Bandı',
        'aciklama': 'Ter emici, elastik, 3lü paket',
        'kategori': 'Spor',
        'fiyat': 99.99,
        'stok': 50,
        'gorselUrl':
            'https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=400&fit=crop',
      },
      {
        'ad': 'Creatine 500gr',
        'aciklama': 'Micronized, monohydrate, aromasız',
        'kategori': 'Spor',
        'fiyat': 599.99,
        'stok': 22,
        'gorselUrl':
            'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=400&fit=crop',
      },
      {
        'ad': 'Voleybol Topu',
        'aciklama': 'Sentetik deri, 18 panel, indoor',
        'kategori': 'Spor',
        'fiyat': 549.99,
        'stok': 16,
        'gorselUrl':
            'https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?w=400&fit=crop',
      },
      {
        'ad': 'Ağırlık Yeleği',
        'aciklama': '10kg, ayarlanabilir, nefes alan',
        'kategori': 'Spor',
        'fiyat': 1499.99,
        'stok': 8,
        'gorselUrl':
            'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&fit=crop',
      },

      // KOZMETİK
      {
        'ad': 'Hyalüronik Asit Serum',
        'aciklama': '%2 HA, nem kilitleme',
        'kategori': 'Kozmetik',
        'fiyat': 459.99,
        'stok': 30,
        'gorselUrl':
            'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400&fit=crop',
      },
      {
        'ad': 'Retinol Gece Kremi',
        'aciklama': '%0.3 retinol, yaşlanma karşıtı',
        'kategori': 'Kozmetik',
        'fiyat': 699.99,
        'stok': 20,
        'gorselUrl':
            'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=400&fit=crop',
      },
      {
        'ad': 'Güneş Kremi SPF50',
        'aciklama': 'Mineral filtre, mat bitim',
        'kategori': 'Kozmetik',
        'fiyat': 349.99,
        'stok': 35,
        'gorselUrl':
            'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400&fit=crop',
      },
      {
        'ad': 'Parfüm EDP 100ml',
        'aciklama': 'Odunsu & çiçeksi koku',
        'kategori': 'Kozmetik',
        'fiyat': 1299.99,
        'stok': 14,
        'gorselUrl':
            'https://images.unsplash.com/photo-1541643600914-78b084683702?w=400&fit=crop',
      },
      {
        'ad': 'Saç Maskesi',
        'aciklama': 'Keratin bakım, 300ml, hasar onarımı',
        'kategori': 'Kozmetik',
        'fiyat': 289.99,
        'stok': 25,
        'gorselUrl':
            'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400&fit=crop',
      },
      {
        'ad': 'Makyaj Fırça Seti',
        'aciklama': '12 parça, sentetik kıl',
        'kategori': 'Kozmetik',
        'fiyat': 599.99,
        'stok': 18,
        'gorselUrl':
            'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=400&fit=crop',
      },
      {
        'ad': 'Fondöten',
        'aciklama': 'Tam kapatıcı, 24 saat kalıcı',
        'kategori': 'Kozmetik',
        'fiyat': 449.99,
        'stok': 22,
        'gorselUrl':
            'https://images.unsplash.com/photo-1590156562745-5a1e1b1e1a37?w=400&fit=crop',
      },
      {
        'ad': 'Ruj Seti',
        'aciklama': 'Mat & parlak, 6 renk',
        'kategori': 'Kozmetik',
        'fiyat': 399.99,
        'stok': 28,
        'gorselUrl':
            'https://images.unsplash.com/photo-1583241800698-e8ab01830a24?w=400&fit=crop',
      },
      {
        'ad': 'Göz Farı Paleti',
        'aciklama': '18 renk, mat & shimmer, vegan',
        'kategori': 'Kozmetik',
        'fiyat': 549.99,
        'stok': 16,
        'gorselUrl':
            'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=400&fit=crop',
      },
      {
        'ad': 'Micellar Su',
        'aciklama': '400ml, hassas cilt, makyaj temizleyici',
        'kategori': 'Kozmetik',
        'fiyat': 199.99,
        'stok': 40,
        'gorselUrl':
            'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=400&fit=crop',
      },
      {
        'ad': 'Saç Kremi',
        'aciklama': 'Argan yağlı, 400ml, yıpranmış saçlar',
        'kategori': 'Kozmetik',
        'fiyat': 249.99,
        'stok': 32,
        'gorselUrl':
            'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400&fit=crop',
      },
      {
        'ad': 'El Kremi',
        'aciklama': 'Shea yağlı, hızlı emilen, 75ml',
        'kategori': 'Kozmetik',
        'fiyat': 149.99,
        'stok': 45,
        'gorselUrl':
            'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400&fit=crop',
      },
      {
        'ad': 'Oje Seti',
        'aciklama': 'Jel formül, 12 renk',
        'kategori': 'Kozmetik',
        'fiyat': 299.99,
        'stok': 30,
        'gorselUrl':
            'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=400&fit=crop',
      },
      {
        'ad': 'Peeling Maskesi',
        'aciklama': 'AHA & BHA, haftalık bakım',
        'kategori': 'Kozmetik',
        'fiyat': 379.99,
        'stok': 22,
        'gorselUrl':
            'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400&fit=crop',
      },
      {
        'ad': 'Dudak Balsamı Seti',
        'aciklama': 'SPF15, 6 aroma, nemlendirici',
        'kategori': 'Kozmetik',
        'fiyat': 179.99,
        'stok': 50,
        'gorselUrl':
            'https://images.unsplash.com/photo-1583241800698-e8ab01830a24?w=400&fit=crop',
      },
      {
        'ad': 'Tırnak Bakım Seti',
        'aciklama': '8 parça, paslanmaz çelik',
        'kategori': 'Kozmetik',
        'fiyat': 349.99,
        'stok': 18,
        'gorselUrl':
            'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=400&fit=crop',
      },
      {
        'ad': 'Vücut Losyonu',
        'aciklama': 'Shea & kakao yağı, 400ml',
        'kategori': 'Kozmetik',
        'fiyat': 229.99,
        'stok': 35,
        'gorselUrl':
            'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=400&fit=crop',
      },
      {
        'ad': 'Maskara',
        'aciklama': 'Hacim & uzatma, su geçirmez',
        'kategori': 'Kozmetik',
        'fiyat': 329.99,
        'stok': 25,
        'gorselUrl':
            'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=400&fit=crop',
      },
      {
        'ad': 'Kaş Kalemi',
        'aciklama': 'Mikro uçlu, 24 saat kalıcı',
        'kategori': 'Kozmetik',
        'fiyat': 249.99,
        'stok': 30,
        'gorselUrl':
            'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=400&fit=crop',
      },
      {
        'ad': 'CC Krem SPF30',
        'aciklama': 'Renk düzeltici, nemlendirici',
        'kategori': 'Kozmetik',
        'fiyat': 399.99,
        'stok': 20,
        'gorselUrl':
            'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=400&fit=crop',
      },

      // KİTAP
      {
        'ad': 'Atomik Alışkanlıklar',
        'aciklama': 'James Clear, kişisel gelişim',
        'kategori': 'Kitap',
        'fiyat': 129.99,
        'stok': 50,
        'gorselUrl':
            'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400&fit=crop',
      },
      {
        'ad': 'Sapiens',
        'aciklama': 'Yuval Noah Harari, tarih',
        'kategori': 'Kitap',
        'fiyat': 149.99,
        'stok': 40,
        'gorselUrl':
            'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&fit=crop',
      },
      {
        'ad': 'Dune',
        'aciklama': 'Frank Herbert, bilim kurgu klasiği',
        'kategori': 'Kitap',
        'fiyat': 139.99,
        'stok': 35,
        'gorselUrl':
            'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&fit=crop',
      },
      {
        'ad': 'Suç ve Ceza',
        'aciklama': 'Dostoyevski, dünya klasiği',
        'kategori': 'Kitap',
        'fiyat': 99.99,
        'stok': 45,
        'gorselUrl':
            'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&fit=crop',
      },
      {
        'ad': 'Küçük Prens',
        'aciklama': 'Antoine de Saint-Exupéry',
        'kategori': 'Kitap',
        'fiyat': 79.99,
        'stok': 60,
        'gorselUrl':
            'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400&fit=crop',
      },
      {
        'ad': 'Harry Potter Set',
        'aciklama': '7 kitap takım, özel kutulu',
        'kategori': 'Kitap',
        'fiyat': 899.99,
        'stok': 15,
        'gorselUrl':
            'https://images.unsplash.com/photo-1474932430478-367dbb6832c1?w=400&fit=crop',
      },
      {
        'ad': 'İnce Memed',
        'aciklama': 'Yaşar Kemal, Türk edebiyatı',
        'kategori': 'Kitap',
        'fiyat': 89.99,
        'stok': 40,
        'gorselUrl':
            'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&fit=crop',
      },
      {
        'ad': 'Tutunamayanlar',
        'aciklama': 'Oğuz Atay, 724 sayfa',
        'kategori': 'Kitap',
        'fiyat': 109.99,
        'stok': 35,
        'gorselUrl':
            'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&fit=crop',
      },
      {
        'ad': 'Python Programlama',
        'aciklama': 'Sıfırdan ileri seviye',
        'kategori': 'Kitap',
        'fiyat': 199.99,
        'stok': 25,
        'gorselUrl':
            'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=400&fit=crop',
      },
      {
        'ad': 'Flutter & Dart Rehberi',
        'aciklama': 'Mobil uygulama geliştirme',
        'kategori': 'Kitap',
        'fiyat': 249.99,
        'stok': 20,
        'gorselUrl':
            'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=400&fit=crop',
      },
      {
        'ad': 'Sherlock Holmes Set',
        'aciklama': 'Arthur Conan Doyle, 4 kitap',
        'kategori': 'Kitap',
        'fiyat': 349.99,
        'stok': 18,
        'gorselUrl':
            'https://images.unsplash.com/photo-1474932430478-367dbb6832c1?w=400&fit=crop',
      },
      {
        'ad': 'Savaş ve Barış',
        'aciklama': 'Tolstoy, 1392 sayfa',
        'kategori': 'Kitap',
        'fiyat': 159.99,
        'stok': 22,
        'gorselUrl':
            'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&fit=crop',
      },
      {
        'ad': 'Simyacı',
        'aciklama': 'Paulo Coelho, kişisel gelişim',
        'kategori': 'Kitap',
        'fiyat': 89.99,
        'stok': 55,
        'gorselUrl':
            'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400&fit=crop',
      },
      {
        'ad': 'Yüzyıllık Yalnızlık',
        'aciklama': 'Garcia Marquez, Nobel ödüllü',
        'kategori': 'Kitap',
        'fiyat': 119.99,
        'stok': 30,
        'gorselUrl':
            'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&fit=crop',
      },
      {
        'ad': 'Bilinçdışı Zihin',
        'aciklama': 'John Bargh, psikoloji',
        'kategori': 'Kitap',
        'fiyat': 169.99,
        'stok': 25,
        'gorselUrl':
            'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&fit=crop',
      },
      {
        'ad': 'Devlet',
        'aciklama': 'Platon, felsefe klasiği',
        'kategori': 'Kitap',
        'fiyat': 99.99,
        'stok': 28,
        'gorselUrl':
            'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&fit=crop',
      },
      {
        'ad': 'Nutuk',
        'aciklama': 'Mustafa Kemal Atatürk, özel baskı',
        'kategori': 'Kitap',
        'fiyat': 199.99,
        'stok': 40,
        'gorselUrl':
            'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&fit=crop',
      },
      {
        'ad': 'Kürk Mantolu Madonna',
        'aciklama': 'Sabahattin Ali',
        'kategori': 'Kitap',
        'fiyat': 69.99,
        'stok': 65,
        'gorselUrl':
            'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400&fit=crop',
      },
      {
        'ad': 'Hayvan Çiftliği',
        'aciklama': 'George Orwell, distopya',
        'kategori': 'Kitap',
        'fiyat': 79.99,
        'stok': 50,
        'gorselUrl':
            'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&fit=crop',
      },
      {
        'ad': '1984',
        'aciklama': 'George Orwell, 352 sayfa',
        'kategori': 'Kitap',
        'fiyat': 89.99,
        'stok': 55,
        'gorselUrl':
            'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&fit=crop',
      },

      // OYUNCAK
      {
        'ad': 'LEGO Technic Araba',
        'aciklama': '1580 parça, çalışan motor',
        'kategori': 'Oyuncak',
        'fiyat': 2499.99,
        'stok': 8,
        'gorselUrl':
            'https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=400&fit=crop',
      },
      {
        'ad': 'Barbie Ev Seti',
        'aciklama': '3 katlı, mobilyalı, 3 bebek',
        'kategori': 'Oyuncak',
        'fiyat': 1299.99,
        'stok': 10,
        'gorselUrl':
            'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?w=400&fit=crop',
      },
      {
        'ad': 'RC Araba',
        'aciklama': '4x4, 30km/h, şarj edilebilir',
        'kategori': 'Oyuncak',
        'fiyat': 599.99,
        'stok': 15,
        'gorselUrl':
            'https://images.unsplash.com/photo-1594787317994-e9c20a7c5ecd?w=400&fit=crop',
      },
      {
        'ad': 'Satranç Takımı',
        'aciklama': 'Ahşap, turnuva boyutu',
        'kategori': 'Oyuncak',
        'fiyat': 449.99,
        'stok': 20,
        'gorselUrl':
            'https://images.unsplash.com/photo-1529699211952-734e80c4d42b?w=400&fit=crop',
      },
      {
        'ad': 'Puzzle 1000 Parça',
        'aciklama': 'Van Gogh Yıldızlı Gece',
        'kategori': 'Oyuncak',
        'fiyat': 249.99,
        'stok': 25,
        'gorselUrl':
            'https://images.unsplash.com/photo-1611996575749-79a3a250f948?w=400&fit=crop',
      },
      {
        'ad': 'Jenga',
        'aciklama': '54 ahşap blok, bez çantalı',
        'kategori': 'Oyuncak',
        'fiyat': 299.99,
        'stok': 22,
        'gorselUrl':
            'https://images.unsplash.com/photo-1611996575749-79a3a250f948?w=400&fit=crop',
      },
      {
        'ad': 'Monopoly Türkiye',
        'aciklama': 'Türkçe, özel Türkiye edisyonu',
        'kategori': 'Oyuncak',
        'fiyat': 399.99,
        'stok': 18,
        'gorselUrl':
            'https://images.unsplash.com/photo-1611996575749-79a3a250f948?w=400&fit=crop',
      },
      {
        'ad': 'Bebek Arabası',
        'aciklama': 'Katlanabilir, şok emici',
        'kategori': 'Oyuncak',
        'fiyat': 3499.99,
        'stok': 6,
        'gorselUrl':
            'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?w=400&fit=crop',
      },
      {
        'ad': 'Tahta Blok Seti',
        'aciklama': '100 parça, renkli, 1-6 yaş',
        'kategori': 'Oyuncak',
        'fiyat': 349.99,
        'stok': 28,
        'gorselUrl':
            'https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=400&fit=crop',
      },
      {
        'ad': 'UNO Kart Oyunu',
        'aciklama': 'Orijinal, 112 kart',
        'kategori': 'Oyuncak',
        'fiyat': 149.99,
        'stok': 40,
        'gorselUrl':
            'https://images.unsplash.com/photo-1611996575749-79a3a250f948?w=400&fit=crop',
      },
      {
        'ad': 'Nintendo Oyun',
        'aciklama': 'Mario Kart 8 Deluxe, Türkçe',
        'kategori': 'Oyuncak',
        'fiyat': 1499.99,
        'stok': 12,
        'gorselUrl':
            'https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=400&fit=crop',
      },
      {
        'ad': 'Sihirli Küp',
        'aciklama': '3x3, speedcube, PVC sticker',
        'kategori': 'Oyuncak',
        'fiyat': 199.99,
        'stok': 35,
        'gorselUrl':
            'https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=400&fit=crop',
      },
      {
        'ad': 'Oyun Hamuru Seti',
        'aciklama': '10 renk, kalıp dahil',
        'kategori': 'Oyuncak',
        'fiyat': 179.99,
        'stok': 30,
        'gorselUrl':
            'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?w=400&fit=crop',
      },
      {
        'ad': 'Teleskop',
        'aciklama': '70mm açıklık, tripod dahil',
        'kategori': 'Oyuncak',
        'fiyat': 1299.99,
        'stok': 8,
        'gorselUrl':
            'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400&fit=crop',
      },
      {
        'ad': 'Karaoke Mikrofon',
        'aciklama': 'Bluetooth, ışıklı, şarjlı',
        'kategori': 'Oyuncak',
        'fiyat': 499.99,
        'stok': 16,
        'gorselUrl':
            'https://images.unsplash.com/photo-1520170350707-b2da59970118?w=400&fit=crop',
      },
      {
        'ad': 'Dinozor Figür Seti',
        'aciklama': '12 parça, gerçekçi boyama',
        'kategori': 'Oyuncak',
        'fiyat': 299.99,
        'stok': 22,
        'gorselUrl':
            'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?w=400&fit=crop',
      },
      {
        'ad': 'Boyama Seti',
        'aciklama': '48 renk pastel, eskiz defteri',
        'kategori': 'Oyuncak',
        'fiyat': 399.99,
        'stok': 25,
        'gorselUrl':
            'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=400&fit=crop',
      },
      {
        'ad': 'Scrabble',
        'aciklama': 'Türkçe baskı, döner tabla',
        'kategori': 'Oyuncak',
        'fiyat': 549.99,
        'stok': 14,
        'gorselUrl':
            'https://images.unsplash.com/photo-1611996575749-79a3a250f948?w=400&fit=crop',
      },
      {
        'ad': 'Zeka Küpü Seti',
        'aciklama': '5 farklı zeka oyunu, ahşap',
        'kategori': 'Oyuncak',
        'fiyat': 349.99,
        'stok': 18,
        'gorselUrl':
            'https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=400&fit=crop',
      },
      {
        'ad': 'Maket Araba',
        'aciklama': 'Ferrari 1:24, boyalı, cam vitrin',
        'kategori': 'Oyuncak',
        'fiyat': 799.99,
        'stok': 10,
        'gorselUrl':
            'https://images.unsplash.com/photo-1594787317994-e9c20a7c5ecd?w=400&fit=crop',
      },

      // EV & YAŞAM
      {
        'ad': 'Bambu Kesme Tahtası',
        'aciklama': 'Antibakteriyel, 3 boyut seti',
        'kategori': 'Ev & Yaşam',
        'fiyat': 249.99,
        'stok': 28,
        'gorselUrl':
            'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&fit=crop',
      },
      {
        'ad': 'Termos 500ml',
        'aciklama': '12 saat sıcak/24 saat soğuk',
        'kategori': 'Ev & Yaşam',
        'fiyat': 399.99,
        'stok': 22,
        'gorselUrl':
            'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400&fit=crop',
      },
      {
        'ad': 'Yemek Takımı 24 Parça',
        'aciklama': 'Porselen, 6 kişilik',
        'kategori': 'Ev & Yaşam',
        'fiyat': 1299.99,
        'stok': 10,
        'gorselUrl':
            'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&fit=crop',
      },
      {
        'ad': 'Çay Seti',
        'aciklama': 'Cam karaf + 6 bardak',
        'kategori': 'Ev & Yaşam',
        'fiyat': 549.99,
        'stok': 16,
        'gorselUrl':
            'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&fit=crop',
      },
      {
        'ad': 'Kahve Makinesi',
        'aciklama': 'Espresso, cappuccino, 15 bar',
        'kategori': 'Ev & Yaşam',
        'fiyat': 4999.99,
        'stok': 6,
        'gorselUrl':
            'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&fit=crop',
      },
      {
        'ad': 'Blender',
        'aciklama': '1200W, 2L cam sürahili',
        'kategori': 'Ev & Yaşam',
        'fiyat': 1799.99,
        'stok': 9,
        'gorselUrl':
            'https://images.unsplash.com/photo-1570222094114-d054a817e56b?w=400&fit=crop',
      },
      {
        'ad': 'Yatak Örtüsü Seti',
        'aciklama': '100% pamuk, king size',
        'kategori': 'Ev & Yaşam',
        'fiyat': 899.99,
        'stok': 14,
        'gorselUrl':
            'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=400&fit=crop',
      },
      {
        'ad': 'Mum Seti',
        'aciklama': 'Soya mumu, 6 farklı koku',
        'kategori': 'Ev & Yaşam',
        'fiyat': 349.99,
        'stok': 30,
        'gorselUrl':
            'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400&fit=crop',
      },
      {
        'ad': 'Çiçek Saksı Seti',
        'aciklama': 'Seramik, 3 boyut',
        'kategori': 'Ev & Yaşam',
        'fiyat': 299.99,
        'stok': 25,
        'gorselUrl':
            'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=400&fit=crop',
      },
      {
        'ad': 'Ahşap Saat',
        'aciklama': 'Duvar saati, sessiz mekanizma',
        'kategori': 'Ev & Yaşam',
        'fiyat': 449.99,
        'stok': 18,
        'gorselUrl':
            'https://images.unsplash.com/photo-1563861826100-9cb868fdbe1c?w=400&fit=crop',
      },
      {
        'ad': 'Banyo Havlusu Seti',
        'aciklama': '100% pamuk, 4 parça',
        'kategori': 'Ev & Yaşam',
        'fiyat': 499.99,
        'stok': 20,
        'gorselUrl':
            'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=400&fit=crop',
      },
      {
        'ad': 'Organizasyon Kutusu',
        'aciklama': 'Ahşap, 6 bölmeli, çekmece',
        'kategori': 'Ev & Yaşam',
        'fiyat': 379.99,
        'stok': 22,
        'gorselUrl':
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&fit=crop',
      },
      {
        'ad': 'Diffuser Set',
        'aciklama': 'Ultrasonik, 500ml, 7 renk LED',
        'kategori': 'Ev & Yaşam',
        'fiyat': 599.99,
        'stok': 16,
        'gorselUrl':
            'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400&fit=crop',
      },
      {
        'ad': 'Dökme Demir Tava',
        'aciklama': '26cm, preseasoned, indüksiyon',
        'kategori': 'Ev & Yaşam',
        'fiyat': 799.99,
        'stok': 12,
        'gorselUrl':
            'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&fit=crop',
      },
      {
        'ad': 'Masa Lambası',
        'aciklama': 'LED, dokunmatik, 3 renk sıcaklığı',
        'kategori': 'Ev & Yaşam',
        'fiyat': 699.99,
        'stok': 18,
        'gorselUrl':
            'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=400&fit=crop',
      },
      {
        'ad': 'Halı 160x230',
        'aciklama': 'Bohem desen, yumuşak dokuma',
        'kategori': 'Ev & Yaşam',
        'fiyat': 2499.99,
        'stok': 5,
        'gorselUrl':
            'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&fit=crop',
      },
      {
        'ad': 'Dekoratif Yastık',
        'aciklama': '45x45, kadife kumaş, 4lü set',
        'kategori': 'Ev & Yaşam',
        'fiyat': 399.99,
        'stok': 20,
        'gorselUrl':
            'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&fit=crop',
      },
      {
        'ad': 'Çerçeve Seti',
        'aciklama': 'Ahşap, 3 farklı boyut, beyaz',
        'kategori': 'Ev & Yaşam',
        'fiyat': 249.99,
        'stok': 30,
        'gorselUrl':
            'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=400&fit=crop',
      },
      {
        'ad': 'Mutfak Terazi',
        'aciklama': 'Dijital, 5kg kapasite',
        'kategori': 'Ev & Yaşam',
        'fiyat': 299.99,
        'stok': 25,
        'gorselUrl':
            'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&fit=crop',
      },
      {
        'ad': 'Hava Temizleyici',
        'aciklama': 'HEPA filtre, 50m², sessiz çalışma',
        'kategori': 'Ev & Yaşam',
        'fiyat': 3499.99,
        'stok': 7,
        'gorselUrl':
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&fit=crop',
      },

      // GIDA
      {
        'ad': 'Organik Bal 500gr',
        'aciklama': 'Çiçek balı, sertifikalı organik',
        'kategori': 'Gıda',
        'fiyat': 189.99,
        'stok': 45,
        'gorselUrl':
            'https://images.unsplash.com/photo-1558642452-9d2a7deb7f62?w=400&fit=crop',
      },
      {
        'ad': 'Filtre Kahve 250gr',
        'aciklama': 'Etiyopya single origin',
        'kategori': 'Gıda',
        'fiyat': 219.99,
        'stok': 33,
        'gorselUrl':
            'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=400&fit=crop',
      },
      {
        'ad': 'Zeytinyağı 1L',
        'aciklama': 'Soğuk sıkım, naturel sızma',
        'kategori': 'Gıda',
        'fiyat': 349.99,
        'stok': 28,
        'gorselUrl':
            'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&fit=crop',
      },
      {
        'ad': 'Kuruyemiş Seti',
        'aciklama': 'Karışık, 1kg, vakumlu ambalaj',
        'kategori': 'Gıda',
        'fiyat': 299.99,
        'stok': 35,
        'gorselUrl':
            'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=400&fit=crop',
      },
      {
        'ad': 'Çikolata Kutusu',
        'aciklama': 'Belçika çikolatası, 24 parça',
        'kategori': 'Gıda',
        'fiyat': 399.99,
        'stok': 20,
        'gorselUrl':
            'https://images.unsplash.com/photo-1549007994-cb92caebd54b?w=400&fit=crop',
      },
      {
        'ad': 'Bitki Çayı Seti',
        'aciklama': '12 farklı çay, 60 poşet',
        'kategori': 'Gıda',
        'fiyat': 249.99,
        'stok': 30,
        'gorselUrl':
            'https://images.unsplash.com/photo-1563822249366-3efb23b8ae88?w=400&fit=crop',
      },
      {
        'ad': 'Granola 400gr',
        'aciklama': 'Yulaf, bal, kuru meyve',
        'kategori': 'Gıda',
        'fiyat': 179.99,
        'stok': 40,
        'gorselUrl':
            'https://images.unsplash.com/photo-1517093702898-ccd9d6e6d1f5?w=400&fit=crop',
      },
      {
        'ad': 'Badem Ezmesi',
        'aciklama': '%100 badem, katkısız, 300gr',
        'kategori': 'Gıda',
        'fiyat': 229.99,
        'stok': 25,
        'gorselUrl':
            'https://images.unsplash.com/photo-1559181567-c3190e3a8f1e?w=400&fit=crop',
      },
      {
        'ad': 'Makarna Seti',
        'aciklama': 'İtalyan, 5 farklı çeşit',
        'kategori': 'Gıda',
        'fiyat': 199.99,
        'stok': 35,
        'gorselUrl':
            'https://images.unsplash.com/photo-1551462147-ff29053bfc14?w=400&fit=crop',
      },
      {
        'ad': 'Baharat Seti',
        'aciklama': '12 özel baharat, cam kavanoz',
        'kategori': 'Gıda',
        'fiyat': 449.99,
        'stok': 18,
        'gorselUrl':
            'https://images.unsplash.com/photo-1532336414038-cf19250c5757?w=400&fit=crop',
      },
      {
        'ad': 'Glutensiz Ekmek',
        'aciklama': 'Yulaf unu, 400gr',
        'kategori': 'Gıda',
        'fiyat': 89.99,
        'stok': 50,
        'gorselUrl':
            'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&fit=crop',
      },
      {
        'ad': 'Protein Bar 12li',
        'aciklama': '20gr protein, 4 çeşit',
        'kategori': 'Gıda',
        'fiyat': 349.99,
        'stok': 30,
        'gorselUrl':
            'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=400&fit=crop',
      },
      {
        'ad': 'Hindistan Cevizi Yağı',
        'aciklama': 'Soğuk sıkım, organik, 500ml',
        'kategori': 'Gıda',
        'fiyat': 199.99,
        'stok': 28,
        'gorselUrl':
            'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&fit=crop',
      },
      {
        'ad': 'Üzüm Pekmezi',
        'aciklama': 'Geleneksel yöntem, 700gr',
        'kategori': 'Gıda',
        'fiyat': 129.99,
        'stok': 40,
        'gorselUrl':
            'https://images.unsplash.com/photo-1558642452-9d2a7deb7f62?w=400&fit=crop',
      },
      {
        'ad': 'Yöresel Peynir Seti',
        'aciklama': '5 çeşit, vakumlu, 1kg',
        'kategori': 'Gıda',
        'fiyat': 499.99,
        'stok': 15,
        'gorselUrl':
            'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=400&fit=crop',
      },
      {
        'ad': 'Matcha 100gr',
        'aciklama': 'Japon seremonial grade',
        'kategori': 'Gıda',
        'fiyat': 399.99,
        'stok': 22,
        'gorselUrl':
            'https://images.unsplash.com/photo-1563822249366-3efb23b8ae88?w=400&fit=crop',
      },
      {
        'ad': 'Zeytin Seti',
        'aciklama': '3 çeşit, yağlı, 1kg',
        'kategori': 'Gıda',
        'fiyat': 249.99,
        'stok': 30,
        'gorselUrl':
            'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&fit=crop',
      },
      {
        'ad': 'Tahin 400gr',
        'aciklama': 'Tam buğday susam, soğuk pres',
        'kategori': 'Gıda',
        'fiyat': 159.99,
        'stok': 35,
        'gorselUrl':
            'https://images.unsplash.com/photo-1559181567-c3190e3a8f1e?w=400&fit=crop',
      },
      {
        'ad': 'Doğal Meyve Kurusu',
        'aciklama': 'Karışık, katkısız, 500gr',
        'kategori': 'Gıda',
        'fiyat': 199.99,
        'stok': 28,
        'gorselUrl':
            'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=400&fit=crop',
      },
      {
        'ad': 'Limon Suyu 500ml',
        'aciklama': 'Taze sıkım, koruyucusuz',
        'kategori': 'Gıda',
        'fiyat': 79.99,
        'stok': 45,
        'gorselUrl':
            'https://images.unsplash.com/photo-1621263764928-df1444c5e859?w=400&fit=crop',
      },
    ];

    for (int i = 0; i < ornekUrunler.length; i++) {
      // Her 3 üründen birine rastgele indirim ekle
      final indirimler = [0, 0, 10, 0, 20, 0, 15, 0, 0, 30, 0, 25, 0, 0, 5];
      final indirim = indirimler[i % indirimler.length];
      final urunMap = Map<String, dynamic>.from(ornekUrunler[i]);
      urunMap['indirimOrani'] = indirim;
      await db.insert('urunler', urunMap);
    }
  }
  // ─────────────────────────────────────────
  // ÜRÜN CRUD İŞLEMLERİ
  // ─────────────────────────────────────────

  // CREATE: Veritabanına yeni ürün ekler
  Future<int> urunEkle(Urun urun) async {
    final db = await database;
    return await db.insert(
      'urunler',
      urun.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ: Veritabanındaki tüm ürünleri listeler
  Future<List<Urun>> tumUrunleriGetir() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('urunler');
    return List.generate(maps.length, (i) => Urun.fromMap(maps[i]));
  }

  // READ: Kategoriye göre ürünleri filtreler
  Future<List<Urun>> kategoriyeGoreGetir(String kategori) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'urunler',
      where: 'kategori = ?',
      whereArgs: [kategori],
    );
    return List.generate(maps.length, (i) => Urun.fromMap(maps[i]));
  }

  // READ: Ada göre ürün arar
  Future<List<Urun>> urunAra(String arananKelime) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'urunler',
      where: 'ad LIKE ?',
      whereArgs: ['%$arananKelime%'],
    );
    return List.generate(maps.length, (i) => Urun.fromMap(maps[i]));
  }

  // UPDATE: Mevcut ürünün bilgilerini günceller
  Future<int> urunGuncelle(Urun urun) async {
    final db = await database;
    return await db.update(
      'urunler',
      urun.toMap(),
      where: 'id = ?',
      whereArgs: [urun.id],
    );
  }

  // DELETE: Ürünü veritabanından siler
  Future<int> urunSil(int id) async {
    final db = await database;
    return await db.delete('urunler', where: 'id = ?', whereArgs: [id]);
  }
  // ─────────────────────────────────────────
  // SEPET CRUD İŞLEMLERİ
  // ─────────────────────────────────────────

  // CREATE: Sepete ürün ekler; aynı ürün varsa sadece adedini artırır
  Future<void> sepeteEkle(SepetItem item) async {
    final db = await database;
    final mevcutlar = await db.query(
      'sepet',
      where: 'urunId = ?',
      whereArgs: [item.urunId],
    );

    if (mevcutlar.isEmpty) {
      // Ürün sepette yoksa yeni kayıt oluştur
      await db.insert('sepet', item.toMap());
    } else {
      // Ürün zaten varsa mevcut adede ekle
      final mevcutAdet = mevcutlar.first['adet'] as int;
      await db.update(
        'sepet',
        {'adet': mevcutAdet + item.adet},
        where: 'urunId = ?',
        whereArgs: [item.urunId],
      );
    }
  }

  // READ: Sepetteki tüm ürünleri getirir
  Future<List<SepetItem>> sepetGetir() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sepet');
    return List.generate(maps.length, (i) => SepetItem.fromMap(maps[i]));
  }

  // UPDATE: Sepetteki ürünün adedini günceller
  Future<int> sepetAdetGuncelle(int id, int yeniAdet) async {
    final db = await database;
    return await db.update(
      'sepet',
      {'adet': yeniAdet},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE: Sepetten tek bir ürünü kaldırır
  Future<int> sepettenSil(int id) async {
    final db = await database;
    return await db.delete('sepet', where: 'id = ?', whereArgs: [id]);
  }

  // Sipariş verilince ürünlerin stoğunu düşürür
  Future<void> stoklariGuncelle(List<SepetItem> sepetItems) async {
    final db = await database;
    for (final item in sepetItems) {
      final urun = await db.query(
        'urunler',
        where: 'id = ?',
        whereArgs: [item.urunId],
      );
      if (urun.isNotEmpty) {
        final mevcutStok = urun.first['stok'] as int;
        final yeniStok = mevcutStok - item.adet;
        await db.update(
          'urunler',
          {'stok': yeniStok < 0 ? 0 : yeniStok},
          where: 'id = ?',
          whereArgs: [item.urunId],
        );
      }
    }
  }

  // DELETE: Sepeti tamamen temizler (sipariş verildikten sonra çağrılır)
  Future<void> sepetiTemizle() async {
    final db = await database;
    await db.delete('sepet');
  }

  // READ: Sepetteki toplam ürün adedini döndürür (AppBar rozeti için)
  Future<int> sepetUrunSayisi() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(adet) as toplam FROM sepet');
    return (result.first['toplam'] as int?) ?? 0;
  }

  // ─────────────────────────────────────────
  // SİPARİŞ İŞLEMLERİ
  // ─────────────────────────────────────────

  // CREATE: Yeni sipariş kaydeder
  Future<int> siparisEkle(double toplamTutar, String urunlerJson) async {
    final db = await database;
    return await db.insert('siparisler', {
      'toplamTutar': toplamTutar,
      'tarih': DateTime.now().toIso8601String(),
      'urunler': urunlerJson,
    });
  }

  // READ: Tüm siparişleri en yeniden eskiye sıralar
  Future<List<Map<String, dynamic>>> tumSiparisleriGetir() async {
    final db = await database;
    return await db.query('siparisler', orderBy: 'id DESC');
  }

  // DELETE: Tek bir siparişi siler
  Future<int> siparisSil(int id) async {
    final db = await database;
    return await db.delete('siparisler', where: 'id = ?', whereArgs: [id]);
  }
  // ─────────────────────────────────────────
  // KULLANICI İŞLEMLERİ
  // ─────────────────────────────────────────

  // Kullanıcı adı ve şifre ile giriş kontrolü yapar
  Future<Map<String, dynamic>?> kullaniciGiris(
    String kullaniciAdi,
    String sifre,
  ) async {
    final db = await database;
    final result = await db.query(
      'kullanicilar',
      where: 'kullaniciAdi = ? AND sifre = ?',
      whereArgs: [kullaniciAdi, sifre],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Yeni kullanıcı kaydeder
  // Yeni kullanıcı kaydeder
  Future<bool> kullaniciKayit(
    String kullaniciAdi,
    String sifre,
    String adSoyad,
  ) async {
    final db = await database;
    try {
      await db.insert('kullanicilar', {
        'kullaniciAdi': kullaniciAdi,
        'sifre': sifre,
        'adSoyad': adSoyad,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─────────────────────────────────────────
  // FAVORİ İŞLEMLERİ
  // ─────────────────────────────────────────

  Future<void> favoriEkle(int urunId) async {
    final db = await database;
    await db.insert('favoriler', {
      'urunId': urunId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> favoriSil(int urunId) async {
    final db = await database;
    await db.delete('favoriler', where: 'urunId = ?', whereArgs: [urunId]);
  }

  Future<bool> favoriMi(int urunId) async {
    final db = await database;
    final result = await db.query(
      'favoriler',
      where: 'urunId = ?',
      whereArgs: [urunId],
    );
    return result.isNotEmpty;
  }

  Future<List<Urun>> favoriUrunleriGetir() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT urunler.* FROM urunler
      INNER JOIN favoriler ON urunler.id = favoriler.urunId
    ''');
    return List.generate(result.length, (i) => Urun.fromMap(result[i]));
  }
  // ─────────────────────────────────────────
  // ARAMA GEÇMİŞİ İŞLEMLERİ
  // ─────────────────────────────────────────

  // Arama kelimesini geçmişe kaydeder (aynı kelime varsa tekrar eklemez)
  Future<void> aramaKaydet(String kelime) async {
    if (kelime.trim().isEmpty) return;
    final db = await database;

    // Aynı kelime daha önce aranmışsa sil (en üste taşımak için)
    await db.delete('aramaGecmisi', where: 'kelime = ?', whereArgs: [kelime]);

    await db.insert('aramaGecmisi', {
      'kelime': kelime,
      'tarih': DateTime.now().toIso8601String(),
    });

    // Sadece son 10 aramayı tut
    final tumKayitlar = await db.query('aramaGecmisi', orderBy: 'id DESC');
    if (tumKayitlar.length > 10) {
      for (int i = 10; i < tumKayitlar.length; i++) {
        await db.delete(
          'aramaGecmisi',
          where: 'id = ?',
          whereArgs: [tumKayitlar[i]['id']],
        );
      }
    }
  }

  // Son aramaları getirir
  Future<List<String>> aramaGecmisiGetir() async {
    final db = await database;
    final result = await db.query(
      'aramaGecmisi',
      orderBy: 'id DESC',
      limit: 10,
    );
    return result.map((e) => e['kelime'] as String).toList();
  }

  // Arama geçmişini temizler
  Future<void> aramaGecmisiTemizle() async {
    final db = await database;
    await db.delete('aramaGecmisi');
  }

  // ─────────────────────────────────────────
  // YORUM İŞLEMLERİ
  // ─────────────────────────────────────────

  // Ürüne yorum ekler
  Future<void> yorumEkle(
    int urunId,
    String kullaniciAdi,
    String yorum,
    int puan,
  ) async {
    final db = await database;
    await db.insert('yorumlar', {
      'urunId': urunId,
      'kullaniciAdi': kullaniciAdi,
      'yorum': yorum,
      'puan': puan,
      'tarih': DateTime.now().toIso8601String(),
    });
  }

  // Bir ürünün tüm yorumlarını getirir
  Future<List<Map<String, dynamic>>> yorumlariGetir(int urunId) async {
    final db = await database;
    return await db.query(
      'yorumlar',
      where: 'urunId = ?',
      whereArgs: [urunId],
      orderBy: 'id DESC',
    );
  }

  // Bir ürünün ortalama puanını hesaplar
  Future<double> ortalamaPuanGetir(int urunId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT AVG(puan) as ortalama FROM yorumlar WHERE urunId = ?',
      [urunId],
    );
    final ortalama = result.first['ortalama'];
    return ortalama == null ? 0.0 : (ortalama as num).toDouble();
  }

  // Yorum sayısını getirir
  Future<int> yorumSayisiGetir(int urunId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as sayi FROM yorumlar WHERE urunId = ?',
      [urunId],
    );
    return (result.first['sayi'] as int?) ?? 0;
  }
}
