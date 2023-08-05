import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:http_interceptor/http_interceptor.dart';

class RawHttpCookieInterceptor implements InterceptorContract {
  final CookieJar cookieJar;

  RawHttpCookieInterceptor(this.cookieJar);

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
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    print("interceptRequest");
    final cookies = await cookieJar.loadForRequest(request.url);
    final previousCookies = request.headers[HttpHeaders.cookieHeader];
    final newCookies = getCookies([
      ...?previousCookies
          ?.split(';')
          .where((e) => e.isNotEmpty)
          .map((c) => Cookie.fromSetCookieValue(c)),
      ...cookies,
    ]);
    if (newCookies.isNotEmpty) {
      request.headers[HttpHeaders.cookieHeader] = newCookies;
    }
    return request;
  }

  @override
  Future<bool> shouldInterceptRequest() async => true;

  @override
  Future<bool> shouldInterceptResponse() async => false;

  @override
  Future<BaseResponse> interceptResponse(
      {required BaseResponse response}) async {
    return response;
  }
}


class RawHttpWithCredentialsInterceptor implements InterceptorContract {

  RawHttpWithCredentialsInterceptor();

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    return request;
  }

  @override
  Future<bool> shouldInterceptRequest() async => true;

  @override
  Future<bool> shouldInterceptResponse() async => false;

  @override
  Future<BaseResponse> interceptResponse(
      {required BaseResponse response}) async {
    return response;
  }
}
