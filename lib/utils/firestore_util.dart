import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class FirestoreUtil {
  // static final FirestoreUtil _instance = new FirestoreUtil._instance();

  // factory FirestoreUtil() => _instance;

  // FirestoreUtil._internal();

  static Future<dynamic> createDocTransaction(FirestoreDoc doc) async {
    final CollectionReference colRef =
        Firestore.instance.collection(doc.collectionPath);
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(colRef.document());

      final Map<String, dynamic> data = doc.toMap();

      await tx.set(ds.reference, data);
      return data;
    };

    return Firestore.instance
        .runTransaction(createTransaction)
        .catchError((error) {
      print('error: $error');
      return null;
    });
  }

  static Future<dynamic> updateDocTransaction(FirestoreDoc doc) async {
    final DocumentReference docRef = Firestore.instance.document(doc.path);
    final TransactionHandler updateTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(docRef);

      await tx.update(ds.reference, doc.toMap());
      return {'updated': true};
    };

    return Firestore.instance
        .runTransaction(updateTransaction)
        .then((result) => result['updated'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

  static Future<dynamic> deleteDocTransaction(FirestoreDoc doc) async {
    final DocumentReference docRef = Firestore.instance.document(doc.path);
    final TransactionHandler deleteTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(docRef);

      await tx.delete(ds.reference);
      return {'deleted': true};
    };

    return Firestore.instance
        .runTransaction(deleteTransaction)
        .then((result) => result['deleted'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

  static Future<dynamic> createDoc(FirestoreDoc doc) {
    CollectionReference colRef = Firestore.instance.collection(doc.collectionPath);
    if (doc.docID != null && doc.docID != '')
      return colRef.document(doc.docID).setData(doc.toMap());
    return colRef
        .add(doc.toMap())
        .then((docRef) => {
              doc.docID = docRef.documentID
            })
        .catchError((error) => {print('error: $error')});
  }

  static Future<void> updateDoc(FirestoreDoc doc) {
    final DocumentReference docRef = Firestore.instance.document(doc.path);
    return docRef
        .updateData(doc.toMap())
        // return docRef.setData(doc.toMap(), merge: true)
        .catchError((error) => {print('error: $error')});
  }

  static Future<void> deleteDoc(FirestoreDoc doc) {
    final DocumentReference docRef = Firestore.instance.document(doc.path);
    return docRef.delete().catchError((error) => {print('error: $error')});
  }

  //TODO: Make this work for batches larger than 500 items
  static void createDocBatch(List<FirestoreDoc> list) {
    WriteBatch batch = Firestore.instance.batch();

    list.forEach((doc) => {
          batch.setData(
              Firestore.instance.document('${doc.collectionPath}/${doc.docID}'),
              doc.toMap())
        });

    batch.commit().catchError((error) => {print('error: $error')});
  }

  static void updateDocBatch(List<FirestoreDoc> list) {
    WriteBatch batch = Firestore.instance.batch();

    list.forEach((doc) =>
        {batch.updateData(Firestore.instance.document(doc.path), doc.toMap())});

    batch.commit().catchError((error) => {print('error: $error')});
  }

  static void deleteDocBatch(List<FirestoreDoc> list) {
    WriteBatch batch = Firestore.instance.batch();

    list.forEach((doc) => {
          batch.delete(
              Firestore.instance.document('${doc.collectionPath}/${doc.docID}'))
        });

    batch.commit().catchError((error) => {print('error: $error')});
  }

  static Stream<QuerySnapshot> getDocList(String collectionPath,
      {DocumentSnapshot prevSnapshot, int limit = 20}) {
    CollectionReference colRef = Firestore.instance.collection(collectionPath);
    Stream<QuerySnapshot> snapshots;

    if (prevSnapshot != null) {
      snapshots =
          colRef.startAfter([prevSnapshot.data]).limit(limit).snapshots();
      return snapshots;
    }

    snapshots = colRef.snapshots();

    return snapshots;
  }

//pass in a typedef in order to get out the desired result
  //TODO: explore the possibility to of returning a new instance of the firestoredoc when a user pulls it 
  //from the cloud, and then populate the doc instead of just returning a document snapshot

  //List<FirestoreDoc> getDoc

  //TODO: Need to add in the ablility to get a stream
  //TODO: Need to add in the ablility to get a list from a document
  //TODO: Need to add in the ablility to get a list of documents from a collection

}

typedef FirestoreDoc FromDocumentSnapshot(DocumentSnapshot snapshot);
typedef FirestoreDoc FromStreamSnapshot(AsyncSnapshot<dynamic> streamSnapshot);

abstract class FirestoreDoc {

  String _collectionPath;
  String docID;

  String get path => docID != '' ? '$collectionPath/$docID' : collectionPath;

  set collectionPath(String colPath) {
    this._collectionPath = colPath;
  }

  String get collectionPath {
    String str = _collectionPath.replaceAll('$docID', '');
    str = str.endsWith('/') ? str.substring(0, str.length - 1) : str;
    return str;
  }

  FirestoreDoc(this._collectionPath, {String docID}) {
    this.docID = docID != null ? docID : '';
    // if (docID != null)
    //   populateDocFromSnapshot();
  }

  // void updateDocFromSnapshot(AsyncSnapshot<dynamic> streamSnapshot);
  // void updateDocFromDocSnapshot(DocumentSnapshot snapshot);

  // static FirestoreDoc fromStreamSnapshot(AsyncSnapshot<dynamic> streamSnapshot, FromStreamSnapshot fromStream) {
  //   return fromStream(streamSnapshot);
  // }

  // static FirestoreDoc fromDocSnapshot(DocumentSnapshot snapshot, FromDocumentSnapshot fromDocument) {
  //   return fromDocument(snapshot);
  // }

  // this._id = obj['id'];
  // this._title = obj['title'];
  // this._description = obj['description'];
  // FirestoreDoc.map(dynamic obj);

  // var map = new Map<String, dynamic>();
  //   if (_id != null) {
  //     map['id'] = _id;
  //   }
  //   map['title'] = _title;
  //   map['description'] = _description;

  //   return map;
  Map<String, dynamic> toMap();

  // this._id = map['id'];
  // this._title = map['title'];
  // this._description = map['description'];
  //FirestoreDoc fromMap(Map<String, dynamic> map);

}

abstract class FirestoreCollection {
  CollectionReference colRef;
}
