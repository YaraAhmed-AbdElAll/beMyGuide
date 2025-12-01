import 'package:flutter/material.dart';

class Customtextformfield extends StatelessWidget{
  final String hintext;
  final TextEditingController myController;
 final String? Function(String?)? validator;
 final bool obscuretext;
  const Customtextformfield ({super.key,required this.hintext,required this.myController,required this.validator,required this.obscuretext});
  @override
  Widget build(BuildContext context) {
  return  TextFormField(
                validator: validator,
                controller:myController,
                obscureText: obscuretext,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: hintext,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              );
  }

}