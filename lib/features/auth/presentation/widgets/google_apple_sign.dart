import 'package:flutter/material.dart';

class GoogleAppleSign extends StatelessWidget {
  final bool isSignIn;
  const GoogleAppleSign({super.key, this.isSignIn = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(onPressed: () {}, child: const Text("Apple")),
        Text(
          isSignIn ? "Or sign in with" : "Or sign up with",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        OutlinedButton(onPressed: () {}, child: const Text("Google")),
      ],
    );
  }
}
