import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_life_app/features/life/pages/map_detail_page.dart';

void main() {
  testWidgets('校园地图页面可以正常打开', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MapDetailPage()),
    );

    expect(find.text('校园地图'), findsOneWidget);
    expect(find.text('河南工学院图书馆'), findsOneWidget);
  });
}
