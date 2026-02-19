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
      if (record.difficulty != null) 'difficulty': record.difficulty,
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
        difficulty: data['difficulty'] as String?,
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

  // 유저 통계 초기화
  Future<void> clearUserStats(String uid) async {
    await _db.collection('user_stats').doc(uid).delete();
  }

  // 퀴즈 통계 업데이트 (user_stats)
  Future<void> updateUserStats(
    String uid,
    String displayName,
    String difficulty,
    int totalCount,
    int correctCount,
  ) async {
    final docRef = _db.collection('user_stats').doc(uid);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data() ?? {};

      final levelData =
          Map<String, dynamic>.from(data[difficulty] as Map? ?? {});
      final prevQuizCount = (levelData['quizCount'] as num?)?.toInt() ?? 0;
      final prevTotalCorrect = (levelData['totalCorrect'] as num?)?.toInt() ?? 0;
      final prevTotalQuestions = (levelData['totalQuestions'] as num?)?.toInt() ?? 0;
      final prevBestRate = (levelData['bestRate'] as num?)?.toDouble() ?? 0.0;

      final currentRate =
          totalCount > 0 ? (correctCount / totalCount * 100) : 0.0;

      levelData['quizCount'] = prevQuizCount + 1;
      levelData['totalCorrect'] = prevTotalCorrect + correctCount;
      levelData['totalQuestions'] = prevTotalQuestions + totalCount;
      levelData['bestRate'] =
          currentRate > prevBestRate ? currentRate : prevBestRate;

      transaction.set(
        docRef,
        {
          'uid': uid,
          'displayName': displayName,
          'updatedAt': FieldValue.serverTimestamp(),
          difficulty: levelData,
        },
        SetOptions(merge: true),
      );
    });
  }

  // 랭킹 조회
  Future<List<Map<String, dynamic>>> getRankings(String difficulty) async {
    final snapshot = await _db.collection('user_stats').get();

    final rankings = <Map<String, dynamic>>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final levelData =
          Map<String, dynamic>.from(data[difficulty] as Map? ?? {});
      final quizCount = (levelData['quizCount'] as num?)?.toInt() ?? 0;
      if (quizCount == 0) continue;

      final bestRate = (levelData['bestRate'] as num?)?.toDouble() ?? 0.0;

      rankings.add({
        'uid': data['uid'] ?? doc.id,
        'displayName': data['displayName'] ?? '알 수 없음',
        'quizCount': quizCount,
        'bestRate': bestRate,
      });
    }

    // 최고 점수 내림차순, 같으면 퀴즈 횟수 내림차순
    rankings.sort((a, b) {
      final cmp =
          (b['bestRate'] as double).compareTo(a['bestRate'] as double);
      if (cmp != 0) return cmp;
      return (b['quizCount'] as int).compareTo(a['quizCount'] as int);
    });

    return rankings.take(10).toList();
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
