// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_tidb_suppression.dart';

class TiDBResult {
  const TiDBResult({
    this.cluster,
    this.database,
    this.table,
    this.statementType,
    this.queryText,
    this.rowsAffected,
    this.region,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? cluster;
  final String? database;
  final String? table;
  final String? statementType;
  final String? queryText;
  final int? rowsAffected;
  final String? region;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class TiDBCallResult<T> {
  const TiDBCallResult({required this.value, this.result});
  final T value;
  final TiDBResult? result;
}

Future<T> tracedTiDB<T>({
  required String operation,
  required Future<TiDBCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (tidbInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_tidb');
  final span = t.startSpan('tidb $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('db.system.name', 'tidb');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.cluster != null) {
        span.setStringAttribute('tidb.cluster', res.cluster!);
      }
      if (res.database != null) {
        span.setStringAttribute('db.namespace', res.database!);
      }
      if (res.table != null) {
        span.setStringAttribute('db.collection.name', res.table!);
      }
      if (res.statementType != null) {
        span.setStringAttribute('db.operation.name', res.statementType!);
      }
      if (res.queryText != null) {
        span.setStringAttribute('db.query.text', res.queryText!);
      }
      if (res.rowsAffected != null) {
        span.setIntAttribute('db.response.returned_rows', res.rowsAffected!);
      }
      if (res.region != null) {
        span.setStringAttribute('cloud.region', res.region!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('tidb.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'tidb.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
