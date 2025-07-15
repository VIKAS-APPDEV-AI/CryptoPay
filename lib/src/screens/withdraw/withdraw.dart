import 'package:crypto_pay/src/utils/Constants.dart';
import 'package:flutter/material.dart';

class WithdrawPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Withdraw'),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('+ Settlement Settings', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.circle, color: Colors.white)),
                title: Text('CARDANO'),
                subtitle: Text('1063.200800 ADA'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text('Withdraw Now >' , style: TextStyle(color: AppColors.kwhite),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.circle, color: Colors.white)),
                title: Text('BITCOIN'),
                subtitle: Text('0.500000 BTC'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text('Withdraw Now >', style: TextStyle(color: AppColors.kwhite),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.circle, color: Colors.white)),
                title: Text('DASH'),
                subtitle: Text('2.789525 DASH'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text('Withdraw Now >', style: TextStyle(color: AppColors.kwhite),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.yellow, child: Icon(Icons.circle, color: Colors.black)),
                title: Text('DOGECOIN'),
                subtitle: Text('3037.745856 DOGE'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text('Withdraw Now >', style: TextStyle(color: AppColors.kwhite),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.purple, child: Icon(Icons.circle, color: Colors.white)),
                title: Text('ETHEREUM'),
                subtitle: Text('0.168934 ETH'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text('Withdraw Now >', style: TextStyle(color: AppColors.kwhite),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.circle, color: Colors.white)),
                title: Text('LITECOIN'),
                subtitle: Text('710.081512 LTC'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text('Withdraw Now >', style: TextStyle(color: AppColors.kwhite),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}