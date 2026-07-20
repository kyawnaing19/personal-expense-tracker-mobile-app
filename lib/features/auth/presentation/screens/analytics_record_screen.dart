import 'package:expense_tracker/features/auth/presentation/bloc/analytics_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/analytics_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/analytics_state.dart';
import 'package:expense_tracker/models/analytics_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalyticalRecordPage extends StatefulWidget {
 final VoidCallback? onBackToHome;
  const AnalyticalRecordPage({Key? key, this.onBackToHome}) : super(key: key);


  @override
  State<AnalyticalRecordPage> createState() => AnalyticalRecordPageState();
}

class AnalyticalRecordPageState extends State<AnalyticalRecordPage> {
   String _selectedType = 'expense';
   String _selectedPeriod = 'month'; 
   String _subPeriod = 'this';

  static const Color primaryPurple = Color(0xFF7F3DFF);
  static const Color expenseBarColor = Color(0xFFEF4444); 
  static const Color incomeBarColor = Color(0xFF22C55E); 

  final List<Map<String, String>> _periodOptions = const [
    {'value': 'week', 'label': 'Week'},
    {'value': 'month', 'label': 'Month'},
    {'value': 'year', 'label': 'Year'},
  ];

  DateTime? _startDate;
  DateTime? _endDate;

  String _previousPeriod = 'month';
  String _previousSubPeriod = 'this';

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

  void _applyPeriodFilter(String period) {
    if (period == _selectedPeriod) return;
    setState(() {
      _selectedPeriod = period;
      _loadAnalyticsData();
    });
  }

  void _loadAnalyticsData() {
    AnalyticsBloc.needsRefresh = false;
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
    if (AnalyticsBloc.needsRefresh) {
      _loadAnalyticsData();
    }
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

                      final bool isYearSelected = _selectedPeriod == 'year';

                      if (isYearSelected) {
                        return Column(
                          children: [
                            _buildAnalyticsCard(state.response, currencyFormatter),
                            const SizedBox(height: 16),
                            Expanded(
                              child: _buildAnnualBarChartCard(state.response, currencyFormatter),
                            ),
                          ],
                        );
                      }

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
      GestureDetector(
  onTap: () {
    if (_selectedPeriod == 'custom') {
      setState(() {
        _selectedPeriod = _previousPeriod;
        _subPeriod = _previousSubPeriod;
      });
      _loadAnalyticsData();
    } else {
      if (widget.onBackToHome != null) {
        widget.onBackToHome!();
      } else {
        Navigator.maybePop(context);
      }
    }
  },
  child: Container(
    width: 40,
    height: 40,
    alignment: Alignment.center,
    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black),
  ),
),

        _buildTypeDropdown(),

        Container(
          width: 39,
          height: 39,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.calendar_month_outlined, size: 16, color: Colors.black),
            onPressed: () async {
              _showCustomDateRangePicker();
            },
          ),
        ),
      ],
    );
  }

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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            selectedLabel,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.black, size: 28),
        ],
      ),
    );
  }
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _periodOptions.map((option) {
          final String value = option['value']!;
          final String label = option['label']!;
          final bool isSelected = _selectedPeriod == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => _applyPeriodFilter(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? primaryPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                ),
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
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        height: 180,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
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
      ),
    );
  }

  Widget _buildAnnualBarChartCard(AnalyticsResponse response, NumberFormat formatter) {
    final Color barColor = _selectedType == 'expense' ? expenseBarColor : incomeBarColor;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: _buildAnnualBarChart(response.monthlyData, formatter, barColor),
    );
  }

  Widget _buildAnnualBarChart(
      List<MonthlyBarData> monthlyData, NumberFormat formatter, Color barColor) {
        
    double maxAmount = 0;
    for (var d in monthlyData) {
      if (d.amount > maxAmount) maxAmount = d.amount;
    }
    if (maxAmount <= 0) maxAmount = 1000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 10.0),
          child: Text(
            _selectedType == 'expense' ? 'Annual Expenses' : 'Annual Income',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 18.0, bottom: 8.0, left: 8.0, right: 8.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxAmount * 1.35,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.transparent, 
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 0,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        formatter.format(rod.toY),
                        const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        int idx = value.toInt();
                        if (idx >= 0 && idx < monthlyData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              monthlyData[idx].monthName,
                              style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 9),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 24,
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
                    showingTooltipIndicators: [0],
                    barRods: [
                      BarChartRodData(
                        toY: monthlyData[index].amount,
                        color: barColor,
                        width: 10,
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
      clipBehavior: Clip.antiAlias,
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
        _start = day;
        _end = null;
      } else if (day.isBefore(_start!)) {
        _start = day;
        _end = null;
      } else {
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