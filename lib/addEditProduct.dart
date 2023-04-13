import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditProduct extends StatefulWidget {
  const AddEditProduct({super.key});

  @override
  State<AddEditProduct> createState() => _AddEditProductState();
}

class _AddEditProductState extends State<AddEditProduct> {
  int id = 0;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController _productName = TextEditingController();
  final TextEditingController _price = TextEditingController();

  void _goBack() {
    Navigator.of(context).pop();
  }

  String? _fieldValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please fill-in this field';
    }
    return null;
  }

  Future<void> _formSubmit() async {
    final form = formKey.currentState;
    if (form!.validate()) {
      String productName = _productName.text;
      String price = _price.text;

      final CollectionReference _products =
          FirebaseFirestore.instance.collection('products');

      final data = {
        'name': productName,
        'price': price,
      };

      await _products.add(data);
      _goBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    String appBarTitle = "Add a product";

    if (arguments != null && arguments['id'] != null) {
      appBarTitle = "Edit a product";
      setState(() {
        id = arguments['id'];
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: GestureDetector(
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onTap: () {
            _goBack();
          },
        ),
      ),
      body: Center(
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 5.0,
                ),
                child: TextFormField(
                  controller: _productName,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Product Name',
                  ),
                  validator: (String? value) {
                    return _fieldValidator(value);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 5.0,
                ),
                child: TextFormField(
                    controller: _price,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Price',
                    ),
                    validator: (String? value) {
                      return _fieldValidator(value);
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ]),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 5.0,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _formSubmit();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
