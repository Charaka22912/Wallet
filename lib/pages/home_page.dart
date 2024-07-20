import 'package:flutter/material.dart';
import 'package:wallet/database/database_helper.dart';
import 'package:wallet/models/personal.dart'; // Import the Personal model
import 'dashboard.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class HomePage extends StatefulWidget {
  final Isar isar;

  const HomePage({super.key, required this.isar});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Image.asset(
                'images/Wavy_Tech-31_Single-01 [Converted]-01.png',
                height: 200,
              ),
            ),
            SizedBox(height: 24.0),
            Center(
              child: Text(
                'Welcome to My Wallet!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Center(
              child: Text(
                'Create your account to start recording your expenses!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 32.0),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: nicknameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nickname',
              ),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text;
                final nickname = nicknameController.text;

                final personal = Personal() // Correct the model name
                  ..name = name
                  ..nickname = nickname;

                await widget.isar.writeTxn(() async {
                  await widget.isar.personals.put(personal); // Use correct collection name
                });

                await _setFirstLaunch(); // Set first launch flag

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User registered successfully!')),
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DashboardScreen(
                      nickname: nickname,
                      isar: widget.isar,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Start',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('firstLaunch', false);
  }
}
