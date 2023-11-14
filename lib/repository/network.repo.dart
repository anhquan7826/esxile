import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:esxile/repository/esxile.repo.dart';

class SessionRepository extends EsxileRepository {
  Interceptor? _interceptor;

  void setToken({required String username, required String password}) {
    if (_interceptor != null) {
      dio.interceptors.remove(_interceptor);
    }
    _interceptor = InterceptorsWrapper(onRequest: (options, handler) {
      options.headers.addAll({
        'Content-Type': 'application/vnd.vmware.vmw.rest-v1+json',
        'Accept': 'application/vnd.vmware.vmw.rest-v1+json',
        'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
      });
      return handler.next(options);
    });
    dio.interceptors.add(_interceptor!);
  }
}
