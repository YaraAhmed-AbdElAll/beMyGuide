import 'package:flutter/material.dart';
class Customicon extends StatelessWidget{
  final IconData myIcon;
  final Color iconColor;
  final bool? isLoading;
  final Future<void> Function()? onPressed;
  const Customicon({super.key,required this.myIcon,required this.iconColor, this.onPressed, this.isLoading});
  @override
  Widget build(BuildContext context) {
   return Container(
                width: 70,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child:  Center(
        child: isLoading == true
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: iconColor,
                ),
              )
            : IconButton(
                onPressed: onPressed,
                icon: Icon(myIcon),
                color: iconColor,
                iconSize: 30,
              ),
      ),
              );
  }
  
}