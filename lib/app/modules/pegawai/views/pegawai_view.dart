import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pegawai_controller.dart';

class PegawaiView extends GetView<PegawaiController> {
  const PegawaiView({super.key});

  static const Color _primary = Color(0xFF1A56DB);
  static const Color _success = Color(0xFF0E9F6E);
  static const Color _warning = Color(0xFFF59E0B);
  static const Color _danger = Color(0xFFEF4444);
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _bg = Color(0xFFF3F6FB);
  static const Color _card = Colors.white;
  static const Color _textDark = Color(0xFF1A202C);
  static const Color _textGray = Color(0xFF718096);

  static const List<Map<String, dynamic>> _privilegeOptions = [
    {'value': '0', 'label': 'Guest'},
    {'value': '1', 'label': 'User'},
    {'value': '2', 'label': 'Manager'},
    {'value': '3', 'label': 'Supervisor'},
    {'value': '14', 'label': 'Super Admin'},
  ];

  @override
  Widget build(BuildContext context) {
    final TextEditingController pinTextController = TextEditingController();

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(pinTextController),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(context, isEdit: false),
        backgroundColor: _primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text(
          'Tambah Pegawai',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _buildSearchCard(pinTextController),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  APP BAR
  // ─────────────────────────────────────────────────────────────────

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
            letterSpacing: 0.3),
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
                tooltip: 'Reset',
                onPressed: () {
                  pinTextController.clear();
                  controller.reset();
                },
              )),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  SEARCH BAR
  // ─────────────────────────────────────────────────────────────────

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
                    fontSize: 14),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Masukkan PIN pegawai...',
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (v) => controller.fetchPegawai(v),
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
                    onPressed: () =>
                        controller.fetchPegawai(pinTextController.text),
                    child: const Text('Cari',
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

  Widget _buildBody(BuildContext context) {
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
                      fontWeight: FontWeight.w600),
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
                Text(controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _textGray, fontSize: 14)),
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
              Text('Masukkan PIN untuk mencari data pegawai',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _textGray, fontSize: 14)),
            ],
          ),
        );
      }

      return _buildPegawaiDetail(context, controller.pegawai.value!);
    });
  }

  // ─────────────────────────────────────────────────────────────────
  //  DETAIL PEGAWAI
  // ─────────────────────────────────────────────────────────────────

  Widget _buildPegawaiDetail(BuildContext context, PegawaiInfo p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Profile card ──────────────────────────────
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
            child: Column(
              children: [
                Row(
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
                              color: _primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: _textDark)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _chip('PIN: ${p.pin}', _primary),
                              const SizedBox(width: 6),
                              _chip(p.privilegeLabel, _success),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tombol Edit & Hapus berdampingan
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showFormDialog(context,
                            isEdit: true, existing: p),
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primary,
                          side: const BorderSide(color: _primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(() => ElevatedButton.icon(
                            onPressed: controller.isDeleting.value
                                ? null
                                : () => _showDeleteConfirmDialog(context, p),
                            icon: controller.isDeleting.value
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.delete_rounded, size: 16),
                            label: Text(controller.isDeleting.value
                                ? 'Menghapus...'
                                : 'Hapus'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _danger,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  _danger.withOpacity(0.6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                            ),
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Biometrik ─────────────────────────────────
          _buildSectionTitle('Biometrik'),
          const SizedBox(height: 8),
          Row(
            children: [
              _bioCard(
                  icon: Icons.fingerprint_rounded,
                  label: 'Sidik Jari',
                  value: '${p.finger}',
                  color: _primary),
              const SizedBox(width: 10),
              _bioCard(
                  icon: Icons.face_rounded,
                  label: 'Wajah',
                  value: '${p.face}',
                  color: _purple),
              const SizedBox(width: 10),
              _bioCard(
                  icon: Icons.water_drop_rounded,
                  label: 'Vein',
                  value: '${p.vein}',
                  color: _warning),
            ],
          ),

          const SizedBox(height: 16),

          // ── Informasi Detail ──────────────────────────
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
                    icon: Icons.tag_rounded,
                    label: 'PIN',
                    value: p.pin,
                    isFirst: true),
                _divider(),
                _infoRow(
                    icon: Icons.person_rounded,
                    label: 'Nama',
                    value: p.name),
                _divider(),
                _infoRow(
                    icon: Icons.admin_panel_settings_rounded,
                    label: 'Hak Akses',
                    value: '${p.privilegeLabel} (${p.privilege})'),
                _divider(),
                _infoRow(
                    icon: Icons.lock_rounded,
                    label: 'Password',
                    value: p.password),
                _divider(),
                _infoRow(
                    icon: Icons.credit_card_rounded,
                    label: 'RFID',
                    value: '${p.rfid}',
                    isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  KONFIRMASI HAPUS
  // ─────────────────────────────────────────────────────────────────

  void _showDeleteConfirmDialog(BuildContext context, PegawaiInfo p) {
    controller.clearDeleteMessage();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon warning
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _danger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_forever_rounded,
                  color: _danger, size: 30),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hapus Pegawai?',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _textDark),
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 14, color: _textGray, height: 1.5),
                children: [
                  const TextSpan(text: 'Data pegawai '),
                  TextSpan(
                    text: p.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: _textDark),
                  ),
                  const TextSpan(text: ' dengan PIN '),
                  TextSpan(
                    text: p.pin,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: _primary),
                  ),
                  const TextSpan(
                      text:
                          ' akan dihapus dari mesin absensi.\n\nTindakan ini tidak dapat dibatalkan.'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Feedback setelah aksi (error/sukses)
            Obx(() {
              if (controller.deleteMessage.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return _buildFeedbackBanner(
                message: controller.deleteMessage.value,
                isSuccess: controller.deleteSuccess.value,
                bottomPadding: 0,
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    controller.clearDeleteMessage();
                    Navigator.pop(ctx);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _textGray,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Obx(() => ElevatedButton.icon(
                      onPressed: controller.isDeleting.value
                          ? null
                          : () async {
                              final success =
                                  await controller.deletePegawai(p.pin);
                              if (success) {
                                await Future.delayed(
                                    const Duration(milliseconds: 800));
                                Navigator.pop(ctx);
                                controller.reset();
                              }
                            },
                      icon: controller.isDeleting.value
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_rounded, size: 16),
                      label: Text(controller.isDeleting.value
                          ? 'Menghapus...'
                          : 'Ya, Hapus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _danger,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _danger.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  FORM DIALOG (Tambah / Edit + Registrasi Biometrik)
  // ─────────────────────────────────────────────────────────────────

  void _showFormDialog(
    BuildContext context, {
    required bool isEdit,
    PegawaiInfo? existing,
  }) {
    final pinCtrl = TextEditingController(text: isEdit ? existing?.pin : '');
    final nameCtrl =
        TextEditingController(text: isEdit ? existing?.name : '');
    final passCtrl = TextEditingController(
        text: isEdit
            ? (existing?.password == '-' ? '' : existing?.password)
            : '');
    final rfidCtrl = TextEditingController(
        text: isEdit
            ? (existing?.rfid == 0 ? '' : '${existing?.rfid}')
            : '');

    final selectedPrivilege =
        (isEdit ? '${existing?.privilege ?? 0}' : '0').obs;
    final formKey = GlobalKey<FormState>();
    controller.clearSaveMessage();
    controller.clearBioMessage();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20, top: 8),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: _primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(
                          isEdit
                              ? Icons.edit_rounded
                              : Icons.person_add_rounded,
                          color: _primary,
                          size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEdit
                          ? 'Edit Data Pegawai'
                          : 'Tambah Pegawai Baru',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _textDark),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Form fields ───────────────────────────
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormField(
                        controller: pinCtrl,
                        label: 'PIN',
                        hint: 'Masukkan PIN pegawai',
                        icon: Icons.tag_rounded,
                        keyboardType: TextInputType.number,
                        readOnly: isEdit,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'PIN wajib diisi'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      _buildFormField(
                        controller: nameCtrl,
                        label: 'Nama',
                        hint: 'Masukkan nama pegawai',
                        icon: Icons.person_rounded,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Nama wajib diisi'
                                : null,
                      ),
                      const SizedBox(height: 14),

                      // Privilege dropdown
                      const Text('Hak Akses',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _textDark)),
                      const SizedBox(height: 6),
                      Obx(() => Container(
                            decoration: BoxDecoration(
                                color: _bg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.grey.shade200)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedPrivilege.value,
                                isExpanded: true,
                                icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: _textGray),
                                items: _privilegeOptions.map((opt) {
                                  return DropdownMenuItem<String>(
                                    value: opt['value'] as String,
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Icons
                                                .admin_panel_settings_rounded,
                                            color: _primary,
                                            size: 18),
                                        const SizedBox(width: 10),
                                        Text(
                                            '${opt['label']} (${opt['value']})',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: _textDark)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    selectedPrivilege.value = val;
                                  }
                                },
                              ),
                            ),
                          )),
                      const SizedBox(height: 14),
                      _buildFormField(
                        controller: passCtrl,
                        label: 'Password',
                        hint: 'Masukkan password (opsional)',
                        icon: Icons.lock_rounded,
                      ),
                      const SizedBox(height: 14),
                      _buildFormField(
                        controller: rfidCtrl,
                        label: 'RFID',
                        hint: 'Masukkan RFID (opsional)',
                        icon: Icons.credit_card_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Registrasi Biometrik ──────────────────
                _buildBiometricSection(ctx, pinCtrl),

                const SizedBox(height: 20),

                // Feedback simpan
                Obx(() {
                  if (controller.saveMessage.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return _buildFeedbackBanner(
                    message: controller.saveMessage.value,
                    isSuccess: controller.saveSuccess.value,
                    bottomPadding: 14,
                  );
                }),

                // Tombol aksi
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          controller.clearSaveMessage();
                          controller.clearBioMessage();
                          Navigator.pop(ctx);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _textGray,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Obx(() => ElevatedButton.icon(
                            onPressed: controller.isSaving.value
                                ? null
                                : () async {
                                    if (formKey.currentState?.validate() !=
                                        true) return;
                                    final success =
                                        await controller.savePegawai(
                                      pin: pinCtrl.text,
                                      name: nameCtrl.text,
                                      privilege: selectedPrivilege.value,
                                      password: passCtrl.text,
                                      rfid: rfidCtrl.text,
                                      isEdit: isEdit,
                                    );
                                    if (success) {
                                      await Future.delayed(
                                          const Duration(seconds: 1));
                                      Navigator.pop(ctx);
                                    }
                                  },
                            icon: controller.isSaving.value
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2),
                                  )
                                : Icon(
                                    isEdit
                                        ? Icons.save_rounded
                                        : Icons.person_add_rounded,
                                    size: 18),
                            label: Text(
                              controller.isSaving.value
                                  ? 'Menyimpan...'
                                  : isEdit
                                      ? 'Simpan Perubahan'
                                      : 'Tambah Pegawai',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  _primary.withOpacity(0.6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          )),
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

  // ─────────────────────────────────────────────────────────────────
  //  SEKSI REGISTRASI BIOMETRIK
  // ─────────────────────────────────────────────────────────────────

  Widget _buildBiometricSection(
      BuildContext context, TextEditingController pinCtrl) {
    final fingers = PegawaiController.biometricTypes
        .where((b) => int.parse(b.code) <= 9)
        .toList();
    final others = PegawaiController.biometricTypes
        .where((b) => int.parse(b.code) > 9)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: _purple.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.fingerprint_rounded,
                    color: _purple, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Registrasi Biometrik',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textDark)),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Kirim perintah registrasi ke mesin absensi. Pegawai kemudian melakukan scan di mesin.',
            style: TextStyle(fontSize: 12, color: _textGray),
          ),
          const SizedBox(height: 16),

          _bioGroupLabel(Icons.fingerprint_rounded, 'Sidik Jari', _primary),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: fingers
                .map((b) => _biometricChipButton(
                    context: context,
                    bio: b,
                    pinCtrl: pinCtrl,
                    color: _primary))
                .toList(),
          ),
          const SizedBox(height: 14),

          _bioGroupLabel(Icons.face_rounded, 'Wajah & Vein', _purple),
          const SizedBox(height: 8),
          Row(
            children: others.map((b) {
              final color = b.code == '12' ? _purple : _warning;
              return Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(right: b == others.last ? 0 : 8),
                  child: _biometricChipButton(
                      context: context,
                      bio: b,
                      pinCtrl: pinCtrl,
                      color: color,
                      fullWidth: true),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          Obx(() {
            if (controller.bioMessage.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return _buildFeedbackBanner(
              message: controller.bioMessage.value,
              isSuccess: controller.bioSuccess.value,
            );
          }),
        ],
      ),
    );
  }

  Widget _bioGroupLabel(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color)),
      ],
    );
  }

  Widget _biometricChipButton({
    required BuildContext context,
    required BiometricType bio,
    required TextEditingController pinCtrl,
    required Color color,
    bool fullWidth = false,
  }) {
    return Obx(() {
      final isLoading = controller.isRegBio.value;
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        child: OutlinedButton(
          onPressed: isLoading
              ? null
              : () async {
                  if (pinCtrl.text.trim().isEmpty) {
                    controller.bioMessage.value =
                        'Isi PIN terlebih dahulu sebelum registrasi biometrik.';
                    controller.bioSuccess.value = false;
                    return;
                  }
                  controller.clearBioMessage();
                  await controller.registerBiometric(
                    pin: pinCtrl.text.trim(),
                    verification: bio.code,
                  );
                },
          style: OutlinedButton.styleFrom(
            foregroundColor: isLoading ? Colors.grey : color,
            side: BorderSide(
                color: isLoading
                    ? Colors.grey.shade300
                    : color.withOpacity(0.5)),
            backgroundColor: color.withOpacity(0.05),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(bio.label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isLoading ? Colors.grey : color)),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────
  //  HELPER WIDGETS
  // ─────────────────────────────────────────────────────────────────

  Widget _buildFeedbackBanner({
    required String message,
    required bool isSuccess,
    double bottomPadding = 0,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSuccess
            ? _success.withOpacity(0.1)
            : _danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSuccess
              ? _success.withOpacity(0.3)
              : _danger.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
            color: isSuccess ? _success : _danger,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(
                  color: isSuccess ? _success : _danger,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textDark)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          validator: validator,
          style: TextStyle(
              fontSize: 14, color: readOnly ? _textGray : _textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _textGray, fontSize: 14),
            prefixIcon: Icon(icon, color: _primary, size: 18),
            filled: true,
            fillColor: readOnly ? Colors.grey.shade100 : _bg,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: _primary, width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _danger)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: _danger, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
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
              fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _textGray,
            letterSpacing: 0.5));
  }

  Widget _bioCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
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
                    fontSize: 20,
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
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textDark)),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
        height: 1, indent: 52, endIndent: 0, thickness: 0.5);
  }
}