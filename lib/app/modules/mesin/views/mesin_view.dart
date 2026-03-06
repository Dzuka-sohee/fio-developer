import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mesin_controller.dart';

class MesinView extends GetView<MesinController> {
  const MesinView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Mesin Page',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}