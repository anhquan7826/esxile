import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:esxile/repository/authentication.repo.dart';

class AuthenticationRepositoryImpl extends AuthenticationRepository {
  Interceptor? _interceptor;

  @override
  Future<bool> authorize(String username, String password) async {
    _interceptor = InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Content-Type'] = 'application/vnd.vmware.vmw.rest-v1+json';
        options.headers['Accept'] = 'application/vnd.vmware.vmw.rest-v1+json';
        options.headers['Authorization'] = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
        handler.next(options);
      },
    );
    dio.interceptors.add(_interceptor!);
    try {
      await dio.get('/vms');
      return true;
    } catch (_) {
      dio.interceptors.remove(_interceptor);
      _interceptor = null;
      return false;
    }
  }

  @override
  Future<void> deAuthorize() async {
    dio.interceptors.remove(_interceptor);
    _interceptor = null;
  }
}
