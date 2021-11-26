import 'dart:convert';
import 'dart:io';

import 'package:azkar/net/api_exception.dart';
import 'package:azkar/net/api_interface/request_base.dart';
import 'package:azkar/net/endpoints.dart';
import 'package:azkar/services/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiCaller {
  static const String API_VERSION_HEADER = 'api-version';
  static const String API_VERSION = '1.10.0';

  static Future<http.Response> get({@required Endpoint route}) async {
    try {
      return await ServiceProvider.httpClient.get(
        Uri.https(
            ApiRoutesUtil.apiRouteToString(
                Endpoint(endpointRoute: EndpointRoute.BASE_URL)),
            ApiRoutesUtil.apiRouteToString(route),
            route.requestParams),
        headers: await getHeaders(),
      );
    } catch (e) {
      print(e);
      throw ApiException.withDefaultError();
    }
  }

  static Future<http.Response> put(
      {@required Endpoint route, RequestBodyBase requestBody}) async {
    try {
      return await ServiceProvider.httpClient.put(
        Uri.https(
            ApiRoutesUtil.apiRouteToString(
                Endpoint(endpointRoute: EndpointRoute.BASE_URL)),
            ApiRoutesUtil.apiRouteToString(route)),
        headers: await getHeaders(),
        body: jsonEncode(requestBody?.toJson()),
      );
    } catch (e) {
      print(e);
      throw ApiException.withDefaultError();
    }
  }

  static Future<http.Response> post(
      {@required Endpoint route, RequestBodyBase requestBody}) async {
    try {
      return await ServiceProvider.httpClient.post(
        Uri.https(
            ApiRoutesUtil.apiRouteToString(
                Endpoint(endpointRoute: EndpointRoute.BASE_URL)),
            ApiRoutesUtil.apiRouteToString(route)),
        headers: await getHeaders(),
        body: jsonEncode(requestBody?.toJson()),
      );
    } catch (e) {
      print(e);
      throw ApiException.withDefaultError();
    }
  }

  static Future<http.Response> delete(
      {@required Endpoint route, RequestBodyBase requestBody}) async {
    try {
      return await ServiceProvider.httpClient.delete(
        Uri.https(
            ApiRoutesUtil.apiRouteToString(
                Endpoint(endpointRoute: EndpointRoute.BASE_URL)),
            ApiRoutesUtil.apiRouteToString(route)),
        headers: await getHeaders(),
        body: jsonEncode(requestBody?.toJson()),
      );
    } catch (e) {
      print(e);
      throw ApiException.withDefaultError();
    }
  }

  static Future<Map<String, String>> getHeaders() async {
    String jwtToken = await ServiceProvider.secureStorageService.getJwtToken();

    return <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: jwtToken,
      API_VERSION_HEADER: API_VERSION,
    };
  }
}
