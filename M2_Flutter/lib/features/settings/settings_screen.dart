import 'package:flutter/material.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../state/app_state.dart';

class SettingsScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback? onLogout;
  final Function(String routeName, {Object? arguments})? onNavigateNamed;

  const SettingsScreen({
    super.key,
    required this.appState,
    this.onLogout,
    this.onNavigateNamed,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English (US / IN)';
  bool _pushEnabled = true;
  bool _smsEnabled = true;
  bool _sirenEnabled = true;
  bool _capEnabled = true;

  void _showArchitectureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.hub_outlined, color: AppColors.teal),
            SizedBox(width: 8),
            Text('Hybrid Backend & AI Specs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('REST API Endpoints (Section 5 & 14):', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
              const SizedBox(height: 6),
              _apiItem('GET', ApiEndpoints.riskLocation),
              _apiItem('GET', '${ApiEndpoints.riskRoad}/{id}'),
              _apiItem('GET', ApiEndpoints.riskArea),
              _apiItem('GET', ApiEndpoints.alertsActive),
              _apiItem('GET', ApiEndpoints.routesRiskAware),
              _apiItem('POST', ApiEndpoints.reports),
              _apiItem('POST', ApiEndpoints.reportVerify),
              _apiItem('POST', ApiEndpoints.actionStatus),
              const SizedBox(height: 12),
              const Text('Backend & Storage (Section 7 & 15):', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.teal)),
              const SizedBox(height: 4),
              const Text('• Supabase Auth & Realtime WebSocket subscriptions\n• PostGIS spatial query engine for DEM/slope polygons\n• Encrypted evidence bucket for camera verification seals', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4)),
              const SizedBox(height: 12),
              const Text('AI/ML Pipeline (Section 3 & 16):', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.riskModerate)),
              const SizedBox(height: 4),
              const Text('• Abstract RiskEngine interface decoupled from UI\n• Model Training: Random Forest / XGBoost / Deep Learning\n• Live feedback loop directly updates weights upon Field Verification', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showNotificationPreferencesDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notification Channels',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Push Notifications', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    subtitle: const Text('Real-time landslide alert notifications', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    value: _pushEnabled,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setModalState(() => _pushEnabled = val);
                      setState(() => _pushEnabled = val);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Emergency SMS Broadcast', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    subtitle: const Text('Low connectivity fallback alerts', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    value: _smsEnabled,
                    activeColor: AppColors.teal,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setModalState(() => _smsEnabled = val);
                      setState(() => _smsEnabled = val);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Audible Siren Broadcast', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    subtitle: const Text('Critical evactuation siren overrides', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    value: _sirenEnabled,
                    activeColor: AppColors.riskHigh,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setModalState(() => _sirenEnabled = val);
                      setState(() => _sirenEnabled = val);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('CAP Protocol Relay', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    subtitle: const Text('Common Alerting Protocol inter-agency dispatch', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    value: _capEnabled,
                    activeColor: AppColors.riskModerate,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setModalState(() => _capEnabled = val);
                      setState(() => _capEnabled = val);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languages = [
      'English (US / IN)',
      'Hindi (हिन्दी)',
      'Assamese (অসমীয়া)',
      'Bengali (বাংলা)',
      'Nepali (नेपाली)',
      'Bodo (बर\')',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select App Language',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              ...languages.map((lang) {
                final isSelected = lang == _selectedLanguage;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                  ),
                  title: Text(
                    lang,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    setState(() => _selectedLanguage = lang);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Language updated to: $lang'),
                        backgroundColor: AppColors.primary,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _apiItem(String method, String path) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: method == 'GET' ? AppColors.tealPastel : AppColors.primaryPastel,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              method,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: method == 'GET' ? AppColors.teal : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(path, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, fontFamily: 'monospace', fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.appState.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile / Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card matching wireframe
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primaryPastel,
                    child: Text(
                      user.name.substring(0, 2).toUpperCase(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text(user.roleDisplayName, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Region: ${user.assignedRegion}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Live Role Switcher Segment (Demo Mode)
            const Text(
              'Switch Active Role',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _buildRoleBtn(context, 'Authority', UserRole.authority),
                  _buildRoleBtn(context, 'Field Officer', UserRole.fieldOfficer),
                  _buildRoleBtn(context, 'Citizen', UserRole.citizen),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings List Tiles matching wireframe (`Settings`: Notification Preferences, Map Layers, Offline Mode, Data Sync, Language, Security, Logout)
            const Text(
              'Settings',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),

            _settingsTile(
              icon: Icons.notifications_none,
              title: 'Notification Preferences',
              subtitle: 'Channels: ${_pushEnabled ? "Push, " : ""}${_smsEnabled ? "SMS, " : ""}${_sirenEnabled ? "Siren, " : ""}${_capEnabled ? "CAP" : ""}',
              onTap: () => _showNotificationPreferencesDialog(context),
            ),
            _settingsTile(
              icon: Icons.layers_outlined,
              title: 'Map Layers',
              subtitle: 'Configure hazard overlays, road network, DEM',
              onTap: () => widget.onNavigateNamed?.call('risk_map'),
            ),
            _settingsTile(
              icon: Icons.wifi_off_outlined,
              title: 'Offline Mode',
              subtitle: 'Manage local SQLite queue & sync state',
              onTap: () => widget.onNavigateNamed?.call('offline_queue'),
            ),
            _settingsTile(
              icon: Icons.sync,
              title: 'Data Sync',
              subtitle: 'Synchronize field reports with central servers',
              onTap: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Starting synchronization with central servers...'), duration: Duration(seconds: 1)),
                );
                await widget.appState.offlineService.syncAllPending();
                await widget.appState.loadAllData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data Synchronization Complete!'), backgroundColor: AppColors.teal),
                  );
                }
              },
            ),
            _settingsTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: _selectedLanguage,
              onTap: () => _showLanguageDialog(context),
            ),
            _settingsTile(
              icon: Icons.security,
              title: 'Security & Integrity',
              subtitle: 'Hardware GPS and sealed metadata hash validation',
              onTap: () => _showArchitectureDialog(context),
            ),
            _settingsTile(
              icon: Icons.hub_outlined,
              title: 'REST API & AI Model Specs',
              subtitle: 'View Model Training & Supabase integration contract',
              onTap: () => _showArchitectureDialog(context),
            ),

            const SizedBox(height: 20),

            // Logout Button matching wireframe
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text('Confirm Logout', style: TextStyle(fontWeight: FontWeight.w800)),
                      content: const Text('Are you sure you want to log out of Terra Sense?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onLogout?.call();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.riskHigh),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout, color: AppColors.riskHigh, size: 18),
                label: const Text('Logout', style: TextStyle(color: AppColors.riskHigh, fontWeight: FontWeight.w800)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.riskHighBorder),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBtn(BuildContext context, String label, UserRole role) {
    final isSelected = widget.appState.currentRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.appState.switchUserRole(role);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Switched role to: $label'),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryPastel,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
