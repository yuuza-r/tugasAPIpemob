import 'package:get/get.dart';
import '../app/views/umkm_form_page.dart';
import '../app/views/umkm_view.dart';

class AppRoutes {
  static const umkmList = '/umkm';
  static const umkmForm = '/umkm/add';

  static final routes = [
    GetPage(
      name: umkmList,
      page: () => const UmkmView(),
    ),
    GetPage(
      name: umkmForm,
      page: () => const UmkmFormPage(),
    ),
  ];
}
