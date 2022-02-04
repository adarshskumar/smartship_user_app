
import 'package:flutter/cupertino.dart';

class Policy{
  final String name;
  final int policyNum;
  bool isActive;

  Policy({@required this.name,@required this.policyNum,this.isActive=true});

  Future<String> getName()async{
    return this.name;
  }

  int getPolicyNum(){
    return this.policyNum;
  }

  bool isPolicyActive(){
    return this.isActive;
  }

}