// import 'dart:developer' as developer;
// import 'package:expense_tracker/models/analytics_model.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'analytics_event.dart';
// import 'analytics_state.dart';
// import 'package:expense_tracker/features/auth/data/analytics_repository.dart'; 

// class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
//   final AnalyticsRepository _repository;

//   AnalyticsBloc(this._repository) : super(AnalyticsInitial()) {
//     on<FetchAnalyticsEvent>((event, emit) async {
//       emit(AnalyticsLoading());


//       String filterParam = 'this_month';
//       if (event.period == 'week') {
//         filterParam = event.subPeriod == 'this' ? 'this_week' : 'last_week';
//       } else if (event.period == 'month') {
//         filterParam = event.subPeriod == 'this' ? 'this_month' : 'last_month';
//       } else if (event.period == 'year') {
//         filterParam = event.subPeriod == 'this' ? 'this_year' : 'last_year';
//       }

//       try {
//         final responseData = await _repository.getCategoryBreakdown(
//           filter: (event.startDate != null) ? 'custom' : filterParam,
//           type: event.type,
//           startDate: event.startDate, // အသစ်ထည့်ရန်
//           endDate: event.endDate,     // အသစ်ထည့်ရန်
//         );
        
//         final dataContainer = responseData['data'] ?? {};
        
//         List<dynamic> targetList = [];
//         if (event.type.toLowerCase() == 'income') {
//           targetList = dataContainer['income'] ?? [];
//         } else {
//           targetList = dataContainer['expense'] ?? [];
//         }

//         // 🎯 [NEW] Bar Chart အတွက် ၁၂ လစာ ဒေတာကို Backend ထံမှ ဆွဲထုတ်ခြင်း
//         List<MonthlyBarData> monthlyBarList = [];
//         // Backend က 'months' သို့မဟုတ် 'monthly_breakdown' ဖြင့် ပို့ပေးလေ့ရှိသည်
//         List<dynamic> rawMonths = dataContainer['months'] ?? dataContainer['monthly_breakdown'] ?? [];
//         for (var m in rawMonths) {
//           monthlyBarList.add(MonthlyBarData.fromJson(m));
//         }

//         // အကယ်၍ Backend တွင် လအလိုက်မပါလာသေးပါက UI စမ်းသပ်နိုင်ရန် Mocking ပုံစံ စစ်ဆေးထားခြင်း
//         if (monthlyBarList.isEmpty && event.period == 'year') {
//           List<String> monthsShort = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
//           monthlyBarList = monthsShort.map((m) => MonthlyBarData(monthName: m, amount: 0.0)).toList();
//         }

//         if (targetList.isEmpty && monthlyBarList.isEmpty) {
//           emit(AnalyticsEmpty());
//           return;
//         }

//         double calcTotal = 0.0;
//         List<AnalyticsData> breakdownData = [];
        
//         for (var item in targetList) {
//           final dataItem = AnalyticsData.fromJson(item);
//           breakdownData.add(dataItem);
//           calcTotal += dataItem.totalAmount;
//         }

//         // Category များကို အများဆုံးမှ အနည်းဆုံးသို့ Sort လုပ်ခြင်း
//         breakdownData.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

//         emit(AnalyticsLoaded(AnalyticsResponse(
//           overallTotal: calcTotal, 
//           breakdown: breakdownData,
//           monthlyData: monthlyBarList, // 🎯 တိုးမြှင့်ထားသော လအလိုက် ဒေတာ
//         )));
//       } catch (e, stacktrace) {
//         developer.log('⚠️ Analytics Parsing Error: $e', name: 'AnalyticsBloc', error: e, stackTrace: stacktrace);
//         emit(AnalyticsError("ဒေတာဆွဲယူရာတွင် အမှားအယွင်းရှိနေပါသည်"));
//       }
//     });
//    on<ResetAnalyticsEvent>((event, emit) {
//   emit(AnalyticsInitial()); 
// });

//   }  
// }

import 'dart:developer' as developer;
import 'package:bloc_concurrency/bloc_concurrency.dart'; // 🆕 [FIX]
import 'package:expense_tracker/models/analytics_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';
import 'package:expense_tracker/features/auth/data/analytics_repository.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository _repository;

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

          List<MonthlyBarData> monthlyBarList = [];
          List<dynamic> rawMonths =
              dataContainer['months'] ?? dataContainer['monthly_breakdown'] ?? [];
          for (var m in rawMonths) {
            monthlyBarList.add(MonthlyBarData.fromJson(m));
          }

          if (monthlyBarList.isEmpty && event.period == 'year') {
            List<String> monthsShort = [
              "Jan", "Feb", "Mar", "Apr", "May", "Jun",
              "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
            ];
            monthlyBarList = monthsShort
                .map((m) => MonthlyBarData(monthName: m, amount: 0.0))
                .toList();
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
      transformer: restartable(), // 🆕 [FIX] နောက်ဆုံး event ချည်းသာ process, အရင်တွေ auto-cancel
    );

    on<ResetAnalyticsEvent>((event, emit) {
      emit(AnalyticsInitial());
    });
  }
}