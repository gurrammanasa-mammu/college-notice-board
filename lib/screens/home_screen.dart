import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/notice.dart';
import '../services/notice_provider.dart';
import '../widgets/notice_card.dart';
import 'add_notice_screen.dart';
import 'detail_screen.dart';
import 'summary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _department = 'All';
  bool _addingSample = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addSample() async {
    if (_addingSample) return;
    setState(() => _addingSample = true);
    try {
      await context.read<NoticeProvider>().addSampleNotice();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save sample notice: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _addingSample = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReady =
        context.watch<NoticeProvider>().status == NoticeLoadStatus.ready;
    return Scaffold(
      appBar: AppBar(
        title: const Text('KHIT Notice Board'),
        actions: [
          IconButton(
            tooltip: 'Notice summary',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SummaryScreen()),
            ),
            icon: const Icon(Icons.insights_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Search by title',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _department,
                          decoration: const InputDecoration(
                            labelText: 'Department',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: ['All', ...Notice.departments]
                              .map(
                                (department) => DropdownMenuItem(
                                  value: department,
                                  child: Text(department),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _department = value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: OutlinedButton.icon(
                          onPressed: _addingSample || !isReady
                              ? null
                              : _addSample,
                          icon: _addingSample
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.science_outlined),
                          label: const Text('Add Sample'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<NoticeProvider>(
                builder: (context, provider, _) {
                  if (provider.status == NoticeLoadStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.status == NoticeLoadStatus.error) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 40,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              provider.loadError ?? 'Could not load notices.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: provider.loadNotices,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final query = _searchController.text.trim().toLowerCase();
                  final notices =
                      provider.notices.where((notice) {
                        final matchesDepartment =
                            _department == 'All' ||
                            notice.department == _department;
                        return matchesDepartment &&
                            notice.title.toLowerCase().contains(query);
                      }).toList()..sort(
                        (first, second) =>
                            second.postedAt.compareTo(first.postedAt),
                      );

                  if (provider.notices.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.campaign_outlined,
                              size: 52,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No notices yet',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add a notice to keep everyone informed.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (notices.isEmpty) {
                    return const Center(child: Text('No matching notices'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: notices.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final notice = notices[index];
                      return NoticeCard(
                        notice: notice,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => DetailScreen(notice: notice),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isReady
            ? () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AddNoticeScreen(),
                ),
              )
            : null,
        icon: const Icon(Icons.add),
        label: const Text('Add Notice'),
      ),
    );
  }
}
