// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:residents/Constant/Constant_Color.dart';
// import 'package:residents/Constant/globalsVariable.dart' as global;
// import 'package:residents/ModelClass/billing.dart';
// import 'package:residents/notification.dart';
//
// import 'DueBillingHistory.dart';
//
// class PaidBillingHistory extends StatefulWidget {
//   final billHead;
//
//   const PaidBillingHistory({Key key, this.billHead}) : super(key: key);
//   @override
//   _BillingMainScreenState createState() => _BillingMainScreenState();
// }
//
// class _BillingMainScreenState extends State<PaidBillingHistory>  {
//   List<BillingModel> billingList = List<BillingModel>();
//
//   bool isLoading = false;
//   bool hasMore = true;
//   int documentLimit = 5;
//   DocumentSnapshot lastDocument = null;
//   bool isExpanded = false;
//   ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     //getBillingDetails(lastDocument);
//     super.initState();
//   }
//
//   @override
//
//
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(children: [
//         SizedBox(
//           height: 10,
//         ),
//         Expanded(
//           child: billingList.length == 0
//               ? Center(child: Text("No Data"))
//               : ListView.builder(
//             controller: _scrollController,
//             itemCount: billingList.length,
//             itemBuilder: (context, index) {
//               return Padding(
//                   padding: const EdgeInsets.only(left: 12, right: 12),
//                   child: GestureDetector(
//                       onTap: () {
//
//                       },
//                       child: Card(
//                         // width: MediaQuery.of(context).size.width,
//                         child: Column(
//                           children: <Widget>[
//                             Padding(
//                               padding: const EdgeInsets.all(5.0),
//                               child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       billingList[index].billingHeader,
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.w800,
//                                         fontSize: 20,
//
//                                       ),overflow: TextOverflow.ellipsis,maxLines: 1,
//                                     ),
//                                     Text(
//                                       "Paid Bill",
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.w800,
//                                           fontSize: 20,
//                                           color: Colors.green
//
//                                       ),overflow: TextOverflow.ellipsis,maxLines: 1,
//                                     )
//
//                                   ]),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(5.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(children: [
//                                     Text(
//
//                                       billingList[index].mode,
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                       ),
//                                     ),
//                                     Spacer(),
//                                     Text(
//                                       "Total Amount - " +
//                                           billingList[index].totalAmount.toString(),
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.w800,
//                                         fontSize: 15,
//                                       ),
//                                     ),
//                                   ]),
//                                   Text(
//                                     "Bill Issue Date - " +
//                                         DateFormat(global.dateFormat)
//                                             .format(billingList[index]
//                                             .startDate),
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                     ),
//                                   ),
//                                   Text(
//                                     "Bill Pay Date - " +
//                                         DateFormat(global.dateFormat)
//                                             .format(billingList[index]
//                                             .endDate),
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                     ),
//                                   ),
//                                   Text(
//                                     "Valid UpTo - " +
//                                         billingList[index].validDays + " days",
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                     ),
//                                   ),
//
//
//                                   SizedBox(height: 10,),
//                                 ],
//                               ),
//                             )
//                           ],
//                         ),
//                       )
//                   )
//
//
//               );
//             },
//           ),
//         ),
//         isLoading
//             ? Container(
//           width: MediaQuery.of(context).size.width,
//           padding: EdgeInsets.all(5),
//           color: UniversalVariables.background,
//           child: Text(
//             'Loading......',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: UniversalVariables.ScaffoldColor,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         )
//             : Container()
//       ]),
//     );
//   }
//
// }
