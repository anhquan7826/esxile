import 'package:esxile/app/login/login.cubit.dart';
import 'package:esxile/app/login/login.state.dart';
import 'package:esxile/constants/app_colors.dart';
import 'package:esxile/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Incorrect username or password!'),
            ),
          );
        }
        if (state is LoggedIn) {
          context.go(AppRoute.home);
        }
      },
      builder: (context, state) => Scaffold(
        backgroundColor: backgroundColor,
        body: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      label: Text('Username'),
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      label: Text('Password'),
                    ),
                    obscureText: true,
                  ),
                  FilledButton(
                    onPressed: () {
                      BlocProvider.of<LoginCubit>(context).login(usernameController.text, passwordController.text);
                    },
                    child: const Text('Authorize'),
                  ),
                  if (state is LoggingIn) const CircularProgressIndicator(),
                ],
              ),
            ),
            const Expanded(
              child: Column(
                children: [
                  Text('ESXile'),
                  Text('An ESXi Host Client'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
