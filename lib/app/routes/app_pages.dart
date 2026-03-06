import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/jadwal/bindings/jadwal_binding.dart';
import '../modules/jadwal/views/jadwal_view.dart';
import '../modules/laporan/bindings/laporan_binding.dart';
import '../modules/laporan/views/laporan_view.dart';
import '../modules/main/bindings/main_binding.dart';
import '../modules/main/views/main_view.dart';
import '../modules/mesin/bindings/mesin_binding.dart';
import '../modules/mesin/views/mesin_view.dart';
import '../modules/pegawai/bindings/pegawai_binding.dart';
import '../modules/pegawai/views/pegawai_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.MAIN;

  static final routes = [
    GetPage(
      name: _Paths.MAIN,
      page: () => const MainView(),
      binding: BindingsBuilder(() {
        MainBinding().dependencies();
        HomeBinding().dependencies();
        LaporanBinding().dependencies();
        MesinBinding().dependencies();
        PegawaiBinding().dependencies();
        JadwalBinding().dependencies();
      }),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.JADWAL,
      page: () => const JadwalView(),
      binding: JadwalBinding(),
    ),
    GetPage(
      name: _Paths.MESIN,
      page: () => const MesinView(),
      binding: MesinBinding(),
    ),
    GetPage(
      name: _Paths.LAPORAN,
      page: () => const LaporanView(),
      binding: LaporanBinding(),
    ),
    GetPage(
      name: _Paths.PEGAWAI,
      page: () => const PegawaiView(),
      binding: PegawaiBinding(),
    ),
  ];
}