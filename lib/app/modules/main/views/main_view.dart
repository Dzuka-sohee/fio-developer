import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

import '../controllers/main_controller.dart';

// Import semua halaman konten
import '../../home/views/home_view.dart';
import '../../laporan/views/laporan_view.dart';
import '../../mesin/views/mesin_view.dart';
import '../../pegawai/views/pegawai_view.dart';
import '../../jadwal/views/jadwal_view.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  static const List<Widget> _pages = [
    HomeView(),
    LaporanView(),
    MesinView(),
    PegawaiView(),
    JadwalView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _pages[controller.selectedIndex.value]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 16),
            child: Obx(
              () => GNav(
                rippleColor: Colors.grey[800]!,
                hoverColor: Colors.grey[700]!,
                haptic: true,
                tabBorderRadius: 15,
                tabActiveBorder: Border.all(color: Colors.black, width: 1),
                // tabBorder: Border.all(color: Colors.grey, width: 1),
                // tabShadow: [
                //   BoxShadow(
                //     color: Colors.grey.withOpacity(0.5),
                //     blurRadius: 8,
                //   )
                // ],
                curve: Curves.easeInExpo,
                duration: const Duration(milliseconds: 600),
                gap: 8,
                color: Colors.grey[800],
                activeColor: Colors.purple,
                iconSize: 20,
                tabBackgroundColor: Colors.purple.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                selectedIndex: controller.selectedIndex.value,
                onTabChange: controller.changeTab,
                tabs: const [
                  GButton(
                    icon: LineIcons.home,
                    text: 'Home',
                  ),
                  GButton(
                    icon: LineIcons.fileAlt,
                    text: 'Laporan',
                  ),
                  GButton(
                    icon: LineIcons.cog,
                    text: 'Mesin',
                  ),
                  GButton(
                    icon: LineIcons.users,
                    text: 'Pegawai',
                  ),
                  GButton(
                    icon: LineIcons.calendar,
                    text: 'Jadwal',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}