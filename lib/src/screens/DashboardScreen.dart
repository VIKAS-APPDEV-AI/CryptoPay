import 'dart:convert';
import 'package:crypto_pay/src/models/ChartDetailsModel.dart';
import 'package:crypto_pay/src/screens/TransactionScreen/DashboardTransactionsAll.dart';
import 'package:crypto_pay/src/screens/TransactionScreen/TransactionScreen.dart';
import 'package:crypto_pay/src/services/api_service.dart';
import 'package:crypto_pay/src/utils/AuthManager.dart';
import 'package:crypto_pay/src/utils/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:http/http.dart' as http;
import 'package:crypto_pay/src/screens/TransactionScreen/TransactionModel/TransactionModel.dart';
import 'package:crypto_pay/src/services/Transaction_api.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> cryptoData = [];
  List<Transaction> transactions = [];
  ChartStatus? chartStatus;
  final ApiService _apiService = ApiService();
  bool isLoading = true;
  String? errorMessage;
  final TransactionApiService apiService =
      TransactionApiService(authManager: AuthManager());
  double btcToUsdRate = 0.0;
  bool isFetchingRate = false;
  TextEditingController btcController = TextEditingController();
  TextEditingController usdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchBtcToUsdRate();
    btcController.addListener(_onBtcChanged);
    usdController.addListener(_onUsdChanged);
  }

  @override
  void dispose() {
    btcController.dispose();
    usdController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    const int maxRetries = 3;
    int retries = 0;
    while (retries < maxRetries) {
      try {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
        await Future.wait([
          fetchCryptoBalances(),
          fetchTransactions(),
          fetchChartStats(),
        ]);
        setState(() {
          isLoading = false;
        });
        return;
      } catch (e) {
        retries++;
        if (retries == maxRetries) {
          setState(() {
            isLoading = false;
            errorMessage =
                'Failed to fetch data after $maxRetries attempts: $e';
          });
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  Future<void> fetchChartStats() async {
    try {
      final stats = await _apiService.fetchTransactionStats();
      debugPrint('Fetched Chart Stats: ${stats.toJson()}');
      setState(() {
        chartStatus = stats;
      });
    } catch (e) {
      debugPrint('Error fetching chart stats: $e');
      throw Exception('Error fetching chart stats: $e');
    }
  }

  Future<void> fetchCryptoBalances({String? currency}) async {
    try {
      final isAuthenticated = await AuthManager.isAuthenticated();
      if (!isAuthenticated) {
        throw Exception('User not authenticated. Please log in.');
      }

      final userData = await AuthManager.getUserData();
      if (userData == null ||
          userData['merchantId'] == null ||
          userData['merchantId'] == 0) {
        throw Exception('Invalid Merchant ID. Please log in again.');
      }

      final merchantId = userData['merchantId'].toString();
      debugPrint('MerchantID: $merchantId');

      final queryParams = {
        if (currency != null && currency.isNotEmpty) 'Currency': currency,
      };
      debugPrint('Query Parameters: $queryParams');

      final uri =
          Uri.parse('https://cryptopay.oyefin.com/API/CryptoBalanceList')
              .replace(queryParameters: queryParams);
      debugPrint('API URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'MerchantID': merchantId,
        },
      );

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          cryptoData = data.map((item) {
            final name = item['Receivedcurrency']?.toString() ?? 'Unknown';
            final balance = item['Balance']?.toString() ?? '0.00';
            final amount =
                '${double.tryParse(balance)?.toStringAsFixed(6) ?? '0.00'} $name';
            final svgAsset = _getSvgAssetForCrypto(name.toLowerCase());
            final fullName = _getFullCryptoName(name.toUpperCase());

            return {
              'svgAsset': svgAsset,
              'name': fullName,
              'amount': amount,
            };
          }).toList();
        });
      } else {
        throw Exception(
            'Failed to load crypto data: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching crypto data: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Error fetching crypto data: $e');
    }
  }

  Future<void> fetchTransactions() async {
    try {
      final fetchedTransactions =
          await apiService.fetchTransactions(limit: 100);
      debugPrint('Fetched ${fetchedTransactions.length} transactions');
      setState(() {
        transactions = fetchedTransactions;
      });
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      throw Exception('Error fetching transactions: $e');
    }
  }

  Future<void> fetchBtcToUsdRate() async {
    try {
      setState(() {
        isFetchingRate = true;
      });
      final response = await http.get(
        Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rate = data['bitcoin']['usd'].toDouble();
        setState(() {
          btcToUsdRate = rate;
          isFetchingRate = false;
        });
        debugPrint('Fetched BTC to USD rate: $btcToUsdRate');
      } else {
        throw Exception('Failed to fetch BTC to USD rate: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching BTC to USD rate: $e');
      setState(() {
        isFetchingRate = false;
      });
      throw Exception('Error fetching BTC to USD rate: $e');
    }
  }

  void _onBtcChanged() {
    if (btcController.text.isEmpty) {
      usdController.text = '';
      return;
    }
    final btcAmount = double.tryParse(btcController.text);
    if (btcAmount != null && btcToUsdRate > 0) {
      final usdAmount = btcAmount * btcToUsdRate;
      usdController.text = usdAmount.toStringAsFixed(2);
    }
  }

  void _onUsdChanged() {
    if (usdController.text.isEmpty) {
      btcController.text = '';
      return;
    }
    final usdAmount = double.tryParse(usdController.text);
    if (usdAmount != null && btcToUsdRate > 0) {
      final btcAmount = usdAmount / btcToUsdRate;
      btcController.text = btcAmount.toStringAsFixed(8);
    }
  }

  String _getSvgAssetForCrypto(String name) {
    const String basePath = 'assets/Svg/';
    switch (name) {
      case 'ada':
        return '${basePath}cardano.svg';
      case 'btc':
        return '${basePath}bitcoin.svg';
      case 'dash':
        return '${basePath}dash.svg';
      case 'doge':
        return '${basePath}dogecoin.svg';
      case 'eth':
        return '${basePath}ethereum.svg';
      case 'ltc':
        return '${basePath}litecoin.svg';
      case 'usdt':
        return '${basePath}tether.svg';
      case 'matic':
        return '${basePath}polygon.svg';
      case 'arb':
        return '${basePath}arbitrum.svg';
      case 'bnb':
        return '${basePath}binance.svg';
      default:
        return '${basePath}default.svg';
    }
  }

  String _getFullCryptoName(String code) {
    final Map<String, String> cryptoMap = {
      'ada': 'Cardano',
      'btc': 'Bitcoin',
      'dash': 'Dash',
      'doge': 'Dogecoin',
      'eth': 'Ethereum',
      'ltc': 'Litecoin',
      'usdt': 'Tether',
      'matic': 'Polygon',
      'arb': 'Arbitrum',
      'bnb': 'Binance Coin',
    };
    return cryptoMap[code.toLowerCase()] ?? code.toUpperCase();
  }

  String formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  double calculateChartRadius(BuildContext context, double totalTransactions) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double baseRadius = 100.0;
    const double scaleFactor = 0.3;
    const double minRadius = 80.0;
    const double maxRadius = 150.0;

    double radius = screenWidth * scaleFactor;
    if (totalTransactions > 50) {
      radius *= 1.2;
    }
    return radius.clamp(minRadius, maxRadius);
  }

  // Helper method to build input field for Coin Converter
  Widget _buildInputField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String hintText,
    required double labelFontSize,
    required double hintFontSize,
    double? width,
  }) {
    return Container(
      width: width,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: labelFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(fontSize: hintFontSize, color: AppColors.kthirdColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Responsive Coin Converter section
  Widget buildCoinConverterSection(BuildContext context) {
    // Get screen size for responsive scaling
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Dynamic font sizes and padding based on screen width
    final titleFontSize = screenWidth < 360 ? 16.0 : 18.0;
    final labelFontSize = screenWidth < 360 ? 18.0 : 20.0;
    final hintFontSize = screenWidth < 360 ? 14.0 : 16.0;
    final rateFontSize = screenWidth < 360 ? 12.0 : 14.0;
    final paddingValue = screenWidth < 360 ? 12.0 : 16.0;
    final spacing = screenWidth < 360 ? 8.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenHeight * 0.04), // Responsive height
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Coin Converter',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.015),
        Container(
          padding: EdgeInsets.all(paddingValue),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Input fields row
              LayoutBuilder(
                builder: (context, constraints) {
                  // Determine if we need to stack inputs vertically on very small screens
                  final isSmallScreen = screenWidth < 360;
                  return isSmallScreen
                      ? Column(
                          children: [
                            _buildInputField(
                              context,
                              label: 'BTC',
                              controller: btcController,
                              hintText: '1.0',
                              labelFontSize: labelFontSize,
                              hintFontSize: hintFontSize,
                              width: constraints.maxWidth,
                            ),
                            SizedBox(height: spacing),
                            const Text(
                              '=',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: spacing),
                            _buildInputField(
                              context,
                              label: 'USD',
                              controller: usdController,
                              hintText: '\$${btcToUsdRate.toStringAsFixed(2)}',
                              labelFontSize: labelFontSize,
                              hintFontSize: hintFontSize,
                              width: constraints.maxWidth,
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _buildInputField(
                                context,
                                label: 'BTC',
                                controller: btcController,
                                hintText: '1.0',
                                labelFontSize: labelFontSize,
                                hintFontSize: hintFontSize,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: spacing),
                              child: const Text(
                                '=',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _buildInputField(
                                context,
                                label: 'USD',
                                controller: usdController,
                                hintText: '\$${btcToUsdRate.toStringAsFixed(2)}',
                                labelFontSize: labelFontSize,
                                hintFontSize: hintFontSize,
                              ),
                            ),
                          ],
                        );
                },
              ),
              SizedBox(height: spacing),
              // Rate and Last Updated row
              LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = screenWidth < 400;
                  return isSmallScreen
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('Rate:'),
                                SizedBox(width: 5),
                                isFetchingRate
                                    ? const SpinKitThreeBounce(
                                        color: AppColors.kprimary,
                                        size: 16,
                                      )
                                    : Text(
                                        '1 BTC = \$${btcToUsdRate.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: AppColors.kprimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: rateFontSize,
                                        ),
                                      ),
                              ],
                            ),
                            SizedBox(height: spacing / 2),
                            Row(
                              children: [
                                const Text('Last Updated: '),
                                SizedBox(width: 4),
                                Text(
                                  DateTime.now().toString().substring(0, 10),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: rateFontSize - 2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text('Rate: '),
                                SizedBox(width: 5),
                                isFetchingRate
                                    ? const SpinKitThreeBounce(
                                        color: AppColors.kprimary,
                                        size: 16,
                                      )
                                    : Text(
                                        '1 BTC = \$${btcToUsdRate.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: AppColors.kprimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: rateFontSize,
                                        ),
                                      ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text('Last Updated: '),
                                SizedBox(width: 4),
                                Text(
                                  DateTime.now().toString().substring(0, 10),
                                  style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: rateFontSize - 2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, double> pieChartData = chartStatus != null
        ? {
            'Success': chartStatus!.totalSuccess.toDouble(),
            'Failed': chartStatus!.totalFailed.toDouble(),
            'Processing': chartStatus!.totalProcess.toDouble(),
          }
        : {};

    final Map<String, Color> statusColors = {
      'Success': AppColors.ksuccess,
      'Processing': AppColors.kprimary,
      'Failed': Colors.red,
    };

    final colorList = pieChartData.keys
        .map((status) => statusColors[status] ?? Colors.grey)
        .toList();

    final double totalTransactions =
        pieChartData.values.fold(0, (sum, value) => sum + value);

    return Scaffold(
      body: isLoading
          ? const Center(
              child: SpinKitDoubleBounce(color: AppColors.kprimary, size: 60))
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage!),
                      if (errorMessage!.contains('authenticated') ||
                          errorMessage!.contains('Merchant ID'))
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text('Go to Login'),
                        ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await fetchData();
                    await fetchBtcToUsdRate();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 110,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: cryptoData.length,
                              itemBuilder: (context, index) {
                                final crypto = cryptoData[index];
                                return Container(
                                  width: 230,
                                  margin: const EdgeInsets.only(right: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 247, 230, 194),
                                        AppColors.kwhite
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  crypto['svgAsset'] as String,
                                                  width: 30,
                                                  height: 30,
                                                ),
                                                const SizedBox(width: 15),
                                                Text(
                                                  '${crypto['name'].toUpperCase()}',
                                                  style: const TextStyle(
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 15),
                                            Text(
                                              '${crypto['amount'].toUpperCase()}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          buildCoinConverterSection(context),
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Transaction Activities: Total - ${totalTransactions.toInt()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 200,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 1,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: pieChartData.isEmpty ||
                                          totalTransactions == 0
                                      ? const Center(
                                          child:
                                              Text('No transactions available'))
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: PieChart(
                                                dataMap: pieChartData,
                                                colorList: colorList,
                                                chartType: ChartType.ring,
                                                chartRadius:
                                                    calculateChartRadius(
                                                        context,
                                                        totalTransactions),
                                                ringStrokeWidth: 38,
                                                legendOptions:
                                                    const LegendOptions(
                                                  showLegends: false,
                                                  legendPosition:
                                                      LegendPosition.right,
                                                  legendTextStyle:
                                                      TextStyle(fontSize: 14),
                                                  showLegendsInRow: false,
                                                ),
                                                chartValuesOptions:
                                                    const ChartValuesOptions(
                                                  showChartValues: false,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              flex: 2,
                                              child: Center(
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount:
                                                      pieChartData.entries.length,
                                                  itemBuilder: (context, index) {
                                                    final entry = pieChartData
                                                        .entries
                                                        .toList()[index];
                                                    final status = entry.key;
                                                    final count =
                                                        entry.value.toInt();
                                                    final color = statusColors[
                                                            status] ??
                                                        Colors.grey;
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            width: 12,
                                                            height: 12,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: color,
                                                              shape:
                                                                  BoxShape.circle,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Text(
                                                            '$status: $count',
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight.w500,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recent Transactions',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) =>
                                          const DashboardTransactionScreenAll(),
                                    ),
                                  );
                                },
                                child: const Text('View All >',
                                    style: TextStyle(color: Colors.blue)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: transactions.take(4).map((transaction) {
                                  Color statusColor;
                                  IconData statusIcon;
                                  switch (transaction.status.toLowerCase()) {
                                    case 'declined':
                                      statusColor = Colors.red;
                                      statusIcon = Icons.close;
                                      break;
                                    case 'success':
                                      statusColor = Colors.green;
                                      statusIcon = Icons.check_circle;
                                      break;
                                    case 'waiting':
                                      statusColor = Colors.orange;
                                      statusIcon = Icons.access_time;
                                      break;
                                    default:
                                      statusColor = Colors.grey;
                                      statusIcon = Icons.help;
                                  }

                                  return Container(
                                    margin:
                                        const EdgeInsets.symmetric(horizontal: 8),
                                    width: 300,
                                    child: Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                      color: Colors.white,
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.all(12),
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              statusColor.withOpacity(0.1),
                                          child: Icon(statusIcon,
                                              color: statusColor, size: 20),
                                        ),
                                        title: Text(
                                          transaction.transactionId,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Text(
                                              '${transaction.requestedAmount} ${transaction.requestedCurrency} → ${transaction.convertedAmount} ${transaction.convertedCurrency}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600]),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              formatDate(transaction.createDate),
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey[500]),
                                            ),
                                          ],
                                        ),
                                        trailing: Container(
                                            padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            transaction.status,
                                            style: TextStyle(
                                            color: statusColor, fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}