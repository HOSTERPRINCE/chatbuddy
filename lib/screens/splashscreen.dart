import 'package:flutter/material.dart';
class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter chat"),

      ),
      body: Center(
        child: Text("Loading...",style: TextStyle(fontSize: 30),),
      ),
    );
  }
}
