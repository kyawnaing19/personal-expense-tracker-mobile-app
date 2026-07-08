import 'package:expense_tracker/features/auth/presentation/bloc/analytics_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/analytics_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/analytics_state.dart';
import 'package:expense_tracker/models/analytics_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalyticalRecordPage extends StatefulWidget {
  const AnalyticalRecordPage({Key? key}) : super(key: key);

  @override
  State<AnalyticalRecordPage> createState() => AnalyticalRecordPageState();
}

class AnalyticalRecordPageState extends State<AnalyticalRecordPage> {
  static String _selectedType = 'expense';
  static String _selectedPeriod = 'week'; // 'week' | 'month' | 'year' | 'custom'
  static String _subPeriod = 'this';

  DateTime? _startDate;
  DateTime? _endDate;

  // 🆕 remembers what Week/Month/Year + This/Last combo was active
  // before switching into 'custom' mode, so the back arrow can restore it
  String _previousPeriod = 'week';
  String _previousSubPeriod = 'this';

  // ---------------------------------------------------------------------
  // 🆕 Custom calendar flow
  //   Step 1: month-grid dialog -> user taps a start date then an end date
  //           (future dates are disabled, only the start/end day itself
  //           gets the purple circle highlight)
  //   Step 2: summary dialog ("Start Time" / "End Time" + Cancel/Confirm)
  // ---------------------------------------------------------------------
  void _showCustomDateRangePicker() async {
    final DateTimeRange? range = await showDialog<DateTimeRange>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) => _CalendarRangeDialog(
        initialStart: _startDate,
        initialEnd: _endDate,
      ),
    );

    if (range == null) return;

    final bool? confirmed = await _showDateRangeConfirmDialog(range);
    if (confirmed == true) {
      setState(() {
        // only remember the prior selection the first time we enter
        // custom mode, so re-opening the calendar while already in
        // custom mode doesn't overwrite it with 'custom' itself
        if (_selectedPeriod != 'custom') {
          _previousPeriod = _selectedPeriod;
          _previousSubPeriod = _subPeriod;
        }
        _startDate = range.start;
        _endDate = range.end;
        _selectedPeriod = 'custom';
      });
      context.read<AnalyticsBloc>().add(FetchAnalyticsEvent(
            period: 'custom',
            subPeriod: '',
            type: _selectedType,
            startDate: _startDate,
            endDate: _endDate,
          ));
    }
  }

  Future<bool?> _showDateRangeConfirmDialog(DateTimeRange range) {
    final dateFmt = DateFormat('MMM d, yyyy');
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _summaryRow('Start Time', dateFmt.format(range.start)),
                const Divider(height: 26, thickness: 0.6, color: Color(0xFFE5E7EB)),
                _summaryRow('End Time', dateFmt.format(range.end)),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.black87)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Confirm',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87)),
        Text(value,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
      ],
    );
  }

  final ScrollController _scrollController = ScrollController();
  bool _showScrollArrow = false;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();

    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 5) {
          if (_showScrollArrow) setState(() => _showScrollArrow = false);
        } else {
          if (!_showScrollArrow) setState(() => _showScrollArrow = true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadAnalyticsData() {
    context.read<AnalyticsBloc>().add(
          _selectedPeriod == 'custom'
              ? FetchAnalyticsEvent(
                  period: 'custom',
                  subPeriod: '',
                  type: _selectedType,
                  startDate: _startDate,
                  endDate: _endDate,
                )
              : FetchAnalyticsEvent(
                  period: _selectedPeriod, subPeriod: _subPeriod, type: _selectedType),
        );
  }

  void refreshCurrentSelection() {
    _loadAnalyticsData();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');
    final bool isCustom = _selectedPeriod == 'custom';

    return Scaffold(
      backgroundColor: const Color(0xFFE8DEF8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildAppBar(),
              const SizedBox(height: 20),
              isCustom ? _buildCustomRangeHeader() : _buildPeriodToggle(),
              const SizedBox(height: 25),
              if (!isCustom) _buildSubPeriodSelector(),
              const SizedBox(height: 20),
              Expanded(
                key: ValueKey('${_selectedType}_${_selectedPeriod}_${_subPeriod}'),
                child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
                  builder: (context, state) {
                    if (state is AnalyticsLoading || state is AnalyticsInitial) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                      );
                    } else if (state is AnalyticsLoaded) {
                      final isStale = state.response.type != _selectedType ||
                          state.response.period != _selectedPeriod ||
                          (_selectedPeriod != 'year' &&
                              _selectedPeriod != 'custom' &&
                              state.response.subPeriod != _subPeriod);

                      if (isStale) {
                        return const Center(
                          child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                        );
                      }

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          bool canScroll =
                              _scrollController.position.maxScrollExtent > 0;
                          if (canScroll != _showScrollArrow) {
                            setState(() => _showScrollArrow = canScroll);
                          }
                        }
                      });
                      return _buildAnalyticsCard(state.response, currencyFormatter);
                    } else if (state is AnalyticsEmpty) {
                      return _buildEmptyState();
                    } else if (state is AnalyticsError) {
                      return Center(
                        child: Text(state.message,
                            style: const TextStyle(color: Colors.red)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
                onPressed: () {
                  if (_selectedPeriod == 'custom') {
                    // leave custom-range mode and go back to the
                    // Week/Month/Year view that was active before
                    setState(() {
                      _selectedPeriod = _previousPeriod;
                      _subPeriod = _previousSubPeriod;
                    });
                    _loadAnalyticsData();
                  } else {
                    Navigator.maybePop(context);
                  }
                })),

        _buildTypeDropdown(),

        Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: IconButton(
                icon: const Icon(Icons.calendar_month_outlined, size: 22, color: Colors.black),
                onPressed: () async {
                  _showCustomDateRangePicker();
                }))
      ],
    );
  }

  // Compact, rounded popup instead of the default DropdownButton menu
  // (which renders as a big, plain, full-width Material list).
  Widget _buildTypeDropdown() {
    const Color primaryPurple = Color(0xFF7F3DFF);
    const options = [
      {'value': 'expense', 'label': 'Expense'},
      {'value': 'income', 'label': 'Income'},
    ];
    final selectedLabel = options.firstWhere((o) => o['value'] == _selectedType)['label']!;

    return PopupMenuButton<String>(
      initialValue: _selectedType,
      onSelected: (value) {
        setState(() {
          _selectedType = value;
          _loadAnalyticsData();
        });
      },
      offset: const Offset(0, 46),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      constraints: const BoxConstraints(minWidth: 140, maxWidth: 160),
      itemBuilder: (context) => options.map((o) {
        final bool isSelected = o['value'] == _selectedType;
        return PopupMenuItem<String>(
          value: o['value'],
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                o['label']!,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? primaryPurple : Colors.black87,
                ),
              ),
              if (isSelected) const Icon(Icons.check, size: 18, color: primaryPurple),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.black, size: 22),
          ],
        ),
      ),
    );
  }

  // 🆕 header shown instead of Week/Month/Year toggle once a custom
  // range has been confirmed (matches the "Jun 1, 2026 ▾ ~ Jun 10, 2026" UI)
  Widget _buildCustomRangeHeader() {
    final dateFmt = DateFormat('MMM d, yyyy');
    return GestureDetector(
      onTap: _showCustomDateRangePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(dateFmt.format(_startDate!),
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
            const Icon(Icons.arrow_drop_down, color: Colors.black),
            const SizedBox(width: 6),
            const Text('~', style: TextStyle(fontSize: 15, color: Colors.black54)),
            const SizedBox(width: 6),
            Text(dateFmt.format(_endDate!),
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodToggle() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: ['week', 'month', 'year'].map((period) {
          bool isSelected = _selectedPeriod == period;
          String labelText =
              period == 'week' ? 'Week' : (period == 'month' ? 'Month' : 'Year');
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                  _loadAnalyticsData();
                });
              },
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF7C3AED) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6)),
                alignment: Alignment.center,
                child: Text(labelText,
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 15)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubPeriodSelector() {
    String thisText =
        _selectedPeriod == 'week' ? 'This Week' : (_selectedPeriod == 'month' ? 'This Month' : 'This Year');
    String lastText =
        _selectedPeriod == 'week' ? 'Last Week' : (_selectedPeriod == 'month' ? 'Last Month' : 'Last Year');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _subPeriod = 'last';
              _loadAnalyticsData();
            });
          },
          child: Column(children: [
            Text(lastText,
                style: TextStyle(
                    fontSize: 16,
                    color: _subPeriod == 'last' ? const Color(0xFF6D28D9) : Colors.black.withOpacity(0.6),
                    fontWeight: _subPeriod == 'last' ? FontWeight.bold : FontWeight.w500)),
            const SizedBox(height: 4),
            Container(width: 65, height: 3, color: _subPeriod == 'last' ? const Color(0xFF6D28D9) : Colors.transparent)
          ]),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _subPeriod = 'this';
              _loadAnalyticsData();
            });
          },
          child: Column(children: [
            Text(thisText,
                style: TextStyle(
                    fontSize: 16,
                    color: _subPeriod == 'this' ? const Color(0xFF6D28D9) : Colors.black.withOpacity(0.6),
                    fontWeight: _subPeriod == 'this' ? FontWeight.bold : FontWeight.w500)),
            const SizedBox(height: 4),
            Container(width: 65, height: 3, color: _subPeriod == 'this' ? const Color(0xFF6D28D9) : Colors.transparent)
          ]),
        )
      ],
    );
  }

  Widget _buildAnalyticsCard(AnalyticsResponse response, NumberFormat formatter) {
    bool isYearSelected = _selectedPeriod == 'year';

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        height: isYearSelected ? 300 : 180,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 142,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          key: ValueKey('${_selectedType}_${_selectedPeriod}_${_subPeriod}'),
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 42,
                            startDegreeOffset: -90,
                            sections: response.breakdown.map((data) {
                              return PieChartSectionData(
                                color: data.color,
                                value: data.percentage,
                                title: '',
                                radius: 10,
                              );
                            }).toList(),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _selectedType == 'expense' ? 'Expense' : 'Income',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formatter.format(response.overallTotal),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 142,
                        child: RawScrollbar(
                          thumbColor: Colors.grey[300],
                          radius: const Radius.circular(4),
                          thickness: 3,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children:
                                    response.breakdown.map((data) => _buildLegendItem(data)).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_showScrollArrow)
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            height: 22,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.white.withOpacity(0.0), Colors.white.withOpacity(0.9)],
                              ),
                            ),
                            child: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF7C3AED)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (isYearSelected) ...[
              const Divider(height: 20, thickness: 0.5, color: Color(0xFFE5E7EB)),
              Expanded(
                child: _buildAnnualBarChart(response.monthlyData),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnnualBarChart(List<MonthlyBarData> monthlyData) {
    double maxAmount = 1000;
    for (var d in monthlyData) {
      if (d.amount > maxAmount) maxAmount = d.amount;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
          child: Text(
            _selectedType == 'expense' ? 'Annual Expenses' : 'Annual Income',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 2.0, left: 8.0, right: 8.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxAmount * 1.15,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        int idx = value.toInt();
                        if (idx >= 0 && idx < monthlyData.length) {
                          return Text(
                            monthlyData[idx].monthName,
                            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 9),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 16,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(monthlyData.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: monthlyData[index].amount,
                        color: const Color(0xFF7C3AED),
                        width: 8,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(3),
                          topRight: Radius.circular(3),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(AnalyticsData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Container(
        height: 19,
        child: Row(
          children: [
            Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, border: Border.all(color: data.color, width: 2.8))),
            const SizedBox(width: 8),
            Expanded(
                child: Text(data.categoryName,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
                    overflow: TextOverflow.ellipsis)),
            Text('${data.percentage.toStringAsFixed(2)}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

 Widget _buildEmptyState() {
  return Align(
    alignment: Alignment.topCenter,
    child: Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart_outline, size: 55, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text("No records yet",
              style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    ),
  );
}
}

// ===========================================================================
// 🆕 Custom month-grid calendar dialog.
//    - Future dates (after "today") are disabled and cannot be tapped.
//    - Only the chosen start date and end date get the purple circle;
//      the days in between are left unstyled, matching the requested design.
//    - First tap sets the start date, second tap sets the end date
//      (tapping again after a full range restarts a fresh selection).
// ===========================================================================
class _CalendarRangeDialog extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;

  const _CalendarRangeDialog({this.initialStart, this.initialEnd});

  @override
  State<_CalendarRangeDialog> createState() => _CalendarRangeDialogState();
}

class _CalendarRangeDialogState extends State<_CalendarRangeDialog> {
  DateTime? _start;
  DateTime? _end;
  late DateTime _displayedMonth;

  static const List<String> _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
    final base = widget.initialStart ?? DateTime.now();
    _displayedMonth = DateTime(base.year, base.month);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isFutureDate(DateTime day) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    return day.isAfter(normalizedToday);
  }

  bool get _canGoNextMonth {
    final firstOfNext = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    return !_isFutureDate(firstOfNext);
  }

  void _onDayTap(DateTime day) {
    if (_isFutureDate(day)) return;
    setState(() {
      if (_start == null || (_start != null && _end != null)) {
        // starting a fresh selection
        _start = day;
        _end = null;
      } else if (day.isBefore(_start!)) {
        // end date can never be earlier than start date —
        // treat this tap as redefining the start date instead of swapping
        _start = day;
        _end = null;
      } else {
        // day is the same as or after start -> valid end date (same day allowed)
        _end = day;
      }
    });
  }

  bool _isInRange(DateTime day) {
    if (_start == null || _end == null) return false;
    final d = DateTime(day.year, day.month, day.day);
    final s = DateTime(_start!.year, _start!.month, _start!.day);
    final e = DateTime(_end!.year, _end!.month, _end!.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_displayedMonth),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                ),
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.chevron_left, color: Colors.black87),
                      onPressed: () {
                        setState(() {
                          _displayedMonth =
                              DateTime(_displayedMonth.year, _displayedMonth.month - 1);
                        });
                      },
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.chevron_right,
                          color: _canGoNextMonth ? Colors.black87 : Colors.grey[300]),
                      onPressed: _canGoNextMonth
                          ? () {
                              setState(() {
                                _displayedMonth = DateTime(
                                    _displayedMonth.year, _displayedMonth.month + 1);
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: _weekdayLabels
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(d,
                              style: TextStyle(
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 4),
            _buildMonthGrid(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: (_start != null && _end != null)
                      ? () => Navigator.pop(
                          context, DateTimeRange(start: _start!, end: _end!))
                      : null,
                  child: Text(
                    'Next',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: (_start != null && _end != null)
                            ? const Color(0xFF7C3AED)
                            : Colors.grey[300]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthGrid() {
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    // DateTime.weekday: Mon=1 ... Sun=7. We render Sun-first, so Sun -> 0.
    final leadingEmpty = firstDayOfMonth.weekday % 7;

    final List<Widget> cells = [];
    for (int i = 0; i < leadingEmpty; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final day = DateTime(_displayedMonth.year, _displayedMonth.month, d);
      final disabled = _isFutureDate(day);
      final isStart = _start != null && _isSameDay(day, _start!);
      final isEnd = _end != null && _isSameDay(day, _end!);
      // once both ends are picked, every day from start through end
      // (inclusive) is highlighted purple, not just the two endpoints
      final isSelected = isStart || isEnd || _isInRange(day);

      cells.add(
        GestureDetector(
          onTap: disabled ? null : () => _onDayTap(day),
          child: Container(
            margin: const EdgeInsets.all(2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? const Color(0xFF7C3AED) : Colors.transparent,
            ),
            child: Text(
              '$d',
              style: TextStyle(
                fontSize: 13,
                color: disabled
                    ? Colors.grey[300]
                    : (isSelected ? Colors.white : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: cells,
    );
  }
}