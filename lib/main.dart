import 'ui/theme/app_theme.dart';
import 'data/candidature_repository.dart';
import 'package:flutter/material.dart';
import 'package:piste_app_flutter/ui/accueil_page.dart';
import 'package:piste_app_flutter/state/candidature_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key, CandidatureRepository? repository})
      : candidatureController =
            CandidatureController(repository ?? SqliteCandidatureRepository())
              ..charger();

  final CandidatureController candidatureController;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piste',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: AccueilPage(controller: candidatureController),
    );
  }
}
