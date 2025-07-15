import 'package:crypto_pay/src/screens/HomeScreen.dart';
import 'package:crypto_pay/src/screens/paylinks/plink.dart';
import 'package:crypto_pay/src/utils/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto_pay/src/services/api_service.dart';
import 'package:crypto_pay/src/models/PayLinkListModel.dart';
import 'package:crypto_pay/src/utils/AuthManager.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package

import 'PayLink.dart';

class PayLinksList extends StatefulWidget {
  PayLinksList({super.key});

  @override
  _PayLinksListState createState() => _PayLinksListState();
}

class _PayLinksListState extends State<PayLinksList> {
  final ApiService apiService = ApiService();
  late Future<List<PayLinkListModel>> _payLinksFuture;

  @override
  void initState() {
    super.initState();
    _payLinksFuture = apiService.fetchPaymentLinkList();
  }

  Future<void> _refreshLinks() async {
    try {
      setState(() {
        _payLinksFuture = apiService.fetchPaymentLinkList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error refreshing links: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kwhite,
      appBar: AppBar(
        leading: InkWell(
          onTap: (){
            Navigator.push(context, CupertinoPageRoute(builder: (context) => HomeScreen(),));
          },
          child: Icon(Icons.arrow_back, color: AppColors.kbackground,)),
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.kprimary, AppColors.kthirdColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Pay Links',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => PaymentLinkPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 5,
              ),
              child: const Text('+ Create Pay Link',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFE0EAF1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 60,
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side:
                        BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        children: const [
                          Expanded(
                              flex: 2,
                              child: Text('Product',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87))),
                          Expanded(
                              flex: 3,
                              child: Text('Link',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87))),
                          Expanded(
                              flex: 1,
                              child: Text('Price',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<bool>(
                  future: AuthManager.isAuthenticated(),
                  builder: (context, authSnapshot) {
                    if (authSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (authSnapshot.hasError || !authSnapshot.data!) {
                      return const Center(
                          child: Text('Please log in to view payment links.',
                              style: TextStyle(color: Colors.grey)));
                    }
                    return FutureBuilder<List<PayLinkListModel>>(
                      future: _payLinksFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          // Display Lottie animation and text when no payment links
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.asset(
                                  'assets/assets/no_transactions.json',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No Transactions Yet',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        final payLinks = snapshot.data!;
                        return RefreshIndicator(
                          onRefresh: _refreshLinks,
                          color: AppColors.kprimary,
                          backgroundColor: Colors.white,
                          child: ListView.builder(
                            itemCount: payLinks.length,
                            itemBuilder: (context, index) {
                              final link = payLinks[index];
                              return PayLinkItem(
                                product: link.productName,
                                link:
                                    'https://cryptopay.oyefin.com/pay?iid=${link.trackid}',
                                price:
                                    '${link.requestedamount} ${link.requestedcurrency}',
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PayLinkItem extends StatelessWidget {
  final String product;
  final String link;
  final String price;

  const PayLinkItem(
      {super.key, required this.product, required this.link, required this.price});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
        child: InkWell(
          onTap: () => _launchURL(link),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    product,
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 6,
                  child: GestureDetector(
                    onTap: () => _launchURL(link),
                    child: Text(
                      link,
                      style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontSize: 14),
                      //overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 4,
                  child: Text(
                    price,
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}