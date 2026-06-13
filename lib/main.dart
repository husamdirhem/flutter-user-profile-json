import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class UserProfile {
  String name;
  int age;

  UserProfile({
    required this.name,
    required this.age,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      age: json['age'],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();

  UserProfile? savedProfile;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<File> getProfileFile() async {
    final dir = await getApplicationDocumentsDirectory();

    return File('${dir.path}/profile.json');
  }

  Future<void> saveProfile() async {
    try {
      final profile = UserProfile(
        name: nameController.text,
        age: int.parse(ageController.text),
      );

      final file = await getProfileFile();

      final jsonString = jsonEncode(profile.toJson());

      await file.writeAsString(jsonString);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile Saved Successfully"),
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {
        savedProfile = profile;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

  Future<void> loadProfile() async {
    try {
      final file = await getProfileFile();

      if (await file.exists()) {
        final content = await file.readAsString();

        final jsonData = jsonDecode(content);

        final profile = UserProfile.fromJson(jsonData);

        setState(() {
          savedProfile = profile;

          nameController.text = profile.name;
          ageController.text = profile.age.toString();
        });
      }
    } catch (e) {
      debugPrint("Load Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile JSON'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveProfile,
                child: const Text('Save Profile'),
              ),
            ),

            const SizedBox(height: 30),

            if (savedProfile != null)
              Card(
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(savedProfile!.name),
                  subtitle: Text(
                    'Age: ${savedProfile!.age}',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}