import 'package:esxile/app/login/login.view.dart';
import 'package:go_router/go_router.dart';

class AppRoute {
  AppRoute._();
  static const login = '/';

  static final routerConfigs = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(  
        path: login,
        builder: (context, state) {
          return const LoginView();
        },
      ),
    ],
  );
}