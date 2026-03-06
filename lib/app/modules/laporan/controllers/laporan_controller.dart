import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AttendanceLog {
  final String pin;
  final String date;
  final String time;
  final String verifyMode;
  final String inOut;

  AttendanceLog({
    required this.pin,
    required this.date,
    required this.time,
    required this.verifyMode,
    required this.inOut,
  });

  factory AttendanceLog.fromMap(Map<String, dynamic> map) {
    // API returns: pin, scan_date ("yyyy-MM-dd HH:mm:ss"), verify, status_scan
    final scanDate = map['scan_date']?.toString() ?? '';
    String date = '-';
    String time = '-';

    if (scanDate.contains(' ')) {
      final parts = scanDate.split(' ');
      date = parts[0]; // "2026-03-03"
      time = parts[1]; // "22:39:15"
    }

    // status_scan: 0 = Masuk (In), 1 = Keluar (Out)
    final statusScan = map['status_scan']?.toString() ?? '-';

    return AttendanceLog(
      pin: map['pin']?.toString() ?? '-',
      date: date,
      time: time,
      verifyMode: map['verify']?.toString() ?? '-',
      inOut: statusScan,
    );
  }
}

class LaporanController extends GetxController {
  static const String _baseUrl =
      'https://developer.fingerspot.io/api/get_attlog';
  static const String _token = '0Z4E0I7Y7YDMTHCE';
  static const String _cloudId = 'C269248053262039';

  final RxList<AttendanceLog> logs = <AttendanceLog>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString statusMessage = ''.obs;

  // Date range - default: 7 days ago to today
  final Rx<DateTime> startDate =
      DateTime.now().subtract(const Duration(days: 7)).obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  // Stats
  final RxInt totalRecords = 0.obs;
  final RxInt totalIn = 0.obs;
  final RxInt totalOut = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLaporan();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> fetchLaporan() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      statusMessage.value = '';

      final body = jsonEncode({
        "trans_id": "1",
        "cloud_id": _cloudId,
        "start_date": _formatDate(startDate.value),
        "end_date": _formatDate(endDate.value),
      });

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // API returns "success": true/false (boolean), not "status": int
        final bool success = data['success'] == true;
        statusMessage.value = '';

        if (success && data['data'] != null) {
          final List<dynamic> rawData = data['data'];
          final parsedLogs = rawData
              .map((item) => AttendanceLog.fromMap(item))
              .toList();

          logs.assignAll(parsedLogs);
          totalRecords.value = parsedLogs.length;
          // status_scan: 0 = Masuk, 1 = Keluar
          totalIn.value =
              parsedLogs.where((l) => l.inOut == '0').length;
          totalOut.value =
              parsedLogs.where((l) => l.inOut == '1').length;
        } else {
          logs.clear();
          totalRecords.value = 0;
          totalIn.value = 0;
          totalOut.value = 0;
          errorMessage.value = 'Data kosong untuk rentang tanggal ini.';
        }
      } else {
        errorMessage.value =
            'Gagal mengambil data. Status: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setDateRange(DateTime start, DateTime end) async {
    startDate.value = start;
    endDate.value = end;
    await fetchLaporan();
  }
}