import 'dart:convert';
import 'package:flutter/foundation.dart';

enum LedgerPlatform { ebay, tcgPlayer, cardmarket, custom }

class CsvPlatformTemplate {
  final LedgerPlatform platform;
  final List<String> titleHeaders;
  final List<String> priceHeaders;
  final List<String> dateHeaders;
  final List<String> feeHeaders;

  const CsvPlatformTemplate({
    required this.platform,
    required this.titleHeaders,
    required this.priceHeaders,
    required this.dateHeaders,
    required this.feeHeaders,
  });

  static const ebay = CsvPlatformTemplate(
    platform: LedgerPlatform.ebay,
    titleHeaders: ['item title', 'title', 'item_name'],
    priceHeaders: ['total price', 'sold for', 'price', 'amount'],
    dateHeaders: ['sale date', 'sold date', 'date'],
    feeHeaders: ['ebay fees', 'final value fee', 'fee'],
  );

  static const tcgPlayer = CsvPlatformTemplate(
    platform: LedgerPlatform.tcgPlayer,
    titleHeaders: ['product name', 'item name', 'title'],
    priceHeaders: ['total', 'item price', 'price', 'sale amount'],
    dateHeaders: ['order date', 'date'],
    feeHeaders: ['fees', 'tcg fee', 'commission'],
  );

  static const cardmarket = CsvPlatformTemplate(
    platform: LedgerPlatform.cardmarket,
    titleHeaders: ['name', 'card name', 'article'],
    priceHeaders: ['price', 'total price', 'sold price'],
    dateHeaders: ['date', 'purchased date'],
    feeHeaders: ['commission', 'fee', 'service fee'],
  );
}

class ImportedLedgerTxn {
  final String title;
  final double amount;
  final double fee;
  final DateTime date;
  final LedgerPlatform platform;

  ImportedLedgerTxn({
    required this.title,
    required this.amount,
    required this.fee,
    required this.date,
    required this.platform,
  });
}

class CsvImportService {
  static List<ImportedLedgerTxn> parseCsv(String csvContent) {
    final List<ImportedLedgerTxn> results = [];
    final List<String> lines = const LineSplitter().convert(_stripBom(csvContent));
    if (lines.isEmpty) return results;

    final List<String> headers = _splitCsvRow(lines.first.toLowerCase());
    final CsvPlatformTemplate template = _detectPlatform(headers);

    final int titleIdx = _findHeaderIndex(headers, template.titleHeaders);
    final int priceIdx = _findHeaderIndex(headers, template.priceHeaders);
    final int dateIdx = _findHeaderIndex(headers, template.dateHeaders);
    final int feeIdx = _findHeaderIndex(headers, template.feeHeaders);

    for (int i = 1; i < lines.length; i++) {
      final String line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        final List<String> row = _splitCsvRow(line);
        if (row.isEmpty) continue;

        final String title = titleIdx != -1 && titleIdx < row.length
            ? row[titleIdx].replaceAll('"', '').trim()
            : '未知卡牌交易';
        final double amount = priceIdx != -1 && priceIdx < row.length ? _parseCurrency(row[priceIdx]) : 0.0;
        final double fee = feeIdx != -1 && feeIdx < row.length ? _parseCurrency(row[feeIdx]) : 0.0;
        final DateTime date = dateIdx != -1 && dateIdx < row.length ? _parseDate(row[dateIdx]) : DateTime.now();

        if (amount > 0) {
          results.add(ImportedLedgerTxn(
            title: title,
            amount: amount,
            fee: fee,
            date: date,
            platform: template.platform,
          ));
        }
      } catch (e) {
        debugPrint('Skip invalid CSV row at line $i: $e');
      }
    }
    return results;
  }

  static CsvPlatformTemplate _detectPlatform(List<String> headers) {
    final String headerStr = headers.join(' ');
    if (headerStr.contains('ebay')) return CsvPlatformTemplate.ebay;
    if (headerStr.contains('tcg')) return CsvPlatformTemplate.tcgPlayer;
    if (headerStr.contains('cardmarket') || headerStr.contains('article')) return CsvPlatformTemplate.cardmarket;
    return CsvPlatformTemplate.ebay;
  }

  static int _findHeaderIndex(List<String> headers, List<String> candidates) {
    for (final cand in candidates) {
      final int idx = headers.indexWhere((h) => h.contains(cand));
      if (idx != -1) return idx;
    }
    return -1;
  }
  static double _parseCurrency(String raw) {
    final String s0 = raw.replaceAll('"', '').trim();
    if (s0.isEmpty) return 0.0;

    String s = s0.replaceAll('\uFEFF', '').replaceAll('\u0000', '').trim();
    bool negative = false;

    // Handle parentheses negative amounts like (1,234.56)
    if (s.startsWith('(') && s.endsWith(')')) {
      negative = true;
      s = s.substring(1, s.length - 1).trim();
    }

    // Remove currency symbols and whitespace except digits, dot, comma, minus
    s = s.replaceAll(RegExp(r"[^0-9,\.\-]"), '');

    // Normalize thousand separators and decimal mark:
    if (s.contains(',') && s.contains('.')) {
      // Decide which is decimal by position of last separator
      if (s.lastIndexOf('.') > s.lastIndexOf(',')) {
        // '.' is decimal separator, remove commas
        s = s.replaceAll(',', '');
      } else {
        // ',' is decimal separator, remove dots as thousands
        s = s.replaceAll('.', '');
        s = s.replaceAll(',', '.');
      }
    } else if (s.contains(',') && !s.contains('.')) {
      // Treat comma as decimal separator
      s = s.replaceAll(',', '.');
    }

    final double value = double.tryParse(s) ?? 0.0;
    return negative ? -value : value;
  }

  static DateTime _parseDate(String raw) {
    final String clean = raw.replaceAll('"', '').replaceAll('\uFEFF', '').trim();
    // Try ISO parse first
    final DateTime? parsed = DateTime.tryParse(clean);
    if (parsed != null) return parsed;

    // Fallback: try common patterns yyyy-MM-dd, dd/MM/yyyy, MM/dd/yyyy
    try {
      final parts = clean.split(RegExp(r'[-\/]'));
      if (parts.length >= 3) {
        if (parts[0].length == 4) {
          // yyyy-mm-dd
          return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        } else {
          // assume dd/mm/yyyy or mm/dd/yyyy -> try to detect year
          final int a = int.parse(parts[0]);
          final int b = int.parse(parts[1]);
          final int c = int.parse(parts[2]);
          if (c > 31) {
            // day, month, year
            return DateTime(c, a, b);
          }
        }
      }
    } catch (_) {
      // ignore and fallback
    }

    return DateTime.now();
  }

  static List<String> _splitCsvRow(String row) {
    final List<String> result = [];
    bool inQuotes = false;
    final StringBuffer buffer = StringBuffer();
    final String trimmedRow = row.replaceAll('\u0000', '');

    for (int i = 0; i < trimmedRow.length; i++) {
      final String char = trimmedRow[i];
      if (char == '"') {
        // Handle escaped double quotes inside quoted field ("" -> ")
        if (inQuotes && i + 1 < trimmedRow.length && trimmedRow[i + 1] == '"') {
          buffer.write('"');
          i++; // skip escaped quote
          continue;
        }
        inQuotes = !inQuotes;
        continue;
      }

      if ((char == ',' || char == ';') && !inQuotes) {
        result.add(buffer.toString().trim());
        buffer.clear();
        continue;
      }

      buffer.write(char);
    }

    if (buffer.isNotEmpty) {
      result.add(buffer.toString().trim());
    }

    return result;
  }

  static String _stripBom(String content) {
    return content.replaceAll('\uFEFF', '').trim();
  }
}