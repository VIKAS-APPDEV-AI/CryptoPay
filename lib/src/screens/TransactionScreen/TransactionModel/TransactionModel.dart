class Transaction {
  final int id;
  final String transactionId;
  final String transactionType;
  final double requestedAmount;
  final String requestedCurrency;
  final double convertedAmount;
  final String convertedCurrency;
  final String receivedCurrency;
  final String status;
  final int subStatus;
  final String customerRefId;
  final String note;
  final DateTime createDate;
  final String destinationAddress;
  final String ip;
  final DateTime responseTimestamp;

  Transaction({
    required this.id,
    required this.transactionId,
    required this.transactionType,
    required this.requestedAmount,
    required this.requestedCurrency,
    required this.convertedAmount,
    required this.convertedCurrency,
    required this.receivedCurrency,
    required this.status,
    required this.subStatus,
    required this.customerRefId,
    required this.note,
    required this.createDate,
    required this.destinationAddress,
    required this.ip,
    required this.responseTimestamp,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['Id'] as int? ?? 0,
      transactionId: json['transaction_id'] as String? ?? '',
      transactionType: json['transaction_type'] as String? ?? '',
      requestedAmount: (json['requestedamount'] as num?)?.toDouble() ?? 0.0,
      requestedCurrency: json['requestedcurrency'] as String? ?? '',
      convertedAmount: (json['convertedamount'] as num?)?.toDouble() ?? 0.0,
      convertedCurrency: json['convertedcurrency'] as String? ?? '',
      receivedCurrency: json['receivedcurrency'] as String? ?? '',
      status: json['status'] as String? ?? '',
      subStatus: json['substatus'] as int? ?? 0,
      customerRefId: json['customerrefid'] as String? ?? '',
      note: json['note'] as String? ?? '',
      createDate: DateTime.parse(json['createdate'] as String? ?? '1970-01-01T00:00:00Z'),
      destinationAddress: json['destinationaddress'] as String? ?? '',
      ip: json['ip'] as String? ?? '',
      responseTimestamp: DateTime.parse(json['response_timestamp'] as String? ?? '1970-01-01T00:00:00Z'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'transaction_id': transactionId,
      'transaction_type': transactionType,
      'requestedamount': requestedAmount,
      'requestedcurrency': requestedCurrency,
      'convertedamount': convertedAmount,
      'convertedcurrency': convertedCurrency,
      'receivedcurrency': receivedCurrency,
      'status': status,
      'substatus': subStatus,
      'customerrefid': customerRefId,
      'note': note,
      'createdate': createDate.toIso8601String(),
      'destinationaddress': destinationAddress,
      'ip': ip,
      'response_timestamp': responseTimestamp.toIso8601String(),
    };
  }
}