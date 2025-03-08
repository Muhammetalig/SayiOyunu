import 'dart:math'; // Rastgele sayı üretmek için matematiksel işlemler kütüphanesi
import 'package:flutter/material.dart'; // Flutter'ın temel widget'larını içeren kütüphane
import 'package:flutter/services.dart'; // Platform servislerine erişim için kütüphane (örneğin, klavye girişi kontrolü)

void main() {
  runApp(const MyApp()); // Uygulamayı başlatır ve MyApp widget'ını çalıştırır
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // MyApp widget'ının constructor'ı

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sayı Tahmin Oyunu', // Uygulamanın başlığı
      debugShowCheckedModeBanner: false, // Debug banner'ını gizler
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.deepPurple), // Renk şeması
        useMaterial3: true, // Material 3 tasarımını etkinleştirir
        textTheme: TextTheme(
          bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold), // Metin stilini belirler
        ),
      ),
      home: const NumberGuessGame(), // Uygulamanın ana sayfası
    );
  }
}

class NumberGuessGame extends StatefulWidget {
  const NumberGuessGame(
      {super.key}); // NumberGuessGame widget'ının constructor'ı

  @override
  State<NumberGuessGame> createState() =>
      _NumberGuessGameState(); // State oluşturur
}

class _NumberGuessGameState extends State<NumberGuessGame> {
  final TextEditingController _controller =
      TextEditingController(); // Kullanıcı girişi için controller
  late String secretNumber; // Sistem tarafından tutulan gizli sayı
  String? feedback; // Kullanıcıya geri bildirim mesajı
  int attempts = 0; // Toplam deneme sayısı
  int playerTurn = 1; // Hangi oyuncunun sırası (1: oyuncu 1, 2: oyuncu 2)
  static const int maxAttempts = 5; // Her oyuncunun maksimum deneme hakkı
  List<String> player1Guesses = []; // Oyuncu 1'in tahminleri
  List<String> player2Guesses = []; // Oyuncu 2'nin tahminleri
  String? winner; // Kazanan oyuncu

  @override
  void initState() {
    super.initState();
    _startNewGame(); // Oyun başladığında yeni bir oyun başlatır
  }

  /// Yeni bir oyun başlatır
  void _startNewGame() {
    secretNumber = _generateRandomNumber(); // Yeni bir gizli sayı üretir
    attempts = 0; // Deneme sayısını sıfırlar
    playerTurn = 1; // Oyuncu sırasını 1'e ayarlar
    feedback = null; // Geri bildirimi temizler
    winner = null; // Kazananı temizler
    player1Guesses.clear(); // Oyuncu 1'in tahminlerini temizler
    player2Guesses.clear(); // Oyuncu 2'nin tahminlerini temizler
    _controller.clear(); // Giriş alanını temizler
    setState(() {}); // State'i günceller
    print("🔢 Sistem Sayısı: $secretNumber"); // Konsola gizli sayıyı yazdırır
  }

  /// 3 basamaklı ve rakamları farklı bir sayı üret
  String _generateRandomNumber() {
    Random random = Random(); // Rastgele sayı üretmek için Random sınıfı
    List<int> digits = []; // Rakamları tutacak liste

    while (digits.length < 3) {
      int num = random.nextInt(10); // 0-9 arası rastgele sayı üretir
      if (!digits.contains(num) && (num != 0 || digits.isNotEmpty)) {
        digits.add(num); // Rakamı listeye ekler
      }
    }
    return digits.join(); // Listeyi stringe çevirir ve döndürür
  }

  /// Kullanıcının tahminini kontrol eden fonksiyon
  void _checkGuess() {
    if (attempts >= maxAttempts * 2 || winner != null)
      return; // Oyun bittiğinde işlem yapma

    String guess = _controller.text.trim(); // Kullanıcının tahminini alır

    // Tahminin geçerli olup olmadığını kontrol eder
    if (guess.length != 3 ||
        guess.contains(RegExp(r'[^0-9]')) ||
        guess.split('').toSet().length != 3) {
      setState(() {
        feedback =
            "Lütfen 3 basamaklı, rakamları farklı bir sayı girin!"; // Geçersiz tahmin mesajı
      });
      return;
    }

    attempts++; // Deneme sayısını artırır
    if (playerTurn == 1) {
      player1Guesses.add(guess); // Oyuncu 1'in tahminini listeye ekler
    } else {
      player2Guesses.add(guess); // Oyuncu 2'nin tahminini listeye ekler
    }

    int correctDigits = 0; // Doğru tahmin edilen rakam sayısı
    for (int i = 0; i < 3; i++) {
      if (secretNumber.contains(guess[i])) {
        correctDigits++; // Rakam var ama yanlış yerde
      }
    }

    setState(() {
      if (correctDigits == 3) {
        winner =
            "Oyuncu $playerTurn kazandı! Sayıyı $attempts denemede buldu."; // Kazanan mesajı
      } else if (attempts >= maxAttempts * 2) {
        feedback =
            "😢 Oyun Bitti! Doğru sayı: $secretNumber."; // Oyun bitti mesajı
      } else {
        feedback =
            "$correctDigits tanesini buldun! Oyuncu $playerTurn'ın sırası."; // Geri bildirim mesajı
      }

      // Sıradaki oyuncuyu değiştirir
      playerTurn = (playerTurn == 1) ? 2 : 1;
    });

    print(
        "🧐 Kullanıcı (Oyuncu $playerTurn): $guess - Sonuç: $feedback"); // Konsola tahmin sonucunu yazdırır
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple, // AppBar arka plan rengi
        title: const Text("Sayı Tahmin Oyunu"), // AppBar başlığı
        centerTitle: true, // Başlığı ortalar
      ),
      body: Container(
        color: Colors.lightBlue[50], // Arka plan rengi
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Padding ekler
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // İçeriği dikeyde ortalar
              children: [
                // Başlık
                const Text(
                  "3 Basamaklı Rakamları Farklı Bir Sayıyı Bulmaya Çalış!",
                  textAlign: TextAlign.center, // Metni ortalar
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple), // Metin stili
                ),
                const SizedBox(height: 30), // Boşluk ekler

                // Tahmin Girişi
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Arka plan rengi
                    borderRadius:
                        BorderRadius.circular(12), // Köşeleri yuvarlar
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2))
                    ], // Gölge ekler
                  ),
                  child: TextField(
                    controller: _controller, // Giriş kontrolü
                    keyboardType: TextInputType.number, // Klavye tipi (sayısal)
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // Sadece rakam girişine izin verir
                      LengthLimitingTextInputFormatter(
                          3), // Maksimum 3 karakter girişi
                    ],
                    decoration: InputDecoration(
                      filled: true, // Dolgulu alan
                      fillColor: Colors.grey[200], // Dolgu rengi
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Kenarları yuvarlar
                      ),
                      hintText: "Tahmininizi Girin", // Placeholder metni
                      hintStyle: TextStyle(
                          color: Colors.grey[600]), // Placeholder stili
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16), // Padding
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Boşluk ekler

                // Tahmin Et Butonu
                ElevatedButton(
                  onPressed: attempts < maxAttempts * 2 && winner == null
                      ? _checkGuess
                      : null, // Butonun tıklanabilirliği
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple, // Buton rengi
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16), // Buton padding'i
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10), // Buton köşelerini yuvarlar
                    ),
                  ),
                  child: const Text(
                    "Tahmin Et",
                    style: TextStyle(
                        fontSize: 16, color: Colors.white), // Buton metin stili
                  ),
                ),
                const SizedBox(height: 10), // Boşluk ekler

                // Yeni Oyun Butonu
                TextButton(
                  onPressed: _startNewGame, // Yeni oyun başlatır
                  child: const Text(
                    "Yeni Oyun",
                    style: TextStyle(
                        fontSize: 16, color: Colors.green), // Buton metin stili
                  ),
                ),
                const SizedBox(height: 20), // Boşluk ekler

                // Geri Bildirim
                if (feedback != null)
                  Container(
                    padding: const EdgeInsets.all(10), // Padding ekler
                    decoration: BoxDecoration(
                      color: Colors.red[100], // Arka plan rengi
                      borderRadius:
                          BorderRadius.circular(10), // Köşeleri yuvarlar
                    ),
                    child: Text(
                      feedback!, // Geri bildirim mesajı
                      textAlign: TextAlign.center, // Metni ortalar
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red), // Metin stili
                    ),
                  ),
                if (winner != null)
                  Container(
                    padding: const EdgeInsets.all(10), // Padding ekler
                    decoration: BoxDecoration(
                      color: Colors.green[100], // Arka plan rengi
                      borderRadius:
                          BorderRadius.circular(10), // Köşeleri yuvarlar
                    ),
                    child: Text(
                      winner!, // Kazanan mesajı
                      textAlign: TextAlign.center, // Metni ortalar
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green), // Metin stili
                    ),
                  ),
                const SizedBox(height: 30), // Boşluk ekler

                // Yapılan Tahminler
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // İçeriği sola hizalar
                  children: [
                    const Text(
                      "Oyuncu 1'in Tahminleri:",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple), // Metin stili
                    ),
                    Wrap(
                      children: player1Guesses
                          .map((guess) => Padding(
                                padding:
                                    const EdgeInsets.all(4.0), // Padding ekler
                                child: Chip(
                                  label: Text(guess), // Tahmini gösterir
                                  backgroundColor:
                                      Colors.deepPurple[100], // Arka plan rengi
                                  labelStyle: const TextStyle(
                                      color: Colors.white), // Metin stili
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 10), // Boşluk ekler
                    const Text(
                      "Oyuncu 2'nin Tahminleri:",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple), // Metin stili
                    ),
                    Wrap(
                      children: player2Guesses
                          .map((guess) => Padding(
                                padding:
                                    const EdgeInsets.all(4.0), // Padding ekler
                                child: Chip(
                                  label: Text(guess), // Tahmini gösterir
                                  backgroundColor:
                                      Colors.deepPurple[100], // Arka plan rengi
                                  labelStyle: const TextStyle(
                                      color: Colors.white), // Metin stili
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
