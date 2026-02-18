import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({super.key});

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final ApiService _apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _future;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  String? selectedPaymentType;
  String? selectedProvider;

  bool _isLoading=false;

  /// Different dropdown values
  final List<String> creditCardOptions = [
    "Visa",
    "MasterCard",
    "RuPay",
  ];

  final List<String> bankOptions = [
    "SBI",
    "HDFC",
    "ICICI",
  ];

  List<String> currentOptions = [];

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
    dynamic data = await _apiService.getJson(
      query: {"action": "bank"},
    );
    final Map<String,dynamic> mapRes = _extractCreditList(data);

    data = await _apiService.getJson(
      query: {"action": "bank"},
    );

    final List<dynamic> list = _extractList(data);
    return list
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry('$key', value)))
        .toList();
  }

  Map<String, dynamic> _extractCreditList(dynamic data) {
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

  void _onPaymentTypeChanged(String? value) {
    setState(() {
      selectedPaymentType = value;
      selectedProvider = null; // reset dropdown

      if (value == "credit") {
        currentOptions = creditCardOptions;
      } else if (value == "bank") {
        currentOptions = bankOptions;
      }
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate() &&
        selectedPaymentType != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Form Submitted Successfully")),
      );
    } else if (selectedPaymentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select payment type")),
      );
    }
  }

  void _reset() {
    _formKey.currentState!.reset();
    nameController.clear();
    emailController.clear();
    amountController.clear();

    setState(() {
      selectedPaymentType = null;
      selectedProvider = null;
      currentOptions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Transaction'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                /// 🔹 Radio Buttons
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Credit Card"),
                        value: "credit",
                        groupValue: selectedPaymentType,
                        onChanged: _onPaymentTypeChanged,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Bank Account"),
                        value: "bank",
                        groupValue: selectedPaymentType,
                        onChanged: _onPaymentTypeChanged,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// 🔹 Dynamic Dropdown
                DropdownButtonFormField<String>(
                  value: selectedProvider,
                  decoration: const InputDecoration(
                    labelText: "Select Provider",
                    border: OutlineInputBorder(),
                  ),
                  items: currentOptions
                      .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedProvider = value;
                    });
                  },
                  validator: (value) {
                    if (selectedPaymentType == null) {
                      return "Select payment type first";
                    }
                    if (value == null) {
                      return "Please select provider";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                /// 🔹 Name
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty
                      ? "Name is required"
                      : null,
                ),

                const SizedBox(height: 16),

                /// 🔹 Email
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email is required";
                    }
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return "Enter valid email";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                /// 🔹 Amount
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Amount is required";
                    }
                    if (double.tryParse(value) == null) {
                      return "Enter valid number";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: const Text("Submit"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _reset,
                        child: const Text("Reset"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    );
  }
}
