import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:app_pengukur_lahan/controllers/splass_page_controller.dart';

class SplassPage extends StatelessWidget {
  SplassPage({super.key});

  SplassPageController controller = Get.put(SplassPageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Image(
              height: 150.0,
              image: const AssetImage("images/logoapp.png"),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                "GPS Pengukur Area",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
