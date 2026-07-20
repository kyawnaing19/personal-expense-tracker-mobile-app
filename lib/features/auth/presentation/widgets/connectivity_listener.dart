import 'package:expense_tracker/cache-first/online-refresh/silent_refresh_registry.dart';
import 'package:expense_tracker/core/connectivity/connectivity_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityListener extends StatelessWidget {
  final Widget child;
  const ConnectivityListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, ConnectivityState>(
      listenWhen: (previous, current) => current.justReconnected,
      listener: (context, state) {
        SilentRefreshRegistry.instance.triggerAllRefresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            content: Row(
              children: [
                Icon(Icons.wifi_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Back Online'),
              ],
            ),
          ),
        );
      },
      child: child,
    );
  }
}