import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../../../presentation/theme/theme.dart';

/// 校园地图详情页 — Web 端展示可完整交互的高德地图，标注河南工学院图书馆位置
class MapDetailView extends StatefulWidget {
  const MapDetailView({super.key});

  @override
  State<MapDetailView> createState() => _MapDetailViewState();
}

class _MapDetailViewState extends State<MapDetailView> {
  static const String _viewType = 'amap-detail-view';
  static bool _registered = false;

  @override
  void initState() {
    super.initState();
    _registerFactory();
  }

  void _registerFactory() {
    if (_registered) return;
    _registered = true;

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final container = html.DivElement()
        ..id = 'amap-detail-$viewId'
        ..style.width = '100%'
        ..style.height = '100%';

      Future.delayed(const Duration(milliseconds: 300), () {
        js.context.callMethod('eval', [
          '''
          (function _waitForAMap() {
            var div = document.getElementById("amap-detail-$viewId");
            if (!div) return;
            if (typeof AMap === "undefined") {
              div.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;height:100%;color:#71717A;font-size:14px;">地图加载中…</div>';
              setTimeout(_waitForAMap, 200);
              return;
            }
            div.innerHTML = "";
            var map = new AMap.Map("amap-detail-$viewId", {
              zoom: 17,
              center: [113.954625, 35.299916],
              dragEnable: true,
              zoomEnable: true,
              scrollWheel: true,
              doubleClickZoom: true,
              touchZoom: true,
              rotateEnable: false,
              viewMode: "2D"
            });
            var marker = new AMap.Marker({
              position: new AMap.LngLat(113.954625, 35.299916),
              title: "河南工学院图书馆",
              content: '<div style="background:#EF4444;width:24px;height:24px;border-radius:50%;border:3px solid white;box-shadow:0 2px 6px rgba(0,0,0,0.3);"></div>',
              offset: new AMap.Pixel(-12, -12)
            });
            marker.setMap(map);
          })();
          ''',
        ]);
      });

      return container;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '校园地图',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: const SizedBox.expand(child: HtmlElementView(viewType: _viewType)),
    );
  }
}
