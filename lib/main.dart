import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:esxile/constants/app_colors.dart';
import 'package:esxile/routes/routes.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
  doWhenWindowReady(() {
    appWindow.minSize = const Size(600, 450);
    appWindow.size = const Size(1280, 720);
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
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
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoute.routerConfigs,
      builder: (context, child) {
        final windowButtonColor = WindowButtonColors(
          mouseOver: const Color(0xFFD32F2F),
          mouseDown: const Color(0xFFB71C1C),
          iconNormal: Colors.white,
          iconMouseOver: const Color(0xFFFFFFFF),
        );
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: Colors.blue),
            // borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              WindowTitleBarBox(
                child: Row(
                  children: [
                    Expanded(
                      child: MoveWindow(),
                    ),
                    MinimizeWindowButton(
                      colors: windowButtonColor,
                    ),
                    MaximizeWindowButton(
                      colors: windowButtonColor,
                    ),
                    CloseWindowButton(
                      colors: windowButtonColor,
                    ),
                  ],
                ),
              ),
              if (child != null) Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}
