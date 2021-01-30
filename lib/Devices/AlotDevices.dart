import 'package:MyDen/Devices/DeviceActivation.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:MyDen/constants/global.dart' as global;

import 'DevicePassword.dart';

class AllotDevices extends StatefulWidget {
  @override
  _AllotDevicesState createState() => _AllotDevicesState();
}

class _AllotDevicesState extends State<AllotDevices> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UniversalVariables.background,
        title: Text(
          "Allot Devices",
          style: TextStyle(color: UniversalVariables.ScaffoldColor),
        ),
      ),
      body: Container(
        child: StreamBuilder(
            stream: Firestore.instance
                .collection("Society")
                .document(global.societyId)
                .collection("Devices")
                .where("enable", isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('loading....');
              return ListView.builder(
                reverse: true,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) =>
                    _imei(context, snapshot.data.documents[index]),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DeviceActivation()));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _imei(BuildContext context, DocumentSnapshot document) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Row(
            children: [
              Expanded(
                child: Text(document["imei"]),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _showDialog(document["imei"]);
                },
              )
            ],
          )),
    );
  }

  Future<void> _showDialog(String deviceId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Are you sure want to disabled this device",
                  style: TextStyle(color: UniversalVariables.background),
                )
              ],
            ),
          ),
          actions: <Widget>[

            RaisedButton(
              child: Text('No'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            RaisedButton(
              child: Text('yes'),
              onPressed: () {
                delete(deviceId);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  delete(deviceId) {
    Firestore.instance
        .collection("Society")
        .document(global.societyId)
        .collection("Devices")
        .document(deviceId)
        .updateData({"enable": false});
  }
}
