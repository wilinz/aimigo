import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

HttpClientAdapter getHttpClientAdapter({bool withCredentials = false}) =>
    BrowserHttpClientAdapter(withCredentials: withCredentials);
