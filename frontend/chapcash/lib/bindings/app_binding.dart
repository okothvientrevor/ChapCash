import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/transaction_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthController()); // This should be in a separate auth binding
    Get.put(UserController());
    Get.put(TransactionController());
  }
}
