// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_tidb/otel_tidb.dart';
import 'package:test/test.dart';

void main() {
  group('otel_tidb', () {
    test('suppression toggles in zone', () async {
      expect(tidbInstrumentationSuppressed(), isFalse);
      await runWithoutTidbInstrumentationAsync(() async {
        expect(tidbInstrumentationSuppressed(), isTrue);
      });
      expect(tidbInstrumentationSuppressed(), isFalse);
    });

    test('TiDBResult fields default null', () {
      const r = TiDBResult();
      expect(r.statusCode, isNull);
    });
  });
}
