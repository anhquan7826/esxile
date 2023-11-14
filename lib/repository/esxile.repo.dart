// ignore_for_file: avoid_classes_with_only_static_members

import 'package:dio/dio.dart';

abstract class EsxileRepository {
  static final _dio = Dio(BaseOptions(
    baseUrl: 'https://192.168.0.103/api',
  ));

  Dio get dio => _dio;
}
