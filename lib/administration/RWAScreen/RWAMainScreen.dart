import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:MyDen/constants/global.dart' as global;

import 'addAnotherRAW.dart';

class RWAMainScreen extends StatefulWidget {
  @override
  _RWAMainScreenState createState() => _RWAMainScreenState();
}

class _RWAMainScreenState extends State<RWAMainScreen> {
  DocumentSnapshot lastDocument = null;
  List<UserData> userDataList = List<UserData>();
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHouseMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Society RWA"),
      ),
      body:  Stack(children: [

        Column(children: [
          SizedBox(
            height: 10,
          ),

          Expanded(
            child: userDataList.length == 0
                ? Center(
              child: Text("No data"),
            )
                : ListView.builder(

              itemCount: userDataList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12,),
                  child:   Card(
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  userDataList[index].name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800, fontSize: 13),
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              children: [
                                Container(
                                    decoration:
                                    BoxDecoration(borderRadius: BorderRadius.circular(70)),
                                    height: 70,
                                    width: 70,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(70),
                                        child: Padding(
                                            padding: EdgeInsets.all(5),
                                            child: ClipRRect(
                                                borderRadius: BorderRadius.circular(70),
                                                child: userDataList[index].profilePhoto == null ||
                                                    userDataList[index].profilePhoto == ""
                                                    ? Image.network(
                                                    "https://icon-library.com/images/person-image-icon/person-image-icon-6.jpg")
                                                    :
                                                Image.network(userDataList[index].profilePhoto)
                                            )))),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    userDataList[index].phoneNo == null || userDataList[index].phoneNo == ""
                                        ? Text("Update Yor Mobile Number")
                                        :
                                    Text(
                                        userDataList[index].phoneNo)
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      )),


                );
              },
            ),
          ),
          isLoading
              ? Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(5),
            color: UniversalVariables.background,
            child: Text(
              'Loading......',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: UniversalVariables.ScaffoldColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
              : Container()
        ]),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.push(context,
                     CupertinoPageRoute(builder: (context) => addRAW()));
      },child: Text("Add"),),
    );
  }



  getHouseMembers()  {
    QuerySnapshot querySnapshot;
    Firestore.instance.collection("Society").document(global.societyId)
        .collection("RWA")
        .where("enable",isEqualTo: true)
        .getDocuments().then((value) {
      value.documents.forEach((element) async {
        querySnapshot = await
        Firestore.instance
            .collection("users")
            .where("id",isEqualTo: element['RWAId'])
            .getDocuments();
        if (querySnapshot.documents.length != 0) {
          lastDocument =
          querySnapshot.documents[querySnapshot.documents.length - 1];
          print("final data");
          setState(() {
            querySnapshot.documents.forEach((element) {
              var userData = UserData();
              userData = UserData.fromMap(element.data);
              userDataList.add(userData);
            });
          });
        }

      }
      );


    });
  }
}
