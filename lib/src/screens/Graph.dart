import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:crypto_pay/src/screens/TransactionScreen/TransactionModel/TransactionModel.dart';
import 'package:crypto_pay/src/services/Transaction_api.dart';

class Graph extends StatefulWidget {
  final TransactionApiService apiService;

  const Graph({super.key, required this.apiService});

  @override
  _GraphState createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  List<Transaction> transactions = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    const int maxRetries = 3;
    int retries = 0;
    while (retries < maxRetries) {
      try {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
        final fetchedTransactions =
            await widget.apiService.fetchTransactions(limit: 337);
        setState(() {
          transactions = fetchedTransactions;
          isLoading = false;
        });
        return;
      } catch (e) {
        retries++;
        if (retries == maxRetries) {
          setState(() {
            isLoading = false;
            errorMessage =
                'Failed to fetch transactions after $maxRetries attempts: $e';
          });
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  double calculateChartRadius(BuildContext context, double totalTransactions) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double baseRadius = 100.0;
    const double scaleFactor = 0.3; // 30% of screen width
    const double minRadius = 80.0;
    const double maxRadius = 150.0;

    double radius = screenWidth * scaleFactor;
    if (totalTransactions > 50) {
      radius *= 1.2; // Increase radius for large datasets
    }
    return radius.clamp(minRadius, maxRadius);
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic status calculation
    final Map<String, double> pieChartData = {};
    for (var transaction in transactions) {
      final status = transaction.status.toLowerCase();
      pieChartData[status] = (pieChartData[status] ?? 0) + 1;
    }

    // Fallback mocked data if no transactions are fetched
    if (pieChartData.isEmpty) {
      pieChartData.addAll({
        'Success': 202.0, // 60% of 337
        'Waiting': 101.0, // 30% of 337
        'Declined': 34.0, // 10% of 337
      });
    }

    final Map<String, Color> statusColors = {
      'completed': Colors.green,
      'waiting': Colors.orange,
      'declined': Colors.red,
    };

    final colorList = pieChartData.keys
        .map((status) => statusColors[status] ?? Colors.grey)
        .toList();

    final double totalTransactions =
        pieChartData.values.fold(0, (sum, value) => sum + value);

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : errorMessage != null
            ? Center(child: Text(errorMessage!))
            : SizedBox(
                height: 150,
                child: Container(
                  padding: const EdgeInsets.all(0),
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
                  child: pieChartData.isEmpty || totalTransactions == 0
                      ? const Center(child: Text('No transactions available'))
                      : PieChart(
                          dataMap: pieChartData,
                          colorList: colorList,
                          chartType: ChartType.ring,
                          chartRadius:calculateChartRadius(context, totalTransactions),
                          ringStrokeWidth: 32,
                          legendOptions: const LegendOptions(
                            showLegends: true,
                            legendPosition: LegendPosition.right,
                            legendTextStyle: TextStyle(fontSize: 14),
                            showLegendsInRow: false,
                          ),
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValues: false,
                          ),
                        ),
                ),
              );
  }
}
