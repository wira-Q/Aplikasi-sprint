import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sprint/JobSeeker/login.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState(){
    super.initState();
    Timer(const Duration(seconds: 5),(){
      Navigator.pushReplacement(context,
       MaterialPageRoute(builder: (context)=> Login())
       );
    }
    );
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xFF1E3A8A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 5),
            const Text("Career Step",
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color:Colors.white,
            ),
            ),
          ],
        ),
      ),
      
    );
  }
}