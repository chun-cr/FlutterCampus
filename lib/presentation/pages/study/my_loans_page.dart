import 'package:flutter/material.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';

class MyLoansPage extends StatelessWidget {
  const MyLoansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CampusAppBar(title: '我的借阅', showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildLoanCard(
            title: '深入浅出Flutter',
            author: '王杰',
            dueDate: '2025-06-25',
            daysLeft: 1,
            isOverdue: false,
          ),
          _buildLoanCard(
            title: '算法导论',
            author: 'Thomas H. Cormen',
            dueDate: '2025-06-15',
            daysLeft: -10,
            isOverdue: true,
          ),
          _buildLoanCard(
            title: '明朝那些事儿',
            author: '当年明月',
            dueDate: '2025-07-10',
            daysLeft: 16,
            isOverdue: false,
          ),
        ],
      ),
    );
  }

  Widget _buildLoanCard({
    required String title,
    required String author,
    required String dueDate,
    required int daysLeft,
    required bool isOverdue,
  }) {
    return CampusCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.book, color: AppColors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('作者: $author', style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.event,
                          size: 14,
                          color: isOverdue ? AppColors.error : AppColors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '应还日期: $dueDate',
                          style: AppTextStyles.caption.copyWith(
                            color: isOverdue
                                ? AppColors.error
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isOverdue)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '已逾期',
                    style: AppTextStyles.overline.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOverdue ? '逾期欠费: ¥2.00' : '剩余天数: $daysLeft天',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isOverdue
                      ? AppColors.error
                      : (daysLeft < 3 ? Colors.orange : AppColors.primary),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  TextButton(onPressed: () {}, child: const Text('详情')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isOverdue ? null : () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text('续借'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
