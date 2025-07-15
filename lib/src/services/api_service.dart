import 'dart:convert';
import 'package:crypto_pay/src/models/ChartDetailsModel.dart';
import 'package:crypto_pay/src/models/LoginModel.dart';
import 'package:crypto_pay/src/models/PayLinkListModel.dart';
import 'package:crypto_pay/src/models/PayRequestModel.dart';
import 'package:crypto_pay/src/models/PayRequestModelList.dart';
import 'package:crypto_pay/src/utils/AuthManager.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://cryptopay.oyefin.com/API/loginPost';
  static const String loggedHistoryUrl =
      'https://cryptopay.oyefin.com/API/LoggedHistory';
  static const String customerListUrl =
      'https://cryptopay.oyefin.com/API/AppCustomer';
  static const String createPayLinkUrl =
      'https://cryptopay.oyefin.com/API/AddPayLinks';
  static const String paymentLinkListUrl =
      'https://cryptopay.oyefin.com/API/PaymentLinkList';
  static const String createAppPayRequestUrl =
      'https://cryptopay.oyefin.com/API/AddAppPayRequest';
  static const String payRequestListUrl =
      'https://cryptopay.oyefin.com/API/PayRequestList';
  static const String transactionStatsUrl =
      'https://cryptopay.oyefin.com/API/TransactionStats';
  static const String checkoutsListUrl =
      'https://cryptopay.oyefin.com/API/CheckoutsList';

  Future<LoginResponseModel> login(String username, String password) async {
    try {
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'username': username,
          'password': password,
        },
      );

      final response =
          await http.post(uri).timeout(const Duration(seconds: 10));

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          return LoginResponseModel.fromJson(json);
        } catch (e) {
          throw Exception('Failed to parse response: $e');
        }
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      throw Exception('Error during login: $e');
    }
  }

  Future<http.Response> registerApp({
    required String fullName,
    required String emailId,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
      };

      final body = {
        'FullName': fullName,
        'EmailID': emailId,
      };

      final jsonBody = jsonEncode(body);
      print('App Registration Request Body: $jsonBody');

      final response = await http
          .post(
            Uri.parse('https://cryptopay.oyefin.com/API/AppRegistrationPost'),
            headers: headers,
            body: jsonBody,
          )
          .timeout(const Duration(seconds: 10));

      print('App Registration Response Status: ${response.statusCode}');
      print('App Registration Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception(
            'Failed to register app with status: ${response.statusCode}, response: ${response.body}');
      }
    } catch (e) {
      print('App Registration Error: $e');
      throw Exception('Error registering app: $e');
    }
  }

  static Future<http.Response> fetchLoginHistory() async {
    final userData = await AuthManager.getUserData();
    final merchantId = userData?['merchantId']?.toString() ?? '190';

    final headers = {
      'MerchantID': merchantId.toString(),
    };

    return await http.get(Uri.parse(loggedHistoryUrl), headers: headers);
  }

  Future<http.Response> fetchCustomerList({
    int limit = 100,
    String? dateFrom,
    String? dateTo,
  }) async {
    if (limit > 500) limit = 500;

    final userData = await AuthManager.getUserData();
    final merchantId = userData?['merchantId']?.toString() ?? '190';

    final queryParams = {
      'limit': limit.toString(),
      if (dateFrom != null) 'dateFrom': dateFrom,
      if (dateTo != null) 'dateTo': dateTo,
    };

    final uri =
        Uri.parse(customerListUrl).replace(queryParameters: queryParams);
    final headers = {
      'MerchantID': merchantId.toString(),
    };

    return await http.get(uri, headers: headers);
  }

  Future<http.Response> createPayLink({
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String productName,
    required String description,
    required String currency,
    required double amount,
  }) async {
    try {
      final userData = await AuthManager.getUserData();
      final merchantId = userData?['merchantId']?.toString() ?? '190';

      final headers = {
        'MerchantID': merchantId.toString(),
        'Content-Type': 'application/json',
      };

      final body = {
        'OrderID': orderId,
        'CustomerName': customerName,
        'CustomerEmail': customerEmail,
        'ProductName': productName,
        'Description': description,
        'Currency': currency,
        'Amount': amount,
      };

      final jsonBody = jsonEncode(body);
      print('Create Pay Link Request Body: $jsonBody');

      final response = await http
          .post(
            Uri.parse(createPayLinkUrl),
            headers: headers,
            body: jsonBody,
          )
          .timeout(const Duration(seconds: 10));

      print('Create Pay Link Response Status: ${response.statusCode}');
      print('Create Pay Link Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception(
            'Failed to create pay link with status: ${response.statusCode}, response: ${response.body}');
      }
    } catch (e) {
      print('Create Pay Link Error: $e');
      throw Exception('Error creating pay link: $e');
    }
  }

  Future<List<PayLinkListModel>> fetchPaymentLinkList({
    int limit = 100,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      if (limit > 500) limit = 500;

      final userData = await AuthManager.getUserData();
      final merchantId = userData?['merchantId']?.toString() ?? '190';

      final queryParams = {
        'limit': limit.toString(),
        if (dateFrom != null) 'dateFrom': dateFrom,
        if (dateTo != null) 'dateTo': dateTo,
      };

      final uri =
          Uri.parse(paymentLinkListUrl).replace(queryParameters: queryParams);
      final headers = {
        'MerchantID': merchantId.toString(),
      };

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      print('Payment Link List Response Status: ${response.statusCode}');
      print('Payment Link List Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final json = jsonDecode(response.body);
          if (json is List) {
            return json
                .map((item) =>
                    PayLinkListModel.fromJson(item as Map<String, dynamic>))
                .toList();
          } else {
            throw Exception('Unexpected response format: Expected a list');
          }
        } catch (e) {
          throw Exception('Failed to parse payment link list: $e');
        }
      } else {
        throw Exception(
            'Failed to fetch payment link list with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Payment Link List Error: $e');
      throw Exception('Error fetching payment link list: $e');
    }
  }

  Future<List<PayRequestModelList>> fetchPayRequestList({
    int limit = 100,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      if (limit > 500) limit = 500;

      final userData = await AuthManager.getUserData();
      final merchantId = userData?['merchantId']?.toString() ?? '190';

      final queryParams = {
        'limit': limit.toString(),
        if (dateFrom != null) 'dateFrom': dateFrom,
        if (dateTo != null) 'dateTo': dateTo,
      };

      final uri =
          Uri.parse(payRequestListUrl).replace(queryParameters: queryParams);
      final headers = {
        'MerchantID': merchantId.toString(),
      };

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      print('Pay Request List Response Status: ${response.statusCode}');
      print('Pay Request List Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final json = jsonDecode(response.body);
          if (json is List) {
            return json
                .map((item) =>
                    PayRequestModelList.fromJson(item as Map<String, dynamic>))
                .toList();
          } else {
            throw Exception('Unexpected response format: Expected a list');
          }
        } catch (e) {
          throw Exception('Failed to parse pay request list: $e');
        }
      } else {
        throw Exception(
            'Failed to fetch pay request list with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Pay Request List Error: $e');
      throw Exception('Error fetching pay request list: $e');
    }
  }

  Future<PayRequestModel> createAppPayRequest({
    required String customerName,
    required String customerEmail,
    required String description,
    required String currency,
    required double amount,
  }) async {
    try {
      final userData = await AuthManager.getUserData();
      final merchantId = userData?['merchantId']?.toString() ?? '190';

      final headers = {
        'MerchantID': merchantId.toString(),
        'Content-Type': 'application/json',
      };

      final body = {
        'CustomerName': customerName,
        'CustomerEmail': customerEmail,
        'Description': description,
        'Currency': currency,
        'Amount': amount,
      };

      final jsonBody = jsonEncode(body);
      print('Create App Pay Request Body: $jsonBody');

      final response = await http
          .post(
            Uri.parse(createAppPayRequestUrl),
            headers: headers,
            body: jsonBody,
          )
          .timeout(const Duration(seconds: 10));

      print('Create App Pay Request Response Status: ${response.statusCode}');
      print('Create App Pay Request Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          return PayRequestModel.fromJson(json);
        } catch (e) {
          throw Exception('Failed to parse response: $e');
        }
      } else {
        throw Exception(
            'Failed to create app pay request with status: ${response.statusCode}, response: ${response.body}');
      }
    } catch (e) {
      print('Create App Pay Request Error: $e');
      throw Exception('Error creating app pay request: $e');
    }
  }

  Future<ChartStatus> fetchTransactionStats() async {
    try {
      final userData = await AuthManager.getUserData();
      final merchantId = userData?['merchantId']?.toString() ?? '190';

      final headers = {
        'MerchantID': merchantId.toString(),
      };

      final response = await http
          .get(Uri.parse(transactionStatsUrl), headers: headers)
          .timeout(const Duration(seconds: 10));

      print('Transaction Stats Response Status: ${response.statusCode}');
      print('Transaction Stats Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          return ChartStatus.fromJson(json);
        } catch (e) {
          throw Exception('Failed to parse transaction stats: $e');
        }
      } else {
        throw Exception(
            'Failed to fetch transaction stats with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Transaction Stats Error: $e');
      throw Exception('Error fetching transaction stats: $e');
    }
  }
   Future<http.Response> fetchCheckoutsList({
    int limit = 100,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      if (limit > 500) limit = 500;

      final userData = await AuthManager.getUserData();
      final merchantId = userData?['merchantId']?.toString() ?? '190';

      final queryParams = {
        'limit': limit.toString(),
        if (dateFrom != null) 'dateFrom': dateFrom,
        if (dateTo != null) 'dateTo': dateTo,
      };

      final uri = Uri.parse(checkoutsListUrl).replace(queryParameters: queryParams);
      final headers = {
        'MerchantID': merchantId.toString(),
      };

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      print('Checkouts List Response Status: ${response.statusCode}');
      print('Checkouts List Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Failed to fetch checkouts list with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Checkouts List Error: $e');
      throw Exception('Error fetching checkouts list: $e');
    }
  }
}
