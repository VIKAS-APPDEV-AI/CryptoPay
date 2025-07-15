class ChartStatus {
  int totalTransactions;
  int totalSuccess;
  int totalFailed;
  int totalProcess;

  ChartStatus({
    required this.totalTransactions,
    required this.totalSuccess,
    required this.totalFailed,
    required this.totalProcess,
  });

  // Factory method to create instance from JSON
  factory ChartStatus.fromJson(Map<String, dynamic> json) {
    return ChartStatus(
      totalTransactions: json['Total_transactions'] as int,
      totalSuccess: json['Total_success'] as int,
      totalFailed: json['Total_failed'] as int,
      totalProcess: json['Total_process'] as int,
    );
  }

  // Method to convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'Total_transactions': totalTransactions,
      'Total_success': totalSuccess,
      'Total_failed': totalFailed,
      'Total_process': totalProcess,
    };
  }
}