// ignore_for_file: avoid_classes_with_only_static_members

import 'package:dio/dio.dart';

abstract class EsxileRepository {
  static final _dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8697/api',
  ));

  Dio get dio => _dio;
}
