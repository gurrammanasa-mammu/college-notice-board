import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notice.dart';

enum NoticeLoadStatus { loading, ready, error }

class NoticeProvider extends ChangeNotifier {
  static const _storageKey = 'college_notices';

  List<Notice> _notices = [];
  NoticeLoadStatus _status = NoticeLoadStatus.loading;
  String? _loadError;

  List<Notice> get notices => List.unmodifiable(_notices);
  NoticeLoadStatus get status => _status;
  String? get loadError => _loadError;

  Future<void> loadNotices() async {
    _status = NoticeLoadStatus.loading;
    _loadError = null;
    notifyListeners();
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getString(_storageKey);
      if (saved == null || saved.isEmpty) {
        _notices = [];
      } else {
        final decoded = jsonDecode(saved);
        if (decoded is! List) {
          throw const FormatException('Saved notices must be a JSON list.');
        }
        _notices = decoded
            .map(
              (item) => Notice.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList();
      }
      _status = NoticeLoadStatus.ready;
    } catch (error) {
      _status = NoticeLoadStatus.error;
      _loadError = 'Could not load notices: $error';
    }
    notifyListeners();
  }

  Future<void> addNotice(Notice notice) async {
    final updated = [..._notices, notice];
    await _save(updated);
    _notices = updated;
    _status = NoticeLoadStatus.ready;
    notifyListeners();
  }

  Future<void> addSampleNotice() async {
    await addNotice(
      Notice(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: 'Campus library hours this week',
        description:
            'The central library will remain open until 8:00 PM this week '
            'to support students preparing for upcoming examinations.',
        department: 'General',
        author: 'College Administration',
        priority: 'Normal',
        postedAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteNotice(String id) async {
    final updated = _notices.where((notice) => notice.id != id).toList();
    await _save(updated);
    _notices = updated;
    notifyListeners();
  }

  Future<void> _save(List<Notice> notices) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(notices.map((notice) => notice.toJson()).toList()),
    );
    if (!saved) {
      throw StateError('The notice could not be saved to this device.');
    }
  }
}
