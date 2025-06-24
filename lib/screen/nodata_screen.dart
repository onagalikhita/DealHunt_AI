import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NodataScreen extends StatelessWidget {
  const NodataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> actionsList = [
      {'name': 'Think', 'icon': Icons.lightbulb, 'color': Colors.amber},
      {'name': 'Search', 'icon': Icons.search, 'color': Colors.red},
      {'name': 'Compare', 'icon': Icons.compare, 'color': Colors.blue},
      {'name': 'Shop', 'icon': Icons.shopping_cart, 'color': Colors.green},
      {'name': 'AI Suggestions', 'icon': Icons.psychology, 'color': Colors.orange},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SingleChildScrollView( // Wrap everything inside a scrollable container
        child: Container(
          margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
          padding: const EdgeInsets.all(20.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
              color: const Color(0xFFD3D3D3),
              width: 0.4,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.inter(height: 1.2),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Search For ',
                      style: GoogleFonts.inter(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF000000),
                      ),
                    ),
                    TextSpan(
                      text: 'Products \n',
                      style: GoogleFonts.inter(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [Color(0xFFFF6F61), Color(0xFF3B5998)],
                            begin: Alignment.topLeft,
                            end: Alignment.topRight,
                          ).createShader(Rect.fromLTWH(0.0, 0.0, 1000.0, 14.0)),
                      ),
                    ),
                    TextSpan(
                      text: 'Efficiently At No Cost',
                      style: GoogleFonts.inter(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF000000),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                children: actionsList.map((action) {
                  return Container(
                    padding: const EdgeInsets.all(3.0),
                    margin: const EdgeInsets.only(right: 10.0, top: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: const Color(0xFFF9F9FA),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            action['icon'],
                            size: 12.0,
                            color: action['color'],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            action['name'],
                            style: GoogleFonts.inter(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF000000),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

