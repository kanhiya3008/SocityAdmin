import 'package:MyDen/validator/validator.dart';
import 'package:flutter/material.dart';
import 'package:MyDen/validator/validator.dart';
import 'package:regexpattern/regexpattern.dart';

 enum validationKey {email, payment, Description, activationCode, date, venue,
   time, device, gateNo, entrance, ownerName, towerNumber, familyMember, documentType,
   adharCard, panCard, gender, password,username,mobileNo,otherMobileNo,name,companyName,
   society, flatNo,controller,option,confirmPassword,validDocumentType,
   amenity,societyCode,guardPassword,mode,TimePeriod,mandatory,BillHeader,houseArea,sqArea,perUnit,unit,fixPrice,interest,enterValidDay}

class constantTextField {



  Widget InputField(String labletext, String hintText,
      validationKey inputValidate,
      TextEditingController controller,
      bool isIconShow,
      IconButton image,
      int maxline,
      int _errorMaxLines,
      TextInputType keyboardType,
      bool _obscureText,
      ){
    return TextFormField(
     keyboardType: keyboardType,
      maxLines: maxline,


      obscureText:  _obscureText,
      controller: controller,
        validator:  (input) =>
        validateInput(input, inputValidate),
        style: TextStyle(
        fontSize: 15.0,
        color: Colors.black,
        ),
        decoration: InputDecoration(
          errorMaxLines: _errorMaxLines,
          suffixIcon: isIconShow ? image : null,
          labelText: labletext,
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
//            border: OutlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
            contentPadding: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 32.0)
        ));
  }

  String validateInput(String inputValue, validationKey key){

    switch(key){
      case validationKey.email:
        // ignore: unnecessary_statements
       return inputValue.isValidEmail() ? null : "Enter correct email";
    break;
      case validationKey.societyCode:
        // ignore: unnecessary_statements
        return inputValue.isValidSocietyCode() ? null : "Enter Correct SocietyCode";
        break;
      case validationKey.name:
        return inputValue.isValidName() ? null : "Enter correct Name";
        break;
      case validationKey.companyName:
        return inputValue.isValidCompanyNmae() ? null : "Enter correct Company Name";
        break;
      case validationKey.mobileNo:
        return inputValue.isValidMobile() ? null : "Please enter valid mobile number";
        break;
      case validationKey.society:
        return inputValue.isValidSociety() ? null : "Enter Full Society Name";
        break;
      case validationKey.flatNo:
        return inputValue.isValidTowerNo() ? null : "Must be Upper Case";
        break;
      case validationKey.payment:
        return inputValue.isValidPayment() ? null : "Enter payment";
        break;
      case validationKey.Description:
        return inputValue.isValidDescription() ? null : "Describe more than 5 words";
        break;
      case validationKey.activationCode:
        return inputValue.isValidActivationCode() ? null : "Enter correct Code";
        break;
      case validationKey.date:
        return inputValue.isValidActiveDate() ? null : "Enter Date here";
        break;
      case validationKey.venue:
        return inputValue.isValidActiveVenue() ? null : "Enter Venue name here";
        break;
      case validationKey.time:
        return inputValue.isValidActiveTime() ? null : "Enter Event time here";
        break;
      case validationKey.device:
        return inputValue.isValidFamilyNo() ? null : "How Many device are there on gate";
        break;
      case validationKey.gateNo:
        return inputValue.isValidTowerNo() ? null : "Enter Gate Number Here";
        break;
      case validationKey.entrance:
        return inputValue.isValidTowerNo() ? null : "Enter Entrance Mode";
        break;
      case validationKey.familyMember:
        return inputValue.isValidFamilyNo() ? null : "Enter Total Family member ";
        break;
      case validationKey.ownerName:
        return inputValue.isValidOwnerName() ? null : "Enter owner Name";
        break;
      case validationKey.towerNumber:
        return inputValue.isValidTowerNo() ? null : "Enter Tower Number";
        break;
      case validationKey.panCard:
        return inputValue.isValidDocument() ? null : "Enter Correct PanCard Number";
        break;
      case validationKey.adharCard:
        return inputValue.isValidAadhaar() ? null : "The aadhaar number must be 12 characters long";
        break;
      case validationKey.gender:
        return inputValue.isValidGender() ? null : "Plz Select your Gender";
        break;
      case validationKey.option:
        return inputValue.isValidGender() ? null : "Plz choose your option";
        break;
      case validationKey.password:
        return inputValue.isPasswordHard() ? null : " Must contains at least: 1 uppercase letter, 1 lowecase letter, 1 number, & 1 special character (symbol)";

        break;
      case validationKey.validDocumentType:
        return inputValue.validDocumentType() ? null : "Select Document Type";
        break;
      case validationKey.amenity:
        return inputValue.isValidName() ? null : "Enter Amenity Name";
        break;
      case validationKey.guardPassword:
        return inputValue.isGuardPassword() ? null : "Enter 6 digit Password";
        break;
      case validationKey.mandatory:
        return inputValue.validDocumentType() ? null : "Select mandatory first";
        break;
      case validationKey.mode:
        return inputValue.validDocumentType() ? null : "Select mode first";
        break;
      case validationKey.TimePeriod:
        return inputValue.validDocumentType() ? null : "Select TimePeriod first";
        break;
      case validationKey.BillHeader:
        return inputValue.isValidName() ? null : "Select Header First";
        break;
      case validationKey.houseArea:
        return inputValue.houseArea() ? null : "Enter House Area";
        break;
      case validationKey.sqArea:
        return inputValue.houseArea() ? null : "Enter House Area";
        break;
      case validationKey.perUnit:
        return inputValue.houseArea() ? null : "Enter Per Unit Price";
        break;
      case validationKey.unit:
        return inputValue.houseArea() ? null : "Enter Total Unit";
        break;
      case validationKey.fixPrice:
        return inputValue.houseArea() ? null : "Enter Fix Price";
        break;
      case validationKey.interest:
        return inputValue.houseArea() ? null : "Enter Interest Price";
        break;
      case validationKey.enterValidDay:
        return inputValue.validDocumentType() ? null : "This field can't be empty";
        break;
    }
  }

}