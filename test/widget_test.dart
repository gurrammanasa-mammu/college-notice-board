import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:khit_notice_board/screens/home_screen.dart';
import 'package:khit_notice_board/services/notice_provider.dart';
import 'package:khit_notice_board/theme/app_theme.dart';

void main() {
  testWidgets('home is empty and add notice validates required fields', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final provider = NoticeProvider();
    await provider.loadNotices();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No notices yet'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save Notice'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Notice'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a title.'), findsOneWidget);
    expect(find.text('Please enter a description.'), findsOneWidget);
    expect(find.text('Please select a department.'), findsOneWidget);
    expect(find.text('Please enter the author name.'), findsOneWidget);
    expect(find.text('Please select a priority.'), findsOneWidget);
  });
}
