import 'package:flutter/material.dart';

class HomeButton extends StatefulWidget {
  final String name;
  final VoidCallback onTap;
  const HomeButton({super.key,required this.onTap,required this.name});

  @override
  State<HomeButton> createState() => _HomeButtonState();
}

class _HomeButtonState extends State<HomeButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 65,
        width: MediaQuery.of(context).size.width*.40,
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: Colors.grey
        ),
        child: Center(
          child: Text(
            widget.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      
      ),
    );
  }
}