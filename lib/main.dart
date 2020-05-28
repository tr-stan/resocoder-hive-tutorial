import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'contact_page.dart';
import 'models/contact.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(ContactAdapter(), 0);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive Tutorial',
      home: FutureBuilder(
        future: Future.delayed(Duration(milliseconds: 2500), () {
          Hive.openBox(
            'contacts',
            // can specify compaction vs Hive compacting automatically
            // automatically does by its own strategy, at 60 deleted + other logic
            compactionStrategy: (int total, int deleted) {
              return deleted > 20;
            },
          );
        }),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError)
              return Text(snapshot.error.toString());
            else
              return ContactPage();
          } else
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.network(
                      "https://media.giphy.com/media/l0HlE1Zi6mJYDfwUU/giphy.gif"),
                ),
              ),
            );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Hive will compact automatically, but you can do so under specific conditions
    Hive.box('contacts').compact();
    Hive.close();
    super.dispose();
  }
}
