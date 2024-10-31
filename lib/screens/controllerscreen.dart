import 'package:analyse/screens/historyscreen.dart';
import 'package:analyse/screens/homescreen.dart';
import 'package:analyse/screens/loginscreen.dart';
import 'package:analyse/screens/profilescreen.dart';
import 'package:flutter/material.dart';

class Controllerscreen extends StatefulWidget {
  const Controllerscreen({super.key});

  @override
  State<Controllerscreen> createState() => _ControllerscreenState();
}

class _ControllerscreenState extends State<Controllerscreen> {
  int currentIndex = 0;
  List<Widget> screens = [
    const Homescreen(),
    const HistoryScreen(),
    const Profilescreen()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: screens[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          unselectedItemColor: Colors.black,
          selectedItemColor: const Color(0xFFf4f0bb),
          backgroundColor: const Color(0xFF226f54),
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          currentIndex: currentIndex,
          elevation: 3,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
        label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.history),
        label: 'Saved'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
        label: 'Profile'),
      ],
    ));
  }
}
