import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/notice.dart';
import '../services/notice_provider.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<NoticeProvider>();
    final notices = provider.notices;
    final latest = notices.isEmpty
        ? null
        : (notices.toList()..sort(
                (first, second) => second.postedAt.compareTo(first.postedAt),
              ))
              .first;

    return Scaffold(
      appBar: AppBar(title: const Text('Notice Summary')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total notices',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${notices.length}',
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('By department', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: Notice.departments.map((department) {
                        final count = notices
                            .where((notice) => notice.department == department)
                            .length;
                        return ListTile(
                          title: Text(department),
                          trailing: CircleAvatar(
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                            child: Text('$count'),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Latest notice', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: latest == null
                          ? const Text('No notices yet')
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  latest.title,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${latest.department} · '
                                  '${DateFormat('MMM d, yyyy').format(latest.postedAt)}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
