import 'package:analyse/screens/controllerscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loginscreen extends StatelessWidget {
  const Loginscreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController name = TextEditingController();
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Lottie.asset('assets/lottie/analyse_login.json'),
              textFieldEdit(
                  'Name', name, false, TextInputType.text, Icons.edit),
              textFieldEdit('Email', email, false, TextInputType.emailAddress,
                  Icons.email),
              textFieldEdit(
                  'Password', password, true, TextInputType.text, Icons.lock),
              ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.indigo)),
                onPressed: () async {
                  if (name.text.isNotEmpty &&
                      email.text.isNotEmpty &&
                      password.text.isNotEmpty) {
                    try {
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .signInWithEmailAndPassword(
                        email: email.text,
                        password: password.text,
                      );
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool('isLoggedIn', true);
                      await FirebaseFirestore.instance
                          .collection('user')
                          .doc(userCredential.user!.uid)
                          .set({
                        'name': name.text,
                      });
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Controllerscreen(),
                          ));
                    } catch (e) {
                      print("Login failed: $e");
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Login failed. Please try again.')));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Please fill in all fields.')));
                  }
                },
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget textFieldEdit(String label, TextEditingController controller,
    bool obscure, TextInputType type, IconData data) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
    child: TextField(
      obscureText: obscure,
      keyboardType: type,
      controller: controller,
      autofocus: false,
      decoration: InputDecoration(
        label: Text(label),
        prefixIcon: Icon(data),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
  );
}
