import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({super.key});

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> bankDetails={};
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  String? selectedPaymentType;
  Map<String,dynamic> creditDetails={};
  bool _isLoading=false;

  /// Different dropdown values
  String? creditCardOptions;

  String? bankOptions;

  @override
  void initState() {
    super.initState();
    _fetchBalance();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _fetchBalance() async {
    setState(() {
      _isLoading = true;
    });
    dynamic data = await _apiService.getJson(
      query: {"action": "creditCard"},
    );
    final Map<String,dynamic> mapRes = _extractCreditList(data);
    creditDetails = mapRes.map((key, value) {
      if (value is Map) {
        return MapEntry(
          key,
          Map<String, dynamic>.from(value),
        );
      }
      return MapEntry(key, value);
    });

    data = await _apiService.getJson(
      query: {"action": "bank"},
    );

    final List<dynamic> list = _extractList(data);
    Map<String,String> res = {};
    for(var item in list){
      res[item["Account"]] = item["Balance"].toString();
    }
    setState(() {
      _isLoading = false;
      bankDetails = res;
    });
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Transaction'),
        ),
        body: (_isLoading)? const Center(child: CircularProgressIndicator()):(bankDetails.keys.isEmpty)? const Center(
                    child: Text('No recent transactions found.')):Padding(
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
                      if(selectedPaymentType == "credit")
                        DropdownButtonFormField<String>(
                          value: creditCardOptions,
                          decoration: const InputDecoration(
                            labelText: "Select Provider",
                            border: OutlineInputBorder(),
                          ),
                          items: creditDetails.keys
                              .map((item) =>
                              DropdownMenuItem(
                                value: item,
                                child: Text(
                                    "$item - ${creditDetails[item]["Available"]}"),
                              ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              creditCardOptions = value;
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
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: bankOptions,
                          decoration: const InputDecoration(
                            labelText: "Select Provider",
                            border: OutlineInputBorder(),
                          ),
                          items: bankDetails.keys
                              .map((item) =>
                              DropdownMenuItem(
                                value: item,
                                child: Text("$item - ${bankDetails[item]}"),
                              ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              bankOptions = value;
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
              )
    );
  }
}
