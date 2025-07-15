class CheckoutModel {
  final int invoiceId;
  final int clientId;
  final String name;
  final String email;
  final String description;
  final double requestedAmount;
  final String requestedCurrency;
  final String status;
  final String createdDate;
  final String ip;
  final String trackId;
  final String productName;
  final int invoiceType;
  final String? orderId;
  final String returnUrl;

  CheckoutModel({
    required this.invoiceId,
    required this.clientId,
    required this.name,
    required this.email,
    required this.description,
    required this.requestedAmount,
    required this.requestedCurrency,
    required this.status,
    required this.createdDate,
    required this.ip,
    required this.trackId,
    required this.productName,
    required this.invoiceType,
    this.orderId,
    required this.returnUrl,
  });

  factory CheckoutModel.fromJson(Map<String, dynamic> json) {
    return CheckoutModel(
      invoiceId: json['Invoice_id'] as int? ?? 0,
      clientId: json['client_id'] as int? ?? 0,
      name: json['name']?.toString() ?? 'Unknown',
      email: json['email']?.toString() ?? 'Unknown',
      description: json['description']?.toString() ?? '',
      requestedAmount: double.tryParse(json['requestedamount']?.toString() ?? '0') ?? 0.0,
      requestedCurrency: json['requestedcurrency']?.toString() ?? 'USD',
      status: json['status']?.toString() ?? 'Unknown',
      createdDate: json['createdate']?.toString() ?? '',
      ip: json['ip']?.toString() ?? '',
      trackId: json['trackid']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? 'Unknown',
      invoiceType: json['invoice_type'] as int? ?? 0,
      orderId: json['order_id']?.toString(),
      returnUrl: json['return_url']?.toString() ?? '',
    );
  }
}