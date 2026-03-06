import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/jadwal_controller.dart';

class JadwalView extends GetView<JadwalController> {
  const JadwalView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Jadwal Page',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}