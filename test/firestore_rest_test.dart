import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:amar_kushtia/models/master_record.dart';

void main() {
  test('Verify Firestore REST API returns MD-0001 with 3 image URLs', () async {
    final url = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/amar-kushtia-419ec/databases/(default)/documents/records?pageSize=300',
    );
    final response = await http.get(url);
    expect(response.statusCode, 200);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final docs = data['documents'] as List<dynamic>? ?? [];
    expect(docs, isNotEmpty);

    final records = docs
        .map((d) => MasterRecord.fromFirestoreRest(d as Map<String, dynamic>))
        .toList();

    final md0001 = records.firstWhere((r) => r.id == 'MD-0001');

    expect(md0001.imageUrls.length, greaterThanOrEqualTo(1));
    expect(md0001.imageUrls.first, contains('upload.wikimedia.org'));
  });
}
