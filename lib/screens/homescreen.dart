import 'package:analyse/screens/plotscreen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    Route createRoute() {
      return PageRouteBuilder(
        transitionDuration: const Duration(seconds: 1),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const PlotScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF226f54),
        title: const Text('Analyse', style: TextStyle(color: Color(0xFFf4f0bb)),),
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) => {
          if (details.delta.dy < 0) {Navigator.of(context).push(createRoute())}
        },
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset('assets/lottie/hello.json', repeat: true),
                const SizedBox(height: 20),
                const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_circle_up),
                      SizedBox(width: 8),
                      Text(
                        "Swipe up for analyze",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
