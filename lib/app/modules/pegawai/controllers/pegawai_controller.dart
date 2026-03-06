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
        return 'User';
      case 1:
        return 'Enroller';
      case 2:
        return 'Manager';
      case 3:
        return 'Admin';
      case 14:
        return 'Super Admin';
      default:
        return 'User';
    }
  }
}

class BiometricType {
  final String label;
  final String code;
  final String description;

  const BiometricType({
    required this.label,
    required this.code,
    required this.description,
  });
}

class PegawaiController extends GetxController {
  static const String _getUserInfoUrl =
      'https://developer.fingerspot.io/api/get_userinfo';
  static const String _setUserInfoUrl =
      'https://developer.fingerspot.io/api/set_userinfo';
  static const String _regOnlineUrl =
      'https://developer.fingerspot.io/api/reg_online';
  static const String _token = '0Z4E0I7Y7YDMTHCE';
  static const String _cloudId = 'C269248053262039';

  static const String _webhookTokenId =
      'a09a238b-bbcd-4c1b-bd89-291a9378fba2';
  // Ambil 1 request terbaru saja — lebih simpel dan tidak ada filter timezone
  static const String _webhookLatestUrl =
      'https://webhook.site/token/$_webhookTokenId/request/latest';

  static const List<BiometricType> biometricTypes = [
    BiometricType(label: 'Jari 1', code: '0', description: 'Sidik jari ke-1'),
    BiometricType(label: 'Jari 2', code: '1', description: 'Sidik jari ke-2'),
    BiometricType(label: 'Jari 3', code: '2', description: 'Sidik jari ke-3'),
    BiometricType(label: 'Jari 4', code: '3', description: 'Sidik jari ke-4'),
    BiometricType(label: 'Jari 5', code: '4', description: 'Sidik jari ke-5'),
    BiometricType(label: 'Jari 6', code: '5', description: 'Sidik jari ke-6'),
    BiometricType(label: 'Jari 7', code: '6', description: 'Sidik jari ke-7'),
    BiometricType(label: 'Jari 8', code: '7', description: 'Sidik jari ke-8'),
    BiometricType(label: 'Jari 9', code: '8', description: 'Sidik jari ke-9'),
    BiometricType(label: 'Jari 10', code: '9', description: 'Sidik jari ke-10'),
    BiometricType(label: 'Wajah', code: '12', description: 'Registrasi wajah'),
    BiometricType(
        label: 'Vein (Telapak)',
        code: '13',
        description: 'Registrasi vein telapak tangan'),
  ];

  final Rx<PegawaiInfo?> pegawai = Rx<PegawaiInfo?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isRegBio = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString statusMessage = ''.obs;
  final RxString saveMessage = ''.obs;
  final RxBool saveSuccess = false.obs;
  final RxString bioMessage = ''.obs;
  final RxBool bioSuccess = false.obs;

  final pinInput = ''.obs;

  Timer? _pollTimer;
  String? _currentPin;

  // UUID dari request webhook SEBELUM kita kirim query.
  // Kita hanya proses request yang UUID-nya BERBEDA dari ini.
  String? _lastSeenUuid;

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  // ─────────────────────────────────────────────
  //  GET PEGAWAI
  // ─────────────────────────────────────────────

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
      statusMessage.value = 'Menyiapkan permintaan...';

      // Step 1: Snapshot UUID terbaru SEBELUM kirim query
      // sehingga kita tahu request mana yang baru
      _lastSeenUuid = await _getLatestWebhookUuid();

      statusMessage.value = 'Mengirim permintaan ke mesin absensi...';

      final body = jsonEncode({
        "trans_id": "1",
        "cloud_id": _cloudId,
        "pin": pin.trim(),
      });

      final response = await http
          .post(
            Uri.parse(_getUserInfoUrl),
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

      statusMessage.value = 'Menunggu respon dari mesin absensi...';
      _startPolling();
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: ${e.toString()}';
      isLoading.value = false;
      statusMessage.value = '';
    }
  }

  /// Ambil UUID dari request terbaru di webhook, untuk dijadikan penanda.
  Future<String?> _getLatestWebhookUuid() async {
    try {
      final response = await http
          .get(Uri.parse(_webhookLatestUrl),
              headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['uuid']?.toString();
      }
    } catch (_) {}
    return null;
  }

  void _startPolling() {
    int attempts = 0;
    const maxAttempts = 30;

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
      } catch (_) {}
    });
  }

  Future<PegawaiInfo?> _pollWebhookSite() async {
    final response = await http
        .get(Uri.parse(_webhookLatestUrl),
            headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 5));

    // 404 = belum ada request sama sekali
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) return null;

    final req = jsonDecode(response.body);
    final String? uuid = req['uuid']?.toString();

    // Jika UUID sama dengan snapshot sebelum query dikirim → ini data lama, skip
    if (uuid != null && uuid == _lastSeenUuid) return null;

    final String? content = req['content']?.toString();
    if (content == null || content.isEmpty) return null;

    Map<String, dynamic> payloadJson;
    try {
      payloadJson = jsonDecode(content);
    } catch (_) {
      return null;
    }

    return _extractPegawai(payloadJson);
  }

  PegawaiInfo? _extractPegawai(Map<String, dynamic> payload) {
    Map<String, dynamic>? userData;

    if (payload['data'] is Map<String, dynamic>) {
      final d = payload['data'] as Map<String, dynamic>;
      if (_currentPin == null || d['pin']?.toString() == _currentPin) {
        userData = d;
      }
    } else if (payload['data'] is List) {
      for (final item in payload['data']) {
        if (item is Map<String, dynamic>) {
          if (_currentPin == null ||
              item['pin']?.toString() == _currentPin) {
            userData = item;
            break;
          }
        }
      }
    } else if (payload.containsKey('pin') && payload.containsKey('name')) {
      if (_currentPin == null ||
          payload['pin']?.toString() == _currentPin) {
        userData = payload;
      }
    }

    if (userData == null) return null;
    return PegawaiInfo.fromMap(userData);
  }

  // ─────────────────────────────────────────────
  //  SAVE PEGAWAI (Tambah / Edit)
  // ─────────────────────────────────────────────

  Future<bool> savePegawai({
    required String pin,
    required String name,
    required String privilege,
    required String password,
    String rfid = '',
    String template = '',
    bool isEdit = false,
  }) async {
    if (pin.trim().isEmpty) {
      saveMessage.value = 'PIN tidak boleh kosong.';
      saveSuccess.value = false;
      return false;
    }
    if (name.trim().isEmpty) {
      saveMessage.value = 'Nama tidak boleh kosong.';
      saveSuccess.value = false;
      return false;
    }

    try {
      isSaving.value = true;
      saveMessage.value = '';
      saveSuccess.value = false;

      final body = jsonEncode({
        "trans_id": "1",
        "cloud_id": _cloudId,
        "data": {
          "pin": pin.trim(),
          "name": name.trim(),
          "privilege": privilege,
          "password": password.trim(),
          "rfid": rfid,
          "template": template,
        }
      });

      final response = await http
          .post(
            Uri.parse(_setUserInfoUrl),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final respData = jsonDecode(response.body);
        if (respData['success'] == true) {
          saveMessage.value = isEdit
              ? 'Data pegawai berhasil diperbarui!'
              : 'Pegawai baru berhasil ditambahkan!';
          saveSuccess.value = true;

          if (isEdit && pegawai.value != null) {
            pegawai.value = PegawaiInfo(
              pin: pin.trim(),
              name: name.trim(),
              privilege: int.tryParse(privilege) ?? 0,
              finger: pegawai.value!.finger,
              face: pegawai.value!.face,
              password: password.trim(),
              rfid: int.tryParse(rfid) ?? 0,
              vein: pegawai.value!.vein,
            );
          }
          return true;
        } else {
          saveMessage.value =
              respData['message']?.toString() ?? 'Gagal menyimpan data.';
          saveSuccess.value = false;
          return false;
        }
      } else {
        saveMessage.value =
            'Gagal menghubungi API. Status: ${response.statusCode}';
        saveSuccess.value = false;
        return false;
      }
    } catch (e) {
      saveMessage.value = 'Terjadi kesalahan: ${e.toString()}';
      saveSuccess.value = false;
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ─────────────────────────────────────────────
  //  REGISTRASI BIOMETRIK
  // ─────────────────────────────────────────────

  Future<void> registerBiometric({
    required String pin,
    required String verification,
  }) async {
    if (pin.trim().isEmpty) {
      bioMessage.value = 'PIN tidak boleh kosong.';
      bioSuccess.value = false;
      return;
    }

    try {
      isRegBio.value = true;
      bioMessage.value = '';
      bioSuccess.value = false;

      final body = jsonEncode({
        "trans_id": "1",
        "cloud_id": _cloudId,
        "pin": pin.trim(),
        "verification": verification,
      });

      final response = await http
          .post(
            Uri.parse(_regOnlineUrl),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final respData = jsonDecode(response.body);
        if (respData['success'] == true) {
          bioMessage.value =
              'Perintah registrasi berhasil dikirim!\n'
              'Silakan tempelkan ${_verificationLabel(verification)} '
              'pada mesin absensi.';
          bioSuccess.value = true;
        } else {
          bioMessage.value =
              respData['message']?.toString() ??
              'Gagal mengirim perintah registrasi.';
          bioSuccess.value = false;
        }
      } else {
        bioMessage.value =
            'Gagal menghubungi API. Status: ${response.statusCode}';
        bioSuccess.value = false;
      }
    } catch (e) {
      bioMessage.value = 'Terjadi kesalahan: ${e.toString()}';
      bioSuccess.value = false;
    } finally {
      isRegBio.value = false;
    }
  }

  String _verificationLabel(String code) {
    final int v = int.tryParse(code) ?? -1;
    if (v >= 0 && v <= 9) return 'jari ke-${v + 1}';
    if (v == 12) return 'wajah';
    if (v == 13) return 'vein (telapak tangan)';
    return 'biometrik';
  }

  // ─────────────────────────────────────────────
  //  RESET
  // ─────────────────────────────────────────────

  void reset() {
    _pollTimer?.cancel();
    pegawai.value = null;
    errorMessage.value = '';
    statusMessage.value = '';
    saveMessage.value = '';
    saveSuccess.value = false;
    bioMessage.value = '';
    bioSuccess.value = false;
    pinInput.value = '';
    _currentPin = null;
    _lastSeenUuid = null;
  }

  void clearSaveMessage() {
    saveMessage.value = '';
    saveSuccess.value = false;
  }

  void clearBioMessage() {
    bioMessage.value = '';
    bioSuccess.value = false;
  }
}