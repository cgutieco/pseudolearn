import 'dart:typed_data';

const int _signatureLength = 8;
const int _headerPayloadOffset = 16;

final class PngHeader {
  final int widthInPixels;
  final int heightInPixels;
  final int bitDepth;
  final int colourType;

  const PngHeader({
    required this.widthInPixels,
    required this.heightInPixels,
    required this.bitDepth,
    required this.colourType,
  });

  bool get carriesAlphaChannel => colourType == 4 || colourType == 6;
}

PngHeader readPngHeader(Uint8List bytes) {
  final view = ByteData.sublistView(bytes);
  final type = String.fromCharCodes(
    bytes.sublist(_signatureLength + 4, _signatureLength + 8),
  );
  if (type != 'IHDR') {
    throw FormatException('First chunk is "$type" instead of IHDR');
  }
  return PngHeader(
    widthInPixels: view.getUint32(_headerPayloadOffset),
    heightInPixels: view.getUint32(_headerPayloadOffset + 4),
    bitDepth: view.getUint8(_headerPayloadOffset + 8),
    colourType: view.getUint8(_headerPayloadOffset + 9),
  );
}
