
// import 'dart:developer' as developer;
// import 'package:bloc_concurrency/bloc_concurrency.dart';
// import 'package:expense_tracker/models/analytics_model.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'analytics_event.dart';
// import 'analytics_state.dart';
// import 'package:expense_tracker/features/auth/data/analytics_repository.dart';

// class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
//   final AnalyticsRepository _repository;

//   AnalyticsBloc(this._repository) : super(AnalyticsInitial()) {
//     on<FetchAnalyticsEvent>(
//       (event, emit) async {
//         emit(AnalyticsLoading());

//         String filterParam = 'this_month';
//         if (event.period == 'week') {
//           filterParam = event.subPeriod == 'this' ? 'this_week' : 'last_week';
//         } else if (event.period == 'month') {
//           filterParam = event.subPeriod == 'this' ? 'this_month' : 'last_month';
//         } else if (event.period == 'year') {
//           filterParam = event.subPeriod == 'this' ? 'this_year' : 'last_year';
//         }

//         try {
//           final responseData = await _repository.getCategoryBreakdown(
//             filter: (event.startDate != null) ? 'custom' : filterParam,
//             type: event.type,
//             startDate: event.startDate,
//             endDate: event.endDate,
//           );

//           final dataContainer = responseData['data'] ?? {};

//           List<dynamic> targetList = [];
//           if (event.type.toLowerCase() == 'income') {
//             targetList = dataContainer['income'] ?? [];
//           } else {
//             targetList = dataContainer['expense'] ?? [];
//           }

//           // 🆕 [FIX] Bar chart data ကို "months"/"monthly_breakdown" key ကနေ
//           // မမျှော်လင့်တော့ဘဲ /reports/annual-summary ကို year ရွေးမှသာ
//           // သီးခြား API call တစ်ခုအနေနဲ့ ခေါ်ပြီး Jan~Dec 12 လအပြည့်
//           // fill-in လုပ်သည် (data မရှိတဲ့လကို 0 ထား).
//           // ဒီ endpoint က query param လုံးဝမလိုအပ်ပါ (Postman confirm ပြီး).
//           List<MonthlyBarData> monthlyBarList = [];
//           if (event.period == 'year') {
//             List<dynamic> annualRaw = [];
//             try {
//               annualRaw = await _repository.getAnnualSummary();
//             } catch (e) {
//               developer.log('⚠️ Annual summary fetch error: $e', name: 'AnalyticsBloc');
//             }
//             monthlyBarList = _buildFullYearData(annualRaw, event.type, event.subPeriod);
//           }

//           if (targetList.isEmpty && monthlyBarList.isEmpty) {
//             emit(AnalyticsEmpty());
//             return;
//           }

//           double calcTotal = 0.0;
//           List<AnalyticsData> breakdownData = [];

//           for (var item in targetList) {
//             final dataItem = AnalyticsData.fromJson(item);
//             breakdownData.add(dataItem);
//             calcTotal += dataItem.totalAmount;
//           }

//           breakdownData.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

//           emit(AnalyticsLoaded(AnalyticsResponse(
//             overallTotal: calcTotal,
//             breakdown: breakdownData,
//             monthlyData: monthlyBarList,
//             type: event.type,
//             period: event.period,
//             subPeriod: event.subPeriod,
//           )));
//         } catch (e, stacktrace) {
//           developer.log('⚠️ Analytics Parsing Error: $e',
//               name: 'AnalyticsBloc', error: e, stackTrace: stacktrace);
//           emit(AnalyticsError("ဒေတာဆွဲယူရာတွင် အမှားအယွင်းရှိနေပါသည်"));
//         }
//       },
//       transformer: restartable(), // နောက်ဆုံး event ချည်းသာ process, အရင်တွေ auto-cancel
//     );

//     on<ResetAnalyticsEvent>((event, emit) {
//       emit(AnalyticsInitial());
//     });
//   }

//   // 🆕 [NEW] annual-summary API ကနေ data ရှိတဲ့လသာ ("2026-07" လို)
//   // ပြန်လာတာကို Jan~Dec 12 လအပြည့်ဖြစ်အောင် fill-in လုပ်ပေးသည့် helper.
//   // subPeriod == 'last' ရွေးထားရင် ပြီးခဲ့တဲ့နှစ်ရဲ့ monthKey တွေကို
//   // ရှာပါလိမ့်မယ် — backend က Last Year အတွက် data ကွဲပြားစွာ ပြန်ပေးမှသာ
//   // ဒါက အလုပ်လုပ်ပါလိမ့်မယ် (Postman ထဲမှာ confirm လုပ်ရန် လိုသေးသည်).
//   List<MonthlyBarData> _buildFullYearData(
//       List<dynamic> apiData, String type, String subPeriod) {
//     final now = DateTime.now();
//     final year = subPeriod == 'last' ? now.year - 1 : now.year;

//     final Map<String, double> monthMap = {
//       for (var item in apiData)
//         (item['month'] as String):
//             double.tryParse(item[type.toLowerCase()].toString()) ?? 0.0
//     };

//     const monthNames = [
//       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//     ];

//     return List.generate(12, (i) {
//       final monthKey = '$year-${(i + 1).toString().padLeft(2, '0')}';
//       return MonthlyBarData(
//         monthName: monthNames[i],
//         amount: monthMap[monthKey] ?? 0.0,
//       );
//     });
//   }
// }

import 'dart:developer' as developer;
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:expense_tracker/models/analytics_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';
import 'package:expense_tracker/features/auth/data/analytics_repository.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository _repository;

  // 🆕 [FIX] analytics_record_screen ကို ပြန်ဝင်တိုင်း data ပြန် load
  // မလုပ်တော့ဘဲ, transaction တစ်ခုခု ပြောင်းလဲမှ (add/edit/delete) မှသာ
  // "dirty" ဖြစ်အောင် လုပ်ပြီး နောက်တစ်ခါ tab ပြန်ဝင်ရင် fetch အသစ်လုပ်ပေးမည်.
  // ပုံမှန် tab ခုန်တာလေးတွေအတွက်တော့ cache ရှိနေတဲ့ data ကိုသာ ပြန်သုံးမည်.
  static bool needsRefresh = true;

  static void markDirty() {
    needsRefresh = true;
  }

  AnalyticsBloc(this._repository) : super(AnalyticsInitial()) {
    on<FetchAnalyticsEvent>(
      (event, emit) async {
        emit(AnalyticsLoading());

        String filterParam = 'this_month';
        if (event.period == 'week') {
          filterParam = event.subPeriod == 'this' ? 'this_week' : 'last_week';
        } else if (event.period == 'month') {
          filterParam = event.subPeriod == 'this' ? 'this_month' : 'last_month';
        } else if (event.period == 'year') {
          filterParam = event.subPeriod == 'this' ? 'this_year' : 'last_year';
        }

        try {
          final responseData = await _repository.getCategoryBreakdown(
            filter: (event.startDate != null) ? 'custom' : filterParam,
            type: event.type,
            startDate: event.startDate,
            endDate: event.endDate,
          );

          final dataContainer = responseData['data'] ?? {};

          List<dynamic> targetList = [];
          if (event.type.toLowerCase() == 'income') {
            targetList = dataContainer['income'] ?? [];
          } else {
            targetList = dataContainer['expense'] ?? [];
          }

          // 🆕 [FIX] Bar chart data ကို "months"/"monthly_breakdown" key ကနေ
          // မမျှော်လင့်တော့ဘဲ /reports/annual-summary ကို year ရွေးမှသာ
          // သီးခြား API call တစ်ခုအနေနဲ့ ခေါ်ပြီး Jan~Dec 12 လအပြည့်
          // fill-in လုပ်သည် (data မရှိတဲ့လကို 0 ထား).
          // ဒီ endpoint က query param လုံးဝမလိုအပ်ပါ (Postman confirm ပြီး).
          List<MonthlyBarData> monthlyBarList = [];
          if (event.period == 'year') {
            List<dynamic> annualRaw = [];
            try {
              annualRaw = await _repository.getAnnualSummary();
            } catch (e) {
              developer.log('⚠️ Annual summary fetch error: $e', name: 'AnalyticsBloc');
            }
            monthlyBarList = _buildFullYearData(annualRaw, event.type, event.subPeriod);
          }

          if (targetList.isEmpty && monthlyBarList.isEmpty) {
            emit(AnalyticsEmpty());
            return;
          }

          double calcTotal = 0.0;
          List<AnalyticsData> breakdownData = [];

          for (var item in targetList) {
            final dataItem = AnalyticsData.fromJson(item);
            breakdownData.add(dataItem);
            calcTotal += dataItem.totalAmount;
          }

          breakdownData.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

          emit(AnalyticsLoaded(AnalyticsResponse(
            overallTotal: calcTotal,
            breakdown: breakdownData,
            monthlyData: monthlyBarList,
            type: event.type,
            period: event.period,
            subPeriod: event.subPeriod,
          )));
        } catch (e, stacktrace) {
          developer.log('⚠️ Analytics Parsing Error: $e',
              name: 'AnalyticsBloc', error: e, stackTrace: stacktrace);
          emit(AnalyticsError("ဒေတာဆွဲယူရာတွင် အမှားအယွင်းရှိနေပါသည်"));
        }
      },
      transformer: restartable(), // နောက်ဆုံး event ချည်းသာ process, အရင်တွေ auto-cancel
    );

    on<ResetAnalyticsEvent>((event, emit) {
      emit(AnalyticsInitial());
    });
  }

  // 🆕 [NEW] annual-summary API ကနေ data ရှိတဲ့လသာ ("2026-07" လို)
  // ပြန်လာတာကို Jan~Dec 12 လအပြည့်ဖြစ်အောင် fill-in လုပ်ပေးသည့် helper.
  // subPeriod == 'last' ရွေးထားရင် ပြီးခဲ့တဲ့နှစ်ရဲ့ monthKey တွေကို
  // ရှာပါလိမ့်မယ် — backend က Last Year အတွက် data ကွဲပြားစွာ ပြန်ပေးမှသာ
  // ဒါက အလုပ်လုပ်ပါလိမ့်မယ် (Postman ထဲမှာ confirm လုပ်ရန် လိုသေးသည်).
  List<MonthlyBarData> _buildFullYearData(
      List<dynamic> apiData, String type, String subPeriod) {
    final now = DateTime.now();
    final year = subPeriod == 'last' ? now.year - 1 : now.year;

    final Map<String, double> monthMap = {
      for (var item in apiData)
        (item['month'] as String):
            double.tryParse(item[type.toLowerCase()].toString()) ?? 0.0
    };

    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return List.generate(12, (i) {
      final monthKey = '$year-${(i + 1).toString().padLeft(2, '0')}';
      return MonthlyBarData(
        monthName: monthNames[i],
        amount: monthMap[monthKey] ?? 0.0,
      );
    });
  }
}