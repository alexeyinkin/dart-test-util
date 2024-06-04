/// ignore: public_member_api_docs
extension IntStreamExtension on Stream<List<int>> {
  /// Waits for all content of this stream, joins it and interprets it
  /// as a String with char codes.
  Future<String> toJointString() async {
    final list = await toList();
    final charCodes = list.expand((l) => l);
    return String.fromCharCodes(charCodes);
  }
}
