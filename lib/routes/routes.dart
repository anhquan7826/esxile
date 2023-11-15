import 'package:esxile/app/home/home.cubit.dart';
import 'package:esxile/app/home/home.view.dart';
import 'package:esxile/app/login/login.cubit.dart';
import 'package:esxile/app/login/login.view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRoute {
  AppRoute._();
  static const login = '/login';
  static const home = '/';

  static final routerConfigs = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(
        path: login,
        builder: (context, state) {
          return BlocProvider<LoginCubit>(
            create: (context) {
              return LoginCubit(RepositoryProvider.of(context));
            },
            child: const LoginView(),
          );
        },
      ),
      GoRoute(
        path: home,
        builder: (context, state) {
          return BlocProvider<HomeCubit>(
            create: (context) => HomeCubit(RepositoryProvider.of(context)),
            child: const HomeView(),
          );
        },
      ),
    ],
  );
}
