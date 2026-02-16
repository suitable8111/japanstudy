import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';

class RankingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  String _selectedDifficulty = 'N5';
  List<Map<String, dynamic>> _rankings = [];
  bool _isLoading = false;

  String get selectedDifficulty => _selectedDifficulty;
  List<Map<String, dynamic>> get rankings => _rankings;
  bool get isLoading => _isLoading;

  String get difficultyLabel {
    switch (_selectedDifficulty) {
      case 'N5':
        return '하';
      case 'N4':
        return '중';
      case 'N3':
        return '상';
      case 'N2':
        return '상상';
      case 'N1':
        return '최상';
      default:
        return '';
    }
  }

  Future<void> loadRankings({String? difficulty}) async {
    if (difficulty != null) {
      _selectedDifficulty = difficulty;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _rankings =
          await _firestoreService.getRankings(_selectedDifficulty);
    } catch (e) {
      debugPrint('Failed to load rankings: $e');
      _rankings = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void changeDifficulty(String difficulty) {
    loadRankings(difficulty: difficulty);
  }
}
