import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/bookmark_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final bookmark = Get.find<BookmarkController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with user header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            title: const Text(
              'Profile',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProfileHeader(auth),
            ),
          ),

          // Stats & Settings
          SliverToBoxAdapter(
            child: Obx(() {
              final user = auth.currentUser.value;
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats row
                    _buildStatsRow(bookmark),
                    const SizedBox(height: 24),

                    // Account section
                    const _SectionTitle(title: 'Account'),
                    const SizedBox(height: 12),
                    if (user != null && !user.isGuest) ...[
                      _ProfileItem(
                        icon: Icons.person_rounded,
                        label: 'Display Name',
                        value: user.displayName ?? '—',
                      ),
                      _ProfileItem(
                        icon: Icons.email_rounded,
                        label: 'Email',
                        value: user.email ?? '—',
                      ),
                      _ProfileItem(
                        icon: Icons.verified_rounded,
                        label: 'Account Type',
                        value: 'Google Account',
                        valueColor: AppColors.success,
                      ),
                    ] else
                      _ProfileItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Account Type',
                        value: 'Guest',
                        valueColor: AppColors.warning,
                      ),
                    const SizedBox(height: 24),

                    // Bookmarks section
                    const _SectionTitle(title: 'Content'),
                    const SizedBox(height: 12),
                    _ActionItem(
                      icon: Icons.bookmark_rounded,
                      iconColor: AppColors.highlight,
                      label: 'My Bookmarks',
                      trailing: Obx(() => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.accentGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${bookmark.bookmarks.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )),
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),

                    // App info section
                    const _SectionTitle(title: 'App'),
                    const SizedBox(height: 12),
                    const _ProfileItem(
                      icon: Icons.info_outline_rounded,
                      label: 'Version',
                      value: '1.0.0',
                    ),
                    const _ProfileItem(
                      icon: Icons.newspaper_rounded,
                      label: 'Powered By',
                      value: 'NewsAPI.org',
                    ),
                    const SizedBox(height: 32),

                    // Sign Out button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => _showSignOutDialog(auth),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Sign Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(AuthController auth) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D0D1A), Color(0xFF0F3460)],
        ),
      ),
      child: Obx(() {
        final user = auth.currentUser.value;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.highlight, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.highlight.withAlpha(80),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: user?.photoUrl != null && !user!.isGuest
                    ? Image.network(
                        user.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.accent,
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.accent,
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.displayName ?? 'Guest User',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (user?.email != null)
              Text(
                user!.email!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                  fontSize: 13,
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildStatsRow(BookmarkController bookmark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A4A), width: 1),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Obx(() => Row(
            children: [
              _StatItem(
                icon: Icons.bookmark_rounded,
                value: '${bookmark.bookmarks.length}',
                label: 'Bookmarks',
                color: AppColors.highlight,
              ),
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFF2A2A4A),
              ),
              const _StatItem(
                icon: Icons.newspaper_rounded,
                value: '∞',
                label: 'Articles',
                color: AppColors.success,
              ),
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFF2A2A4A),
              ),
              const _StatItem(
                icon: Icons.chat_bubble_rounded,
                value: 'AI',
                label: 'NewsBot',
                color: AppColors.accent,
              ),
            ],
          )),
    );
  }

  void _showSignOutDialog(AuthController auth) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textHint),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              auth.signOut();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textHint,
        fontFamily: 'Poppins',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A4A), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textHint, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A4A), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textHint,
              fontFamily: 'Poppins',
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
