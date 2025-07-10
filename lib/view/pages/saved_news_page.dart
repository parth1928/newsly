import 'package:flutter/material.dart';
import '../../constants/style_constants.dart';
import '../../models/news_model.dart';
import '../../services/firebase_service.dart';
import '../../widgets/news_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/full_screen_news_card.dart';

class SavedNewsPage extends StatefulWidget {
	const SavedNewsPage({super.key});

	@override
	State<SavedNewsPage> createState() => _SavedNewsPageState();
}

class _SavedNewsPageState extends State<SavedNewsPage> {
	final FirebaseService _firebaseService = FirebaseService();
	late Stream<List<NewsModel>> _savedNewsStream;

	@override
	void initState() {
		super.initState();
		_initializeSavedNewsStream();
	}

	void _initializeSavedNewsStream() {
		final userEmail = FirebaseAuth.instance.currentUser?.email;
		if (userEmail != null) {
			print('Initializing saved news stream for user: $userEmail');
			_savedNewsStream = _firebaseService.getSavedArticlesStream();
		} else {
			print('No user logged in during stream initialization');
		}

	}

	@override
	Widget build(BuildContext context) {
		final userEmail = FirebaseAuth.instance.currentUser?.email;
		
		if (userEmail == null) {
			return Center(
				child: Text(
					'Please log in to view saved articles',
					style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
				),
			);
		}

		return Scaffold(
			backgroundColor: AppColors.background,
			appBar: AppBar(
				backgroundColor: Colors.transparent,
				elevation: 0,
				title: Text(
					'Saved Articles',
					style: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
				),
			),
			body: StreamBuilder<List<NewsModel>>(
				stream: _savedNewsStream,
				builder: (context, snapshot) {
					if (snapshot.connectionState == ConnectionState.waiting) {
						return const Center(child: CircularProgressIndicator());
					}

					if (snapshot.hasError) {
						return Center(
							child: Text(
								'Error loading saved articles',
								style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
							),
						);
					}

					if (!snapshot.hasData || snapshot.data!.isEmpty) {
						return Center(
							child: Column(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									Icon(
										Icons.bookmark_border_rounded,
										size: 48,
										color: AppColors.textSecondary,
									),
									const SizedBox(height: 16),
									Text(
										'No saved articles yet',
										style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
									),
									const SizedBox(height: 8),
									Padding(
										padding: const EdgeInsets.symmetric(horizontal: 32),
										child: Text(
											'Tap the bookmark icon on any article to save it for later',
											style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
											textAlign: TextAlign.center,
										),
									),
								],
							),
						);
					}

					return ListView.builder(
						padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
						itemCount: snapshot.data!.length,
						itemBuilder: (context, index) {
							final article = snapshot.data![index];
							return NewsCard(
								news: article,
								onTap: () {
									Navigator.push(
										context,
										MaterialPageRoute(
											builder: (context) => FullScreenNewsCard(
												news: article,
											),
										),
									);
								},
							);

						},
					);
				},
			),
		);
	}
}