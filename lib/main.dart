import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/haptic_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/sync_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync<StorageService>(() => StorageService().init(), permanent: true);
  Get.put<HapticService>(HapticService(), permanent: true);
  Get.put<SyncService>(SyncService(), permanent: true);
  Get.put<DeepLinkService>(DeepLinkService(), permanent: true);
  Get.put<ThemeController>(ThemeController(), permanent: true);
  _bindBackgroundChannel();
  runApp(const PulseTrackApp());
}

void _bindBackgroundChannel() {
  const MethodChannel('pulsetrack/background').setMethodCallHandler((call) async {
    if (call.method == 'syncOverdueHabits') {
      return Get.find<SyncService>().syncNow();
    }
    throw PlatformException(code: 'not_implemented');
  });
}

class PulseTrackApp extends StatelessWidget {
  const PulseTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Obx(
      () => GetMaterialApp(
        title: 'PulseTrack',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeController.themeMode.value,
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 360),
        builder: (context, child) => AnimatedTheme(
          data: Theme.of(context),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          child: child ?? const SizedBox.shrink(),
        ),
        smartManagement: SmartManagement.full,
      ),
    );
  }
}
