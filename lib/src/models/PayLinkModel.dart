class PayLinkResponseModel {
  final String status;
  final String referenceId;
  final String payUrl;

  PayLinkResponseModel({
    required this.status,
    required this.referenceId,
    required this.payUrl,
  });

  factory PayLinkResponseModel.fromJson(Map<String, dynamic> json) {
    return PayLinkResponseModel(
      status: json['Status'] as String,
      referenceId: json['ReferanceID'] as String,
      payUrl: json['PayURL'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Status': status,
      'ReferanceID': referenceId,
      'PayURL': payUrl,
    };
  }
}