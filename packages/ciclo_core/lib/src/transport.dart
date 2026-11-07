import "dart:convert";

import "package:http/http.dart" as http;

import "mock_server.dart";
import "models.dart";

abstract class ApiTransport {
  Future<Map<String, dynamic>> request({
    required String method,
    required String path,
    String? token,
    Map<String, dynamic>? body,
  });
}

class MockTransport implements ApiTransport {
  MockTransport({
    CicloMockServer? server,
    Duration latency = const Duration(milliseconds: 280),
  }) : server = server ?? CicloMockServer(latency: latency);

  final CicloMockServer server;

  @override
  Future<Map<String, dynamic>> request({
    required String method,
    required String path,
    String? token,
    Map<String, dynamic>? body,
  }) {
    return server.handle(method: method, path: path, token: token, body: body);
  }
}

class HttpTransport implements ApiTransport {
  HttpTransport({required String baseUrl, http.Client? client})
    : baseUrl = baseUrl.endsWith("/")
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl,
      _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  @override
  Future<Map<String, dynamic>> request({
    required String method,
    required String path,
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }
    final uri = Uri.parse("$baseUrl$path");
    final encoded = body == null ? null : jsonEncode(body);
    final http.Response response;
    switch (method.toUpperCase()) {
      case "GET":
        response = await _client.get(uri, headers: headers);
      case "POST":
        response = await _client.post(uri, headers: headers, body: encoded);
      case "PATCH":
        response = await _client.patch(uri, headers: headers, body: encoded);
      case "DELETE":
        response = await _client.delete(uri, headers: headers, body: encoded);
      default:
        throw ApiException(
          status: 500,
          code: "BAD_METHOD",
          message: "Método não suportado.",
        );
    }
    return decodeResponse(response.statusCode, response.body);
  }
}

Map<String, dynamic> decodeResponse(int status, String rawBody) {
  final raw = rawBody.trim().isEmpty ? "{}" : rawBody;
  final dynamic decoded;
  try {
    decoded = jsonDecode(raw);
  } catch (_) {
    throw ApiException(
      status: status,
      code: "BAD_RESPONSE",
      message: "O servidor devolveu uma resposta que não é JSON.",
    );
  }
  if (decoded is! Map) {
    throw ApiException(
      status: status,
      code: "BAD_RESPONSE",
      message: "Resposta inesperada do servidor.",
    );
  }
  final map = Map<String, dynamic>.from(decoded);
  if (status >= 400) {
    final error = map["error"];
    if (error is Map) {
      final fieldsRaw = error["fields"];
      final fields = <String, String>{};
      if (fieldsRaw is Map) {
        fieldsRaw.forEach((key, value) {
          fields["$key"] = "$value";
        });
      }
      throw ApiException(
        status: status,
        code: "${error["code"] ?? "HTTP_$status"}",
        message: "${error["message"] ?? "Falha ao falar com o servidor."}",
        fields: fields,
      );
    }
    throw ApiException(
      status: status,
      code: "HTTP_$status",
      message: "Falha ao falar com o servidor.",
    );
  }
  return map;
}
