import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodel/jobs_viewmodel.dart';
import '../model/job_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/widgets.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final _vm = JobsViewModel();

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CareerLens'),
        actions: [
          IconButton(
            icon: const Icon(Icons.description_outlined),
            onPressed: () => context.push('/resume'),
            tooltip: 'My Resume',
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => context.push('/chat'),
            tooltip: 'Chat with Resume',
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-job'),
        backgroundColor: AppTheme.accent,
        foregroundColor: AppTheme.bg,
        icon: const Icon(Icons.add),
        label: const Text('Add Job', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder<List<JobModel>>(
        stream: _vm.jobsStream(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error: ${snap.error}',
                  style: const TextStyle(color: AppTheme.danger, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.accent));
          }
          final jobs = snap.data ?? [];
          if (jobs.isEmpty) return _EmptyState();
          return _JobsList(jobs: jobs);
        },
      ),
    );
  }
}

class _JobsList extends StatelessWidget {
  final List<JobModel> jobs;
  const _JobsList({required this.jobs});

  @override
  Widget build(BuildContext context) {
    final applied = jobs.where((j) => j.status == 'applied').length;
    final interview = jobs.where((j) => j.status == 'interview').length;
    final offer = jobs.where((j) => j.status == 'offer').length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            _StatChip(label: 'Applied', count: applied, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            _StatChip(label: 'Interview', count: interview, color: AppTheme.warning),
            const SizedBox(width: 8),
            _StatChip(label: 'Offer', count: offer, color: AppTheme.success),
          ],
        ).animate().fadeIn(),
        const SizedBox(height: 20),
        ...jobs.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _JobCard(job: e.value),
          ).animate().fadeIn(delay: (e.key * 60).ms).slideY(begin: 0.05);
        }),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobModel job;
  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/job/${job.id}'),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surfaceHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
            ),
            child: Center(
              child: Text(
                job.company.isNotEmpty ? job.company[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15),
                ),
                const SizedBox(height: 3),
                Text(job.company,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (job.matchScore != null) ScoreGauge(score: job.matchScore!),
              if (job.matchScore == null)
                StatusBadge(status: job.status)
              else ...[
                const SizedBox(height: 6),
                StatusBadge(status: job.status)
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text('$count',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
                color: AppTheme.accentDim,
                borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.work_outline,
                color: AppTheme.accent, size: 32),
          ).animate().scale(duration: 400.ms),
          const SizedBox(height: 20),
          const Text('No jobs yet',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text(
            'Add a job to start tracking\nyour applications.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
          ),
        ],
      ).animate().fadeIn(delay: 100.ms),
    );
  }
}