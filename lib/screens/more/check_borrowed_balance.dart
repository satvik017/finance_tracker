import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class CheckBorrowedBalance extends StatefulWidget {
  const CheckBorrowedBalance({super.key});

  @override
  State<CheckBorrowedBalance> createState() => _CheckBorrowedBalanceState();
}

class _CheckBorrowedBalanceState extends State<CheckBorrowedBalance> {
  final ApiService _apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _future;

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

  Future<List<Map<String, dynamic>>> _fetchBalance() async {
    final dynamic data = await _apiService.getJson(
      query: {"action": "borrowed"},
    );
    final List<dynamic> list = _extractList(data);
    return list
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry('$key', value)))
        .toList();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) {
      return data;
    }
    if (data is Map) {
      final dynamic fromData = data['data'];
      if (fromData is List) {
        return fromData;
      }
      final dynamic fromTransactions = data['balance'];
      if (fromTransactions is List) {
        return fromTransactions;
      }
    }
    return <dynamic>[];
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

  void showFormPopup(BuildContext context, String name) {
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("User Form ($name)"),
          content: BankForm(formKey: _formKey, name: name),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Check Borrowed Balance'),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
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
                    'Failed to load transactions.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return const Center(child: Text('No recent transactions found.'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                final title = _stringFromKeys(item, [
                  'Account',
                ]);
                final amount = _stringFromKeys(item, [
                  'Balance',
                ]);

                return GestureDetector(
                  onLongPress: (){
                    showFormPopup(context, item["Account"]??"");
                  },
                  child: Card(
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
                      trailing: Text(
                        amount,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
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

class BankForm extends StatefulWidget {
  const BankForm({
    super.key,
    required GlobalKey<FormState> formKey, required this.name
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final String name;

  @override
  State<BankForm> createState() => _BankFormState();
}

class _BankFormState extends State<BankForm> {
  final TextEditingController amount = TextEditingController();
  final TextEditingController remark = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget._formKey,
      child: (_isLoading)?SizedBox(
        height: 50,
          child: const Center(child: CircularProgressIndicator())):Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: amount,
            decoration: const InputDecoration(labelText: "Amount"),
            validator: (value) =>
            value!.isEmpty ? "Enter Amount" : null,
          ),
          TextFormField(
            controller: remark,
            decoration: const InputDecoration(labelText: "Remark"),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async{
                  if (widget._formKey.currentState!.validate()) {
                    setState(() {
                      _isLoading=true;
                    });
                    try{
                      var res = await _apiService.postJson(
                        body: {"action": "updateMoney",
                          "amount": amount.text,
                          "which": widget.name,
                          "where": "borrowed"
                        },
                      );
                      debugPrint(res.toString());
                    }
                    catch(e){
                      debugPrint(e.toString());
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Form Submitted Successfully",style: TextStyle(color: Colors.white),), backgroundColor: Colors.green,),
                    );
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text("Submit"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
