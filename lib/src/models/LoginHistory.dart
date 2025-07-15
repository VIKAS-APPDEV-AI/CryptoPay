class LoginHistoryModel {
  final int tokenId;
  final int clientId;
  final String loginTime;
  final String loginIp;
  final int loginType;

  LoginHistoryModel({
    required this.tokenId,
    required this.clientId,
    required this.loginTime,
    required this.loginIp,
    required this.loginType,
  });

  factory LoginHistoryModel.fromMap(Map<String, dynamic> map) {
    return LoginHistoryModel(
      tokenId: map['Token_id'],
      clientId: map['client_id'],
      loginTime: map['login_time'],
      loginIp: map['login_ip'],
      loginType: map['login_type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Token_id': tokenId,
      'client_id': clientId,
      'login_time': loginTime,
      'login_ip': loginIp,
      'login_type': loginType,
    };
  }
}