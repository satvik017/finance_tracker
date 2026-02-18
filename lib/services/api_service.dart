import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl =
      'https://script.google.com/macros/s/AKfycbwEau43GSsoX3kxCRJgxYvtRKpfZKiMMTDs8VCA5BzRB0lsBpXAccVc8_W9KT_HskJH/exec';

  final http.Client _client;

  Future<dynamic> getJson({
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(baseUrl).replace(queryParameters: query);
    final response = await _client.get(uri, headers: headers);
    return _handleResponse(response);
  }

  Future<dynamic> postJson({
    Map<String, String>? query,
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse(baseUrl).replace(queryParameters: query);
    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: body == null ? null : jsonEncode(body),
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    }

    throw http.ClientException(
      'Request failed with status ${response.statusCode}: ${response.body}',
      response.request?.url,
    );
  }

  void dispose() {
    _client.close();
  }
}
