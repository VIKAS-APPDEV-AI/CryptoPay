import 'package:crypto_pay/src/models/CustomerListModel.dart';
import 'package:crypto_pay/src/services/api_service.dart';
import 'package:crypto_pay/src/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomerListScreen extends StatefulWidget {
  @override
  _CustomerListScreenState createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  List<CustomerListModel> customers = [];

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    final apiService = ApiService();
    try {
      final response = await apiService.fetchCustomerList();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          customers = data.map((json) => CustomerListModel.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load customers');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.kthirdColor,
        // leading: InkWell(
        //   onTap: () => Navigator.pop(context),
        //   child: Icon(Icons.arrow_back, color: AppColors.kwhite,),
        // ),
        title: Center(
          child: Text(
            'Customer List',
            style: TextStyle(
              color: AppColors.kwhite,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Container(
        color: AppColors.kwhite,
        child: RefreshIndicator(
          onRefresh: fetchCustomers,
          color: AppColors.kprimary,
          backgroundColor: AppColors.kwhite,
          child: ListView.builder(
            itemCount: customers.length + 1, // +1 for header row
            itemBuilder: (context, index) {
              if (index == 0) {
                return  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Table(
                      border: TableBorder.all(color: Colors.grey, width: 1),
                      columnWidths: {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(1),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: AppColors.kdisabled,
                          ),
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Name',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Email',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'No of Use',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    
                  ),
                );
              }
              final customer = customers[index - 1];
              return  Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Table(
                    border: TableBorder.all(color: Colors.grey, width: 1),
                    columnWidths: {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        children: [
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(customer.customerName),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(customer.customerEmail),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(customer.totalCustomer),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                
              );
            },
          ),
        ),
      ),
    );
  }
}