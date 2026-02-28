import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class CreditCardBalance extends StatefulWidget {
  const CreditCardBalance({super.key});

  @override
  State<CreditCardBalance> createState() => _CreditCardBalanceState();
}

class _CreditCardBalanceState extends State<CreditCardBalance> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchBalance();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchBalance() async {
    final dynamic data = await _apiService.getJson(
      query: {"action": "creditCard"},
    );

    final Map<String, dynamic> list = _extractList(data);

    return list.map((key, value) {
      if (value is Map) {
        return MapEntry(
          key,
          Map<String, dynamic>.from(value),
        );
      }
      return MapEntry(key, value);
    });
  }

  Map<String, dynamic> _extractList(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      final dynamic fromData = data['data'];
      if (fromData is Map<String, dynamic>) {
        return fromData;
      }
      final dynamic fromTransactions = data['balance'];
      if (fromTransactions is Map<String, dynamic>) {
        return fromTransactions;
      }
    }
    return {};
  }

  String _stringFromKeys(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Check Balance'),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Failed to load balances.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final items = snapshot.data ?? {};
            if (items.keys.isEmpty) {
              return const Center(child: Text('No credit card balance found.'));
            }
            final keys = items.keys.toList();

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: items.keys.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = keys[index];
                final title = item;
                final amount = _stringFromKeys(items[item], [
                  'Available'
                ]);
                final billed = _stringFromKeys(items[item], [
                  'Billed'
                ]);
                final unbilled = _stringFromKeys(items[item], [
                  'UnBilled',
                ]);

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE0F2F1),
                      child: Icon(Icons.account_balance_wallet, color: Color(0xFF0F766E)),
                    ),
                    title: Text(title),
                    trailing: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Available : ",
                              style: const TextStyle(fontWeight: FontWeight.w800,color: Color(0xFF0F766E)),
                            ),
                            Text(
                              amount,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "UnBilled : ",
                              style: const TextStyle(fontWeight: FontWeight.w800,color: Color(0xFF0F766E)),
                            ),
                            Text(
                              unbilled,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Billed : ",
                              style: const TextStyle(fontWeight: FontWeight.w800,color: Color(0xFF0F766E)),
                            ),
                            Text(
                              billed,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        )
    );
  }
}
