import 'package:esxile/app/login/login.state.dart';
import 'package:esxile/repository/authentication.repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authRepo) : super(const LoginInitialState());

  final AuthenticationRepository _authRepo;

  Future<void> login(String username, String password) async {
    emit(LoggingIn(username, password));
    final result = await _authRepo.authorize(username, password);
    if (result) {
      emit(LoggedIn(username, password));
    } else {
      emit(LoginError(username, password));
    }
  }
}
