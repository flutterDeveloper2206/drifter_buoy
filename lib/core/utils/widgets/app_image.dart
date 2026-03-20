import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AppImageType {
  network,
  cachedNetwork,
  asset,
  file,
  svgAsset,
  svgNetwork,
  svgFile,
}

class AppImage extends StatelessWidget {
  final AppImageType _type;
  final String? _path;
  final File? _file;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? color;

  const AppImage.network(
    String url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.color,
  }) : _type = AppImageType.network,
       _path = url,
       _file = null;

  const AppImage.cachedNetwork(
    String url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.color,
  }) : _type = AppImageType.cachedNetwork,
       _path = url,
       _file = null;

  const AppImage.asset(
    String assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.color,
  }) : _type = AppImageType.asset,
       _path = assetPath,
       _file = null;

  const AppImage.file(
    File file, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.color,
  }) : _type = AppImageType.file,
       _path = null,
       _file = file;

  const AppImage.svgAsset(
    String assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.color,
  }) : _type = AppImageType.svgAsset,
       _path = assetPath,
       _file = null;

  const AppImage.svgNetwork(
    String url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.color,
  }) : _type = AppImageType.svgNetwork,
       _path = url,
       _file = null;

  const AppImage.svgFile(
    File file, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.color,
  }) : _type = AppImageType.svgFile,
       _path = null,
       _file = file;

  @override
  Widget build(BuildContext context) {
    Widget image;

    switch (_type) {
      case AppImageType.network:
        image = Image.network(
          _path!,
          width: width,
          height: height,
          fit: fit,
          color: color,
          errorBuilder: (_, __, ___) => _errorWidget(),
          loadingBuilder: (_, child, progress) {
            if (progress == null) {
              return child;
            }
            return _placeholderWidget();
          },
        );
      case AppImageType.cachedNetwork:
        image = CachedNetworkImage(
          imageUrl: _path!,
          width: width,
          height: height,
          fit: fit,
          color: color,
          placeholder: (_, __) => _placeholderWidget(),
          errorWidget: (_, __, ___) => _errorWidget(),
        );
      case AppImageType.asset:
        image = Image.asset(
          _path!,
          width: width,
          height: height,
          fit: fit,
          color: color,
          errorBuilder: (_, __, ___) => _errorWidget(),
        );
      case AppImageType.file:
        image = Image.file(
          _file!,
          width: width,
          height: height,
          fit: fit,
          color: color,
          errorBuilder: (_, __, ___) => _errorWidget(),
        );
      case AppImageType.svgAsset:
        image = SvgPicture.asset(
          _path!,
          width: width,
          height: height,
          fit: fit,
          colorFilter: _colorFilter,
          placeholderBuilder: (_) => _placeholderWidget(),
        );
      case AppImageType.svgNetwork:
        image = SvgPicture.network(
          _path!,
          width: width,
          height: height,
          fit: fit,
          colorFilter: _colorFilter,
          placeholderBuilder: (_) => _placeholderWidget(),
        );
      case AppImageType.svgFile:
        image = SvgPicture.file(
          _file!,
          width: width,
          height: height,
          fit: fit,
          colorFilter: _colorFilter,
          placeholderBuilder: (_) => _placeholderWidget(),
        );
    }

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }

  ColorFilter? get _colorFilter {
    if (color == null) {
      return null;
    }

    return ColorFilter.mode(color!, BlendMode.srcIn);
  }

  Widget _placeholderWidget() {
    if (placeholder != null) {
      return placeholder!;
    }

    return SizedBox(
      width: width,
      height: height,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _errorWidget() {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Center(child: Icon(Icons.broken_image_outlined)),
    );
  }
}
