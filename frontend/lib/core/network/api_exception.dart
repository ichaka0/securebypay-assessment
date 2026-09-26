import 'package:dio/dio.dart';

/// A failed API call, normalised from the backend's error body:
/// `{ statusCode, message, errors?: { field: [messages] } }`.
class ApiException implements Exception {
  const ApiException(this.message,
      {this.statusCode, this.fieldErrors = const {}});

  /// Maps any [DioException] (HTTP error, timeout, offline) to an [ApiException].
  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    if (response == null) {
      return const ApiException(
        'Unable to reach the server. Check your connection and try again.',
      );
    }

    final data = response.data;
    var message = 'Something went wrong. Please try again.';
    final fieldErrors = <String, String>{};

    if (data is Map<String, dynamic>) {
      final raw = data['message'];
      if (raw is String && raw.isNotEmpty) message = raw;
      if (raw is List && raw.isNotEmpty) message = raw.first.toString();

      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        errors.forEach((field, value) {
          if (value is List && value.isNotEmpty) {
            fieldErrors[field] = value.first.toString();
          }
        });
      }
    }

    return ApiException(
      message,
      statusCode: response.statusCode,
      fieldErrors: fieldErrors,
    );
  }

  final String message;
  final int? statusCode;

  /// First validation message per request field, keyed by field name.
  final Map<String, String> fieldErrors;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}
