import 'package:flutter/material.dart';
import '../../constants/style_constants.dart';

class ExplorerPage extends StatelessWidget {
	const ExplorerPage({super.key});

	@override
	Widget build(BuildContext context) {
		final List<String> categories = [
			'Technology',
			'Sports',
			'Politics',
			'Entertainment',
			'Science',
			'Health',
			'Business',
			'Education'
		];

		return Scaffold(
			backgroundColor: AppColors.background,
			body: SafeArea(
				child: Padding(
					padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(
								'Explore Topics',
								style: AppTypography.heading1,
							),
							const SizedBox(height: 20),
							Container(
								decoration: BoxDecoration(
									color: AppColors.surface,
									borderRadius: BorderRadius.circular(20),
									border: Border.all(color: AppColors.divider),
								),
								child: TextField(
									style: AppTypography.body1,
									decoration: AppInputDecoration.defaultDecoration('Search topics...').copyWith(
										prefixIcon: Icon(
											Icons.search_rounded,
											color: AppColors.textSecondary,
										),
										hintStyle: AppTypography.body1.copyWith(
											color: AppColors.textSecondary,
										),
									),
								),
							),
							const SizedBox(height: 24),
							Expanded(
								child: GridView.builder(
									gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
										crossAxisCount: 2,
										crossAxisSpacing: 10,
										mainAxisSpacing: 10,
										childAspectRatio: 1.3,
									),
									padding: EdgeInsets.zero,
									itemCount: categories.length,
									itemBuilder: (context, index) {
										return AnimatedContainer(
											duration: const Duration(milliseconds: 200),
											decoration: BoxDecoration(
												color: AppColors.surface,
												borderRadius: BorderRadius.circular(20),
												border: Border.all(color: AppColors.divider),
												boxShadow: [
													BoxShadow(
														color: Colors.black.withOpacity(0.2),
														offset: const Offset(0, 4),
														blurRadius: 20,
													),
												],
											),
											child: Material(
												color: Colors.transparent,
												child: InkWell(
													onTap: () {},
													borderRadius: BorderRadius.circular(20),
													splashColor: AppColors.accent.withOpacity(0.1),
													highlightColor: AppColors.accent.withOpacity(0.05),
													child: Container(
														padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
														child: Column(
															mainAxisAlignment: MainAxisAlignment.center,
															children: [
																Container(
																	padding: const EdgeInsets.all(8),
																	decoration: BoxDecoration(
																		color: AppColors.accent.withOpacity(0.1),
																		shape: BoxShape.circle,
																	),
																	child: Icon(
																		_getCategoryIcon(categories[index]),
																		size: 22,
																		color: AppColors.accent,
																	),
																),
																const SizedBox(height: 4),
																Text(
																	categories[index],
																	style: AppTypography.body2.copyWith(
																		fontWeight: FontWeight.w600,
																		fontSize: 12,
																	),
																	textAlign: TextAlign.center,
																	maxLines: 1,
																	overflow: TextOverflow.ellipsis,
																),
															],
														),
													),
												),
											),
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

	IconData _getCategoryIcon(String category) {
		switch (category.toLowerCase()) {
			case 'technology':
				return Icons.computer_rounded;
			case 'sports':
				return Icons.sports_rounded;
			case 'politics':
				return Icons.gavel_rounded;
			case 'entertainment':
				return Icons.movie_rounded;
			case 'science':
				return Icons.science_rounded;
			case 'health':
				return Icons.health_and_safety_rounded;
			case 'business':
				return Icons.business_rounded;
			case 'education':
				return Icons.school_rounded;
			default:
				return Icons.category_rounded;
		}
	}
}