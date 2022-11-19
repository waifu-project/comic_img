import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'comic_const.dart';
import 'comic_secret.dart';

String generateImageLink(int id, String pid, String ext) {
  return '${kNetworkImageUrlTemplate.replaceFirst('id', id.toString()).replaceFirst('pid', pid)}.$ext';
}

enum CommicImageUrlType {
  network,
  assets,
}

class CommicImage extends StatefulWidget {
  const CommicImage({
    Key? key,
    this.width,
    this.height,
    this.placeholder,
    this.image,
    required this.detailID,
    required this.picID,
    this.imageType = CommicImageUrlType.assets,
    this.fit = BoxFit.cover,
    this.imageExtension = 'webp',
  }) : super(key: key);

  final String? image;
  final int detailID;
  final String picID;
  final CommicImageUrlType imageType;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final String imageExtension;

  @override
  State<CommicImage> createState() => _CommicImageState();
}

class _CommicImageState extends State<CommicImage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then(
      (_) {
        if (mounted) beforeHook();
      },
    );
  }

  @override
  void didUpdateWidget(covariant CommicImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    beforeHook();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String get imageUrl {
    if (widget.imageType == CommicImageUrlType.network) {
      return generateImageLink(
        widget.detailID,
        widget.picID,
        widget.imageExtension,
      );
    }
    assert(widget.image != null);
    return widget.image as String;
  }

  Widget get placeholderWidget {
    if (widget.placeholder != null) return widget.placeholder as Widget;
    return const CircularProgressIndicator();
  }

  ui.Image? data;
  ImageProvider? imageProvider;

  int w = 0;
  int h = 0;

  bool get needRegenerated {
    return !(kScrambleId > widget.detailID || widget.imageExtension == 'gif');
  }

  renderAssets() async {
    if (mounted) {
      switch (widget.imageType) {
        case CommicImageUrlType.network:
          imageProvider = NetworkImage(
            imageUrl,
            headers: {
              "user-agent":
                  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36",
              "referer": "https://18comic.org",
            },
          );
          setState(() {});
          break;
        default:
          imageProvider = AssetImage(imageUrl);
          setState(() {});
      }
    }
    if (needRegenerated) {
      var responeData =
          await loadImageByProvider(imageProvider as ImageProvider);
      if (mounted) {
        w = responeData.width;
        h = responeData.height;
        data = responeData;
        setState(() {});
      }
    }
  }

  beforeHook() async {
    await renderAssets();
  }

  @override
  Widget build(BuildContext context) {
    if (!needRegenerated) {
      if (imageProvider == null) return placeholderWidget;
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Image(
          loadingBuilder: (_, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return placeholderWidget;
          },
          image: imageProvider as ImageProvider,
        ),
      );
    }
    Widget build = FittedBox(
      fit: widget.fit,
      clipBehavior: ui.Clip.antiAlias,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Builder(builder: (context) {
          if (data == null) return placeholderWidget;
          return CustomPaint(
            painter: CommicImgPainter(
              data: data!,
              detailID: widget.detailID,
              picID: widget.picID,
            ),
            size: Size(
              w.toDouble(),
              h.toDouble(),
            ),
          );
        }),
      ),
    );
    return build;
  }
}

class CommicImgPainter extends CustomPainter {
  CommicImgPainter({
    required this.data,
    required this.detailID,
    required this.picID,
  });

  int detailID;
  String picID;

  ui.Image data;

  @override
  void paint(Canvas canvas, Size size) {
    final h = data.height.toDouble();
    final w = data.width.toDouble();
    final int chunk = getNum(detailID, picID);
    for (var i = 0; i < chunk; i++) {
      final ui.Paint paint = ui.Paint();
      final double l = (h % chunk).floor().toDouble();
      double fillHeight = (h / chunk).floor().toDouble();
      double fillPositionTop = fillHeight * i;
      double fillOffsetHeight = h - (fillHeight * (i + 1)) - l;
      if (i == 0) {
        fillHeight += l;
      } else {
        fillPositionTop += l;
      }
      final Rect src = Rect.fromLTWH(0, fillOffsetHeight, w, fillHeight);
      final Rect dst = Rect.fromLTWH(0, fillPositionTop, w, fillHeight);
      canvas.drawImageRect(data, src, dst, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CommicImgPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

Future<ui.Image> loadImageByProvider(
  ImageProvider provider, {
  ImageConfiguration config = ImageConfiguration.empty,
}) async {
  Completer<ui.Image> completer = Completer<ui.Image>();
  late ImageStreamListener listener;
  ImageStream stream = provider.resolve(config);
  listener = ImageStreamListener((ImageInfo frame, bool sync) {
    final ui.Image image = frame.image;
    completer.complete(image);
    stream.removeListener(listener);
  });
  stream.addListener(listener);
  return completer.future;
}
