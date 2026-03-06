import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PegawaiInfo {
  final String pin;
  final String name;
  final int privilege;
  final int finger;
  final int face;
  final String password;
  final int rfid;
  final int vein;

  PegawaiInfo({
    required this.pin,
    required this.name,
    required this.privilege,
    required this.finger,
    required this.face,
    required this.password,
    required this.rfid,
    required this.vein,
  });

  factory PegawaiInfo.fromMap(Map<String, dynamic> map) {
    return PegawaiInfo(
      pin: map['pin']?.toString() ?? '-',
      name: map['name']?.toString() ?? '-',
      privilege: (map['privilege'] as num?)?.toInt() ?? 0,
      finger: (map['finger'] as num?)?.toInt() ?? 0,
      face: (map['face'] as num?)?.toInt() ?? 0,
      password: map['password']?.toString() ?? '-',
      rfid: (map['rfid'] as num?)?.toInt() ?? 0,
      vein: (map['vein'] as num?)?.toInt() ?? 0,
    );
  }

  String get privilegeLabel {
    switch (privilege) {
      case 0:
        return 'guest';
      case 1:
        return 'User';
      case 2:
        return 'Manager';
      case 3:
        return 'Supervisor';
      case 14:
        return 'Super Admin';
      default:
        return 'User';
    }
  }
}

class PegawaiController extends GetxController {
  // === Fingerspot API ===
  static const String _baseUrl =
      'https://developer.fingerspot.io/api/get_userinfo';
  static const String _token = '0Z4E0I7Y7YDMTHCE';
  static const String _cloudId = 'C269248053262039';

  // === Webhook.site token ID ===
  // Ambil dari URL webhook kamu: https://webhook.site/{TOKEN_ID_INI}
  // Ganti dengan token ID milikmu jika berbeda
  static const String _webhookTokenId =
      '3c04f137-cec7-42c8-8af7-14fea960b8cb';

  // API webhook.site untuk ambil request terbaru
  static const String _webhookApiLatest =
      'https://webhook.site/token/$_webhookTokenId/request/latest';

  // API webhook.site untuk ambil semua request (sorting newest)
  static const String _webhookApiRequests =
      'https://webhook.site/token/$_webhookTokenId/requests?sorting=newest&per_page=5';

  final Rx<PegawaiInfo?> pegawai = Rx<PegawaiInfo?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString statusMessage = ''.obs;

  final pinInput = ''.obs;

  Timer? _pollTimer;
  String? _currentPin;
  DateTime? _requestSentAt; // catat waktu request dikirim

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchPegawai(String pin) async {
    if (pin.trim().isEmpty) {
      errorMessage.value = 'PIN tidak boleh kosong.';
      return;
    }

    _pollTimer?.cancel();
    _currentPin = pin.trim();

    try {
      isLoading.value = true;
      errorMessage.value = '';
      pegawai.value = null;
      statusMessage.value = 'Mengirim permintaan ke mesin absensi...';

      // Catat waktu sebelum request dikirim
      _requestSentAt = DateTime.now().toUtc();

      // POST ke Fingerspot API
      final body = jsonEncode({
        "trans_id": "1",
        "cloud_id": _cloudId,
        "pin": pin.trim(),
      });

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        errorMessage.value =
            'Gagal menghubungi API. Status: ${response.statusCode}';
        isLoading.value = false;
        statusMessage.value = '';
        return;
      }

      final respData = jsonDecode(response.body);
      if (respData['success'] != true) {
        errorMessage.value = 'Permintaan ditolak API Fingerspot.';
        isLoading.value = false;
        statusMessage.value = '';
        return;
      }

      // Fingerspot API sukses, sekarang polling webhook.site
      // untuk menunggu callback dari mesin absensi
      statusMessage.value = 'Menunggu respon dari mesin absensi...';
      _startPolling();
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: ${e.toString()}';
      isLoading.value = false;
      statusMessage.value = '';
    }
  }

  void _startPolling() {
    int attempts = 0;
    const maxAttempts = 30; // max 30 detik

    _pollTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      attempts++;

      if (attempts > maxAttempts) {
        timer.cancel();
        isLoading.value = false;
        statusMessage.value = '';
        errorMessage.value =
            'Timeout: Mesin absensi tidak merespons dalam 30 detik.\n'
            'Pastikan mesin menyala dan terhubung ke internet.';
        return;
      }

      try {
        final result = await _pollWebhookSite();
        if (result != null) {
          timer.cancel();
          pegawai.value = result;
          isLoading.value = false;
          statusMessage.value = '';
        }
      } catch (_) {
        // Lanjut ke iterasi berikutnya
      }
    });
  }

  Future<PegawaiInfo?> _pollWebhookSite() async {
    // Ambil request terbaru dari webhook.site
    final response = await http
        .get(
          Uri.parse(_webhookApiRequests),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) return null;

    final body = jsonDecode(response.body);
    final List<dynamic> data = body['data'] ?? [];

    if (data.isEmpty) return null;

    for (final req in data) {
      // Cek apakah request ini SETELAH kita kirim permintaan
      // agar tidak mengambil data lama
      if (_requestSentAt != null) {
        final String? createdAtStr = req['created_at']?.toString();
        if (createdAtStr != null) {
          try {
            // Format webhook.site: "2026-03-06 11:27:30"
            final DateTime createdAt =
                DateTime.parse(createdAtStr.replaceFirst(' ', 'T') + 'Z');
            // Beri toleransi 5 detik sebelum request dikirim
            if (createdAt
                .isBefore(_requestSentAt!.subtract(const Duration(seconds: 5)))) {
              continue; // Request ini lebih lama, skip
            }
          } catch (_) {
            // Lanjut jika parse tanggal gagal
          }
        }
      }

      // Ambil content (body yang dikirim Fingerspot ke webhook)
      final String? content = req['content']?.toString();
      if (content == null || content.isEmpty) continue;

      // Parse JSON dari Fingerspot callback
      Map<String, dynamic> payloadJson;
      try {
        payloadJson = jsonDecode(content);
      } catch (_) {
        continue;
      }

      // Extract data pegawai dari payload
      final userData = _extractUserData(payloadJson);
      if (userData != null) {
        return PegawaiInfo.fromMap(userData);
      }
    }

    return null;
  }

  Map<String, dynamic>? _extractUserData(Map<String, dynamic> payload) {
    // Format Fingerspot callback:
    // { "type": "get_userinfo", "cloud_id": "...", "trans_id": 1,
    //   "data": { "pin": "...", "name": "...", ... } }

    // Validasi ini memang dari Fingerspot (opsional tapi lebih aman)
    // if (payload['type'] != 'get_userinfo') return null;

    // Cek field 'data' berupa Map
    if (payload['data'] is Map<String, dynamic>) {
      final d = payload['data'] as Map<String, dynamic>;
      if (_currentPin == null || d['pin']?.toString() == _currentPin) {
        return d;
      }
    }

    // Cek field 'data' berupa List
    if (payload['data'] is List) {
      for (final item in payload['data']) {
        if (item is Map<String, dynamic>) {
          if (_currentPin == null || item['pin']?.toString() == _currentPin) {
            return item;
          }
        }
      }
    }

    // Fallback: cek langsung di root
    if (payload.containsKey('pin') && payload.containsKey('name')) {
      if (_currentPin == null || payload['pin']?.toString() == _currentPin) {
        return payload;
      }
    }

    return null;
  }

  void reset() {
    _pollTimer?.cancel();
    pegawai.value = null;
    errorMessage.value = '';
    statusMessage.value = '';
    pinInput.value = '';
    _currentPin = null;
    _requestSentAt = null;
  }
}