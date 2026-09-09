import 'dart:io';
import 'dart:typed_data';

const List<int> _pngSignature = <int>[137, 80, 78, 71, 13, 10, 26, 10];
const int _truecolourWithoutAlpha = 2;
const int _bitDepth = 8;
const int _paethFilter = 4;
const int _bytesPerPixel = 3;
const int _opaqueAlpha = 255;
const int _deflateLevel = 6;

final class RasterizedFrame {
  final int widthInPixels;
  final int heightInPixels;
  final Uint8List rgbaBytes;

  const RasterizedFrame({
    required this.widthInPixels,
    required this.heightInPixels,
    required this.rgbaBytes,
  });
}

final class TransparentPixelFound implements Exception {
  final int x;
  final int y;
  final int alpha;

  const TransparentPixelFound({
    required this.x,
    required this.y,
    required this.alpha,
  });

  @override
  String toString() =>
      'Pixel ($x, $y) has alpha $alpha; store artwork must be fully opaque';
}

Uint8List encodeOpaquePng(RasterizedFrame frame) {
  final body = BytesBuilder();
  body.add(_pngSignature);
  body.add(_chunk('IHDR', _headerBytes(frame)));
  body.add(_chunk('IDAT', _deflate(_filteredScanlines(frame))));
  body.add(_chunk('IEND', Uint8List(0)));
  return body.toBytes();
}

Uint8List _headerBytes(RasterizedFrame frame) {
  final header = ByteData(13);
  header.setUint32(0, frame.widthInPixels);
  header.setUint32(4, frame.heightInPixels);
  header.setUint8(8, _bitDepth);
  header.setUint8(9, _truecolourWithoutAlpha);
  header.setUint8(10, 0);
  header.setUint8(11, 0);
  header.setUint8(12, 0);
  return header.buffer.asUint8List();
}

Uint8List _deflate(Uint8List raw) =>
    Uint8List.fromList(ZLibCodec(level: _deflateLevel).encode(raw));

Uint8List _filteredScanlines(RasterizedFrame frame) {
  final width = frame.widthInPixels;
  final height = frame.heightInPixels;
  final rowLength = width * _bytesPerPixel;
  final output = Uint8List(height * (rowLength + 1));
  final current = Uint8List(rowLength);
  var previous = Uint8List(rowLength);

  for (var y = 0; y < height; y++) {
    _readOpaqueRow(frame, y, current);
    final rowStart = y * (rowLength + 1);
    output[rowStart] = _paethFilter;
    _writePaethRow(current, previous, output, rowStart + 1);
    previous = Uint8List.fromList(current);
  }
  return output;
}

void _readOpaqueRow(RasterizedFrame frame, int y, Uint8List row) {
  final width = frame.widthInPixels;
  for (var x = 0; x < width; x++) {
    final source = (y * width + x) * 4;
    final alpha = frame.rgbaBytes[source + 3];
    if (alpha != _opaqueAlpha) {
      throw TransparentPixelFound(x: x, y: y, alpha: alpha);
    }
    final target = x * _bytesPerPixel;
    row[target] = frame.rgbaBytes[source];
    row[target + 1] = frame.rgbaBytes[source + 1];
    row[target + 2] = frame.rgbaBytes[source + 2];
  }
}

void _writePaethRow(
  Uint8List row,
  Uint8List previousRow,
  Uint8List output,
  int outputStart,
) {
  for (var i = 0; i < row.length; i++) {
    final left = i >= _bytesPerPixel ? row[i - _bytesPerPixel] : 0;
    final above = previousRow[i];
    final aboveLeft = i >= _bytesPerPixel ? previousRow[i - _bytesPerPixel] : 0;
    final predicted = _paethPredictor(left, above, aboveLeft);
    output[outputStart + i] = (row[i] - predicted) & 0xFF;
  }
}

int _paethPredictor(int left, int above, int aboveLeft) {
  final estimate = left + above - aboveLeft;
  final toLeft = (estimate - left).abs();
  final toAbove = (estimate - above).abs();
  final toAboveLeft = (estimate - aboveLeft).abs();
  if (toLeft <= toAbove && toLeft <= toAboveLeft) return left;
  if (toAbove <= toAboveLeft) return above;
  return aboveLeft;
}

Uint8List _chunk(String type, Uint8List payload) {
  final typeBytes = Uint8List.fromList(type.codeUnits);
  final chunk = BytesBuilder();
  final length = ByteData(4)..setUint32(0, payload.length);
  chunk.add(length.buffer.asUint8List());
  chunk.add(typeBytes);
  chunk.add(payload);
  final checksum = ByteData(4)
    ..setUint32(0, _crc32(<Uint8List>[typeBytes, payload]));
  chunk.add(checksum.buffer.asUint8List());
  return chunk.toBytes();
}

final Uint32List _crcTable = _buildCrcTable();

Uint32List _buildCrcTable() {
  final table = Uint32List(256);
  for (var index = 0; index < 256; index++) {
    var value = index;
    for (var bit = 0; bit < 8; bit++) {
      value = (value & 1) == 1 ? 0xEDB88320 ^ (value >> 1) : value >> 1;
    }
    table[index] = value;
  }
  return table;
}

int _crc32(List<Uint8List> parts) {
  var crc = 0xFFFFFFFF;
  for (final part in parts) {
    for (final byte in part) {
      crc = _crcTable[(crc ^ byte) & 0xFF] ^ (crc >> 8);
    }
  }
  return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
}
