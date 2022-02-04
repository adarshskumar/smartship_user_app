import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final Function onChange;
  final String label;
  final Function validate;
  final TextInputType keyboardType;
  final bool obscure;

  CustomTextField(
      {this.onChange,
      this.label,
      this.validate,
      this.keyboardType,
      this.obscure = false});

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
//  final TextEditingController c = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
      child: TextFormField(
        validator: widget.validate,
        keyboardType: widget.keyboardType,
        autofocus: false,
        onChanged: widget.onChange,
        obscureText: widget.obscure,
        decoration: InputDecoration(
          labelText: widget.label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              4.0,
            ),
          ),
        ),
      ),
    );
  }
}
