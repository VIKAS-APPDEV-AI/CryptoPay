import 'package:crypto_pay/src/screens/paylinks/PayLink.dart';
import 'package:crypto_pay/src/utils/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PayLinksScreen extends StatelessWidget {
  const PayLinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Container(
        color: Colors.grey[200],
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shopping_cart,
                  size: 80,
                  color: Colors.black,
                ),
                const SizedBox(height: 20),
                const Text(
                  'No Pay Links yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'You currently do not have any paylinks.\nCreate one to start accepting payment',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                   Navigator.push(context, CupertinoPageRoute(builder: (context) => PaymentLinkPage(),));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kprimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('+ Create Pay Link', style: TextStyle(color: AppColors.kwhite),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}