import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallet/pages/add_expences.dart';
import 'package:wallet/pages/dashboard.dart';
import 'package:wallet/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/pages/summery.dart';
import 'models/expences.dart';
import 'models/income.dart';
import 'models/personal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [ExpensesSchema, IncomesSchema, PersonalSchema], // Add schemas here
    directory: dir.path,
  );

  final isFirstLaunch = await checkFirstLaunch();

  runApp(MyApp(isar: isar, isFirstLaunch: isFirstLaunch));
}

Future<bool> checkFirstLaunch() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('firstLaunch') ?? true;
}

class MyApp extends StatelessWidget {
  final Isar isar;
  final bool isFirstLaunch;

  MyApp({required this.isar, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: isFirstLaunch ? '/' : '/dashboard',
      routes: {
        '/': (context) => HomePage(isar: isar),
        '/dashboard': (context) => FutureBuilder<String>(
          future: getNicknameFromDatabase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
            } else {
              final nickname = snapshot.data!;
              return DashboardScreen(nickname: nickname, isar: isar);
            }
          },
        ),
        '/add_expenses': (context) => addexpence(isar: isar),
        '/expenses_details': (context) => ExpensesDetailsScreen(isar: isar), // Add the new route
        '/dashboard': (context) => DashboardScreen(nickname: '', isar: isar),// Add more routes here as needed
      },
    );
  }

  Future<String> getNicknameFromDatabase() async {
    final personal = await isar.personals.where().findFirst();
    return personal?.nickname ?? '';
  }
}
