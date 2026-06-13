import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/theme/app_theme.dart';
import '../../data/moment_model.dart';
import '../../data/moments_repository.dart';

class MomentsScreen extends StatefulWidget {
  const MomentsScreen({super.key});

  @override
  State<MomentsScreen> createState() => _MomentsScreenState();
}

class _MomentsScreenState extends State<MomentsScreen> {
  final MomentsRepository _repo = MomentsRepository();
  List<MomentModel> _moments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final moments = await _repo.getMoments();
      setState(() { _moments = moments; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('朋友圈'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: () => _showPublishSheet(context),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('加载失败: $_error'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: _moments.length,
                    itemBuilder: (context, index) {
                      return _MomentCard(moment: _moments[index]);
                    },
                  ),
                ),
    );
  }

  void _showPublishSheet(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '发朋友圈',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: '分享你的想法...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image_outlined),
                  onPressed: () {},
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('发布成功！')),
                      );
                    }
                  },
                  child: const Text('发布'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MomentCard extends StatelessWidget {
  final MomentModel moment;

  const _MomentCard({required this.moment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像 + 昵称 + 时间
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: moment.avatarUrl != null
                      ? NetworkImage(moment.avatarUrl!)
                      : null,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: moment.avatarUrl == null
                      ? Text(moment.userName[0])
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moment.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        timeago.format(moment.createdAt, locale: 'zh_CN'),
                        style: const TextStyle(
                          color: AppTheme.textHint,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 内容
            Text(moment.content, style: const TextStyle(fontSize: 15, height: 1.5)),
            // 图片
            if (moment.imageUrl != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  moment.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            // 点赞 + 评论
            Row(
              children: [
                // 点赞
                InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Icon(
                        moment.likes.isNotEmpty
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 20,
                        color: moment.likes.isNotEmpty
                            ? AppTheme.accentColor
                            : AppTheme.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        moment.likeCount > 0 ? '${moment.likeCount}' : '赞',
                        style: TextStyle(
                          color: moment.likes.isNotEmpty
                              ? AppTheme.accentColor
                              : AppTheme.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // 评论
                InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline,
                          size: 20, color: AppTheme.textHint),
                      const SizedBox(width: 4),
                      Text(
                        moment.commentCount > 0
                            ? '${moment.commentCount}'
                            : '评论',
                        style: const TextStyle(color: AppTheme.textHint),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 评论列表
            if (moment.comments.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: moment.comments.map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                          ),
                          children: [
                            TextSpan(
                              text: '${c.userName}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            TextSpan(text: c.content),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
