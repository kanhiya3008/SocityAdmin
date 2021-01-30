import 'package:MyDen/Activity/Visitors/visitorsMainScreen.dart';
import 'package:MyDen/Devices/AlotDevices.dart';
import 'package:MyDen/administration/Accounting/AccountingMainScreen.dart';
import 'package:MyDen/administration/Alerts/AlertsMainScreen.dart';
import 'package:MyDen/administration/AmenityScreen/mainAmenityScreen.dart';
import 'package:MyDen/administration/Billing/BillingScreen/Billing.dart';
import 'package:MyDen/administration/Billing/BillingScreen/BillingMainScreen.dart';
import 'package:MyDen/administration/EventsScreen/EventsScreen.dart';
import 'package:MyDen/administration/GateScreen/mainGateScreen.dart';
import 'package:MyDen/administration/GuardScreen/mainGaurdScreen.dart';
import 'package:MyDen/administration/HousesScreen/HousesMainScreen.dart';
import 'package:MyDen/administration/NoticeScreen/NoticesScreen.dart';
import 'package:MyDen/administration/PollsScreen/pollmainScreen.dart';
import 'package:MyDen/administration/SocietyBudget/AddSocietySalary.dart';
import 'package:MyDen/administration/SocietyBudget/ShowSocietyBill.dart';
import 'package:MyDen/administration/SocietyBudget/SocietyHeaderSalary.dart';
import 'package:MyDen/administration/SocietyScreen/SocietyMainScreen.dart';

import 'package:MyDen/administration/vendorsScreen/vendorsMainScreen.dart';
import 'package:MyDen/bloc/AuthBloc.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/loginScreen/ActivationScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:MyDen/Constants/Constant_colors.dart';
import '../main.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>  with SingleTickerProviderStateMixin {
  double maxWidth = 210;
  double minWidth = 60;
  bool isCollapsed = false;
  AnimationController _animationController;
  Animation<double> widthAnimation;
  int currentSelectedIndex = 0;


  @override
  void initState() {

    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 300));
    widthAnimation = Tween<double>(begin: maxWidth, end: minWidth)
        .animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      // appBar: AppBar(
      //   title: Text("Welcome"),
      //   backgroundColor: UniversalVariables.background,
      // ),
      // drawer: Drawer(
      //
      //  child: Material(
      //    child: Container(
      //     // width: widthAnimation.value,
      //      color: UniversalVariables.background,
      //      child:  Column(
      //        children: <Widget>[
      //          CollapsingListTile(title: 'Profile', icon: Icons.person, animationController: _animationController,),
      //          Divider(color: Colors.grey, height: 80.0,),
      //          Expanded(
      //            child: ListView.separated(
      //              separatorBuilder: (context, counter) {
      //                return Divider(height: 12.0);
      //              },
      //              itemBuilder: (context, counter) {
      //                return CollapsingListTile(
      //                  onTap: () {
      //                    setState(() {
      //                      currentSelectedIndex = counter;
      //                 //_NavigateScreen();
      //                    });
      //                  },
      //                  isSelected: currentSelectedIndex == counter,
      //                  title: navigationItems[counter].title,
      //                  icon: navigationItems[counter].icon,
      //                  animationController: _animationController,
      //                );
      //              },
      //              itemCount: navigationItems.length,
      //            ),
      //          ),
      //          InkWell(
      //            onTap: () {
      //              AuthService().signOut();
      //              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyApp()));
      //            },
      //            child: Text('LogOut',style: TextStyle(color:UniversalVariables.ScaffoldColor, fontWeight: FontWeight.w800),)
      //          ),
      //          SizedBox(
      //            height: 50.0,
      //          ),
      //        ],
      //      ),
      //    ),
      //  )
      //
      //
      // ),



      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(children: [
          Positioned(
            bottom: 60,
            left: -MediaQuery.of(context).size.width * .4,
            child: BezierContainerTwo(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: ListView(
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ActivationScreen()));
                      },
                      child: Card(
                          elevation: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.menu),
                          )),
                    ),
                    Card(
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width/1.7,
                            child: Text("Welcome ",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                              ),overflow: TextOverflow.ellipsis,maxLines: 1,),
                          ),
                        )),
                    GestureDetector(
                      onTap: (){
                      context.bloc<AuthBloc>().signOut().then((value) =>
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyApp())));
                      },
                      child: Card(
                          elevation: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.close),
                          )),
                    ),
                  ],
                ),

                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Administration",
                          style: (TextStyle(
                            fontWeight: FontWeight.w800,
                          )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 12),
                        child: GridView.count(
                            crossAxisCount: 4,
                            crossAxisSpacing: 6,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children:
                                List.generate(_categories.length, (index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 5),
                                child: InkWell(
                                  splashColor: UniversalVariables.background,
                                  onTap: () {
                                    _NavigateScreen(index);
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15))),
                                    elevation: 10,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 2,
                                        ),
                                        Container(
                                          child: Image.network(
                                            _categories[index]["image"],
                                            height: 30,
                                            width: 30,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            _categories[index]["name"],
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            })),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Activity",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          GridView.count(
                              crossAxisCount: 3,
                              crossAxisSpacing: 6,
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              children:
                                  List.generate(_categoriesTwo.length, (index) {
                                return InkWell(
                                  onTap: (){
                                    _activatiyNavigation(index);
                                  },
                                  child: Card(
                                    elevation: 10,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.elliptical(120, 50))),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Image.network(
                                            'https://www.myden.ie/wp-content/themes/myden/images/my-den-logo-@2x.png',
                                            width: 45,
                                            height: 45,
                                            color: Colors.black.withOpacity(1),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          // right: 32,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 5,
                                              left: 2,
                                            ),
                                            child: Text(
                                              _categoriesTwo[index]["name"],
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(35.0),
                                          child: Align(
                                              alignment: Alignment(0, -0.1),
                                              child: Image.network(
                                                _categoriesTwo[index]["image"],
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })),
                        ]),
                  ),
                ),
                SizedBox(
                  height: 90,
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }


  Widget _activatiyNavigation (int indexValue) {
    if (indexValue == 0) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => GetExpectedVisitors()));
    } else if (indexValue == 1) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => HousesScreen()));
    } else if (indexValue == 2) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => GatesScreen()));
    } else if (indexValue == 3) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => AddGuard()));
    } else if (indexValue == 4) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => VendorsScreen()));
    } else if (indexValue == 5) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => AmenityScreen()));
    }
    else {
      return Text("");
    }
  }


  Widget _NavigateScreen(int indexValue) {
    if (indexValue == 0) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => SocietyScreen()));
    } else if (indexValue == 1) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => HousesScreen()));
    } else if (indexValue == 2) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => GatesScreen()));
    } else if (indexValue == 3) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => AddGuard()));
    } else if (indexValue == 4) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => VendorsScreen()));
    } else if (indexValue == 5) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => AmenityScreen()));
    } else if (indexValue == 6) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => EventsScreen()));
    } else if (indexValue == 7) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => NoticesScreen()));
    } else if (indexValue == 8) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => mainPollScreen()));
    } else if (indexValue == 9) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => AlertsScreen()));
    } else if (indexValue == 10) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => GetExpectedVisitors()));
    } else if (indexValue == 11) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => AllotDevices()));
    }else if (indexValue == 12) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => AccountingMainScreen()));
    }
    else if (indexValue == 13) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => BillingMainScreen()));
    }
    else if (indexValue == 14) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => SocietySalary()));
    }
    else if (indexValue == 15) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => ShowSocietyBill()));
    }
    else {
      return Text("");
    }
  }
}

List<Map<String, dynamic>> _categories = [
  {
    'name': 'Society',
    'icon': Icons.account_balance,
    'image': "https://www.isee.org/content/images/couch_people.png"
  },
  {
    'name': "Houses",
    'icon': Icons.face,
    'image':
        "https://www.iconarchive.com/download/i19000/iconshock/vista-general/house.ico"
  },
  {
    'name': 'Gates',
    'icon': Icons.close,
    'image':
        "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcS56SSZe6mbCuAnwJE6HKwUrbfHZEF6vgr5fw&usqp=CAU"
  },
  {
    'name': "Guards",
    'icon': Icons.tag_faces,
    'image':
        "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQqql2YQcUNjEGim1osCwmgXAiBvrgdo8lbnw&usqp=CAU"
  },
  {
    'name': 'Vendors',
    'icon': Icons.wb_sunny,
    'image': "https://image.flaticon.com/icons/png/128/79/79565.png"
  },
  {
    'name': "Amenity",
    'icon': Icons.wb_sunny,
    'image':
        "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSGQYakY1YcSEBpAdQe7tXM7-zq7IyHrctlTg&usqp=CAU"
  },
  {
    'name': 'Events',
    'icon': Icons.wb_sunny,
    'image':
        "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcT8CG02pBIg0AeXTtnoI1yFa2QqDFpYzIw54g&usqp=CAU"
  },
  {
    'name': "Notices",
    'icon': Icons.wb_sunny,
    'image':
        "https://cdn.iconscout.com/icon/free/png-256/notice-assistance-1817331-1538201.png"
  },
  {
    'name': "Polls",
    'icon': Icons.bookmark,
    'image': "https://www.shareicon.net/data/2015/06/05/49543_polls_256x256.png"
  },
  {
    'name': "Alerts",
    'icon': Icons.face,
    'image':
        "https://www.jknews7.com/wp-content/uploads/2017/10/high-importance-xxl.png"
  },
  {
    'name': "Visitors",
    'icon': Icons.face,
    'image':
    "https://authorisedvisitor.com/img/visitors/people.png"
  },
  {
    'name': "Devices",
    'image':
    "https://authorisedvisitor.com/img/visitors/people.png"
  },
  {
    'name': "Accounting",
    'image':
    "https://authorisedvisitor.com/img/visitors/people.png"
  },
  {
    'name': "Billings",
    'image':
    "https://authorisedvisitor.com/img/visitors/people.png"
  },
  {
    'name': "Salary H",
    'icon': Icons.pageview,
    'image': "https://www.cesc.co.in/ptrlineins/imags/Service-Charge-Bill.png"
  },
  {
    'name': "Salary",
    'icon': Icons.pageview,
    'image': "https://www.cesc.co.in/ptrlineins/imags/Service-Charge-Bill.png"
  },
];





List<Map<String, dynamic>> _categoriesTwo = [
  {
    'name': 'Visitors Book',
    'icon': Icons.account_balance,
    'image':
        "https://ps.w.org/comment-guestbook/assets/icon-256x256.png?rev=1024899"
  },
  // {
  //   'name': "Vehicle In/Out",
  //   'icon': Icons.card_giftcard,
  //   'image':
  //       "https://cdn2.iconfinder.com/data/icons/iconslandtransport/PNG/256x256/TowTruckYellow.png"
  // },
  // {
  //   'name': 'Complaints Log',
  //   'icon': Icons.email,
  //   'image':
  //       "https://i.pinimg.com/originals/81/4b/b7/814bb733cb83cb725cb56dba4966fc68.png"
  // },
  // {
  //   'name': "Suggestion",
  //   'icon': Icons.tag_faces,
  //   'image':
  //       "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQ87FiqPEMGwFoD3uJL9ZVAJVGa_LMaq43awQ&usqp=CAU"
  // },
  // {
  //   'name': 'Payments',
  //   'icon': Icons.wb_sunny,
  //   'image':
  //       "https://www.freepngimg.com/thumb/money/71649-salary-money-dollar-hand-holding-the-payment.png"
  // },
  // {
  //   'name': "Bills",
  //   'icon': Icons.pageview,
  //   'image': "https://www.cesc.co.in/ptrlineins/imags/Service-Charge-Bill.png"
  // },

];





