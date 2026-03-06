import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mesin_controller.dart';

class MesinView extends GetView<MesinController> {
  const MesinView({super.key});

  static const Color _primary = Color(0xFF1A56DB);
  static const Color _success = Color(0xFF0E9F6E);
  static const Color _danger = Color(0xFFEF4444);
  static const Color _warning = Color(0xFFF59E0B);
  static const Color _bg = Color(0xFFF3F6FB);
  static const Color _card = Colors.white;
  static const Color _textDark = Color(0xFF1A202C);
  static const Color _textGray = Color(0xFF718096);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeaderAction(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  APP BAR
  // ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _primary,
      elevation: 0,
      title: const Text(
        'Data Mesin',
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
                      color: Colors.white, strokeWidth: 2.5),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                tooltip: 'Refresh',
                onPressed: controller.fetchMesin,
              )),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  HEADER ACTION (Fetch Button Bar)
  // ─────────────────────────────────────────────────────────────────

  Widget _buildHeaderAction() {
    return Container(
      color: _primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.devices_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Cloud ID: C269248053262039',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
            ),
            Obx(() => controller.isLoading.value
                ? const SizedBox(
                    width: 36,
                    height: 36,
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      ),
                    ),
                  )
                : TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: controller.fetchMesin,
                    child: const Text('Ambil Data',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  )),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  BODY
  // ─────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: _primary),
                const SizedBox(height: 20),
                Text(
                  controller.statusMessage.value.isNotEmpty
                      ? controller.statusMessage.value
                      : 'Memuat data mesin...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: _textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mohon tunggu, sedang menghubungi API Fingerspot...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _textGray, fontSize: 12),
                ),
              ],
            ),
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
                const Icon(Icons.devices_other_rounded,
                    color: _textGray, size: 52),
                const SizedBox(height: 14),
                Text(controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _textGray, fontSize: 14)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: controller.fetchMesin,
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

      if (controller.mesin.value == null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.router_rounded,
                    color: _primary, size: 52),
              ),
              const SizedBox(height: 20),
              const Text(
                'Belum ada data mesin',
                style: TextStyle(
                    color: _textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tekan "Ambil Data" untuk memuat\ninformasi mesin absensi',
                textAlign: TextAlign.center,
                style: TextStyle(color: _textGray, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: controller.fetchMesin,
                icon: const Icon(Icons.cloud_download_rounded, size: 16),
                label: const Text('Ambil Data Sekarang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      }

      return _buildMesinDetail(controller.mesin.value!);
    });
  }

  // ─────────────────────────────────────────────────────────────────
  //  DETAIL MESIN
  // ─────────────────────────────────────────────────────────────────

  Widget _buildMesinDetail(MesinInfo m) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Device card ──────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: _primary.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.fingerprint_rounded,
                        size: 32, color: _primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.deviceName,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: _textDark),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _chip('ID: ${m.cloudId}', _primary),
                          const SizedBox(width: 6),
                          _chip(
                            m.statusLabel,
                            m.isActive ? _success : _warning,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Status stat cards ─────────────────────────
          _buildSectionTitle('Status Koneksi'),
          const SizedBox(height: 8),
          Row(
            children: [
              _statCard(
                icon: Icons.circle_rounded,
                label: 'Status',
                value: m.statusLabel,
                color: m.isActive ? _success : _warning,
              ),
              const SizedBox(width: 10),
              _statCard(
                icon: Icons.access_time_rounded,
                label: 'Aktivitas',
                value: m.isActive ? 'Ada' : 'N/A',
                color: m.isActive ? _success : _textGray,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Informasi detail ──────────────────────────
          _buildSectionTitle('Informasi Detail'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                _infoRow(
                    icon: Icons.badge_rounded,
                    label: 'Cloud ID',
                    value: m.cloudId,
                    isFirst: true),
                _divider(),
                _infoRow(
                    icon: Icons.devices_rounded,
                    label: 'Nama Mesin',
                    value: m.deviceName),
                _divider(),
                _infoRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Dibuat Pada',
                    value: m.createdAt),
                _divider(),
                _infoRow(
                    icon: Icons.history_rounded,
                    label: 'Aktivitas Terakhir',
                    value: m.lastActivity,
                    isLast: true),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Webhook URL ───────────────────────────────
          _buildSectionTitle('Webhook'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                          color: _primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.webhook_rounded,
                          color: _primary, size: 16),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Webhook URL',
                      style: TextStyle(
                          fontSize: 13,
                          color: _textGray,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    m.webhookUrl,
                    style: const TextStyle(
                        fontSize: 12,
                        color: _primary,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Set Timezone ──────────────────────────────
          _buildSectionTitle('Atur Zona Waktu'),
          const SizedBox(height: 8),
          _buildSetTimezone(),
        ],
      ),
    );
  }

  Widget _buildSetTimezone() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: _warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.schedule_rounded,
                    color: _warning, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'Set Time Mesin',
                style: TextStyle(
                    fontSize: 13,
                    color: _textGray,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Text(
              'Pilih zona waktu lalu tekan "Terapkan" untuk mengubah jam mesin.',
              style: TextStyle(fontSize: 11, color: _textGray),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedTimezone.value,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: _primary),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _textDark),
                    items: MesinController.timezoneOptions
                        .map((tz) => DropdownMenuItem(
                              value: tz,
                              child: Text(tz),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectedTimezone.value = value;
                        controller.setTimeMessage.value = '';
                      }
                    },
                  ),
                ),
              )),
          const SizedBox(height: 12),
          Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.isSettingTime.value
                      ? null
                      : controller.setTimezone,
                  icon: controller.isSettingTime.value
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_rounded, size: 16),
                  label: Text(controller.isSettingTime.value
                      ? 'Menerapkan...'
                      : 'Terapkan Zona Waktu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _warning,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _warning.withOpacity(0.5),
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              )),
          Obx(() {
            if (controller.setTimeMessage.value.isEmpty) {
              return const SizedBox.shrink();
            }
            final isSuccess = controller.setTimeSuccess.value;
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSuccess
                      ? _success.withOpacity(0.08)
                      : _danger.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: isSuccess
                          ? _success.withOpacity(0.3)
                          : _danger.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSuccess
                          ? Icons.check_circle_rounded
                          : Icons.error_rounded,
                      color: isSuccess ? _success : _danger,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.setTimeMessage.value,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSuccess ? _success : _danger),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  HELPER WIDGETS
  // ─────────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _textGray,
            letterSpacing: 0.5));
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color)),
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: _textGray,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: _primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: _primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      color: _textGray,
                      fontWeight: FontWeight.w500))),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _textDark)),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, indent: 52, endIndent: 0, thickness: 0.5);
  }
}