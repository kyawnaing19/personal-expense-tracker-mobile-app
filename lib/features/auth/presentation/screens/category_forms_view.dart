import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; 

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
    required VoidCallback onCancel,
    required VoidCallback onDone,
  }) {
    return Container(
      color: const Color(0xFFE8DEF8),
      width: double.infinity,
      height: constraints.maxHeight,

      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormInputs(
                nameController: nameController,
                tempColor: tempColor,
                tempIcon: tempIcon,
                tempType: tempType,
                showType: true,
              ),
              const SizedBox(height: 20),
              const Text("Choose Colour", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 12),
              _buildColorPicker(availableColors, tempColor, onColorSelected),
              const SizedBox(height: 24),
              const Text("Choose Icon", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 12),
              _buildIconGrid(availableIcons, tempIcon, onIconSelected),
              const SizedBox(height: 24),
              _buildButtonRow(
                leftLabel: "Cancel",
                leftIsOutlined: true,
                onLeft: onCancel,
                rightLabel: "Done",
                onRight: onDone,
              ),
            ],
          ),
        ),
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
    required VoidCallback onDelete,
    required VoidCallback onDone,
  }) {
    return Container(
      color: const Color(0xFFE8DEF8),
      width: double.infinity,
      height: constraints.maxHeight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormInputs(
                nameController: nameController,
                tempColor: tempColor,
                tempIcon: tempIcon,
                tempType: tempType,
                showType: false, 
              ),
              const SizedBox(height: 20),
              const Text("Choose Colour", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 12),
              _buildColorPicker(availableColors, tempColor, onColorSelected),
              const SizedBox(height: 24),
              _buildButtonRow(
                leftLabel: "Delete",
                leftIsOutlined: true,
                onLeft: onDelete,
                rightLabel: "Done",
                onRight: onDone,
              ),
            ],
          ),
        ),
      ),
    );
  }
  static Widget _buildButtonRow({
    required String leftLabel,
    required bool leftIsOutlined,
    required VoidCallback onLeft,
    required String rightLabel,
    required VoidCallback onRight,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            side: const BorderSide(color: Color(0xFF7F3DFF), width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onLeft,
          child: Text(leftLabel, style: const TextStyle(color: Color(0xFF7F3DFF), fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            backgroundColor: const Color(0xFF7F3DFF),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          onPressed: onRight,
          child: Text(rightLabel, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  static Widget buildCalendarPopup({
    required double screenWidth,
    required DateTime currentSelectedCalendarDate,
    required Function(DateTime) onDateSelected,
    required VoidCallback onClose,
    required VoidCallback onPrevMonth,
    required VoidCallback onNextMonth,
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

    final double cardWidth = screenWidth * 0.9;

    return GestureDetector(
      // Tap outside the card closes the pop-up
      onTap: onClose,
      child: Container(
        color: Colors.black38,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            width: cardWidth,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 8))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: onPrevMonth,
                      child: const Icon(Icons.chevron_left, size: 22, color: Color(0xFF6B7280)),
                    ),
                    Text(
                      DateFormat('MMM yyyy').format(currentSelectedCalendarDate),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: onNextMonth,
                      child: const Icon(Icons.chevron_right, size: 22, color: Color(0xFF6B7280)),
                    ),
                    GestureDetector(
                      onTap: onClose,
                      child: const Icon(Icons.close, size: 20, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: weekdays.map((w) => SizedBox(
                    width: (cardWidth - 40) / 8,
                    child: Text(w, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                  )).toList(),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 260,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: calendarDays.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 6,
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
                              fontSize: 14,
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
          ),
        ),
      ),
    );
  }

  static Widget _buildFormInputs({
    required TextEditingController nameController,
    required Color tempColor,
    required IconData tempIcon,
    required String tempType,
    bool showType = true,
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
  child: ValueListenableBuilder<TextEditingValue>(
    valueListenable: nameController,
    builder: (context, value, child) {
      return TextField(
        controller: nameController,
        textAlign: TextAlign.end,
        maxLength: 30,
        inputFormatters: [LengthLimitingTextInputFormatter(30)],
        style: const TextStyle(fontSize: 15, color: Colors.black),
        decoration: InputDecoration(
          hintText: "...",
          border: InputBorder.none,
          counterText: "${value.text.length}/30", 
          counterStyle: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          suffixIcon: const Icon(Icons.edit, size: 16, color: Color(0xFF9CA3AF)),
        ),
      );
    },
  ),
),),
        if (showType) ...[
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
      ],
    );
  }

  static Widget _buildColorPicker(List<Color> colors, Color selectedColor, Function(Color) onSelected) {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 14),
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
    return _IconGridSelector(icons: icons, selectedIcon: selectedIcon, onSelected: onSelected);
  }
}

class _IconGridSelector extends StatefulWidget {
  final List<IconData> icons;
  final IconData selectedIcon;
  final Function(IconData) onSelected;

  const _IconGridSelector({
    required this.icons,
    required this.selectedIcon,
    required this.onSelected,
  });

  @override
  State<_IconGridSelector> createState() => _IconGridSelectorState();
}

class _IconGridSelectorState extends State<_IconGridSelector> {
  final ScrollController _scrollController = ScrollController();
  static const int _dotCount = 3;
  int _activeDot = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final double maxScroll = _scrollController.position.maxScrollExtent;
    int newDot;
    if (maxScroll <= 0) {
      newDot = 0;
    } else {
      final double progress = (_scrollController.offset / maxScroll).clamp(0.0, 1.0);
      newDot = (progress * (_dotCount - 1)).round();
    }
    if (newDot != _activeDot) setState(() => _activeDot = newDot);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double cellSize = 52;
    const double rowSpacing = 14;
    const double columnSpacing = 16;
    const double scrollAreaPadding = 16;
    final int columnCount = (widget.icons.length / 2).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: cellSize * 2 + rowSpacing + scrollAreaPadding,
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: scrollAreaPadding, right: 14),
              itemCount: columnCount,
              itemBuilder: (context, colIndex) {
                final int topIndex = colIndex * 2;
                final int bottomIndex = topIndex + 1;
                return Padding(
                  padding: EdgeInsets.only(right: colIndex == columnCount - 1 ? 0 : columnSpacing),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildIconCell(topIndex, cellSize),
                      const SizedBox(height: rowSpacing),
                      bottomIndex < widget.icons.length
                          ? _buildIconCell(bottomIndex, cellSize)
                          : SizedBox(width: cellSize, height: cellSize),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_dotCount, (i) {
            bool isActive = i == _activeDot;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 8 : 6,
              height: isActive ? 8 : 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? const Color(0xFF7F3DFF) : const Color(0xFFD1D5DB),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildIconCell(int index, double size) {
    final IconData icon = widget.icons[index];
    final bool isSelected = widget.selectedIcon == icon;
    return GestureDetector(
      onTap: () => widget.onSelected(icon),
      child: SizedBox(
        width: size,
        height: size,
        child: CircleAvatar(
          backgroundColor: isSelected ? const Color(0xFFFCE7F3) : const Color(0xFFE5E7EB),
          child: Icon(icon, color: isSelected ? const Color(0xFFEC4899) : const Color(0xFF6B7280)),
        ),
      ),
    );
  }
}