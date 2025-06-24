import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LargeButton extends StatelessWidget {
  const LargeButton({super.key, this.text, this.function, this.icon});

  // Variables
  final text;
  final function;
  final icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: GestureDetector(
        onTap: function,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5.0),
          child: Container(
            height: 56.0,
            color: Color(0xFFFF6F61),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Color(0xFFFFFFFF)),
                SizedBox(
                  width: 3.0,
                ),
                Text(
                  text,
                  style: GoogleFonts.rubik(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
