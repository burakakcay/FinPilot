# FinPilot

Yapay zekâ destekli kişisel finans yönetimi ve karar destek sistemi.

FinPilot; kullanıcıların gelir-gider işlemlerini takip etmesini, bütçe ve tasarruf hedefleri oluşturmasını, finansal raporlarını incelemesini ve temel finansal içgörüler almasını sağlar.

## Özellikler

- Firebase Authentication ile kayıt ve giriş
- Oturumun açık tutulması
- Gelir ve gider işlemleri
- İşlem düzenleme ve silme
- Bütçe oluşturma ve bütçe aşımı uyarıları
- Tasarruf hedefleri
- Dashboard finansal özeti
- Aylık gelir-gider grafikleri
- Kategori bazlı harcama grafiği
- Otomatik finansal içgörüler
- Gemini destekli AI finansal değerlendirme
- Profil ve tema ayarları
- Açık ve koyu tema
- Responsive Flutter Web arayüzü

## Kullanılan Teknolojiler

- Flutter
- Dart
- Material 3
- Firebase Authentication
- Cloud Firestore
- Node.js
- Express.js
- Google Gemini API

## Gereksinimler

- Flutter SDK
- Dart SDK
- Node.js
- Firebase projesi
- Firebase CLI

## Kurulum

Projeyi klonladıktan sonra Flutter bağımlılıklarını yükleyin:

```bash
flutter pub get
```

Firebase yapılandırmasının ardından uygulamayı çalıştırın:

```bash
flutter run -d edge --web-hostname localhost --web-port 5000
```

## AI Sunucusunu Çalıştırma

AI servisi `ai_server` klasöründe bulunur.

```bash
cd ai_server
npm install
```

`ai_server/.env` dosyasını oluşturun:

```env
GEMINI_API_KEY=YOUR_GEMINI_API_KEY
```

AI sunucusunu başlatın:

```bash
node index.js
```

Sunucu `http://localhost:3000` adresinde çalışır. AI özelliğini kullanırken bu sunucunun açık olması gerekir.

## Firebase Veri Yapısı

```text
users/{uid}/transactions
users/{uid}/budgets
users/{uid}/goals
```

Her kullanıcı yalnızca kendi finansal verilerine erişebilir.

## Kontrol Komutları

```bash
dart format lib
flutter analyze lib
```

## Test Edilen Akışlar

- Kullanıcı kayıt ve giriş
- Oturum açık tutma ve çıkış yapma
- Yetkisiz route erişimi
- Gelir ve gider ekleme, düzenleme ve silme
- Bütçe ve bütçe aşımı kontrolü
- Tasarruf hedefleri
- Dashboard ve rapor grafikleri
- Otomatik finansal içgörüler
- Gemini AI değerlendirmesi
- Profil ismi düzenleme
- Açık/koyu tema geçişi

## Proje Durumu

FinPilot projesinin Flutter Web odaklı MVP sürümü tamamlanmıştır. Android desteği ilerleyen aşamalarda aynı Flutter kod tabanı üzerinden geliştirilebilir.
