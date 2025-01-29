import 'dart:async';

import 'package:flutter/material.dart';
import 'package:leafy_lenz/utils/wrapper.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 3), (){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Wrapper()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset("asset/plant-growing.json", alignment: Alignment.center, height: 200, frameRate: FrameRate.max),
              const SizedBox(height: 30),
              // App name
              Text(
                'LeafyLenz',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your Green Companion',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green[500],
                ),
              ),
            ],
          ),
      ),
      );
  }
}
