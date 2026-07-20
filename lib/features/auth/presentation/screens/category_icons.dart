import 'package:flutter/material.dart';

const Map<String, IconData> kCategoryIcons = {
  'restaurant': Icons.restaurant,
  'shopping_bag': Icons.shopping_bag,
  'directions_car': Icons.directions_car,
  'home': Icons.home,
  'local_hospital': Icons.local_hospital,
  'school': Icons.school,
  'flight': Icons.flight,
  'movie': Icons.movie,
  'fitness_center': Icons.fitness_center,
  'dry_cleaning': Icons.dry_cleaning,
  'pets': Icons.pets,
  'wifi': Icons.wifi,
  'build': Icons.build,
  'card_giftcard': Icons.card_giftcard,
  'attach_money': Icons.attach_money,
  'payments': Icons.payments,
  'trending_up': Icons.trending_up,
  'storefront': Icons.storefront,
  'account_balance': Icons.account_balance,
  'calendar_month_outlined': Icons.calendar_month_outlined,
  'handshake': Icons.handshake,
  'phone': Icons.phone,
  'school_outlined': Icons.school_outlined,
  'music_note_outlined': Icons.music_note_outlined,
  'headphones': Icons.headphones,
  'local_cafe': Icons.local_cafe,
  'health_and_safety': Icons.health_and_safety,
  'computer': Icons.computer,
  'cake': Icons.cake,
  'content_cut': Icons.content_cut,       
  'lunch_dining': Icons.lunch_dining,     
  'egg_alt': Icons.egg_alt,               
  'checkroom': Icons.checkroom,           
  'sports_esports': Icons.sports_esports, 
  'medical_services': Icons.medical_services,
  'child_care': Icons.child_care,
  'book': Icons.book,
  'local_gas_station': Icons.local_gas_station,
  'electric_bolt': Icons.electric_bolt,   
  'water_drop': Icons.water_drop,        
  'savings': Icons.savings,
};

const String kDefaultIconKey = 'restaurant';
const IconData kDefaultIcon = Icons.restaurant;
IconData resolveIcon(String? key) {
  if (key == null) return kDefaultIcon;
  return kCategoryIcons[key] ?? kDefaultIcon;
}

bool isKnownIconKey(String? key) {
  if (key == null) return false;
  return kCategoryIcons.containsKey(key);
}
String iconToKey(IconData icon) {
  for (final entry in kCategoryIcons.entries) {
    if (entry.value == icon) return entry.key;
  }
  return kDefaultIconKey;
}

List<IconData> get kAvailableIconsList => kCategoryIcons.values.toList();