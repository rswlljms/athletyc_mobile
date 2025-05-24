
class AppConfig {
  static const String baseUrl = 'http://192.168.94.39:5000';

  static Uri addToCart = Uri.parse('$baseUrl/api/add_to_cart');
  static Uri login = Uri.parse('$baseUrl/api/login');
  static Uri register = Uri.parse('$baseUrl/api/register');
  static Uri verify_otp =  Uri.parse('$baseUrl/api/verify_otp');
  static Uri send_otp = Uri.parse('$baseUrl/api/send_otp');
  static Uri forgot_password = Uri.parse('$baseUrl/api/forgot_password');
  static Uri get_messages = Uri.parse('$baseUrl/api/get_messages');
  static Uri send_message = Uri.parse('$baseUrl/api/send_message');
  static Uri profile = Uri.parse('$baseUrl/api/profile');
  static Uri apply_voucher = Uri.parse('$baseUrl/api/apply-voucher');
  static Uri updateCartQty = Uri.parse('$baseUrl/api/update_cart_quantity');
  static Uri deleteFromCart = Uri.parse('$baseUrl/api/delete_from_cart');
  static Uri confirmOrder = Uri.parse('$baseUrl/api/confirm_order');
  static Uri order_feedback = Uri.parse('$baseUrl/api/order_feedback');
  static Uri remove_cart_items = Uri.parse('$baseUrl/api/remove-cart-items');
  static Uri place_order =  Uri.parse('$baseUrl/api/place-order');

  //final encodedPrType = Uri.encodeComponent(prType);
  //final response = await http.get(Uri.parse('http://192.168.94.39:5000/api/products?prType=$encodedPrType'));
  static Uri getProductsUri(String prType) {
    return Uri.parse('$baseUrl/api/products').replace(queryParameters: {
      'prType': prType,
    });
  }

  //Uri.parse('http://192.168.94.39:5000/api/products/by_type/$prType'),
  static Uri getProductsByType(String prType) {
    return Uri.parse('$baseUrl/api/products/by_type/$prType');
  }

  //'http://192.168.94.39:5000/${product.imageUrl}'
  static String fullImageUrl(String path) {
    String cleanedPath = path.replaceAll('\\', '/').replaceFirst(RegExp(r'^/+'), '');
    return '$baseUrl/$cleanedPath';
  }

  // Uri.encodeFull('http://192.168.94.39:5000/${product.imageUrl!.replaceAll('\\', '/')}')
  static String teamsports_image(String path) {
     final normalizedPath = path.replaceAll('\\', '/');
    return Uri.encodeFull('$baseUrl/$normalizedPath');
  }

  //Uri.parse('http://192.168.94.39:5000/api/show_cart?email=$email'),
  static Uri showCart(String email) {
    return Uri.parse('$baseUrl/api/show_cart').replace(queryParameters: {
      'email': email,
    });
  }

  //Uri.parse('http://192.168.94.39:5000/api/show_to_ship?email=$email'
  static Uri show_to_ship(String email) {
    return Uri.parse('$baseUrl/api/show_to_ship').replace(queryParameters: {
      'email': email,
    });
  }

  //Uri.parse('http://192.168.94.39:5000/api/show_to_receive?email=$email')
  static Uri show_to_receive(String email) {
    return Uri.parse('$baseUrl/api/show_to_receive').replace(queryParameters: {
      'email': email,
    });
  }

  //Uri.parse('http://192.168.94.39:5000/api/show_to_rate?email=$email')
  static Uri show_to_rate(String email) {
    return Uri.parse('$baseUrl/api/show_to_rate').replace(queryParameters: {
      'email': email,
    });
  }

  //Uri.parse('http://192.168.94.39:5000/api/show_to_pay?email=$email'
  static Uri show_to_pay(String email) {
    return Uri.parse('$baseUrl/api/show_to_pay').replace(queryParameters: {
      'email': email,
    });
  }

  static Uri show_completed(String email) {
    return Uri.parse('$baseUrl/api/show_completed').replace(queryParameters: {
      'email': email,
    });
  }

  //Uri.parse('http://YOUR_FLASK_SERVER_IP:PORT/get_feedback/$productId')
  static Uri get_feedback(String productId) {
    return Uri.parse('$baseUrl/api/get_feedback/$productId');
  }

}
