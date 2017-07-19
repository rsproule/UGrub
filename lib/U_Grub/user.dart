import 'package:flutter/foundation.dart';

class User {
  const User({
    @required this.name,
    @required this.image,
    @required this.Id,
    this.contactInfo
  }) :  assert(name != null),
        assert(image != null),
        assert(Id != null);

  final String name;
  final String image;
  final ContactInfo contactInfo;
  final String Id;


}

class ContactInfo {
   ContactInfo({
    this.email,
    this.phoneNumber,
    this.facebookLink,

  });

  String phoneNumber = "None Listed";
  String facebookLink = "None Listed";
  String email = "None Listed";

}