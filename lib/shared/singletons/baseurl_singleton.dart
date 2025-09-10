class BaseURL {
  static BaseURL? _instance;

  BaseURL._();

  static BaseURL get getInstance => _instance ??= BaseURL._();

  String baseUrl = "";
  String imageUrl = "";

  setBaseUrl(String newUrl) {
    baseUrl = newUrl;
  }

  String getBaseUrl() {
    return baseUrl;
  }

  setImageUrl(String newUrl) {
    imageUrl = newUrl;
  }

  String getImageUrl() {
    return imageUrl;
  }
}
