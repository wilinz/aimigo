import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:fetch_client/fetch_client.dart';
import 'package:openai_dart_dio/openai_dart_dio.dart';

Future<HttpClientAdapter> getHttpClientAdapter({bool withCredentials = false}) async =>
    ConversionLayerAdapter(FetchClient(
        mode: RequestMode.cors, credentials: RequestCredentials.cors));
