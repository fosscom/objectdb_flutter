library objectdb_flutter;

import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:objectdb/objectdb.dart' as base;
export 'package:objectdb/objectdb.dart';

class ObjectDB extends base.ObjectDB {
  ObjectDB(path) : super(path);
}

class Store<E> extends ListBase<E> {
  final ObjectDB db;
  final Map<dynamic, dynamic> query;
  Function callback;

  List innerList = List();

  Store(this.db, this.query, this.callback);

  Future init() async {
    innerList = await db.find(query, (base.Method method, dynamic data) {
      switch (method) {
        case base.Method.add:
          {
            innerList.add(data);
            break;
          }
        case base.Method.remove:
          {
            assert(data is List);
            innerList.removeWhere((record) => data.contains(record['_id']));
            break;
          }
        case base.Method.update:
          {
            innerList.removeWhere((record) => data['_id'] == record['_id']);
            innerList.add(data);
            break;
          }
      }
      this.callback();
    });
    this.callback();
  }

  int get length => innerList.length;

  set length(int length) {
    innerList.length = length;
  }

  void operator []=(int index, E value) {
    innerList[index] = value;
  }

  E operator [](int index) => innerList[index];
}

abstract class StoreWatcherMixin<T extends StatefulWidget> extends State<T> {
  @protected
  Future<Store> listenToStore(ObjectDB db, Map<dynamic, dynamic> query) async {
    final Store store = Store(db, query, () {
      setState(() {});
    });
    await store.init();
    return store;
  }
}
