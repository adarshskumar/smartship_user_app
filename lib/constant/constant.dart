import 'package:flutter/material.dart';

const kThemeBlueColor = Color.fromRGBO(0,171,237,1.0);
const kThemeGreenColor = Color.fromRGBO(138,196,63,1.0);


var KStandardBoxShadow = [BoxShadow(
    offset: Offset(1,3),
    blurRadius: 3.0,
    color: Colors.blueGrey.shade100
)];

const KCardHeadingTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 30.0,
    color: Colors.black,
    shadows: [Shadow(offset: Offset(2,2),blurRadius: 1.0,color: Colors.grey)]
);


const KCardSubHeadingTextStyle = TextStyle(
  fontWeight: FontWeight.w800,
  fontSize: 15.0,
  fontFamily: 'Monte',
  color: Colors.black,
);

const KPriceTextStyle = TextStyle(
    fontSize: 50.0,
    fontFamily: 'Monte',
    color: Colors.black
);

const KProductImageTextStyle = TextStyle(
    fontSize: 25.0,
    fontFamily: 'Monte',
    color: Colors.black, shadows: [
  Shadow(
      offset: Offset(2, 3),
      blurRadius: 3.0,
      color: Colors.white),
]);