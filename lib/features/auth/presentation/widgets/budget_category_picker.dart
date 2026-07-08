import 'package:flutter/material.dart';
import '../../../../models/category_model.dart';

/// Category grid shown when the user taps "Choose Category" in the budget
/// form. Per the design, this renders as its own section *below* the
/// "Set Budget" / "Edit Budget" white card — not nested inside it — so it
/// must NOT be wrapped in another white Container by the caller.
class BudgetCategoryPicker extends StatelessWidget {
  final List<CategoryItem> categories;
  final CategoryItem? selected;
  final ValueChanged<CategoryItem> onSelected;

  const BudgetCategoryPicker({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          "No categories found. Please add a category first.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Select Category",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 24,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: categories.map((cat) {
            final bool isSelected = selected?.id == cat.id;
            return GestureDetector(
              onTap: () => onSelected(cat),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                // Fixed width so long category names wrap onto a second
                // line instead of squeezing the avatar / clipping text —
                // this is what made the picker look "too small" before.
                width: 64,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: cat.color,
                      child: Icon(cat.icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF8A4BEB) : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}