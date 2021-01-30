// import 'package:flutter/material.dart';//AmenityScreen
// class AmenityScreen extends StatefulWidget {
//
//   _MyWidgetState createState()=>_MyWidgetState();
//
// }
// class _MyWidgetState extends State<AmenityScreen>{
//   List _selectedIndexs=[];
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       body:  ListView.builder(
//           itemCount: 4,
//           itemBuilder: (ctx,i){
//             final _isSelected=_selectedIndexs.contains(i);
//             return GestureDetector(
//               onTap:(){
//                 setState((){
//                   if(_isSelected){
//                     _selectedIndexs.remove(i);
//
//                   }else{
//                     _selectedIndexs.add(i);
//
//                   }
//                 });
//               },
//               child:Container(
//                 color:_isSelected?Colors.red:null,
//                 child:ListTile(title:Text("Khadga")),
//               ),
//             );
//           }
//       ),
//     );
//
//
//
//   }
//
//
// }
