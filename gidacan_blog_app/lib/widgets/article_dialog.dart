import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/article_service.dart';
import '../models/article_model.dart';
import '../utils/loading.dart';

class AddEditArticleDialog extends StatefulWidget {
	final Article? article;
	final void Function(Article newOrUpdatedArticle)? onSaved;
	const AddEditArticleDialog({Key? key, this.article, this.onSaved}) : super(key: key);

	@override
	State<AddEditArticleDialog> createState() => _AddEditArticleDialogState();
}

class _AddEditArticleDialogState extends State<AddEditArticleDialog> {
	late TextEditingController titleController;
	late TextEditingController authorController;
	late TextEditingController contentController;
	late bool isActive;
	bool isSaving = false;
	final formKey = GlobalKey<FormState>();

	@override
	void initState() {
		super.initState();
		titleController = TextEditingController(text: widget.article?.title ?? '');
		authorController = TextEditingController(text: widget.article?.name ?? '');
		contentController = TextEditingController(
			text: widget.article?.content.join('\n') ?? '',
		);
		isActive = widget.article?.isActive ?? true;
	}

	@override
	void dispose() {
		titleController.dispose();
		authorController.dispose();
		contentController.dispose();
		super.dispose();
	}

	List<String> _toList(String raw) {
		return raw
				.split(RegExp(r'[\n,]'))
				.map((s) => s.trim())
				.where((s) => s.isNotEmpty)
				.toList();
	}

	Future<void> save() async {
		if (isSaving) return;
		if (!formKey.currentState!.validate()) return;
		setState(() => isSaving = true);

		// Show loading overlay
		LoadingOverlay.show(
			context,
			message: widget.article == null ? 'Adding article...' : 'Updating article...'
		);

		try {
			final payload = {
				'title': titleController.text.trim(),
				'name': authorController.text.trim(),
				'content': _toList(contentController.text),
				'isActive': isActive,
			};
			Map res;
			Article newOrUpdated;
			if (widget.article == null) {
				res = await ArticleService().createArticle(payload);
				final created = (res['article'] ?? res);
				newOrUpdated = Article.fromJson(created);
			} else {
				final articleId = widget.article?.aid ?? '';
				res = await ArticleService().updateArticle(articleId, payload);
				final updated = (res['article'] ?? res);
				newOrUpdated = Article.fromJson(updated);
			}

			// Hide loading overlay
			if (mounted) LoadingOverlay.hide(context);

			if (widget.onSaved != null) widget.onSaved!(newOrUpdated);
			if (mounted) Navigator.of(context).pop();
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text(widget.article == null ? 'Article added.' : 'Article updated.')),
				);
			}
		} catch (e) {
			// Hide loading overlay in case of error
			if (mounted) LoadingOverlay.hide(context);
			
			setState(() => isSaving = false);
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text('Failed to save: $e')),
				);
			}
		}
	}

	@override
	Widget build(BuildContext context) {
		return AlertDialog(
			title: Text(widget.article == null ? 'Add Article' : 'Edit Article'),
			content: Form(
				key: formKey,
				child: SingleChildScrollView(
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							TextFormField(
								controller: titleController,
								textInputAction: TextInputAction.next,
								decoration: const InputDecoration(
									labelText: 'Title',
									border: OutlineInputBorder(),
								),
								validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
							),
							SizedBox(height: 12.h),
							TextFormField(
								controller: authorController,
								textInputAction: TextInputAction.next,
								decoration: const InputDecoration(
									labelText: 'Author / Name',
									border: OutlineInputBorder(),
								),
								validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
							),
							SizedBox(height: 12.h),
							TextFormField(
								controller: contentController,
								minLines: 3,
								maxLines: 6,
								decoration: const InputDecoration(
									labelText: 'Content (one item per line or comma-separated)',
									border: OutlineInputBorder(),
									alignLabelWithHint: true,
								),
								validator: (v) {
									final items = v == null
											? []
											: v.trim().split(RegExp(r'[\n,]')).where((s) => s.trim().isNotEmpty).toList();
									return items.isEmpty ? 'At least one content item' : null;
								},
							),
							SizedBox(height: 8.h),
							SwitchListTile.adaptive(
								contentPadding: EdgeInsets.zero,
								title: const Text('Active'),
								value: isActive,
								onChanged: (val) => setState(() => isActive = val),
							),
						],
					),
				),
			),
			actions: [
				TextButton(
					onPressed: isSaving ? null : () => Navigator.of(context).pop(),
					child: const Text('Cancel'),
				),
				ElevatedButton.icon(
					onPressed: isSaving ? null : save,
					icon: const Icon(Icons.save),
					label: Text(widget.article == null ? 'Save' : 'Update'),
				),
			],
		);
	}
}
