
import 'package:flutter/material.dart';

class ElevatedCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  const ElevatedCard({
    required this.child,this.elevation=10,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(


        color: Colors.white,
        elevation: elevation,
        child: child);
  }
}