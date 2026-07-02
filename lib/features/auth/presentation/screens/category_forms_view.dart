import 'package:flutter/material.dart';

class CategoryFormsView {
   static Widget buildAddCategoryView({
    required BoxConstraints constraints,
    required TextEditingController nameController,
    required Color tempColor,
    required IconData tempIcon,
    required String tempType,
    required List<Color> availableColors,
    required List<IconData> availableIcons,
    required Function(Color) onColorSelected,
    required Function(IconData) onIconSelected,
    required VoidCallback onSave,
  }) {
    return Container(
      color: Colors.white,
      height: constraints.maxHeight,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormInputs(
                    nameController: nameController,
                    tempColor: tempColor,
                    tempIcon: tempIcon,
                    tempType: tempType,
                  ),
                  const SizedBox(height: 20),
                  const Text("Choose Colour", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 12),
                  _buildColorPicker(availableColors, tempColor, onColorSelected),
                  const SizedBox(height: 24),
                  const Text("Choose Icon", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 12),
                  _buildIconGrid(availableIcons, tempIcon, onIconSelected),
                  const SizedBox(height: 16), 
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
            child: _buildSaveButton(label: "Save", onPressed: onSave),
          ),
        ],
      ),
    );
  }
    static Widget buildEditCategoryView({
    required BoxConstraints constraints,
    required TextEditingController nameController,
    required Color tempColor,
    required IconData tempIcon,
    required String tempType,
    required List<Color> availableColors,
    required Function(Color) onColorSelected,
    required VoidCallback onCancel,
    required VoidCallback onDone,
  }) {
    return Container(
      color: Colors.white, 
      height: constraints.maxHeight,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // အပေါ်ပိုင်း Input နှင့် Color Picker အပိုင်း
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormInputs(nameController: nameController, tempColor: tempColor, tempIcon: tempIcon, tempType: tempType), 
                  const SizedBox(height: 24),
                  const Text("Choose Colour", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 14),
                  _buildColorPicker(availableColors, tempColor, onColorSelected),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
                // Cancel Button (ခရမ်းရောင်)
                SizedBox(
                  width: 110,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7F3DFF), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: onCancel,
                    child: const Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                
                // Done Button (ခရမ်းရောင်)
                SizedBox(
                  width: 110,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7F3DFF), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: onDone,
                    child: const Text("Done", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // 3️⃣ Calendar View
  static Widget buildCalendarView({
    required double screenWidth,
    required DateTime currentSelectedCalendarDate,
    required Function(DateTime) onDateSelected,
  }) {
    final List<String> weekdays = ["S", "M", "T", "W", "T", "F", "S"];
    final DateTime now = currentSelectedCalendarDate;
    final int year = now.year;
    final int month = now.month;

    final DateTime firstDayOfMonth = DateTime(year, month, 1);
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final int firstWeekdayIndex = firstDayOfMonth.weekday % 7; 
    final int daysInPrevMonth = DateTime(year, month, 0).day;

    final List<Map<String, dynamic>> calendarDays = [];

    for (int i = firstWeekdayIndex - 1; i >= 0; i--) {
      calendarDays.add({
        "day": daysInPrevMonth - i,
        "isCurrentMonth": false,
        "date": DateTime(year, month - 1, daysInPrevMonth - i)
      });
    }

    for (int i = 1; i <= daysInMonth; i++) {
      calendarDays.add({
        "day": i,
        "isCurrentMonth": true,
        "date": DateTime(year, month, i)
      });
    }

    int totalSlots = 42; 
    int nextMonthDay = 1;
    while (calendarDays.length < totalSlots) {
      calendarDays.add({
        "day": nextMonthDay,
        "isCurrentMonth": false,
        "date": DateTime(year, month + 1, nextMonthDay)
      });
      nextMonthDay++;
    }

    return Container(
      color: Colors.white, 
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.map((w) => SizedBox(
              width: screenWidth / 8,
              child: Text(w, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
            )).toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              itemCount: calendarDays.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, 
                mainAxisSpacing: 14, 
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final dayData = calendarDays[index];
                final int dayNumber = dayData["day"];
                final bool isCurrentMonth = dayData["isCurrentMonth"];
                final DateTime cellDate = dayData["date"];

                bool isSelectedDay = isCurrentMonth && 
                    (cellDate.day == currentSelectedCalendarDate.day) &&
                    (cellDate.month == currentSelectedCalendarDate.month) &&
                    (cellDate.year == currentSelectedCalendarDate.year);

                return GestureDetector(
                  key: ValueKey(cellDate.toString()), 
                  onTap: () => onDateSelected(cellDate),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelectedDay ? const Color(0xFF7F3DFF) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      dayNumber.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelectedDay ? FontWeight.bold : FontWeight.w600,
                        color: isSelectedDay 
                            ? Colors.white 
                            : (isCurrentMonth ? Colors.black : const Color(0xFF9CA3AF)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildFormInputs({
    required TextEditingController nameController,
    required Color tempColor,
    required IconData tempIcon,
    required String tempType,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Icon", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
          trailing: CircleAvatar(
            backgroundColor: tempColor, 
            radius: 24, 
            child: Icon(tempIcon, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 10),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Name", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
          trailing: SizedBox(
            width: 180,
            child: TextField(
              controller: nameController,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 15, color: Colors.black),
              decoration: const InputDecoration(
                hintText: "Enter category name...",
                border: InputBorder.none,
                suffixIcon: Icon(Icons.edit, size: 16, color: Color(0xFF9CA3AF)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Type", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
          trailing: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(tempType, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16)),
          ),
        ),
      ],
    );
  }

  static Widget _buildColorPicker(List<Color> colors, Color selectedColor, Function(Color) onSelected) {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          bool isSelected = selectedColor == color;
          return GestureDetector(
            onTap: () => onSelected(color),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected ? Border.all(color: const Color(0xFFF472B6), width: 3) : null,
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _buildIconGrid(List<IconData> icons, IconData selectedIcon, Function(IconData) onSelected) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, mainAxisSpacing: 16, crossAxisSpacing: 16
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final icon = icons[index];
        bool isSelected = selectedIcon == icon;
        return GestureDetector(
          onTap: () => onSelected(icon),
          child: CircleAvatar(
            backgroundColor: isSelected ? const Color(0xFFFCE7F3) : const Color(0xFFE5E7EB),
            child: Icon(icon, color: isSelected ? const Color(0xFFEC4899) : const Color(0xFF6B7280)),
          ),
        );
      },
    );
  }

  static Widget _buildSaveButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7F3DFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}