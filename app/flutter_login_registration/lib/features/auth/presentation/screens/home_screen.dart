import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final UserEntity user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: _HomeView(user: user),
    );
  }
}

class _HomeView extends StatelessWidget {
  final UserEntity user;

  const _HomeView({required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.bgGradient),
          child: SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        _buildWelcomeCard(context),
                        const SizedBox(height: 28),
                        _sectionLabel('Profile'),
                        const SizedBox(height: 12),
                        _buildProfileCard(),
                        const SizedBox(height: 28),
                        _sectionLabel('Session Info'),
                        const SizedBox(height: 12),
                        _buildSessionRow(),
                        const SizedBox(height: 28),
                        _sectionLabel('Security'),
                        const SizedBox(height: 12),
                        _buildSecurityList(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── top bar ──────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.dashboard_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Text('Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                  )),
          const Spacer(),
          _LogoutButton(),
        ],
      ),
    );
  }

  // ── welcome card ─────────────────────────────────────────────────────────

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withAlpha(90),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  user.username,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '✅  Session active',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.person_rounded,
                color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  // ── profile card ─────────────────────────────────────────────────────────

  Widget _buildProfileCard() {
    final shortId = user.id.length > 8
        ? '${user.id.substring(0, 8)}…'
        : user.id;

    return _Card(
      children: [
        _InfoRow(
          icon: Icons.person_outline,
          label: 'Username',
          value: user.username,
        ),
        const _CardDivider(),
        _InfoRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: user.email,
        ),
        const _CardDivider(),
        _InfoRow(
          icon: Icons.fingerprint_rounded,
          label: 'User ID',
          value: shortId,
        ),
      ],
    );
  }

  // ── session info row ─────────────────────────────────────────────────────

  Widget _buildSessionRow() {
    return Row(
      children: const [
        Expanded(
          child: _StatTile(
            icon: Icons.token_rounded,
            label: 'Access Token',
            value: '15 min',
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.replay_rounded,
            label: 'Refresh Token',
            value: '7 days',
            color: AppColors.accent,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.verified_user_rounded,
            label: 'Status',
            value: 'Active',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  // ── security list ─────────────────────────────────────────────────────────

  Widget _buildSecurityList() {
    const items = [
      _SecurityItem(
        icon: Icons.https_rounded,
        title: 'HTTPS / TLS',
        subtitle: 'All traffic encrypted in transit',
        color: AppColors.success,
      ),
      _SecurityItem(
        icon: Icons.push_pin_rounded,
        title: 'SSL Certificate Pinning',
        subtitle: 'SHA-256 fingerprint verified per request',
        color: AppColors.primary,
      ),
      _SecurityItem(
        icon: Icons.shield_rounded,
        title: 'Helmet Security Headers',
        subtitle: 'CSP, HSTS, X-Frame-Options active',
        color: AppColors.accent,
      ),
      _SecurityItem(
        icon: Icons.storage_rounded,
        title: 'Secure Token Storage',
        subtitle: 'Keychain (iOS) / Keystore (Android)',
        color: Color(0xFFFFC107),
      ),
      _SecurityItem(
        icon: Icons.refresh_rounded,
        title: 'Token Rotation',
        subtitle: 'Refresh token rotated on every use',
        color: Color(0xFF00BCD4),
      ),
    ];

    return _Card(
      children: List.generate(items.length, (i) {
        return Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: items[i].color.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(items[i].icon,
                        color: items[i].color, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[i].title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items[i].subtitle,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle_rounded,
                      color: items[i].color, size: 18),
                ],
              ),
            ),
            if (i < items.length - 1)
              const Divider(
                  height: 1, color: AppColors.border, indent: 68),
          ],
        );
      }),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ── Logout button ─────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final loading = state is AuthLoading;
        return GestureDetector(
          onTap: loading
              ? null
              : () => context.read<AuthBloc>().add(const LogoutRequested()),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.error.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.error.withAlpha(70)),
            ),
            child: loading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                        color: AppColors.error, strokeWidth: 2),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout_rounded,
                          color: AppColors.error, size: 15),
                      SizedBox(width: 5),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final List<Widget> children;

  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 17),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}

class _SecurityItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _SecurityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
