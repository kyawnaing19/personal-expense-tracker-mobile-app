import 'package:flutter/material.dart';

class RecordItem {
  
  String title;     
  String note;      
  String time;     
  String amount;   
  String type;     
  IconData icon;
  Color color;

  RecordItem({
    required this.title,
    required this.note,
    required this.time,
    required this.amount,
    required this.type,
    required this.icon,
    required this.color,
  });
}