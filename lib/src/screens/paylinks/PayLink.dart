import 'package:crypto_pay/src/models/PayLinkModel.dart';
import 'package:crypto_pay/src/screens/paylinks/PayLinkList.dart';
import 'package:crypto_pay/src/services/api_service.dart';
import 'package:crypto_pay/src/utils/Constants.dart';

import 'package:crypto_pay/src/utils/AuthManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
 // Import PayLinksList

class PaymentLinkPage extends StatefulWidget {
  const PaymentLinkPage({super.key});

  @override
  _PaymentLinkPageState createState() => _PaymentLinkPageState();
}

class _PaymentLinkPageState extends State<PaymentLinkPage> {
  String selectedCurrency = 'USD';
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    productNameController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }

  // Sanitize input to remove potentially problematic characters
  String _sanitizeInput(String input) {
    return input.replaceAll(RegExp(r'[^\w\s.,-]'), '').trim();
  }

  Future<void> _createPaymentLink() async {
    // Validate required fields
    if (productNameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Sanitize inputs
    final productName = _sanitizeInput(productNameController.text);
    final description = _sanitizeInput(descriptionController.text);

    // Validate amount
    double? amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Fetch user data from AuthManager
      final userData = await AuthManager.getUserData();
      final merchantName = userData?['merchantName']?.toString();
      final merchantEmail = userData?['merchantEmail']?.toString();

      // Validate AuthManager data
      if (merchantName == null || merchantName.isEmpty) {
        throw Exception('Merchant name not found in user data');
      }
      if (merchantEmail == null || merchantEmail.isEmpty) {
        throw Exception('Merchant email not found in user data');
      }
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
          .hasMatch(merchantEmail)) {
        throw Exception('Invalid merchant email in user data');
      }

      // Generate a unique OrderID
      final orderId = 'ORDER-${DateTime.now().millisecondsSinceEpoch}';

      final apiService = ApiService();
      final response = await apiService.createPayLink(
        orderId: orderId,
        customerName: merchantName,
        customerEmail: merchantEmail,
        productName: productName,
        description: description,
        currency: selectedCurrency,
        amount: amount,
      );

      try {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        final payLinkResponse = PayLinkResponseModel.fromJson(responseJson);

        if (payLinkResponse.status == 'Ok') {
          // Add the new link to PayLinksList
          // PayLinksList.addPayLink(
          //   product: productName,
          //   link: payLinkResponse.payUrl,
          //   price: '${selectedCurrency} ${amount.toStringAsFixed(2)}',
          // );

          // Navigate to PayLinksList
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PayLinksList()),
          );

          // Show success SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment link created: ${payLinkResponse.payUrl}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Copy',
                textColor: Colors.white,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: payLinkResponse.payUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment link copied to clipboard'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
              ),
            ),
          );
        } else {
          throw Exception('API returned non-Ok status: ${responseJson['Status']}');
        }
      } catch (e) {
        throw Exception('Failed to parse API response: $e, body: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Generate Payment Link',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Product Name'),
                TextField(
                  controller: productNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter Product Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildLabel('Description'),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter Product Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildLabel('Fiat Amount'),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Amount',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCurrency,
                          items: ['USD', 'THB', 'JPY', 'INR', 'GBP', 'EUR', 'CNY', 'AUD']
                              .map((value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCurrency = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _createPaymentLink,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kprimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Create Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }
}