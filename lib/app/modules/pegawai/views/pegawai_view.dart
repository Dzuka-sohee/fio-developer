import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pegawai_controller.dart';

class PegawaiView extends GetView<PegawaiController> {
  const PegawaiView({super.key});

  static const Color _primary = Color(0xFF1A56DB);
  static const Color _success = Color(0xFF0E9F6E);
  static const Color _bg = Color(0xFFF3F6FB);
  static const Color _card = Colors.white;
  static const Color _textDark = Color(0xFF1A202C);
  static const Color _textGray = Color(0xFF718096);

  @override
  Widget build(BuildContext context) {
    final TextEditingController pinTextController = TextEditingController();

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(pinTextController),
      body: Column(
        children: [
          _buildSearchCard(pinTextController),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(TextEditingController pinTextController) {
    return AppBar(
      backgroundColor: _primary,
      elevation: 0,
      title: const Text(
        'Data Pegawai',
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
                tooltip: 'Reset',
                onPressed: () {
                  pinTextController.clear();
                  controller.reset();
                },
              )),
      ],
    );
  }

  Widget _buildSearchCard(TextEditingController pinTextController) {
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
            const Icon(Icons.badge_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: pinTextController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Masukkan PIN pegawai...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (value) => controller.fetchPegawai(value),
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
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
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
                    onPressed: () =>
                        controller.fetchPegawai(pinTextController.text),
                    child: const Text(
                      'Cari',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

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
                      : 'Memuat data...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mohon tunggu, sedang menghubungi mesin absensi...',
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
                const Icon(Icons.person_off_rounded,
                    color: _textGray, size: 52),
                const SizedBox(height: 14),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _textGray, fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: controller.reset,
                  icon: const Icon(Icons.search_rounded, size: 16),
                  label: const Text('Cari Ulang'),
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

      if (controller.pegawai.value == null) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.manage_accounts_rounded, color: _textGray, size: 60),
              SizedBox(height: 14),
              Text(
                'Masukkan PIN untuk mencari data pegawai',
                textAlign: TextAlign.center,
                style: TextStyle(color: _textGray, fontSize: 14),
              ),
            ],
          ),
        );
      }

      return _buildPegawaiDetail(controller.pegawai.value!);
    });
  }

  Widget _buildPegawaiDetail(PegawaiInfo p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile card
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
                  offset: const Offset(0, 3),
                ),
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
                  child: Center(
                    child: Text(
                      p.name.isNotEmpty
                          ? p.name.substring(0, 1).toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'PIN: ${p.pin}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              p.privilegeLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _success,
                              ),
                            ),
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

          _buildSectionTitle('Biometrik'),
          const SizedBox(height: 8),
          Row(
            children: [
              _bioCard(
                icon: Icons.fingerprint_rounded,
                label: 'Sidik Jari',
                value: '${p.finger}',
                color: _primary,
              ),
              const SizedBox(width: 10),
              _bioCard(
                icon: Icons.face_rounded,
                label: 'Wajah',
                value: '${p.face}',
                color: const Color(0xFF7C3AED),
              ),
              const SizedBox(width: 10),
              _bioCard(
                icon: Icons.water_drop_rounded,
                label: 'Vein',
                value: '${p.vein}',
                color: const Color(0xFFD97706),
              ),
            ],
          ),

          const SizedBox(height: 16),

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
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _infoRow(
                  icon: Icons.tag_rounded,
                  label: 'PIN',
                  value: p.pin,
                  isFirst: true,
                ),
                _divider(),
                _infoRow(
                  icon: Icons.person_rounded,
                  label: 'Nama',
                  value: p.name,
                ),
                _divider(),
                _infoRow(
                  icon: Icons.admin_panel_settings_rounded,
                  label: 'Hak Akses',
                  value: '${p.privilegeLabel} (${p.privilege})',
                ),
                _divider(),
                _infoRow(
                  icon: Icons.lock_rounded,
                  label: 'Password',
                  value: p.password,
                ),
                _divider(),
                _infoRow(
                  icon: Icons.credit_card_rounded,
                  label: 'RFID',
                  value: '${p.rfid}',
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: _textGray,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _bioCard({
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
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: _textGray,
                fontWeight: FontWeight.w500,
              ),
            ),
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
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: _textGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, indent: 52, endIndent: 0, thickness: 0.5);
  }
}