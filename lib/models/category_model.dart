import 'package:flutter/material.dart';

class CategoryItem {
  final String id; 
  String name; 
  IconData icon; 
  Color color; 
  String type; 

  CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  }); 
}