import 'dart:math';

/// Generates a random RFC 4122 version-4 UUID.
///
/// M3 types `client_report_id` as `Optional[UUID]` - the offline-sync
/// idempotency key that makes safe resubmission possible. It must be
/// globally collision-safe across devices, which a sequential string like
/// `'NER-1043'` is not (see the integration audit, §3.9, cause 2).
///
/// Implemented locally (no `uuid` package dependency) since this
/// environment has no Flutter/Dart SDK available to verify a new pubspec
/// dependency actually resolves - `Random.secure()` gives cryptographically
/// strong randomness, which is all RFC 4122 v4 requires.
String generateUuidV4() {
  final rnd = Random.secure();
  final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));

  // Per RFC 4122 §4.4: set version (4) and variant (RFC 4122) bits.
  bytes[6] = (bytes[6] & 0x0F) | 0x40;
  bytes[8] = (bytes[8] & 0x3F) | 0x80;

  String hex(int start, int end) =>
      bytes.sublist(start, end).map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
