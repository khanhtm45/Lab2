import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings_extension.dart';
import '../providers/publication_provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../firebase/messaging_service.dart';
import '../firebase/crashlytics_service.dart';
import '../theme/app_theme.dart';
import '../services/pdf_preview_service.dart';
import 'about_screen.dart';
import 'openalex_config_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

/// Profile tab — Firebase authentication, services, and user management
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    CrashlyticsService.recordScreenView('ProfileScreen');
    
    return SafeArea(
      child: Consumer2<AuthViewModel, ProfileViewModel>(
        builder: (context, authViewModel, profileViewModel, child) {
          if (!authViewModel.isSignedIn) {
            return _buildGuestView(context);
          }

          return _buildAuthenticatedView(context, authViewModel, profileViewModel);
        },
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    final palette = context.palette;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: palette.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline_rounded,
              size: 48,
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sign In to Access Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in with Google to access personalized features, notifications, and more',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: palette.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.login_rounded),
              label: const Text('Sign In with Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedView(
    BuildContext context,
    AuthViewModel authViewModel,
    ProfileViewModel profileViewModel,
  ) {
    final s = context.strings;
    final palette = context.palette;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        // Header
        Center(
          child: Text(
            'Profile & Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // User Info Section - Theo yêu cầu thầy
        _buildUserInfoSection(authViewModel, palette),
        const SizedBox(height: 24),

        // Bookmarks Section - Theo yêu cầu thầy  
        _buildBookmarksSection(context, palette),
        const SizedBox(height: 24),

        // Crashlytics Test Section - Theo yêu cầu thầy
        _buildCrashlyticsTestSection(context, profileViewModel, palette),
        const SizedBox(height: 24),

        // Additional Firebase Features
        _buildFirebaseFeaturesSection(context, profileViewModel, palette),
        const SizedBox(height: 24),

        // Report Export & Preview Section - Theo yêu cầu thầy
        _buildReportExportSection(context, profileViewModel, palette),
        const SizedBox(height: 24),

        // App Settings Section
        _buildAppSettingsSection(context, s, palette),
        const SizedBox(height: 24),

        // Sign Out Button
        _buildSignOutButton(context, authViewModel, palette),
      ],
    );
  }

  Widget _buildBookmarksSection(BuildContext context, AppPalette palette) {
    return Consumer<PublicationProvider>(
      builder: (context, provider, child) {
        final bookmarkedTopics = provider.bookmarkedTopics;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
        boxShadow: palette.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bookmark, color: palette.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'List Bookmark',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: palette.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${bookmarkedTopics.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: palette.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (bookmarkedTopics.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: palette.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 48,
                    color: palette.textTertiary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Chưa có bookmark nào',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bookmark các chủ đề nghiên cứu để truy cập nhanh',
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            // Bookmarked Topics
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: bookmarkedTopics.map((topic) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: palette.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: palette.secondary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bookmark,
                        size: 12,
                        color: palette.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        topic,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: palette.secondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => provider.toggleBookmarkTopic(topic),
                        child: Icon(
                          Icons.close,
                          size: 12,
                          color: palette.secondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            
            if (bookmarkedTopics.length > 3) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Navigate to full bookmarks page
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Tất cả Bookmarks (${bookmarkedTopics.length})'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: bookmarkedTopics.map((topic) {
                              return ListTile(
                                leading: Icon(Icons.bookmark, color: palette.secondary),
                                title: Text(topic),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () {
                                    provider.toggleBookmarkTopic(topic);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Đóng'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Xem tất cả (${bookmarkedTopics.length})',
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
      },
    );
  }

  Widget _buildCrashlyticsTestSection(BuildContext context, ProfileViewModel profileViewModel, AppPalette palette) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
        boxShadow: palette.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, color: palette.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                'Test Crashlytics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Kiểm tra tính năng Firebase Crashlytics để theo dõi lỗi ứng dụng',
            style: TextStyle(
              fontSize: 12,
              color: palette.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Test Exception Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => profileViewModel.generateTestException(),
              icon: Icon(Icons.error_outline, size: 16, color: palette.warning),
              label: Text(
                'Test Exception',
                style: TextStyle(
                  fontSize: 14,
                  color: palette.warning,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: palette.warning),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),

          // Test Crash Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCrashConfirmation(context, profileViewModel, palette),
              icon: Icon(Icons.warning, size: 16, color: Colors.white),
              label: Text(
                'Test Crash (Cẩn thận!)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.error,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Info note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: palette.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: palette.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dữ liệu lỗi sẽ được gửi lên Firebase Console để phân tích',
                    style: TextStyle(
                      fontSize: 11,
                      color: palette.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirebaseFeaturesSection(BuildContext context, ProfileViewModel profileViewModel, AppPalette palette) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
        boxShadow: palette.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_outlined, color: palette.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Firebase Features',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick access to Firebase features
          Row(
            children: [
              _buildFeatureButton(
                context,
                'Analytics',
                Icons.analytics_outlined,
                palette.primary,
                () => _showAnalyticsDialog(context, palette),
              ),
              const SizedBox(width: 8),
              _buildFeatureButton(
                context,
                'Storage',
                Icons.cloud_upload_outlined,
                palette.secondary,
                () => _showStorageDialog(context, profileViewModel, palette),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              _buildFeatureButton(
                context,
                'Messaging',
                Icons.message_outlined,
                palette.accent,
                () => _showMessagingDialog(context, profileViewModel, palette),
              ),
              const SizedBox(width: 8),
              _buildFeatureButton(
                context,
                'Remote Config',
                Icons.settings_remote_outlined,
                palette.warning,
                () => _showRemoteConfigDialog(context, profileViewModel, palette),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(AuthViewModel authViewModel, AppPalette palette) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
        boxShadow: palette.cardShadow,
      ),
      child: Column(
        children: [
          // Profile picture
          CircleAvatar(
            radius: 40,
            backgroundColor: palette.primary,
            backgroundImage: authViewModel.userPhotoUrl != null
                ? NetworkImage(authViewModel.userPhotoUrl!)
                : null,
            child: authViewModel.userPhotoUrl == null
                ? Text(
                    authViewModel.getUserInitials(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),

          // User name
          Text(
            authViewModel.userDisplayName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            authViewModel.userEmail,
            style: TextStyle(
              fontSize: 14,
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          // Firebase UID
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: palette.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'UID: ${authViewModel.userUid.isNotEmpty ? authViewModel.userUid.substring(0, 8) : 'N/A'}...',
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'monospace',
                color: palette.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(ProfileViewModel profileViewModel, AppPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notifications_rounded, color: palette.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Notification Center',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
            const Spacer(),
            ValueListenableBuilder<List<NotificationMessage>>(
              valueListenable: MessagingService.notificationsNotifier,
              builder: (context, notifications, child) {
                final unreadCount = notifications.where((n) => !n.isRead).length;
                if (unreadCount == 0) return const SizedBox.shrink();
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: palette.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.add_alert_rounded,
                title: 'Add Demo Notifications',
                onTap: () => profileViewModel.addDemoNotifications(),
                palette: palette,
              ),
              Divider(height: 1, color: palette.border),
              ValueListenableBuilder<List<NotificationMessage>>(
                valueListenable: MessagingService.notificationsNotifier,
                builder: (context, notifications, child) {
                  if (notifications.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No notifications yet',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: notifications.take(3).map((notification) {
                      return _buildNotificationItem(notification, profileViewModel, palette);
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(
    NotificationMessage notification,
    ProfileViewModel profileViewModel,
    AppPalette palette,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notification.isRead ? null : palette.primary.withValues(alpha: 0.05),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: notification.isRead ? palette.textTertiary : palette.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
                if (notification.body.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 11,
                      color: palette.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Text(
            notification.getTimeAgo(),
            style: TextStyle(
              fontSize: 10,
              color: palette.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoteConfigSection(ProfileViewModel profileViewModel, AppPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.settings_remote_rounded, color: palette.accent, size: 20),
            const SizedBox(width: 8),
            Text(
              'Remote Config',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.refresh_rounded, size: 18, color: palette.primary),
              onPressed: () => profileViewModel.refreshRemoteConfig(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConfigItem('Maximum Journals', 
                  '${profileViewModel.getRemoteConfigValue('max_journals', 10)}', palette),
              const SizedBox(height: 8),
              _buildConfigItem('Maximum Keywords', 
                  '${profileViewModel.getRemoteConfigValue('max_keywords', 15)}', palette),
              const SizedBox(height: 8),
              _buildConfigItem('App Version', 
                  profileViewModel.getRemoteConfigValue('app_version', '1.0.0'), palette),
              const SizedBox(height: 8),
              _buildConfigItem('Theme', 
                  profileViewModel.getRemoteConfigValue('theme', 'light'), palette),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfigItem(String label, String value, AppPalette palette) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: palette.textSecondary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: palette.surfaceMuted,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFirebaseServicesSection(BuildContext context, ProfileViewModel profileViewModel, AppPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bug_report_rounded, color: palette.warning, size: 20),
            const SizedBox(width: 8),
            Text(
              'Crashlytics Demo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.error_outline_rounded,
                title: 'Generate Test Exception',
                onTap: () => profileViewModel.generateTestException(),
                palette: palette,
              ),
              Divider(height: 1, color: palette.border),
              _buildMenuItem(
                icon: Icons.warning_rounded,
                title: 'Generate Test Crash',
                onTap: () => _showCrashConfirmation(context, profileViewModel, palette),
                palette: palette,
                titleColor: palette.error,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppSettingsSection(BuildContext context, dynamic s, AppPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.settings_rounded, color: palette.textSecondary, size: 20),
            const SizedBox(width: 8),
            Text(
              'App Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.api_rounded,
                title: 'OpenAlex Configuration',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OpenAlexConfigScreen()),
                  );
                },
                palette: palette,
              ),
              Divider(height: 1, color: palette.border),
              _buildMenuItem(
                icon: Icons.tune_rounded,
                title: s.settings,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                palette: palette,
              ),
              Divider(height: 1, color: palette.border),
              _buildMenuItem(
                icon: Icons.info_outline_rounded,
                title: s.about,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                },
                palette: palette,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    required AppPalette palette,
    Color? titleColor,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: titleColor ?? palette.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? palette.textPrimary,
                ),
              ),
            ),
            if (trailing != null) ...[
              trailing,
            ] else if (onTap != null) ...[
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: palette.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, AuthViewModel authViewModel, AppPalette palette) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: authViewModel.isLoading
            ? null
            : () => _showSignOutConfirmation(context, authViewModel),
        icon: authViewModel.isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(palette.surface),
                ),
              )
            : const Icon(Icons.logout_rounded),
        label: Text(authViewModel.isLoading ? 'Signing Out...' : 'Sign Out'),
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showSignOutConfirmation(BuildContext context, AuthViewModel authViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              authViewModel.signOut().then((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              });
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showCrashConfirmation(BuildContext context, ProfileViewModel profileViewModel, AppPalette palette) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Test Crash'),
        content: const Text(
          'This will crash the app for testing Crashlytics. '
          'The app will restart automatically. Continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Delay to allow dialog to close
              Future.delayed(const Duration(milliseconds: 500), () {
                profileViewModel.generateTestCrash();
              });
            },
            child: Text(
              'Crash App',
              style: TextStyle(color: palette.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportExportSection(BuildContext context, ProfileViewModel profileViewModel, AppPalette palette) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
        boxShadow: palette.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.file_download_outlined, color: palette.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Export & Upload Report',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tạo và tải báo cáo PDF nghiên cứu IT',
            style: TextStyle(
              fontSize: 12,
              color: palette.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Preview Report Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _previewReport(context, profileViewModel),
              icon: Icon(Icons.preview, size: 16, color: palette.primary),
              label: Text(
                'Preview Report',
                style: TextStyle(
                  fontSize: 14,
                  color: palette.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: palette.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),

          // Export & Upload Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: profileViewModel.isExportingPdf
                  ? null
                  : () => _exportAndUploadReport(context, profileViewModel),
              icon: profileViewModel.isExportingPdf
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Icon(Icons.cloud_upload, size: 16, color: Colors.white),
              label: Text(
                profileViewModel.isExportingPdf
                    ? 'Đang tải lên...'
                    : 'Export & Upload',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.secondary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // Uploaded Files Section
          if (profileViewModel.uploadedFiles.isNotEmpty) ...[
            Text(
              'Uploaded Reports (${profileViewModel.uploadedFiles.length})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: profileViewModel.uploadedFiles.take(3).map((fileName) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, size: 16, color: palette.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fileName,
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.cloud_done, size: 14, color: palette.success),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            if (profileViewModel.uploadedFiles.length > 3) ...[
              const SizedBox(height: 4),
              Text(
                'và ${profileViewModel.uploadedFiles.length - 3} file khác...',
                style: TextStyle(
                  fontSize: 11,
                  color: palette.textTertiary,
                ),
              ),
            ],
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: palette.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chưa có báo cáo nào được tải lên',
                      style: TextStyle(
                        fontSize: 12,
                        color: palette.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _previewReport(BuildContext context, ProfileViewModel profileViewModel) async {
    try {
      // Get user info for report
      final authViewModel = context.read<AuthViewModel>();
      final userDisplayName = authViewModel.userDisplayName;
      
      // Generate analytics data
      final analyticsData = {
        'totalPublications': '156',
        'activeResearchers': '89',
        'topConferences': '24',
        'avgCitations': '15.3',
        'researchPeriod': '2020-2024',
        'reportDate': DateTime.now().toString().split(' ')[0],
      };

      // Show PDF preview
      await PdfPreviewService.showPdfPreview(
        context,
        userDisplayName: userDisplayName,
        reportTitle: 'IT Research Analytics Dashboard',
        analyticsData: analyticsData,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preview failed: ${e.toString()}'),
            backgroundColor: context.palette.error,
          ),
        );
      }
    }
  }

  Future<void> _exportAndUploadReport(BuildContext context, ProfileViewModel profileViewModel) async {
    try {
      // Get user info for report
      final authViewModel = context.read<AuthViewModel>();
      final userDisplayName = authViewModel.userDisplayName;
      
      // Generate analytics data
      final analyticsData = {
        'totalPublications': '156',
        'activeResearchers': '89',
        'topConferences': '24',
        'avgCitations': '15.3',
        'researchPeriod': '2020-2024',
        'reportDate': DateTime.now().toString().split(' ')[0],
      };

      // Export PDF report using ProfileViewModel
      final downloadUrl = await profileViewModel.exportPdfReport(
        topic: 'IT Research Analytics Dashboard',
        analyticsData: analyticsData,
      );

      if (downloadUrl != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.cloud_done, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Báo cáo đã được tạo và tải lên thành công!'),
                ),
              ],
            ),
            backgroundColor: context.palette.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Export failed: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: context.palette.error,
          ),
        );
      }
    }
  }

  // ========== FIREBASE FEATURE DIALOGS ==========

  void _showAnalyticsDialog(BuildContext context, AppPalette palette) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.analytics, color: palette.primary),
            const SizedBox(width: 8),
            const Text('Firebase Analytics'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics Data',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildAnalyticsStat('Total Users', '1,234', Icons.people, palette.primary),
              const SizedBox(height: 12),
              _buildAnalyticsStat('Active Sessions', '89', Icons.phone_android, palette.secondary),
              const SizedBox(height: 12),
              _buildAnalyticsStat('Screen Views', '5,678', Icons.visibility, palette.accent),
              const SizedBox(height: 12),
              _buildAnalyticsStat('Avg Session Duration', '4m 32s', Icons.timer, palette.warning),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: palette.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: palette.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: palette.success, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Analytics is tracking events successfully',
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsStat(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showStorageDialog(BuildContext context, ProfileViewModel profileViewModel, AppPalette palette) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Header
              Row(
                children: [
                  Icon(Icons.cloud_upload, color: palette.secondary, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Firebase Storage',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Upload buttons
              ElevatedButton.icon(
                onPressed: profileViewModel.isExportingPdf
                    ? null
                    : () async {
                        Navigator.of(context).pop();
                        await _exportAndUploadReport(context, profileViewModel);
                      },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Generate & Upload PDF Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              
              const SizedBox(height: 12),
              
              OutlinedButton.icon(
                onPressed: () async {
                  final fileName = await profileViewModel.mockSelectFile();
                  if (fileName != null && context.mounted) {
                    await profileViewModel.mockUploadFile(fileName);
                  }
                },
                icon: const Icon(Icons.file_upload),
                label: const Text('Select & Upload File (Mock)'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Uploaded files
              Text(
                'Uploaded Files (${profileViewModel.uploadedFiles.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: profileViewModel.uploadedFiles.length,
                  itemBuilder: (context, index) {
                    final fileName = profileViewModel.uploadedFiles[index];
                    return ListTile(
                      leading: Icon(Icons.picture_as_pdf, color: palette.error),
                      title: Text(
                        fileName,
                        style: const TextStyle(fontSize: 13),
                      ),
                      trailing: Icon(Icons.cloud_done, color: palette.success, size: 20),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessagingDialog(BuildContext context, ProfileViewModel profileViewModel, AppPalette palette) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications, color: palette.accent),
            const SizedBox(width: 8),
            const Text('Firebase Messaging'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Push Notification Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: palette.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: palette.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: palette.success, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'FCM Token Active',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: palette.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildMessagingStat('Total Received', '47', palette.primary),
              const SizedBox(height: 10),
              _buildMessagingStat('Unread', '${profileViewModel.unreadNotificationCount}', palette.warning),
              const SizedBox(height: 10),
              _buildMessagingStat('Subscribed Topics', '3', palette.accent),
              
              const SizedBox(height: 20),
              
              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    profileViewModel.addDemoNotifications();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('✅ Demo notifications added!'),
                        backgroundColor: palette.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_alert),
                  label: const Text('Add Demo Notifications'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagingStat(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  void _showRemoteConfigDialog(BuildContext context, ProfileViewModel profileViewModel, AppPalette palette) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.settings_remote, color: palette.warning),
            const SizedBox(width: 8),
            const Text('Remote Config'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Configuration Values',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: palette.primary, size: 20),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await profileViewModel.refreshRemoteConfig();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(profileViewModel.successMessage ?? 'Config refreshed'),
                            backgroundColor: palette.success,
                          ),
                        );
                        _showRemoteConfigDialog(context, profileViewModel, palette);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              ...profileViewModel.remoteConfigValues.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: palette.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: palette.warning.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          entry.value.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: palette.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: palette.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: palette.primary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Values updated from Firebase Remote Config',
                        style: TextStyle(
                          fontSize: 11,
                          color: palette.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

}
