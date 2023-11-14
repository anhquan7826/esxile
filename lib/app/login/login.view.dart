import 'package:esxile/constants/app_colors.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState(); 
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    label: Text("Username"),
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    label: Text("Password"),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text("ESXile"),
                Text("An ESXi Host Client"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
