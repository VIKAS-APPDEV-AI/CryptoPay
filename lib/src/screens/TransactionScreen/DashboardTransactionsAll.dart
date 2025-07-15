import 'package:crypto_pay/src/screens/TransactionScreen/TransactionModel/TransactionModel.dart';
import 'package:crypto_pay/src/services/Transaction_api.dart';
import 'package:crypto_pay/src/utils/AuthManager.dart';
import 'package:crypto_pay/src/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class DashboardTransactionScreenAll extends StatefulWidget {
  const DashboardTransactionScreenAll({super.key});

  @override
  _DashboardTransactionScreenAllState createState() =>
      _DashboardTransactionScreenAllState();
}

class _DashboardTransactionScreenAllState
    extends State<DashboardTransactionScreenAll> {
  final TransactionApiService apiService =
      TransactionApiService(authManager: AuthManager());
  List<Transaction> transactions = [];
  List<Transaction> filteredTransactions = [];
  String selectedTransId = 'Select';
  String selectedStatus = 'All Status';
  DateTime? selectedDate;
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> transIdOptions = ['Select', 'TransID', 'Status'];
  List<String> statuses = ['All Status'];

  int currentPage = 1;
  int itemsPerPage = 10;
  int totalItems = 0;
  TextEditingController pageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTransactions();
    searchController.addListener(() {
      filterTransactions();
    });
    pageController.addListener(() {
      setState(() {
        final newPage = int.tryParse(pageController.text) ?? 1;
        if (newPage > 0 && newPage <= (totalItems / itemsPerPage).ceil()) {
          currentPage = newPage;
        } else {
          pageController.text = currentPage.toString();
        }
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    pageController.dispose();
    super.dispose();
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

  Future<void> fetchTransactions() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final isAuthenticated = await AuthManager.isAuthenticated();
      debugPrint('Is Authenticated: $isAuthenticated');
      final userData = await AuthManager.getUserData();
      debugPrint('User Data: $userData');

      debugPrint('Fetching all transactions');

      final fetchedTransactions =
          await apiService.fetchTransactions(); // Adjust limit as needed
      totalItems = fetchedTransactions.length;

      debugPrint('Fetched ${fetchedTransactions.length} transactions');

      final statusList =
          fetchedTransactions.map((t) => t.status).toSet().toList();

      setState(() {
        transactions = fetchedTransactions;
        filteredTransactions = transactions;
        statuses = ['All Status', ...statusList];
        isLoading = false;
      });

      filterTransactions();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      setState(() {
        errorMessage = 'Failed to load transactions: $e';
        isLoading = false;
      });
    }
  }

  void filterTransactions() {
    setState(() {
      filteredTransactions = transactions.where((transaction) {
        final matchesSearch = searchController.text.isEmpty ||
            transaction.transactionId
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            transaction.destinationAddress
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            transaction.note
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            transaction.customerRefId
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            transaction.status
                .toLowerCase()
                .contains(searchController.text.toLowerCase());

        final matchesTransId = selectedTransId == 'Select' ||
            (selectedTransId == 'TransID' &&
                transaction.transactionId.isNotEmpty) ||
            (selectedTransId == 'Status' && transaction.status.isNotEmpty);

        final matchesStatus = selectedStatus == 'All Status' ||
            transaction.status == selectedStatus;

        final matchesDate = selectedDate == null ||
            transaction.createDate.year == selectedDate!.year &&
                transaction.createDate.month == selectedDate!.month &&
                transaction.createDate.day == selectedDate!.day;

        debugPrint('Transaction ${transaction.transactionId}: '
            'Search=$matchesSearch, TransId=$matchesTransId, Status=$matchesStatus, Date=$matchesDate');

        return matchesSearch && matchesTransId && matchesStatus && matchesDate;
      }).toList();

      totalItems = filteredTransactions.length;
      debugPrint('Filtered ${filteredTransactions.length} transactions');
      pageController.text =
          currentPage.toString(); // Reset page input to current page

      if (filteredTransactions.isEmpty && transactions.isNotEmpty) {
        debugPrint(
            'No transactions after filtering, falling back to unfiltered list');
        filteredTransactions = transactions;
        totalItems = filteredTransactions.length;
        errorMessage =
            'No transactions match the filters. Showing all transactions.';
      } else if (filteredTransactions.isEmpty) {
        errorMessage = 'No transactions found for the selected criteria.';
      } else {
        errorMessage = '';
      }
    });
  }

  void previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        pageController.text = currentPage.toString();
      });
    }
  }

  void nextPage() {
    if ((currentPage * itemsPerPage) < totalItems) {
      setState(() {
        currentPage++;
        pageController.text = currentPage.toString();
      });
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'declined':
        return Colors.red;
      case 'waiting':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    final paginatedTransactions = filteredTransactions.sublist(
      startIndex,
      endIndex > filteredTransactions.length
          ? filteredTransactions.length
          : endIndex,
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.kprimary,
        elevation: 2,
        title: const Text(
          'Transactions List',
          style: TextStyle(
            color: AppColors.kwhite,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.kwhite),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
          tooltip: 'Back',
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Filter Transactions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            _buildSearchField(),
            const SizedBox(height: 20),
            _buildTransIdDropdown(),
            const SizedBox(height: 20),
            _buildStatusDropdown(),
            const SizedBox(height: 20),
            _buildDatePicker(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                filterTransactions();
                Navigator.pop(context); // Close drawer after applying filters
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kprimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Filter Icon (Left side)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.black87),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    tooltip: 'Filter Transactions',
                  ),
                ),
                const SizedBox(width: 10),
                // Excel and PDF Icons (Right side)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Image.asset(
                          'assets/images/Excel.png',
                          height: 24,
                          width: 24,
                        ),
                        onPressed: () {
                          debugPrint('Excel export clicked');
                        },
                        tooltip: 'Export to Excel',
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Image.asset(
                          'assets/images/Pdf.png',
                          height: 24,
                          width: 24,
                        ),
                        onPressed: () {
                          debugPrint('PDF export clicked');
                        },
                        tooltip: 'Export to PDF',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          errorMessage,
                          style:
                              const TextStyle(fontSize: 16, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : paginatedTransactions.isEmpty
                        ? const Center(
                            child: Text(
                              'No Transactions Found',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: paginatedTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = paginatedTransactions[index];
                              return AnimatedOpacity(
                                opacity: 1.0,
                                duration: const Duration(milliseconds: 300),
                                child: Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ExpansionTile(
                                    leading: Icon(
                                      Icons.remove_red_eye,
                                      color: Colors.grey[600],
                                      size: 20,
                                    ),
                                    title: isSmallScreen
                                        ? _buildCompactTileTitle(transaction)
                                        : _buildExpandedTileTitle(transaction),
                                    children: [
                                      _buildTransactionDetails(transaction),
                                    ],
                                    tilePadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    expandedCrossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    iconColor: Colors.grey[600],
                                    collapsedIconColor: Colors.grey[600],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: AppColors.kthirdColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                  child: Text(
                    'Page [$currentPage] Total $totalItems',
                    style:
                        const TextStyle(fontSize: 14, color: AppColors.kwhite),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 30,
                  child: ElevatedButton(
                    onPressed: previousPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                    ),
                    child: const Icon(Icons.arrow_back_ios, size: 16),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 30,
                  height: 30,
                  child: TextField(
                    style: TextStyle(color: AppColors.kwhite),
                    controller: pageController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 30,
                  child: ElevatedButton(
                    onPressed: nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                    ),
                    child: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: 'Search transactions...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    searchController.clear();
                  });
                },
              )
            : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      style: const TextStyle(fontSize: 14),
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildTransIdDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: selectedTransId,
        isExpanded: true,
        items: transIdOptions.map((value) {
          return DropdownMenuItem(
            value: value,
            child: Text(value, style: const TextStyle(fontSize: 14)),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              selectedTransId = value;
            });
          }
        },
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        dropdownColor: Colors.white,
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: selectedStatus,
        isExpanded: true,
        items: statuses.map((value) {
          return DropdownMenuItem(
            value: value,
            child: Text(value, style: const TextStyle(fontSize: 14)),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              selectedStatus = value;
            });
          }
        },
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        dropdownColor: Colors.white,
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() {
            selectedDate = picked;
            fetchTransactions();
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              selectedDate == null ? 'Select Date' : formatDate(selectedDate!),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedTileTitle(Transaction transaction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            transaction.transactionId,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Image.asset(
            'assets/crypto/${transaction.convertedCurrency.toLowerCase()}.png',
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, color: Colors.red, size: 20),
          ),
        ),
        Flexible(
          flex: 2,
          child: Text(
            '${transaction.requestedAmount} ${transaction.requestedCurrency}',
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          flex: 2,
          child: Text(
            '${transaction.convertedAmount} ${transaction.convertedCurrency}',
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          flex: 2,
          child: Text(
            transaction.receivedCurrency,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          flex: 2,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_drop_up, size: 16, color: Colors.green),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  transaction.transactionType,
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Flexible(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: getStatusColor(transaction.status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              transaction.status,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactTileTitle(Transaction transaction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                transaction.note,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: getStatusColor(transaction.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                transaction.status,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Flexible(
              child: Text(
                '${transaction.requestedAmount} ${transaction.requestedCurrency} → ${transaction.convertedAmount} ${transaction.convertedCurrency}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionDetails(Transaction transaction) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Transaction ID', transaction.transactionId),
          _buildDetailRow('ID', transaction.id.toString()),
          _buildDetailRow('Transaction Type', transaction.transactionType),
          _buildDetailRow('Requested Amount',
              '${transaction.requestedAmount} ${transaction.requestedCurrency}'),
          _buildDetailRow('Converted Amount',
              '${transaction.convertedAmount} ${transaction.convertedCurrency}'),
          _buildDetailRow('Received Currency', transaction.receivedCurrency),
          _buildDetailRow('Status', transaction.status),
          _buildDetailRow('Sub Status', transaction.subStatus.toString()),
          _buildDetailRow('Customer Ref ID', transaction.customerRefId),
          _buildDetailRow('Note', transaction.note),
          _buildDetailRow('Create Date', formatDate(transaction.createDate)),
          _buildDetailRow(
              'Destination Address', transaction.destinationAddress),
          _buildDetailRow('IP', transaction.ip),
          _buildDetailRow(
              'Response Timestamp', formatDate(transaction.responseTimestamp)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label :',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}