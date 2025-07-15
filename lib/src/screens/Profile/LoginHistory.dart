import 'dart:convert';
import 'package:crypto_pay/src/services/api_service.dart';
import 'package:crypto_pay/src/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:crypto_pay/src/models/LoginHistory.dart'; // Adjust import path

class LoginHistoryScreen extends StatefulWidget {
  @override
  _LoginHistoryScreenState createState() => _LoginHistoryScreenState();
}

class _LoginHistoryScreenState extends State<LoginHistoryScreen> {
  late Future<List<LoginHistoryModel>> _loginHistoryFuture;

  @override
  void initState() {
    super.initState();
    _loginHistoryFuture = fetchLoginHistory();
  }

  Future<List<LoginHistoryModel>> fetchLoginHistory() async {
    try {
      final response = await ApiService.fetchLoginHistory();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => LoginHistoryModel.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load login history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching login history: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.of(context).pop,
          child: Icon(Icons.arrow_back)),
        title: const Text('Login History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              // Navigate to dashboard or handle as needed
            },
          ),
        ],
      ),
      body: FutureBuilder<List<LoginHistoryModel>>(
        future: _loginHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No login history available'));
          } else {
            final loginHistory = snapshot.data!;
            return Column(
              children: [
                Card(
                  elevation: 0,
                  color: AppColors.kthirdColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Removes border radius
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('Login Date/Time', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.kwhite))),
                          Spacer(),
                          Expanded(child: Text('Logout Date/Time', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.kwhite))),
                          Spacer(),
                          Expanded(child: Text('Login IP', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.kwhite))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: ListView.builder(
                      itemCount: loginHistory.length,
                      itemBuilder: (context, index) {
                        final history = loginHistory[index];
                        return Container(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(history.loginTime ?? ''))),
                              const Expanded(child: Padding(padding: EdgeInsets.all(8.0), child: Text(''))),
                              Expanded(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(history.loginIp ?? ''))),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}