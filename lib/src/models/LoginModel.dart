class LoginResponseModel {
  final bool isSuccess;
  final String? merchantName;
  final String? merchantEmail;
  final int? merchantId;
  final String? merchantLoginIp;
  final String? error;

  LoginResponseModel({
    required this.isSuccess,
    this.merchantName,
    this.merchantEmail,
    this.merchantId,
    this.merchantLoginIp,
    this.error,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      isSuccess: json['Status'] == 'Ok',
      merchantName: json['MerchantName'],
      merchantEmail: json['MerchantEmail'],
      merchantId: json['MerchantID'],
      merchantLoginIp: json['MerchantLoginIP'],
      error: json['Status'] != 'Ok' ? 'Login failed' : null,
    );
  }

  @override
  String toString() {
    return 'LoginResponseModel(isSuccess: $isSuccess, merchantName: $merchantName, merchantEmail: $merchantEmail, merchantId: $merchantId, merchantLoginIp: $merchantLoginIp, error: $error)';
  }
}