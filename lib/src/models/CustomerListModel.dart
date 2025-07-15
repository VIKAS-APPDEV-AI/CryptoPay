class CustomerListModel {
  final String customerName;
  final String customerEmail;
  final String totalCustomer;

  CustomerListModel({
    required this.customerName,
    required this.customerEmail,
    required this.totalCustomer,
  });

  factory CustomerListModel.fromJson(Map<String, dynamic> json) {
    return CustomerListModel(
      customerName: json['customer_name'],
      customerEmail: json['customer_email'],
      totalCustomer: json['total_customer'],
    );
  }
}
