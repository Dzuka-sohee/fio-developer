import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class MesinInfo {
  final String cloudId;
  final String deviceName;
  final String webhookUrl;
  final String createdAt;
  final String lastActivity;

  MesinInfo({
    required this.cloudId,
    required this.deviceName,
    required this.webhookUrl,
    required this.createdAt,
    required this.lastActivity,
  });

  factory MesinInfo.fromMap(Map<String, dynamic> map) {
    return MesinInfo(
      cloudId: map['cloud_id']?.toString() ?? '-',
      deviceName: map['device_name']?.toString() ?? '-',
      webhookUrl: map['webhook_url']?.toString() ?? '-',
      createdAt: map['created_at']?.toString() ?? '-',
      lastActivity: map['last_activity']?.toString() ?? 'N/A',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cloud_id': cloudId,
      'device_name': deviceName,
      'webhook_url': webhookUrl,
      'created_at': createdAt,
      'last_activity': lastActivity,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  String get statusLabel {
    if (lastActivity == 'N/A' || lastActivity.isEmpty || lastActivity == '-') {
      return 'Tidak Aktif';
    }
    return 'Aktif';
  }

  bool get isActive {
    return lastActivity != 'N/A' && lastActivity.isNotEmpty && lastActivity != '-';
  }
}

class MesinController extends GetxController {
  static const String _getDeviceUrl =
      'https://developer.fingerspot.io/api/get_device';
  static const String _token = '0Z4E0I7Y7YDMTHCE';
  static const String _cloudId = 'C269248053262039';

  static const String _setTimeUrl =
      'https://developer.fingerspot.io/api/set_time';

  static const String _webhookTokenId =
      '36917e68-7164-48c7-9ddd-b3981158eb2e';
  static const String _webhookLatestUrl =
      'https://webhook.site/token/$_webhookTokenId/request/latest';

  // ── Firestore ────────────────────────────────────
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'mesin';

  static const List<String> timezoneOptions = [
    'Asia/Jakarta',
    'Asia/Makassar',
    'Asia/Jayapura',
    'Asia/Pontianak',
  ];

  final Rx<MesinInfo?> mesin = Rx<MesinInfo?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString statusMessage = ''.obs;

  final RxBool isSettingTime = false.obs;
  final RxString setTimeMessage = ''.obs;
  final RxBool setTimeSuccess = false.obs;
  final RxString selectedTimezone = 'Asia/Jakarta'.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // ─────────────────────────────────────────────
  //  GET DEVICE
  // ─────────────────────────────────────────────

  Future<void> fetchMesin() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      mesin.value = null;
      statusMessage.value = 'Mengirim permintaan ke API Fingerspot...';

      final body = jsonEncode({
        "trans_id": "1",
        "cloud_id": _cloudId,
      });

      final response = await http
          .post(
            Uri.parse(_getDeviceUrl),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 15));

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

      final data = respData['data'];
      if (data == null) {
        errorMessage.value = 'Data mesin tidak ditemukan.';
        isLoading.value = false;
        statusMessage.value = '';
        return;
      }

      Map<String, dynamic>? deviceMap;
      if (data is Map<String, dynamic>) {
        deviceMap = data;
      } else if (data is List && data.isNotEmpty) {
        deviceMap = data.first as Map<String, dynamic>;
      }

      if (deviceMap == null) {
        errorMessage.value = 'Format data mesin tidak dikenali.';
        isLoading.value = false;
        statusMessage.value = '';
        return;
      }

      mesin.value = MesinInfo.fromMap(deviceMap);
      isLoading.value = false;
      statusMessage.value = '';

      // ── Simpan hasil fetch ke Firestore ──────────
      await _saveMesinToFirestore(mesin.value!);
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: ${e.toString()}';
      isLoading.value = false;
      statusMessage.value = '';
    }
  }

  // ─────────────────────────────────────────────
  //  FIRESTORE: Simpan data mesin
  // ─────────────────────────────────────────────

  Future<void> _saveMesinToFirestore(MesinInfo info) async {
    try {
      final data = info.toMap();
      data['fetchedAt'] = FieldValue.serverTimestamp();
      await _firestore
          .collection(_collectionName)
          .doc(info.cloudId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      // Gagal simpan Firestore tidak mengganggu alur utama
    }
  }

  // ─────────────────────────────────────────────
  //  SET TIME / TIMEZONE
  // ─────────────────────────────────────────────

  Future<void> setTimezone() async {
    try {
      isSettingTime.value = true;
      setTimeMessage.value = '';
      setTimeSuccess.value = false;

      final body = jsonEncode({
        "trans_id": "1",
        "cloud_id": _cloudId,
        "timezone": selectedTimezone.value,
      });

      final response = await http
          .post(
            Uri.parse(_setTimeUrl),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        setTimeMessage.value =
            'Gagal menghubungi API. Status: ${response.statusCode}';
        isSettingTime.value = false;
        return;
      }

      final respData = jsonDecode(response.body);

      if (respData['success'] == true) {
        setTimeSuccess.value = true;
        setTimeMessage.value =
            'Zona waktu berhasil diubah ke ${selectedTimezone.value}';

        // ── Simpan perubahan timezone ke Firestore ────
        await _saveTimezoneToFirestore(selectedTimezone.value);
      } else {
        setTimeSuccess.value = false;
        setTimeMessage.value =
            respData['message']?.toString() ?? 'Gagal mengubah zona waktu.';
      }

      isSettingTime.value = false;
    } catch (e) {
      setTimeMessage.value = 'Terjadi kesalahan: ${e.toString()}';
      isSettingTime.value = false;
    }
  }

  // ─────────────────────────────────────────────
  //  FIRESTORE: Simpan perubahan timezone
  // ─────────────────────────────────────────────

  Future<void> _saveTimezoneToFirestore(String timezone) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(_cloudId)
          .set({
        'timezone': timezone,
        'timezoneUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Gagal simpan Firestore tidak mengganggu alur utama
    }
  }

  // ─────────────────────────────────────────────
  //  RESET
  // ─────────────────────────────────────────────

  void reset() {
    mesin.value = null;
    errorMessage.value = '';
    statusMessage.value = '';
    setTimeMessage.value = '';
    setTimeSuccess.value = false;
  }
}