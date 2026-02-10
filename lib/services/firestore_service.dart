import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/study_record.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 유저 프로필 생성
  Future<void> createUserProfile(String uid, String email, String displayName) async {
    await _db.collection('users').doc(uid).set({
      'displayName': displayName,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // 학습 기록 저장
  Future<void> saveStudyRecord(String uid, StudyRecord record) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('study_records')
        .doc(record.id)
        .set({
      'date': Timestamp.fromDate(record.date),
      'type': record.type,
      'totalCount': record.totalCount,
      if (record.correctCount != null) 'correctCount': record.correctCount,
      'items': record.items
          .map((e) => {
                'japanese': e.japanese,
                'reading': e.reading,
                'korean': e.korean,
                if (e.isCorrect != null) 'isCorrect': e.isCorrect,
              })
          .toList(),
    });
  }

  // 학습 기록 조회
  Future<List<StudyRecord>> getStudyRecords(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('study_records')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return StudyRecord(
        id: doc.id,
        date: (data['date'] as Timestamp).toDate(),
        type: data['type'] as String,
        totalCount: data['totalCount'] as int,
        correctCount: data['correctCount'] as int?,
        items: (data['items'] as List)
            .map((e) => StudyItem(
                  japanese: e['japanese'] as String,
                  reading: e['reading'] as String,
                  korean: e['korean'] as String,
                  isCorrect: e['isCorrect'] as bool?,
                ))
            .toList(),
      );
    }).toList();
  }

  // 기록 삭제
  Future<void> deleteStudyRecord(String uid, String recordId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('study_records')
        .doc(recordId)
        .delete();
  }

  // 전체 기록 삭제
  Future<void> clearStudyRecords(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('study_records')
        .get();

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // 학습 통계 조회
  Future<Map<String, int>> getUserStats(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('study_records')
        .get();

    int total = snapshot.docs.length;
    int wordCount = 0;
    int sentenceCount = 0;
    int quizCount = 0;

    for (final doc in snapshot.docs) {
      final type = doc.data()['type'] as String;
      if (type == 'word') {
        wordCount++;
      } else if (type == 'sentence') {
        sentenceCount++;
      } else if (type.startsWith('quiz')) {
        quizCount++;
      }
    }

    return {
      'total': total,
      'word': wordCount,
      'sentence': sentenceCount,
      'quiz': quizCount,
    };
  }
}
