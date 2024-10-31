import 'dart:math';

import 'package:analyse/screens/loginscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  String? userName;

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('user').doc(user.uid).get();
      setState(() {
        userName = doc['name'];
      });
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Loginscreen(),)); // Make sure to define this route
  }
  @override
  Widget build(BuildContext context) {
    Widget listProfile(String name, IconData data) {
      return ListTile(
        title: Text(name),
        leading: Icon(data),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF226f54),
        title: const Text('Profile', style: TextStyle(color: Color(0xFFf4f0bb)),),
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout, color: Color(0xFFf4f0bb),))
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20,),
          Text(
            userName != null ? 'Welcome, $userName!' : 'Loading...',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          listProfile('Setting', Icons.settings),
          listProfile('EditProfile', Icons.edit),
          listProfile('SavedPlots', Icons.save)
        ],
      ),
    );
  }
}