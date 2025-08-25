import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/article_model.dart';
import '../services/article_service.dart';
import '../widgets/custom_text.dart';
import '../widgets/article_dialog.dart';
import 'article_detail_screen.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late Future<List<Article>> _futureArticles;
  List<Article> _allArticles = [];
  List<Article> _filteredArticles = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _futureArticles = _getAllArticles();
  }

  Future<List<Article>> _getAllArticles() async {
    final response = await ArticleService().getAllArticle();
    final articles =
        response.map<Article>((e) => Article.fromJson(e)).toList();
    setState(() {
      _allArticles = articles;
      _filteredArticles = articles;
    });
    return articles;
  }

  void _filterArticles() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredArticles = _allArticles;
      } else {
        _filteredArticles = _allArticles
            .where((article) =>
                article.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                article.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _openAddArticleDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AddEditArticleDialog(
        onSaved: (newArticle) {
          setState(() {
            _allArticles.insert(0, newArticle);
            _filterArticles();
          });
        },
      ),
    );
  }

  Widget _statusChip(bool active) {
    return Chip(
      label: Text(active ? 'Active' : 'Inactive'),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: active ? Colors.green : Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar here, handled by HomeScreen
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddArticleDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search articles...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _filterArticles();
                  });
                },
              ),
            ),
            SizedBox(height: 16.h),
            FutureBuilder<List<Article>>(
              future: _futureArticles,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return SizedBox(
                    height: ScreenUtil().screenHeight * 0.6,
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CustomText(
                          text: 'Error loading articles...',
                        ),
                      ),
                    ),
                  );
                }

                if (_filteredArticles.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: const Center(
                      child: CustomText(
                        text: 'No articles to display...',
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  shrinkWrap: true,
                  itemCount: _filteredArticles.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final article = _filteredArticles[index];
                    final preview = article.content.isNotEmpty
                        ? article.content.first
                        : '';
                    return Card(
                      elevation: 1,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ArticleDetailScreen(article: article),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(15),
                            vertical: ScreenUtil().setHeight(15),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: CustomText(
                                      text: article.title.isEmpty
                                          ? 'Untitled'
                                          : article.title,
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                      maxLines: 2,
                                    ),
                                  ),
                                  _statusChip(article.isActive),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              CustomText(
                                text: article.name,
                                fontSize: 13.sp,
                              ),
                              if (preview.isNotEmpty) ...[
                                SizedBox(height: 6.h),
                                CustomText(
                                  text: preview,
                                  fontSize: 12.sp,
                                  maxLines: 2,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
