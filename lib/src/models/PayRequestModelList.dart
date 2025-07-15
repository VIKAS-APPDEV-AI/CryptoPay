class PayRequestModelList {
  int invoiceId;
  int clientId;
  String name;
  String email;
  String description;
  double requestedAmount;
  String requestedCurrency;
  String status;
  DateTime createDate;
  String ip;
  String trackid;
  String productName;
  int invoiceType;
  String returnUrl;

  PayRequestModelList({
    required this.invoiceId,
    required this.clientId,
    required this.name,
    required this.email,
    required this.description,
    required this.requestedAmount,
    required this.requestedCurrency,
    required this.status,
    required this.createDate,
    required this.ip,
    required this.trackid,
    required this.productName,
    required this.invoiceType,
    required this.returnUrl,
  });

  factory PayRequestModelList.fromJson(Map<String, dynamic> json) {
    print('Parsing PayRequest JSON: $json'); // Log JSON for debugging
    try {
      return PayRequestModelList(
        invoiceId: (json['Invoice_id'] as num?)?.toInt() ?? 0, // Handle null
        clientId: (json['client_id'] as num?)?.toInt() ?? 0, // Handle null
        name: json['name']?.toString() ?? '', // Handle null
        email: json['email']?.toString() ?? '', // Handle null
        description: json['description']?.toString() ?? '', // Handle null
        requestedAmount: (json['requestedamount'] as num?)?.toDouble() ?? 0.0, // Handle null
        requestedCurrency: json['requestedcurrency']?.toString() ?? '', // Handle null
        status: json['status']?.toString() ?? '', // Handle null
        createDate: DateTime.tryParse(json['createdate']?.toString() ?? '') ?? DateTime.now(), // Handle null/invalid date
        ip: json['ip']?.toString() ?? '', // Handle null
        trackid: json['trackid']?.toString() ?? '', // Handle null
        productName: json['product_name']?.toString() ?? '', // Handle null
        invoiceType: (json['invoice_type'] as num?)?.toInt() ?? 0, // Handle null
        returnUrl: json['return_url']?.toString() ?? '', // Handle null
      );
    } catch (e) {
      print('Error parsing JSON: $json, Error: $e');
      rethrow; // Rethrow for UI to catch
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Invoice_id': invoiceId,
      'client_id': clientId,
      'name': name,
      'email': email,
      'description': description,
      'requestedamount': requestedAmount,
      'requestedcurrency': requestedCurrency,
      'status': status,
      'createdate': createDate.toIso8601String(),
      'ip': ip,
      'trackid': trackid,
      'product_name': productName,
      'invoice_type': invoiceType,
      'return_url': returnUrl,
    };
  }
}