<p align="center">
  <a href="https://flutter.dev" target="_blank">
    <img src="assets/images/logo-dev.png" width="300" alt="Flutter Logo">
  </a>
</p>

<p align="center">
  <a href="https://flutter.dev/docs/development/tools/sdk/releases">
    <img src="https://img.shields.io/badge/Flutter-%3E%3D3.0.0-blue?logo=flutter" alt="Flutter Version">
  </a>
  <a href="https://dart.dev">
    <img src="https://img.shields.io/badge/Dart-%3E%3D3.0.0-blue?logo=dart" alt="Dart Version">
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
  </a>
</p>

## About [Nama Aplikasi]

[Nama Aplikasi] adalah aplikasi mobile yang dibangun menggunakan Flutter dengan sintaks yang ekspresif dan elegan. Kami percaya bahwa pengembangan aplikasi harus menjadi pengalaman yang menyenangkan dan kreatif. Aplikasi ini mempermudah berbagai kebutuhan pengguna, seperti:

## Prerequisites

Pastikan kamu sudah menginstall semua kebutuhan berikut sebelum menjalankan project ini:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) >= 3.0.0
- [Dart SDK](https://dart.dev/get-dart) >= 3.0.0
- [Android Studio](https://developer.android.com/studio) atau [VS Code](https://code.visualstudio.com/)
- Android Emulator atau iOS Simulator (atau device fisik)

## Installation

Ikuti langkah-langkah berikut untuk menjalankan project di lokal:

```bash
# 1. Clone repository ini
git clone https://github.com/Dzuka-sohee/fio-developer.git

# 2. Masuk ke direktori project
cd fio-developer

# 3. Install semua dependencies
flutter pub get

# 4. Jalankan aplikasi
flutter run
```

## Configuration

Sebelum menjalankan aplikasi, pastikan kamu mengatur variabel di function GetxController yaitu BaseUrl API, Token API, dan Cloud ID pada Controllers Mesin, Pegawai, dan Laporan menjadi Token API dan Cloud ID masing masing akun developer fingerspot.io:

```env
  static const String _baseUrl =
      'https://developer.fingerspot.io/api/get_attlog';
  static const String _token = '0Z4E0I7Y7YDMTHCE';
  static const String _cloudId = 'C269248053262039';
```

## Project Structure

```
lib/
├── app/
│   └── data/
├── modules/
│   ├── home/
│   │   ├── bindings/
│   │   ├── controllers/
│   │   └── views/
│   ├── jadwal/
│   │   ├── bindings/
│   │   ├── controllers/
│   │   └── views/
│   ├── laporan/
│   │   ├── bindings/
│   │   ├── controllers/
│   │   └── views/
│   ├── main/
│   │   ├── bindings/
│   │   ├── controllers/
│   │   └── views/
│   ├── mesin/
│   │   ├── bindings/
│   │   ├── controllers/
│   │   │   └── mesin_controller.dart
│   │   └── views/
│   └── pegawai/
│       ├── bindings/
│       ├── controllers/
│       │   └── pegawai_controller.dart
│       └── views/
└── routes/
    ├── app_pages.dart
    └── app_routes.dart
```

## Build & Deployment

```bash
# Build Android APK (release)
flutter build apk --release

# Build Android App Bundle
flutter build appbundle --release

# Build iOS (release)
flutter build ios --release
```