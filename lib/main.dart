import 'package:esxile/constants/app_colors.dart';
import 'package:esxile/repository/authentication.repo.dart';
import 'package:esxile/repository/impl/authentication.repo.impl.dart';
import 'package:esxile/repository/impl/vm_management.repo.impl.dart';
import 'package:esxile/repository/vm_management.repo.dart';
import 'package:esxile/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ESXile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: mainColor),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoute.routerConfigs,
      builder: (context, child) {
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AuthenticationRepository>(
              create: (context) => AuthenticationRepositoryImpl(),
            ),
            RepositoryProvider<VMManagementRepository>(
              create: (context) => VMManagementRepositoryImpl(),
            ),
          ],
          child: child ?? const Placeholder(),
        );
      },
    );
  }
}
