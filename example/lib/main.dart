import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:objectdb_flutter/objectdb_flutter.dart';

// declare db object
ObjectDB db;

void main() async {
  // get document directory using path_provider plugin
  Directory appDocDir = await getApplicationDocumentsDirectory();

  String dbFilePath = [appDocDir.path, 'user.db'].join('/');

  // delete old database file if exists
  File dbFile = File(dbFilePath);

  // check if database already exists
  var isNew = !await dbFile.exists();
  if (!isNew) dbFile.deleteSync();
  // initialize and open database
  db = ObjectDB(dbFilePath);
  db.open();

  // insert sample data
  db.insertMany([
    {
      'name': {'first': 'Alex', 'last': 'Boyle'},
      'message': 'abc',
      'active': true,
      'count': 0,
    },
    {
      'name': {'first': 'Maia', 'last': 'Herzog'},
      'message': 'def',
      'active': true,
      'count': 0,
    },
    {
      'name': {'first': 'Curtis', 'last': 'Smith'},
      'message': 'ghi',
      'active': true,
      'count': 0,
    },
    {
      'name': {'first': 'Jaquelin', 'last': 'Renner'},
      'message': 'jkl',
      'active': false,
      'count': 0,
    },
    {
      'name': {'first': 'Denis', 'last': 'Swift'},
      'message': 'mno',
      'active': true,
      'count': 0,
    },
    {
      'name': {'first': 'Anna', 'last': 'Metz'},
      'message': 'pqr',
      'active': true,
      'count': 0,
    },
    {
      'name': {'first': 'Malinda', 'last': 'Reynolds'},
      'message': 'stu',
      'active': false
    },
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ObjectDB Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'ObjectDB Demo Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with StoreWatcherMixin<MyHomePage> {
  Store contacts;

  void initState() {
    super.initState();

    init();
  }

  void init() async {
    contacts = await listenToStore(db, {'active': true});

    int i = 0;
    new Timer.periodic(Duration(seconds: 2), (Timer t) {
      db.insert({
        'name': {'first': 'Malinda', 'last': 'Reynolds'},
        'message': 'hoho',
        'active': false,
        'count': i++
      });

      if (i > 10) i = 0;
    });

    new Timer.periodic(Duration(seconds: 10), (Timer t) {
      db.update({
        Op.gte: {'count': 5}
      }, {
        Op.set: {'message': 'updated'}
      });
    });

    new Timer.periodic(Duration(seconds: 15), (Timer t) {
      db.remove({'message': 'updated'});
    });
  }

  @override
  void dispose() async {
    await db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: contacts == null // check if _contacts has been initialized
          ? Center(
              child: Text('loading...'),
            )
          : ListView(
              children:
                  contacts.map((contact) => contactItem(contact)).toList(),
            ),
    );
  }
}

// creates list tile with contact info
Widget contactItem(Map contact) {
  return ListTile(
    title: Text(contact['name']['first'] + ' ' + contact['name']['last']),
    subtitle: Text(contact['message']),
  );
}
