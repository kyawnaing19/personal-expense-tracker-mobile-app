import 'package:flutter/material.dart';

class RecordItem {
  // edit လုပ်တဲ့အခါ တန်ဖိုးအသစ် အစားထိုးနိုင်ရန် final များကို ဖြုတ်လိုက်ပါသည်
  String title;     // Category Name
  String note;      // Note စာသား
  String time;      // စာရင်းသွင်းချိန်
  String amount;    // ငွေပမာဏ
  String type;      // 'expense' သို့မဟုတ် 'income'
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