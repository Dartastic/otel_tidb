// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

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

    test('TidbResult fields default null', () {
      const r = TidbResult();
      expect(r.statusCode, isNull);
    });
  });
}
