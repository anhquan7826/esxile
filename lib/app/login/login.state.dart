import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();
}

class LoginInitialState extends LoginState {
  const LoginInitialState();

  @override
  List<Object?> get props => [];
}

class LoggingIn extends LoginState {
  const LoggingIn(this.username, this.password);
  final String username;
  final String password;
  
  @override
  List<Object?> get props => [username, password];
}

class LoggedIn extends LoginState {
  const LoggedIn(this.username, this.password);
  final String username;
  final String password;
  
  @override
  List<Object?> get props => [username, password];
}

class LoginError extends LoginState {
  const LoginError(this.username, this.password);
  final String username;
  final String password;
  
  @override
  List<Object?> get props => [username, password];
}
