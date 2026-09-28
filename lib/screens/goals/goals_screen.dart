import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/goal_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/goal_progress.dart';
import 'add_goal_screen.dart';
import 'goal_detail_screen.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final active = s.goals.where((g) => !g.completed).toList();
    final done = s.goals.where((g) => g.completed).toList();

    void add() => Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AddGoalScreen()));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Goals'),
          bottom: TabBar(tabs: [
            Tab(text: 'Active (${active.length})'),
            Tab(text: 'Completed (${done.length})'),
          ]),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: add,
          icon: const Icon(Icons.add),
          label: const Text('Add Goal'),
        ),
        body: TabBarView(
          children: [
            active.isEmpty
                ? EmptyState(
                    icon: Icons.flag_rounded,
                    title: 'No active goals',
                    subtitle: 'What are you saving for?',
                    actionLabel: 'Add Goal',
                    onAction: add)
                : _list(context, s, active),
            done.isEmpty
                ? const EmptyState(
                    icon: Icons.task_alt_rounded,
                    title: 'No completed goals yet',
                    subtitle: 'Complete a goal to see it here.')
                : _list(context, s, done),
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context, AppState s, List<GoalModel> goals) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: goals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => GoalTile(goal: goals[i], walletName: s.walletById(goals[i].walletId)?.name),
    );
  }
}

class GoalTile extends StatelessWidget {
  final GoalModel goal;
  final String? walletName;
  const GoalTile({super.key, required this.goal, this.walletName});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final g = goal;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => GoalDetailScreen(goalId: g.id!))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(g.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  Text(g.completed ? 'Complete' : CurrencyFormatter.percent(g.progress),
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
              if (walletName != null)
                Text(walletName ?? '',
                    style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
              const SizedBox(height: 10),
              GoalProgress(progress: g.progress),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${CurrencyFormatter.compact(g.currentAmount, g.currency)} / ${CurrencyFormatter.compact(g.targetAmount, g.currency)}',
                      style: const TextStyle(fontSize: 13)),
                  if (!g.completed)
                    Text(DateFormatter.deadlineText(g.deadline),
                        style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
