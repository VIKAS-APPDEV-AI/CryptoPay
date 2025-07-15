import 'package:crypto_pay/src/screens/TransactionScreen/TransactionModel/TransactionModel.dart';
import 'package:crypto_pay/src/utils/AuthManager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TransactionApiService {
  static const String baseUrl = 'https://cryptopay.oyefin.com/API/TransactionList';
  final AuthManager authManager;

  TransactionApiService({required this.authManager});

  Future<List<Transaction>> fetchTransactions({
    int? limit, // Make limit optional
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      // Check if authenticated and get merchant ID
      final isAuthenticated = await AuthManager.isAuthenticated();
      if (!isAuthenticated) {
        throw Exception('User not authenticated. Please log in.');
      }

      final userData = await AuthManager.getUserData();
      final merchantId = userData?['merchantId'] as int? ?? 0;
      if (merchantId == 0) {
        throw Exception('Invalid Merchant ID.');
      }

      // Build query parameters
      final queryParams = <String, String>{};
      if (limit != null) {
        queryParams['Limit'] = limit.toString();
      }
      if (dateFrom != null) {
        queryParams['DateFrom'] = dateFrom;
      }
      if (dateTo != null) {
        queryParams['DateTo'] = dateTo;
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'MerchantID': merchantId.toString(),
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Transaction.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }
}