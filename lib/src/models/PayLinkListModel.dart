class PayLinkListModel {
  final int invoiceId;
  final int clientId;
  final String name;
  final String email;
  final String description;
  final double requestedamount;
  final String requestedcurrency;
  final String status;
  final String createdate;
  final String ip;
  final String trackid;
  final String productName;
  final int invoiceType;
  final String orderId;
  final String? returnUrl; // Nullable since it can be empty

  PayLinkListModel({
    required this.invoiceId,
    required this.clientId,
    required this.name,
    required this.email,
    required this.description,
    required this.requestedamount,
    required this.requestedcurrency,
    required this.status,
    required this.createdate,
    required this.ip,
    required this.trackid,
    required this.productName,
    required this.invoiceType,
    required this.orderId,
    this.returnUrl,
  });

  factory PayLinkListModel.fromJson(Map<String, dynamic> json) {
    return PayLinkListModel(
      invoiceId: json['Invoice_id'] as int? ?? 0,
      clientId: json['client_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      description: json['description'] as String? ?? '',
      requestedamount: (json['requestedamount'] as num?)?.toDouble() ?? 0.0,
      requestedcurrency: json['requestedcurrency'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdate: json['createdate'] as String? ?? '',
      ip: json['ip'] as String? ?? '',
      trackid: json['trackid'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      invoiceType: json['invoice_type'] as int? ?? 0,
      orderId: json['order_id'] as String? ?? '',
      returnUrl: json['return_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Invoice_id': invoiceId,
      'client_id': clientId,
      'name': name,
      'email': email,
      'description': description,
      'requestedamount': requestedamount,
      'requestedcurrency': requestedcurrency,
      'status': status,
      'createdate': createdate,
      'ip': ip,
      'trackid': trackid,
      'product_name': productName,
      'invoice_type': invoiceType,
      'order_id': orderId,
      'return_url': returnUrl,
    };
  }
}