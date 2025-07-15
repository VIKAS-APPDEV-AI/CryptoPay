class PayRequestModel {
  final String status;
  final String referenceId;
  final String payUrl;

  PayRequestModel({
    required this.status,
    required this.referenceId,
    required this.payUrl,
  });

  // Factory constructor to create a PayRequestModel from JSON
  factory PayRequestModel.fromJson(Map<String, dynamic> json) {
    return PayRequestModel(
      status: json['Status'] as String,
      referenceId: json['ReferanceID'] as String,
      payUrl: json['PayURL'] as String,
    );
  }

  // Method to convert a PayRequestModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'Status': status,
      'ReferanceID': referenceId,
      'PayURL': payUrl,
    };
  }
}