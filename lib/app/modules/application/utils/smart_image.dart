import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class SmartImage extends StatefulWidget {
  const SmartImage({
    required this.originalImageUrl,
    required this.convertToProxyUrl,
    required this.onOpenDirect,
    required this.isWhitelistedHost,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String originalImageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String Function(String) convertToProxyUrl;
  final void Function(String) onOpenDirect;
  final bool isWhitelistedHost;

  @override
  State<SmartImage> createState() => _SmartImageState();
}

class _SmartImageState extends State<SmartImage> {
  bool _useProxy = false;
  late final String _viewTypeId;

  @override
  void initState() {
    super.initState();
    _useProxy = false;
    _viewTypeId =
        'smart-image-${DateTime.now().microsecondsSinceEpoch}-${widget.originalImageUrl.hashCode}';
    if (kIsWeb) {
      _registerWebImageViewFactory(
        _viewTypeId,
        widget.originalImageUrl,
        widget.fit,
      );
    }
  }

  @override
  void didUpdateWidget(covariant SmartImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kIsWeb && oldWidget.originalImageUrl != widget.originalImageUrl) {
      final newId =
          'smart-image-${DateTime.now().microsecondsSinceEpoch}-${widget.originalImageUrl.hashCode}';
      setState(() {
        _useProxy = false;
      });
      _registerWebImageViewFactory(newId, widget.originalImageUrl, widget.fit);
    }
  }

  void _registerWebImageViewFactory(String viewType, String url, BoxFit fit) {
    final cssObjectFit = _mapBoxFitToCss(fit);
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final img =
          html.ImageElement()
            ..src = url
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.objectFit = cssObjectFit
            ..style.borderRadius = '8px';
      img.onError.listen((_) {
        if (!mounted) return;
        setState(() {
          _useProxy = true;
        });
      });
      return img;
    });
  }

  String _mapBoxFitToCss(BoxFit fit) {
    switch (fit) {
      case BoxFit.contain:
        return 'contain';
      case BoxFit.fill:
        return 'fill';
      case BoxFit.fitHeight:
        return 'cover';
      case BoxFit.fitWidth:
        return 'cover';
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scale-down';
      case BoxFit.cover:
        return 'cover';
    }
  }

  @override
  Widget build(BuildContext context) {
    final proxyUrl = widget.convertToProxyUrl(widget.originalImageUrl);

    // 決策：Web 先直連（DOM <img>），若白名單或預設皆先嘗試；出錯再退回 proxy
    if (kIsWeb && !_useProxy) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: HtmlElementView(viewType: _viewTypeId),
      );
    }

    // 非 Web 或已決定使用 Proxy：改用 Image.network
    final String urlToLoad =
        (_useProxy || !kIsWeb)
            ? (_useProxy ? proxyUrl : widget.originalImageUrl)
            : proxyUrl;

    return Image.network(
      urlToLoad,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade50,
          width: widget.width,
          height: widget.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(height: 12),
                Text(
                  '載入圖片中...',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (!_useProxy) {
          // 直連失敗 → 改用 proxy 再試
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _useProxy = true;
            });
          });
          return SizedBox(width: widget.width, height: widget.height);
        }

        // 連 proxy 也失敗 → 顯示錯誤卡片
        return Container(
          color: Colors.red.shade50,
          width: widget.width,
          height: widget.height,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '圖片載入失敗',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '來源站可能不允許存取，或 Proxy 無法連線',
                    style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _useProxy = false; // 退回直連重試
                          });
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('重試'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed:
                            () => widget.onOpenDirect(widget.originalImageUrl),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('直接開啟'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
