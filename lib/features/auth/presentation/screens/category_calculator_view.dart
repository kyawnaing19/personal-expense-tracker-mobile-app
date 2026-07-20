import 'package:flutter/material.dart';
import 'package:expense_tracker/models/category_model.dart';

class CategoryCalculatorView extends StatefulWidget {
  final CategoryItem? selectedCategory;
  final String amount;
  final String expression;
  final TextEditingController noteController;
  final Function(String) onKeypadPressed;

  const CategoryCalculatorView({
    Key? key,
    required this.selectedCategory,
    required this.amount,
    required this.expression,
    required this.noteController,
    required this.onKeypadPressed,
  }) : super(key: key);

  @override
  State<CategoryCalculatorView> createState() => _CategoryCalculatorViewState();
}

class _CategoryCalculatorViewState extends State<CategoryCalculatorView> {
  final FocusNode _noteFocusNode = FocusNode();
  bool _isNoteFocused = false;

  @override
  void initState() {
    super.initState();
    _noteFocusNode.addListener(() {
      setState(() {
        _isNoteFocused = _noteFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _noteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isNoteFocused) _noteFocusNode.unfocus();
      },
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          color: const Color(0xFFF7F5FC),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.expression.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(widget.expression, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                ),
              Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded(
      child: widget.selectedCategory != null
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1.8),
                  ),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: widget.selectedCategory!.color,
                    child: Icon(widget.selectedCategory!.icon, color: Colors.white, size: 16),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.selectedCategory!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, 
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            )
          : const Icon(Icons.article_outlined, color: Color(0xFF4B5563), size: 28),
    ),
    const SizedBox(width: 12), 
    Text(
      widget.amount,
      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
    ),
  ],
),
              const SizedBox(height: 12),
              TextField(
                controller: widget.noteController,
                focusNode: _noteFocusNode,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _noteFocusNode.unfocus(),
                decoration: InputDecoration(
                  hintText: "Note: Enter a note ......",
                  hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFFF7F5FC),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Color(0xFF7F3DFF), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              AnimatedSize(
                duration: const Duration(milliseconds: 150),
                child: _isNoteFocused
                    ? const SizedBox.shrink()
                    : _buildBalancedKeypadUI(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalancedKeypadUI() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cellHeight = 44;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 10,
          childAspectRatio: (constraints.maxWidth / 4) / cellHeight,
          children: [
            _buildBaseButton("7"), _buildBaseButton("8"), _buildBaseButton("9"), _buildActionButton("Today"),
            _buildBaseButton("4"), _buildBaseButton("5"), _buildBaseButton("6"),
            Row(
              children: [
                Expanded(child: _buildActionButton("+")),
                const SizedBox(width: 6),
                Expanded(child: _buildActionButton("-")),
              ],
            ),
            _buildBaseButton("1"), _buildBaseButton("2"), _buildBaseButton("3"),
            Row(
              children: [
                Expanded(child: _buildActionButton("×")),
                const SizedBox(width: 6),
                Expanded(child: _buildActionButton("÷")),
              ],
            ),
            _buildBaseButton("."), _buildBaseButton("0"), _buildActionButton("⌫"),
            _buildActionButton("="),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(String label) {
    bool isEqual = label == "=";
    bool isToday = label == "Today";

    return GestureDetector(
      onTap: () => widget.onKeypadPressed(label),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEDE9FE),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isToday ? 13 : 20,
              fontWeight: FontWeight.w600,
              color: isEqual ? const Color(0xFF7F3DFF) : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBaseButton(String label) {
    return GestureDetector(
      onTap: () => widget.onKeypadPressed(label),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEDE9FE),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
        ),
      ),
    );
  }
}