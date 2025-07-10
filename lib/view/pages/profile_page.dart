import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants/style_constants.dart';
import '../../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
	const ProfilePage({super.key});

	@override
	State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
	late final AuthService _authService;
	String? _errorMessage;

	@override
	void initState() {
		super.initState();
		_authService = AuthService();
	}

	@override
	Widget build(BuildContext context) {
		final user = FirebaseAuth.instance.currentUser;

		return Scaffold(
			backgroundColor: AppColors.background,
			body: SafeArea(
				child: SingleChildScrollView(
					padding: const EdgeInsets.all(24.0),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(
								'Profile',
								style: AppTypography.heading1,
							),
							const SizedBox(height: 32),
							Container(
								padding: const EdgeInsets.all(24),
								decoration: BoxDecoration(
									color: AppColors.surface,
									borderRadius: BorderRadius.circular(24),
									border: Border.all(color: AppColors.divider),
									boxShadow: [
										BoxShadow(
											color: Colors.black.withOpacity(0.2),
											offset: const Offset(0, 4),
											blurRadius: 20,
										),
									],
								),
								child: Column(
									children: [
										Container(
											width: 120,
											height: 120,
											decoration: BoxDecoration(
												color: AppColors.accent.withOpacity(0.1),
												shape: BoxShape.circle,
											),
											child: Icon(
												Icons.person_rounded,
												size: 64,
												color: AppColors.accent,
											),
										),
										const SizedBox(height: 16),
										Text(
											user?.email ?? 'No email',
											style: AppTypography.heading3,
										),
									],
								),
							),
							const SizedBox(height: 24),
							Container(
								decoration: BoxDecoration(
									color: AppColors.surface,
									borderRadius: BorderRadius.circular(24),
									border: Border.all(color: AppColors.divider),
									boxShadow: [
										BoxShadow(
											color: Colors.black.withOpacity(0.2),
											offset: const Offset(0, 4),
											blurRadius: 20,
										),
									],
								),
								child: Column(
									children: [
										_buildProfileOption(
											icon: Icons.bookmark_rounded,
											title: 'Saved Articles',
											onTap: () {},
										),
										Divider(
										  height: 1,
										  color: AppColors.divider,
										),
										_buildProfileOption(
											icon: Icons.settings_rounded,
											title: 'Settings',
											onTap: () {},
										),
										Divider(
											height: 1,
											color: AppColors.divider,
										),
										_buildProfileOption(
											icon: Icons.logout_rounded,
											title: 'Logout',
											onTap: () async {
												try {
													await _authService.signOut();
													if (context.mounted) {
														Navigator.of(context).pushNamedAndRemoveUntil(
															'/login',
															(route) => false,
														);
													}
												} catch (e) {
													if (context.mounted) {
														ScaffoldMessenger.of(context).showSnackBar(
															SnackBar(
																content: Text(
																	'Error signing out: ${e.toString()}',
																	style: AppTypography.body2.copyWith(
																		color: AppColors.textPrimary,
																	),
																),
																backgroundColor: AppColors.surface,
																duration: const Duration(seconds: 3),
															),
														);
													}
												}
											},
											isDestructive: true,
										),
									],
								),
							),
						],
					),
				),
			),
		);
	}

	Widget _buildProfileOption({
		required IconData icon,
		required String title,
		required VoidCallback onTap,
		bool isDestructive = false,
	}) {
		return Material(
			color: Colors.transparent,
			child: InkWell(
				onTap: onTap,
				borderRadius: BorderRadius.circular(24),
				splashColor: isDestructive 
						? AppColors.actionPrimary.withOpacity(0.1)
						: AppColors.accent.withOpacity(0.1),
				highlightColor: isDestructive
						? AppColors.actionPrimary.withOpacity(0.05)
						: AppColors.accent.withOpacity(0.05),
				child: Padding(
					padding: const EdgeInsets.all(20.0),
					child: Row(
						children: [
							Container(
								padding: const EdgeInsets.all(8),
								decoration: BoxDecoration(
									color: isDestructive
											? AppColors.actionPrimary.withOpacity(0.1)
											: AppColors.accent.withOpacity(0.1),
									shape: BoxShape.circle,
								),
								child: Icon(
									icon,
									color: isDestructive ? AppColors.actionPrimary : AppColors.accent,
									size: 24,
								),
							),
							const SizedBox(width: 16),
							Text(
								title,
								style: AppTypography.body1.copyWith(
									fontWeight: FontWeight.w600,
									color: isDestructive ? AppColors.actionPrimary : AppColors.textPrimary,
								),
							),
							const Spacer(),
							Icon(
								Icons.chevron_right_rounded,
								color: isDestructive
										? AppColors.actionPrimary.withOpacity(0.5)
										: AppColors.textSecondary,
							),
						],
					),
				),
			),
		);
	}
}