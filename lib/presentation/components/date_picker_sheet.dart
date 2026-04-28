import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../theme/theme.dart';

class DatePickerSheet {
  /// 显示底部滚动日期选择器（仅日期，无时间）
  /// 返回用户选择的日期，点取消返回 null
  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? minDate,
    DateTime? maxDate,
    String title = '选择日期',
  }) => _show(
    context,
    mode: CupertinoDatePickerMode.date,
    initialDate: initialDate,
    minDate: minDate,
    maxDate: maxDate,
    title: title,
  );

  /// 显示底部滚动日期+时间选择器（精确到分钟）
  /// 返回用户选择的 DateTime，点取消返回 null
  static Future<DateTime?> showDateTime(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? minDate,
    DateTime? maxDate,
    String title = '选择时间',
  }) => _show(
    context,
    mode: CupertinoDatePickerMode.dateAndTime,
    minuteInterval: 5,
    initialDate: initialDate,
    minDate: minDate,
    maxDate: maxDate,
    title: title,
  );

  // ── 内部实现 ───────────────────────────────────────────────────────────

  static Future<DateTime?> _show(
    BuildContext context, {
    required CupertinoDatePickerMode mode,
    int minuteInterval = 1,
    DateTime? initialDate,
    DateTime? minDate,
    DateTime? maxDate,
    required String title,
  }) async {
    final fallbackDate = DateTime.now();
    final normalizedInitialDate = normalizeInitialDateTime(
      initialDate: initialDate,
      minDate: minDate,
      maxDate: maxDate,
      fallbackDate: fallbackDate,
      minuteInterval: minuteInterval,
    );
    DateTime tempDate = normalizedInitialDate;
    DateTime? result;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Localizations.override(
        context: sheetContext,
        locale: const Locale('zh'),
        delegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖拽条
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 标题行
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        '取消',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(title, style: AppTextStyles.titleMedium),
                    TextButton(
                      onPressed: () {
                        result = tempDate;
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        '确认',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Cupertino 滚轮
              SizedBox(
                height: mode == CupertinoDatePickerMode.dateAndTime ? 220 : 200,
                child: CupertinoDatePicker(
                  mode: mode,
                  minuteInterval: minuteInterval,
                  initialDateTime: normalizedInitialDate,
                  minimumDate: minDate,
                  maximumDate:
                      maxDate ??
                      DateTime.now().add(const Duration(days: 365 * 4)),
                  onDateTimeChanged: (date) => tempDate = date,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );

    return result;
  }

  /// 计算可安全用于 CupertinoDatePicker 的初始时间，避免超出范围或分钟未对齐导致报错。
  @visibleForTesting
  static DateTime normalizeInitialDateTime({
    DateTime? initialDate,
    DateTime? minDate,
    DateTime? maxDate,
    required DateTime fallbackDate,
    int minuteInterval = 1,
  }) {
    var normalizedDate = _alignToInterval(
      initialDate ?? fallbackDate,
      minuteInterval,
    );

    if (minDate != null && normalizedDate.isBefore(minDate)) {
      normalizedDate = _alignToInterval(minDate, minuteInterval, roundUp: true);
    }

    if (maxDate != null && normalizedDate.isAfter(maxDate)) {
      normalizedDate = _alignToInterval(maxDate, minuteInterval);
    }

    if (minDate != null && normalizedDate.isBefore(minDate)) {
      normalizedDate = _alignToInterval(minDate, minuteInterval, roundUp: true);
    }

    return normalizedDate;
  }

  /// 把分钟对齐到 interval 的整数倍，避免 CupertinoDatePicker 报错。
  static DateTime _alignToInterval(
    DateTime dt,
    int interval, {
    bool roundUp = false,
  }) {
    final normalized = DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute);
    if (interval <= 1) return normalized;

    final remainder = normalized.minute % interval;
    if (remainder == 0) return normalized;

    if (!roundUp) {
      return normalized.subtract(Duration(minutes: remainder));
    }

    return normalized.add(Duration(minutes: interval - remainder));
  }
}
