


class Product {
  final String name;
  final String brand;
  final double price;
  final String prDesc;
  final int qty;
  final String size;
  final String color;
  final String? imageUrl;
  final String prType;
  final String id;
  final String email;
  final int sellerID;

  //CART
  int cartQuantity;
  double totalPrice;
  double orderTotal;

  Product({
    required this.name,
    required this.brand,
    required this.price,
    required this.prDesc,
    required this.qty,
    required this.size,
    required this.color,
    this.imageUrl,
    required this.prType,
    required this.id,
    required this.email,
    required this.sellerID,
    this.cartQuantity = 1,
    this.totalPrice = 0.0,
    this.orderTotal = 0.0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String rawPrice = json['prPrice'].toString().replaceAll(',', '');
    // var feedbacksList = (json['feedbacks'] as List)
    //     .map((feedbackJson) => Feedback.fromJson(feedbackJson))
    //     .toList();

    //for api fields
    return Product(
      id: json['productID'].toString(),
      name: json['prName'],
      brand: json['brand']?.toString() ?? 'N/A',
      price: double.parse(rawPrice),
      prDesc: json['prDesc']?.toString() ?? 'N/A',
      qty: int.tryParse(json['qty']?.toString() ?? '') ?? 0,
      size: json['size'] ?? '',
      color: json['color'] ?? '',
      imageUrl: json['image_paths'] ?? '',
      prType: json['prType'] ?? '',
      email: json['email'] ?? '',
      sellerID: int.tryParse(json['sellerID']?.toString() ?? '') ?? 0,
      //feedbacks: feedbacksList,

      // Cart-specific data
      cartQuantity: int.tryParse(json['quantity']?.toString() ?? '') ?? 1,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      orderTotal: double.tryParse(json['order_total']?.toString() ?? '0') ?? 0.0,
    );
  }
}


class ProductFeedback {
  final String user_id;
  final String feedback;

  ProductFeedback({
    required this.user_id,
    required this.feedback,
  });

  factory ProductFeedback.fromJson(Map<String, dynamic> json) {
    return ProductFeedback(
      user_id: json['user_id'],
      feedback: json['feedback'],
    );
  }
}

