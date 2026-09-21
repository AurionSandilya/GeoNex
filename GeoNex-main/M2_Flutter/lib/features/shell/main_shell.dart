import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../state/app_state.dart';
import '../actions/action_engine_screen.dart';
import '../alerts/alerts_screen.dart';
import '../analytics/region_analytics_screen.dart';
import '../citizen_reporting/citizen_reporting_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../field_verification/field_verification_screen.dart';
import '../history/risk_history_screen.dart';
import '../offline_queue/offline_queue_screen.dart';
import '../priority/priority_queue_screen.dart';
import '../risk_details/risk_details_screen.dart';
import '../risk_map/risk_map_screen.dart';
import '../risk_routing/risk_aware_routing_screen.dart';
import '../settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  final AppState appState;
  final VoidCallback onLogout;

  const MainShell({
    super.key,
    required this.appState,
    required this.onLogout,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  String? _subRoute;

  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _navigateToNamed(String routeName, {Object? arguments}) {
    setState(() {
      _subRoute = routeName;
    });
  }

  void _clearSubRoute() {
    setState(() {
      _subRoute = null;
    });
  }

  List<BottomNavigationBarItem> _buildNavItems(UserRole role) {
    if (role == UserRole.authority) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Risk Map'),
        BottomNavigationBarItem(icon: Icon(Icons.format_list_numbered), activeIcon: Icon(Icons.format_list_numbered_rtl), label: 'Priority'),
        BottomNavigationBarItem(icon: Icon(Icons.crisis_alert_outlined), activeIcon: Icon(Icons.crisis_alert), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
      ];
    } else if (role == UserRole.fieldOfficer) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.verified_user_outlined), activeIcon: Icon(Icons.verified_user), label: 'Verification'),
        BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Map'),
        BottomNavigationBarItem(icon: Icon(Icons.crisis_alert_outlined), activeIcon: Icon(Icons.crisis_alert), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
      ];
    } else {
      // Citizen
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Risk Map'),
        BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), activeIcon: Icon(Icons.camera_alt), label: 'Report'),
        BottomNavigationBarItem(icon: Icon(Icons.crisis_alert_outlined), activeIcon: Icon(Icons.crisis_alert), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
      ];
    }
  }

  Widget _buildBody(UserRole role) {
    // If a sub-route is active, show the sub-route screen
    if (_subRoute != null) {
      switch (_subRoute) {
        case 'risk_details':
          return RiskDetailsScreen(
            appState: widget.appState,
            onBack: _clearSubRoute,
            onNavigateNamed: _navigateToNamed,
          );
        case 'risk_routing':
        case 'risk_aware_routing':
          return RiskAwareRoutingScreen(
            appState: widget.appState,
            onBack: _clearSubRoute,
          );
        case 'citizen_reporting':
          return CitizenReportingScreen(
            appState: widget.appState,
            onBack: _clearSubRoute,
            onNavigateNamed: _navigateToNamed,
          );
        case 'field_verification':
          return FieldVerificationScreen(
            appState: widget.appState,
            onBack: _clearSubRoute,
          );
        case 'action_engine':
          return ActionEngineScreen(
            appState: widget.appState,
            onBack: _clearSubRoute,
          );
        case 'priority_queue':
          return PriorityQueueScreen(
            appState: widget.appState,
            onBack: _clearSubRoute,
            onNavigateNamed: _navigateToNamed,
          );
        case 'region_analytics':
          return RegionAnalyticsScreen(
            appState: widget.appState,
            onBack: _clearSubRoute,
          );
        case 'risk_history':
          return RiskHistoryScreen(
            appState: widget.appState,
            onBack: _clearSubRoute,
          );
        case 'offline_queue':
          return OfflineQueueScreen(
            appState: widget.appState,
            onBack: _clearSubRoute,
          );
      }
    }

    // Role-specific Tab Views
    if (role == UserRole.authority) {
      switch (_currentIndex) {
        case 0:
          return DashboardScreen(
            appState: widget.appState,
            onNavigateTab: (idx) => setState(() {
              _currentIndex = idx;
              _subRoute = null;
            }),
            onNavigateNamed: _navigateToNamed,
          );
        case 1:
          return RiskMapScreen(
            appState: widget.appState,
            onNavigateNamed: _navigateToNamed,
          );
        case 2:
          return PriorityQueueScreen(
            appState: widget.appState,
            onNavigateNamed: _navigateToNamed,
          );
        case 3:
          return AlertsScreen(
            appState: widget.appState,
            onNavigateNamed: _navigateToNamed,
          );
        case 4:
        default:
          return SettingsScreen(
            appState: widget.appState,
            onLogout: widget.onLogout,
            onNavigateNamed: _navigateToNamed,
          );
      }
    } else if (role == UserRole.fieldOfficer) {
      switch (_currentIndex) {
        case 0:
          return DashboardScreen(
            appState: widget.appState,
            onNavigateTab: (idx) => setState(() {
              _currentIndex = idx;
              _subRoute = null;
            }),
            onNavigateNamed: _navigateToNamed,
          );
        case 1:
          return FieldVerificationScreen(
            appState: widget.appState,
          );
        case 2:
          return RiskMapScreen(
            appState: widget.appState,
            onNavigateNamed: _navigateToNamed,
          );
        case 3:
          return AlertsScreen(
            appState: widget.appState,
            onNavigateNamed: _navigateToNamed,
          );
        case 4:
        default:
          return SettingsScreen(
            appState: widget.appState,
            onLogout: widget.onLogout,
            onNavigateNamed: _navigateToNamed,
          );
      }
    } else {
      // Citizen
      switch (_currentIndex) {
        case 0:
          return DashboardScreen(
            appState: widget.appState,
            onNavigateTab: (idx) => setState(() {
              _currentIndex = idx;
              _subRoute = null;
            }),
            onNavigateNamed: _navigateToNamed,
          );
        case 1:
          return RiskMapScreen(
            appState: widget.appState,
            onNavigateNamed: _navigateToNamed,
          );
        case 2:
          return CitizenReportingScreen(
            appState: widget.appState,
            onNavigateNamed: _navigateToNamed,
          );
        case 3:
          return AlertsScreen(
            appState: widget.appState,
            onNavigateNamed: _navigateToNamed,
          );
        case 4:
        default:
          return SettingsScreen(
            appState: widget.appState,
            onLogout: widget.onLogout,
            onNavigateNamed: _navigateToNamed,
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.appState.currentRole;

    return Scaffold(
      body: _buildBody(role),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _subRoute = null; // reset subroute when switching main tabs
          });
        },
        items: _buildNavItems(role),
      ),
    );
  }
}
