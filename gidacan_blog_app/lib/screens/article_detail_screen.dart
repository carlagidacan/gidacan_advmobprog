import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/article_model.dart';
import '../widgets/custom_text.dart';
import '../widgets/article_dialog.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late Article _currentArticle;

  @override
  void initState() {
    super.initState();
    _currentArticle = widget.article;
  }

  Future<void> _openEditDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AddEditArticleDialog(
        article: _currentArticle,
        onSaved: (updatedArticle) {
          setState(() {
            _currentArticle = updatedArticle;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: "Article Detail",
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Article',
            onPressed: _openEditDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder image box
            Container(
              width: double.infinity,
              height: 200.h,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(
                  Icons.image,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  CustomText(
                    text: _currentArticle.title,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 8.h),

               
                  CustomText(
                    text: "By ${_currentArticle.name}",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                  SizedBox(height: 12.h),

              
                  ..._currentArticle.content.map(
                    (paragraph) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: CustomText(
                        text: paragraph,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),

              
                  SizedBox(height: 20.h),
                  CustomText(
                    text: _currentArticle.isActive ? "Status: Active" : "Status: Inactive",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _currentArticle.isActive ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
