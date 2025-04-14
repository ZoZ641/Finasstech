import 'package:flutter/material.dart';

//ToDo: change the loader to loading_animation_widget
class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
