import 'package:get/get.dart';
import 'package:app_pengukur_lahan/views/home_page.dart';

class SplassPageController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    Future.delayed(const Duration(seconds: 5), () {
      Get.offAll(HomePage(), duration: const Duration(milliseconds: 500), transition: Transition.fade);
    });
    super.onInit();
  }
}
