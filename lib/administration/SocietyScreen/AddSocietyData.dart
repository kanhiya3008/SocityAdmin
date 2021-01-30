import 'package:MyDen/constants/ConstantTextField.dart';
import 'package:MyDen/constants/Constant_colors.dart';
import 'package:MyDen/constants/bezierContainer.dart';
import 'package:MyDen/model/sharedperef.dart';
import 'package:MyDen/screens/tabScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:MyDen/constants/global.dart' as global;

class AddSocietyData extends StatefulWidget {
  @override
  _AddSocietyDataState createState() => _AddSocietyDataState();
}

class _AddSocietyDataState extends State<AddSocietyData> {
  TextEditingController _flatController = TextEditingController();
  TextEditingController _paymentController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<Null> _selectDate(
      BuildContext context, DateTime firstDate, DateTime lastDate) async {
    DateTime selectedDate = firstDate;
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: firstDate,
        lastDate: lastDate);
    if (picked != null) // && picked != selectedDate)
      selectedDate = picked;
    String _formattedate =
        new DateFormat(global.dateFormat).format(selectedDate);
    setState(() {
      _startDateController.value = TextEditingValue(text: _formattedate);
    });
  }

  SaveSociety() {
    if (formKey.currentState.validate()) {
      setState(() {
        // print  ( prefs.get("activationCode"));
        isLoading = true;
      });
      Firestore.instance
          .collection("Society")
          .document(global.societyId)
          .setData({
        'numberOfFlates': _flatController.text,
        'paymentAmount': _paymentController.text,
        'date': _startDateController.text,
        'password': _passwordController.text,

      },merge: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -MediaQuery.of(context).size.height * .15,
            right: -MediaQuery.of(context).size.width * .4,
            child: BezierContainer(),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ListView(children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: UniversalVariables.background,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        "Add Society",
                        style: TextStyle(
                            color: UniversalVariables.background,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 50,
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    constantTextField().InputField(
                        "Number Of Flats",
                        "",
                        validationKey.flatNo,
                        _flatController,
                        false,
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.edit),
                        ),
                        1,1,
                        TextInputType.name,
                        false),
                    SizedBox(
                      height: 10,
                    ),
                    constantTextField().InputField(
                        "Payment Amount",
                        "",
                        validationKey.fixPrice,
                        _paymentController,
                        false,
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.edit),
                        ),
                        1,1,
                        TextInputType.number,
                        false),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () => _selectDate(
                          context,
                          DateTime.now().subtract(Duration(days: 0)),
                          DateTime.now().add(Duration(days: 365))),
                      child: IgnorePointer(
                        child: constantTextField().InputField(
                            "Select Date",
                            "20 - 12 - 2020",
                            validationKey.date,
                            _startDateController,
                            true,
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.calendar_today),
                            ),
                            1,1,
                            TextInputType.emailAddress,
                            false
                            //Icon(Icons.calendar_today)

                            ),
                      ),
                    ),
                   SizedBox(height: 10,),
                    constantTextField().InputField(
                        "Password",
                        "",
                        validationKey.guardPassword,
                        _passwordController,
                        false,
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.edit),
                        ),
                        1,1,
                        TextInputType.number,
                        false),


                  ],
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                  width: 2,
                ),
                GestureDetector(
                    onTap: () {
                      SaveSociety();
                    },
                    child: Card(
                        color: UniversalVariables.background,
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 8, bottom: 8),
                          child: Text(
                            "Save",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                          ),
                        ))),
              ])
            ]),
          )
        ],
      ),
    );
  }
}
