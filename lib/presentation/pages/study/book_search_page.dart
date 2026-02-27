import 'package:flutter/material.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';

class BookSearchPage extends StatefulWidget {
  const BookSearchPage({super.key});

  @override
  State<BookSearchPage> createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<String> _history = ['三体', 'Flutter核心技术', '明朝那些事儿', '数据挖掘导论'];
  List<String> _hot = ['平凡的世界', '机器学习', '算法导论', '活着', '小王子'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CampusSearchAppBar(
        title: '图书检索',
        searchController: _searchController,
        onSearch: (val) {
          setState(() {
            _isSearching = val.isNotEmpty;
          });
        },
      ),
      body: _isSearching ? _buildSearchResults() : _buildSearchHistory(),
    );
  }

  Widget _buildSearchHistory() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('搜索历史', style: AppTextStyles.titleSmall),
              IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline, size: 20)),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _history.map((e) => _buildChip(e)).toList(),
          ),
          const SizedBox(height: 24),
          Text('热门搜索', style: AppTextStyles.titleSmall),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _hot.map((e) => _buildChip(e, isHot: true)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {bool isHot = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isHot ? AppColors.primary.withOpacity(0.3) : AppColors.greyLight),
      ),
      child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: isHot ? AppColors.primary : AppColors.textPrimary)),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildBookResultCard(index);
      },
    );
  }

  Widget _buildBookResultCard(int index) {
    return CampusCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(4),
              image: const DecorationImage(
                image: NetworkImage('https://via.placeholder.com/80x110'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('高等数学 (同济第七版)', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('作者: 同济大学数学系', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Text('ISBN: 9787040396637', style: AppTextStyles.caption),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('状态: 可借 (5/10)', style: AppTextStyles.caption.copyWith(color: AppColors.success)),
                    Text('三楼 B区 302', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
