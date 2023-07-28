import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:http_interceptor/http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../util/openai_key.dart';

extension DioExt on Dio {
  Dio setFollowRedirects(bool followRedirects) {
    options.followRedirects = followRedirects;
    if (followRedirects) {
      options.validateStatus =
          (int? status) => status != null && status >= 200 && status < 300;
    } else {
      options.validateStatus =
          (int? status) => status != null && status >= 200 && status < 400;
    }
    return this;
  }
}

class HttpCookieInterceptor implements InterceptorContract {
  final CookieJar cookieJar;

  HttpCookieInterceptor(this.cookieJar);

  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    print("interceptRequest");
    final cookies = await cookieJar.loadForRequest(Uri.parse(data.url));
    final previousCookies = data.headers[HttpHeaders.cookieHeader];
    final newCookies = getCookies([
      ...?previousCookies
          ?.split(';')
          .where((e) => e.isNotEmpty)
          .map((c) => Cookie.fromSetCookieValue(c)),
      ...cookies,
    ]);
    if (newCookies.isNotEmpty) {
      data.headers[HttpHeaders.cookieHeader] = newCookies;
    }

    return data;
  }

  static String getCookies(List<Cookie> cookies) {
    // Sort cookies by path (longer path first).
    cookies.sort((a, b) {
      if (a.path == null && b.path == null) {
        return 0;
      } else if (a.path == null) {
        return -1;
      } else if (b.path == null) {
        return 1;
      } else {
        return b.path!.length.compareTo(a.path!.length);
      }
    });
    return cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    print(data);
    return data;
  }

}

class AppNetwork {
  static const String baseUrl = "https://hk.wilinz.com:8090";
  static const String typeUrlEncode = "application/x-www-form-urlencoded";
  static const String userAgent =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36";

  static Future<CookieJar> getCookieJar() async {
    CookieJar cookieJar;
    if (!kIsWeb) {
      var dir = await getApplicationSupportDirectory();
      cookieJar =
          PersistCookieJar(storage: FileStorage(join(dir.path, "cookies")));
    } else {
      cookieJar = CookieJar();
    }
    return cookieJar;
  }

  static Future<Dio> setupDio(Dio dio, CookieJar cookieJar) async {
    dio.options = BaseOptions(
      baseUrl: await baseUrl,
      headers: {"User-Agent": userAgent},
      followRedirects: false,
      validateStatus: (int? status) =>
          status != null && status >= 200 && status < 400,
    );
    dio.interceptors.add(CookieManager(cookieJar));
    // proxy(dio);
    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: true,
          error: true,
          compact: true,
          maxWidth: 200));
    }
    dio.interceptors.add(JsonpInterceptor());
    return dio;
  }

  static void proxy(Dio dio) {
    if (!kReleaseMode &&
        (Platform.isWindows || Platform.isMacOS || Platform.isAndroid)) {
      (dio.httpClientAdapter as dynamic).onHttpClientCreate = (client) {
        client.findProxy = (uri) {
          // 这里设置代理地址和端口号
          return "PROXY 192.168.1.5:18888";
        };
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      };
    }
  }

  /// 使用底层重定向
  late Dio _dio;

  /// 关闭重定向
  late Dio _dio1;

  /// 使用重定向拦截器，推荐
  late Dio _dio2;

  late InterceptedClient _rawHttpClient;

  InterceptedClient get rawHttpClient => _rawHttpClient;

  static Future<InterceptedClient> getRawHttpClient() async {
    var appNetwork = await getInstance();
    return appNetwork.rawHttpClient;
  }

  _initRawHttpClient() {
    _rawHttpClient = InterceptedClient.build(interceptors: [
      HttpCookieInterceptor(cookieJar),
    ]);
  }

  _initOpenAi() {
    OpenAI.baseUrl = baseUrl;
    OpenAI.apiKey = generateOpenAiKey(48);
  }

  AppNetwork._create();

  static AppNetwork? _instance = null;

  static Future<Dio> getDio() async {
    var appNetwork = await getInstance();
    Dio dio = appNetwork.redirect2Dio;
    return dio;
  }

  Dio get redirectDio => _dio;

  Dio get dio => _dio1;

  Dio get redirect2Dio => _dio2;

  late CookieJar cookieJar;

  static Future<AppNetwork> getInstance() async {
    if (_instance == null) {
      _instance = AppNetwork._create();
      _instance!.cookieJar = await getCookieJar();
      _instance!._initRawHttpClient();
      _instance!._initOpenAi();

      _instance!._dio = await setupDio(Dio(), _instance!.cookieJar);
      _instance!._dio.setFollowRedirects(true);

      _instance!._dio1 = await setupDio(Dio(), _instance!.cookieJar);
      _instance!._dio1.setFollowRedirects(false);

      final dio2 = Dio();
      _instance!._dio2 = await setupDio(dio2, _instance!.cookieJar);
      _instance!._dio2.setFollowRedirects(false);
      _instance!._dio2.interceptors.add(RedirectInterceptor(dio2));
    }
    return Future(() => _instance!);
  }
}

class UnauthorizedException implements Exception {
  final String msg;

  UnauthorizedException(this.msg);

  @override
  String toString() => msg;
}

/// options: Options(extra: {JsonpInterceptor.UseJsonpParser: true})
class JsonpInterceptor extends Interceptor {
  static const String UseJsonpParser = "use_jsonp_parser";

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final useJsonpParser = options.extra[UseJsonpParser] as bool? ?? false;
    if (useJsonpParser) {
      options.responseType = ResponseType.plain;
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final useJsonpParser =
        response.requestOptions.extra[UseJsonpParser] as bool? ?? false;
    if (useJsonpParser) {
      response.data = json.decode(_removeJsonpWrapper(response.data));
    }
    handler.next(response);
  }

  String _removeJsonpWrapper(String jsonp) {
    int functionStart = jsonp.indexOf('(') + 1;
    int functionEnd = jsonp.lastIndexOf(')');
    String jsonString = jsonp.substring(functionStart, functionEnd);
    return jsonString;
  }
}

class RedirectInterceptor extends Interceptor {
  final Dio dio;

  RedirectInterceptor(this.dio);

  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    if (_isRedirect(response.statusCode ?? 0)) {
      try {
        final location = response.headers.value('location');
        if (location == null) throw Exception("Redirect location is null");
        final requestOptions = response.requestOptions;
        final rawUri = requestOptions.uri.toString();

        final option = Options(
          sendTimeout: requestOptions.sendTimeout,
          receiveTimeout: requestOptions.receiveTimeout,
          extra: requestOptions.extra,
          headers: requestOptions.headers,
          responseType: requestOptions.responseType,
          contentType: requestOptions.contentType,
          validateStatus: requestOptions.validateStatus,
          receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
          followRedirects: requestOptions.followRedirects,
          maxRedirects: requestOptions.maxRedirects,
          persistentConnection: requestOptions.persistentConnection,
          requestEncoder: requestOptions.requestEncoder,
          responseDecoder: requestOptions.responseDecoder,
          listFormat: requestOptions.listFormat,
        );
        final redirectResponse = await dio.get(
          _parseHttpLocation(rawUri, location),
          options: option,
        );
        return handler.next(redirectResponse);
      } on DioException catch (e) {
        return handler.reject(e);
      }
    }
    return handler.next(response);
  }

  bool _isRedirect(int statusCode) {
    return statusCode == 301 ||
        statusCode == 302 ||
        statusCode == 303 ||
        statusCode == 307 ||
        statusCode == 308;
  }

  String _parseHttpLocation(final String rawUri, final String location) {
    var location1 = location;
    String uri;
    if (!location1.contains("://")) {
      final schemaEndIndex = rawUri.indexOf("://") + 3;
      var index = location1.startsWith("/")
          ? rawUri.indexOf("/", schemaEndIndex)
          : rawUri.substring(schemaEndIndex).lastIndexOf("/") + schemaEndIndex;
      if (index == -1) index = rawUri.length - 1;
      var baseUrl = rawUri.substring(0, index + 1);
      if (baseUrl.endsWith("/")) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }
      if (location1.startsWith("/")) {
        location1 = location1.substring(1);
      }
      uri = baseUrl + "/" + location1;
    } else {
      uri = location1;
    }
    return uri;
  }
}
