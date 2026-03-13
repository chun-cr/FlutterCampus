import 'package:flutter/material.dart';

import 'map_detail_page_stub.dart'
    if (dart.library.html) 'map_detail_page_web.dart' as map_detail;

class MapDetailPage extends StatelessWidget {
  const MapDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const map_detail.MapDetailView();
  }
}
