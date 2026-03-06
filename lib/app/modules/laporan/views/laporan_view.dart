import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/laporan_controller.dart';

class LaporanView extends GetView<LaporanController> {
  const LaporanView({super.key});

  static const Color _primary = Color(0xFF1A56DB);
  static const Color _success = Color(0xFF0E9F6E);
  static const Color _danger = Color(0xFFE02424);
  static const Color _bg = Color(0xFFF3F6FB);
  static const Color _card = Colors.white;
  static const Color _textDark = Color(0xFF1A202C);
  static const Color _textGray = Color(0xFF718096);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildFilterCard(context),
          _buildStatsRow(),
          Expanded(child: _buildLogList()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _primary,
      elevation: 0,
      title: const Text(
        'Laporan Kehadiran',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: 0.3,
        ),
      ),
      actions: [
        Obx(() => controller.isLoading.value
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                tooltip: 'Refresh',
                onPressed: controller.fetchLaporan,
              )),
      ],
    );
  }

  Widget _buildFilterCard(BuildContext context) {
    return Container(
      color: _primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Obx(() => Text(
                    '${_fmt(controller.startDate.value)}  →  ${_fmt(controller.endDate.value)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  )),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => _showDateRangePicker(context),
              child: const Text(
                'Filter',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Obx(() => Row(
            children: [
              _statCard(
                icon: Icons.list_alt_rounded,
                label: 'Total',
                value: '${controller.totalRecords.value}',
                color: _primary,
              ),
              const SizedBox(width: 10),
              _statCard(
                icon: Icons.login_rounded,
                label: 'Masuk',
                value: '${controller.totalIn.value}',
                color: _success,
              ),
              const SizedBox(width: 10),
              _statCard(
                icon: Icons.logout_rounded,
                label: 'Keluar',
                value: '${controller.totalOut.value}',
                color: _danger,
              ),
            ],
          )),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: _textGray,
                        fontWeight: FontWeight.w500)),
                Text(value,
                    style: TextStyle(
                        fontSize: 18,
                        color: color,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: _primary),
              SizedBox(height: 14),
              Text('Memuat data...',
                  style: TextStyle(color: _textGray, fontSize: 14)),
            ],
          ),
        );
      }

      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded,
                    color: _textGray, size: 52),
                const SizedBox(height: 14),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: _textGray, fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: controller.fetchLaporan,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.logs.isEmpty) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_rounded, color: _textGray, size: 52),
              SizedBox(height: 12),
              Text('Tidak ada data pada rentang tanggal ini',
                  style: TextStyle(color: _textGray, fontSize: 14)),
            ],
          ),
        );
      }

      return Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Text(
                  '${controller.logs.length} Catatan',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (controller.statusMessage.isNotEmpty) ...[
                  const Spacer(),
                  Text(
                    controller.statusMessage.value,
                    style: const TextStyle(fontSize: 11, color: _textGray),
                  ),
                ]
              ],
            ),
          ),
          // Table header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('PIN',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _primary))),
                Expanded(
                    flex: 3,
                    child: Text('TANGGAL',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _primary))),
                Expanded(
                    flex: 2,
                    child: Text('JAM',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _primary))),
                Expanded(
                    flex: 2,
                    child: Text('STATUS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _primary))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              itemCount: controller.logs.length,
              itemBuilder: (context, index) {
                final log = controller.logs[index];
                final isIn = log.inOut == '0' || log.inOut == 'In';
                return _buildLogRow(log, isIn, index);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildLogRow(AttendanceLog log, bool isIn, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // PIN with avatar
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      log.pin.length > 2
                          ? log.pin.substring(0, 2)
                          : log.pin,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _primary),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(log.pin,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _textDark)),
                ),
              ],
            ),
          ),
          // Date
          Expanded(
            flex: 3,
            child: Text(
              log.date,
              style: const TextStyle(fontSize: 12, color: _textDark),
            ),
          ),
          // Time
          Expanded(
            flex: 2,
            child: Text(
              log.time,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textDark),
            ),
          ),
          // In/Out badge
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isIn
                      ? _success.withOpacity(0.1)
                      : _danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isIn ? 'Masuk' : 'Keluar',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isIn ? _success : _danger,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: controller.startDate.value,
        end: controller.endDate.value,
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: _primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            useMaterial3: true,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await controller.setDateRange(picked.start, picked.end);
    }
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}