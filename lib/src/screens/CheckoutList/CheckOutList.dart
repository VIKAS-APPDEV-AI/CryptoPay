import 'dart:convert';
import 'package:crypto_pay/src/services/api_service.dart';
import 'package:crypto_pay/src/utils/Constants.dart';
import 'package:crypto_pay/src/models/CheckoutModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckoutListPage extends StatefulWidget {
  const CheckoutListPage({Key? key}) : super(key: key);

  @override
  _CheckoutListPageState createState() => _CheckoutListPageState();
}

class _CheckoutListPageState extends State<CheckoutListPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<CheckoutModel> _allCheckouts = [];
  List<CheckoutModel> _filteredCheckouts = [];
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCheckouts);
    _fetchCheckouts();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  Future<void> _fetchCheckouts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.fetchCheckoutsList();
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is List) {
          setState(() {
            _allCheckouts = json
                .map((item) =>
                    CheckoutModel.fromJson(item as Map<String, dynamic>))
                .toList();
            _filteredCheckouts = _allCheckouts;
            _isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format: Expected a list');
        }
      } else {
        throw Exception('Failed to fetch checkouts');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching checkouts: $e';
      });
    }
  }

  void _filterCheckouts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCheckouts = _allCheckouts
          .where((checkout) =>
              checkout.name.toLowerCase().contains(query) ||
              checkout.invoiceId.toString().toLowerCase().contains(query) ||
              checkout.productName.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kthirdColor.withOpacity(0.1),
      appBar: AppBar(
        title: const Text('Checkout List',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.kbackground)),
        backgroundColor: AppColors.kprimary,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.kprimary, AppColors.kthirdColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCheckouts,
        color: AppColors.kprimary,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16.0),
              Expanded(
                child: _isLoading
                    ? _buildLoadingIndicator()
                    : _errorMessage != null
                        ? _buildErrorWidget()
                        : _filteredCheckouts.isEmpty
                            ? _buildEmptyState()
                            : _buildCheckoutList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by customer, ID, or product...',
        prefixIcon: const Icon(Icons.search, color: AppColors.kprimary),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.kprimary),
                onPressed: () {
                  _searchController.clear();
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: AppColors.kthirdColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: AppColors.kprimary, width: 2),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.kprimary),
      ),
    );
  }

  Widget _buildErrorWidget(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.kprimary, size: 48),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An error occurred',
            style: TextStyle(color: AppColors.kthirdColor, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchCheckouts,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kprimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, color: AppColors.kthirdColor, size: 48),
          const SizedBox(height: 16),
          Text(
            'No checkouts found',
            style: TextStyle(color: AppColors.kthirdColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutList() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return ListView.builder(
          itemCount: _filteredCheckouts.length,
          itemBuilder: (context, index) {
            final checkout = _filteredCheckouts[index];
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        AppColors.kthirdColor.withOpacity(0.1)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.kprimary.withOpacity(0.1),
                      child: Icon(
                        Icons.payment,
                        color: AppColors.kprimary,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      checkout.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.kthirdColor,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Invoice ID: ${checkout.invoiceId}',
                          style: TextStyle(
                              color: AppColors.kthirdColor.withOpacity(0.7)),
                        ),
                        Text(
                          'Product: ${checkout.productName}',
                          style: TextStyle(
                              color: AppColors.kthirdColor.withOpacity(0.7)),
                        ),
                        Text(
                          'Amount: ${checkout.requestedAmount.toStringAsFixed(2)} ${checkout.requestedCurrency}',
                          style: TextStyle(
                              color: AppColors.kthirdColor.withOpacity(0.7)),
                        ),
                        Text(
                          'Date: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(checkout.createdDate))}',
                          style: TextStyle(
                              color: AppColors.kthirdColor.withOpacity(0.7)),
                        ),
                      ],
                    ),
                    trailing: _beautifyStatus(checkout.status),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selected: ${checkout.name}')),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _beautifyStatus(String status) {
    switch (status) {
      case '1':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Pending', style: TextStyle(color: Colors.green)),
        );
      case '2':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Completed', style: TextStyle(color: Colors.blue)),
        );
      case '3':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Failed', style: TextStyle(color: Colors.red)),
        );
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.kthirdColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(status, style: TextStyle(color: AppColors.kthirdColor)),
        );
    }
  }
}