import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_crudfirebase/addEditProduct.dart';
import 'package:basic_utils/basic_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      routes: {
        "home": (context) => const HomePage(),
        "addEditProduct": (context) => const AddEditProduct()
      },
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Query _products =
      FirebaseFirestore.instance.collection('products').orderBy('name');

  _closeModal() {
    Navigator.pop(context);
  }

  Future<void> _confirmDeleteUser(BuildContext contex, String id) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Product"),
          content: const Text("Are you sure you want to delete this product?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Delete"),
              onPressed: () async {
                FirebaseFirestore.instance
                    .collection('products')
                    .doc(id)
                    .delete()
                    .then((value) => _closeModal());
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                _closeModal();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Firebase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add',
            onPressed: () => Navigator.pushNamed(context, "addEditProduct"),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _products.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: ((BuildContext context, int index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];

                return ListTile(
                  title: Text(
                      StringUtils.capitalize("${documentSnapshot['name']}")),
                  subtitle: Text("\$${documentSnapshot['price'].toString()}"),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => Navigator.pushNamed(
                            context, "addEditProduct",
                            arguments: {'id': documentSnapshot.id}),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            _confirmDeleteUser(context, documentSnapshot.id),
                      )
                    ],
                  ),
                );
              }),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
