import 'package:flutter/material.dart';

import '../l10n/strings_extension.dart';
import '../theme/app_theme.dart';
import '../widgets/about_widgets.dart';
import '../widgets/app_logo.dart';

/// About the Journal Trend Analyzer application.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s.about,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const AboutHeroSection(version: appVersion),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              s.projectInformation,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.2,
              ),
            ),
          ),
          PremiumCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                AboutInfoCard(
                  icon: Icons.school_outlined,
                  iconColor: AppColors.primary,
                  label: s.course,
                  value: s.courseValue,
                ),
                AboutInfoCard(
                  icon: Icons.science_outlined,
                  iconColor: AppColors.secondary,
                  label: s.project,
                  value: s.projectValue,
                ),
                AboutInfoCard(
                  icon: Icons.code_rounded,
                  iconColor: AppColors.secondary,
                  label: s.framework,
                  value: s.frameworkValue,
                ),
                AboutInfoCard(
                  icon: Icons.cloud_download_outlined,
                  iconColor: AppColors.analyticsTeal,
                  label: s.dataSource,
                  value: 'OpenAlex',
                ),
                AboutInfoCard(
                  icon: Icons.phone_android_rounded,
                  iconColor: AppColors.analyticsTeal,
                  label: s.platform,
                  value: s.android,
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const AboutAiReviewCard(),
          const SizedBox(height: 28),
          Center(
            child: Text(
              s.developedForAcademic,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.45,
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
