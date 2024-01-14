import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class Base64UrlImage extends ImageProvider<Base64UrlImage> {
  /// Creates an object that decodes a Base64 data URL string as an image.
  const Base64UrlImage(this.dataUrl, {this.scale = 1.0});

  /// The Base64 data URL string to decode into an image.
  final String dataUrl;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  @override
  Future<Base64UrlImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<Base64UrlImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(Base64UrlImage key, ImageDecoderCallback decode) {
    assert(key == this);
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: key.scale,
      debugLabel: 'Base64UrlImage(${describeIdentity(key.dataUrl)})',
    );
  }

  Future<ui.Codec> _loadAsync(Base64UrlImage key) async {
    assert(key == this);

    // Extract the Base64 part of the data URL.
    final Uri dataUri = Uri.parse(key.dataUrl);
    if (!dataUri.isScheme('data') || dataUri.data == null) {
      throw ArgumentError('Invalid data URL for image');
    }

    // Convert the Base64 string to a Uint8List.
    final Uint8List bytes = dataUri.data!.contentAsBytes();

    // Decode the image.
    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return await ui.instantiateImageCodecFromBuffer(buffer);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Base64UrlImage
        && other.dataUrl == dataUrl
        && other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(dataUrl.hashCode, scale);

  @override
  String toString() => '${objectRuntimeType(this, 'Base64UrlImage')}(${describeIdentity(dataUrl)}, scale: ${scale.toStringAsFixed(1)})';
}
