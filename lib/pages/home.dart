import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_auth/utils/auth.dart';

class HomePage extends StatelessWidget {
  HomePage({this.auth, this.onSignOut});
  final BaseAuth auth;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    void _signOut() async {
      try {
        await auth.signOut();
        onSignOut();
      } catch (e) {
        print(e);
      }
    }

    return new Scaffold(
        appBar: new AppBar(
          actions: <Widget>[
            new FlatButton(
                onPressed: _signOut,
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)))
          ],
        ),
        body: new FutureBuilder(
          future: _getStream(),
          builder: (BuildContext context, AsyncSnapshot<String>userSnapshot){
            if (userSnapshot.connectionState != ConnectionState.done) return new Center(child: new Container(child:CircularProgressIndicator()));
          return new Center(child: new Container(child:Text(userSnapshot.data.toString(), style: TextStyle(fontSize: 40))));
          // return new StreamBuilder(
          //   stream: _getStream(),      //Firestore.instance.collection('users').document(Firestore.instance.document(userSnapshot.data.toString())),
          //   builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          //     if (!snapshot.hasData) return new Center(child: new Container(child:CircularProgressIndicator()));
          //     return new Center(child: new Container(child:new Text(
          //       snapshot.data.documents[0]['email'], 
          //     style: new TextStyle(fontSize: 50))));
          //   }
          // );
        
          }
        )
        );
  }

  
}


Future<String> _getStream() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String uid = user.uid;
    var docReference = Firestore.instance.collection('users').document(uid);
    return docReference.get().then((documentSnapshot) {
      if (documentSnapshot.exists)
        return documentSnapshot.data['email'];
      else
        return "Document for user $uid was not found.";
    });
    // var snapshots = Firestore.instance.collection('users').document(uid).collection('mainlist').snapshots();
    // return snapshots;
  }
//   Widget _buildListItem(BuildContext context, DocumentSnapshot doc){
//     return new ListTile(
//       title: new Text(doc['title']),
//       subtitle: new Text(doc['type']),
//     );
//   }
// }


  

//   Future<String> getUID() async {
//     FirebaseUser user = await FirebaseAuth.instance.currentUser();
//     return user.uid;
//   }

// new StreamBuilder(
//           stream: _getStream(),
//           builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
//             if (!snapshot.hasData) return new Center(child: new Container(child:CircularProgressIndicator()));
//             return ListView.builder(
//           itemExtent: 80.0,
//           itemCount: snapshot.data.documents.length,
//           itemBuilder: (context, index) => _buildListItem(context, snapshot.data.documents[index]),
//         );
//           }
        

