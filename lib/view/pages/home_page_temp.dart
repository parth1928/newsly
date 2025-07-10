import 'package:flutter/material.dart';
import '../../constants/style_constants.dart';
import '../../services/firebase_service.dart';
import '../../models/news_model.dart';
import '../../widgets/home_news_card.dart';

class HomePage extends StatefulWidget {
	const HomePage({super.key});

	@override
	State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
	final FirebaseService _firebaseService = FirebaseService();
	late Future<List<NewsModel>> _newsFuture;

	@override
	void initState() {
		super.initState();
		_newsFuture = _firebaseService.fetchNewsArticles();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: AppColors.background,
			body: SafeArea(
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Padding(
							padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
							child: Text(
								'Latest News',
								style: AppTypography.heading1,
							),
						),
						Expanded(
							child: FutureBuilder<List<NewsModel>>(
								future: _newsFuture,
								builder: (context, snapshot) {
									if (snapshot.connectionState == ConnectionState.waiting) {
										return Center(
											child: CircularProgressIndicator(
												color: AppColors.accent,
											),
										);
									}

									if (snapshot.hasError) {
										return Center(
											child: Text(
												'Error loading news',
												style: AppTypography.body1.copyWith(
													color: AppColors.textSecondary,
												),
											),
										);
									}

									if (!snapshot.hasData || snapshot.data!.isEmpty) {
										return Center(
											child: Text(
												'No news available',
												style: AppTypography.body1.copyWith(
													color: AppColors.textSecondary,
												),
											),
										);
									}

									return RefreshIndicator(
										onRefresh: () async {
											setState(() {
												_newsFuture = _firebaseService.fetchNewsArticles();
											});
										},
										color: AppColors.accent,
										child: ListView.builder(
											padding: const EdgeInsets.symmetric(horizontal: 24),
											itemCount: snapshot.data!.length,
											itemBuilder: (context, index) {
												final news = snapshot.data![index];
												return HomeNewsCard(
													news: news,
													onTap: () {
														// Handle news item tap
													},
												);
											},
										),
									);
								},
							),
						),
					],
				),
			),
		);
	}
}