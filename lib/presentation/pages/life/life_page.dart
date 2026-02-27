import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';

class LifePage extends ConsumerWidget {
  const LifePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 校园头条 (Premium Feed)
              _buildSectionHeader('Campus Insights'),
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  clipBehavior: Clip.none,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 320,
                      margin: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.greyLight.withOpacity(0.6), width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.greyLight.withOpacity(0.3),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                image: DecorationImage(
                                  image: NetworkImage('https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&q=80&w=800&h=400'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'EDITION ${index + 1}',
                                  style: AppTextStyles.overline.copyWith(letterSpacing: 2, color: AppColors.primary),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  index == 0 ? 'Spring 2026 Opening Ceremonies' : 'Annual Campus Music Festival',
                                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w500, height: 1.3),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 48),

              // 2. 食堂与后勤 (Daily Menu - Minimalist)
              _buildSectionHeader('Culinary Selections'),
              _buildPremiumCard(
                child: Column(
                  children: [
                    _buildCanteenItem('Dining Hall I', 'Braised Pork, Mapo Tofu', 4.8),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, thickness: 0.5, color: AppColors.greyLight),
                    ),
                    _buildCanteenItem('Dining Hall II', 'Sweet & Sour Ribs, Seasonal Greens', 4.5),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: AppColors.primary.withOpacity(0.3), width: 0.5),
                          ),
                        ),
                        child: Text(
                          'View Full Menu',
                          style: AppTextStyles.button.copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // 3. 校车与地图 (Campus Transit - Sleek)
              _buildSectionHeader('Transit & Maps'),
              _buildPremiumCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&q=80&w=800&h=400'),
                          fit: BoxFit.cover,
                          opacity: 0.6,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textPrimary),
                              const SizedBox(width: 6),
                              Text('View Map', style: AppTextStyles.labelMedium),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.directions_bus_outlined, color: AppColors.primary, size: 24),
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Campus Shuttle A', style: AppTextStyles.titleMedium),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.success,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text('Arriving in 5 mins', style: AppTextStyles.caption),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.greyLight.withOpacity(0.6), width: 0.5),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelLarge.copyWith(
          letterSpacing: 1.5,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCanteenItem(String name, String menu, double rating) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.titleMedium),
              const SizedBox(height: 4),
              Text(menu, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, size: 14, color: AppColors.textPrimary),
              const SizedBox(width: 4),
              Text(rating.toString(), style: AppTextStyles.labelMedium),
            ],
          ),
        ),
      ],
    );
  }
}
