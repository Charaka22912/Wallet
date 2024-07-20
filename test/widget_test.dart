import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/main.dart';
import 'package:wallet/models/expences.dart';
import 'package:wallet/models/income.dart';
import 'package:wallet/models/personal.dart';
import 'package:wallet/pages/home_page.dart';
import 'package:wallet/models/personal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;

  setUpAll(() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [ExpensesSchema, IncomesSchema, PersonalSchema],
      directory: dir.path,
    );

    // Set firstLaunch to true in SharedPreferences for testing purposes
    SharedPreferences.setMockInitialValues({'firstLaunch': true});
  });

  testWidgets('Test MyApp widget', (WidgetTester tester) async {
    // Build the MyApp widget and trigger a frame.
    await tester.pumpWidget(MyApp(isar: isar, isFirstLaunch: true));

    // Verify that the HomePage is displayed.
    expect(find.text('Welcome to My Wallet!'), findsOneWidget);
  });

  tearDownAll(() async {
    await isar.close();
  });
}
