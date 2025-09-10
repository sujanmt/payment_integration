import 'dart:io';

abstract class Response {
  static String defaultErrorMessage = "Internal Server Error";

  static String defaultConnectionError = "No internet connection";

  static String getErrorMessage(Object error) {
    String errorMessage;
    if (error is SocketException) {
      errorMessage = Response.defaultConnectionError;
    } else {
      errorMessage = Response.defaultErrorMessage;
    }
    return errorMessage;
  }
}
