import 'package:careerlens/features/match/model/match_result_model.dart';
import 'package:careerlens/features/match/viewmodel/match_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/widgets.dart';
import '../../jobs/model/job_model.dart';
import '../../jobs/viewmodel/jobs_viewmodel.dart';

class JobDetailPage extends StatefulWidget {
  final String jobId;
  const JobDetailPage({super.key, required this.jobId});

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  final _matchVm = MatchViewModel();
  final _jobsVm = JobsViewModel();
  JobModel? _job;

  @override
  void initState() {
    super.initState();
    _loadJob();
  }

  Future<void> _loadJob() async {
    final doc = await FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobId)
        .get();
    if (doc.exists && mounted) {
      setState(() => _job = JobModel.fromMap(doc.data()!, doc.id));
      // Load existing match result if any
      _matchVm.loadExistingResult(widget.jobId, () => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_job == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_job!.title),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: AppTheme.surface,
            onSelected: (val) async {
              if (val == 'delete') {
                await _jobsVm.deleteJob(widget.jobId);
                if (mounted) Navigator.pop(context);
              } else {
                await _jobsVm.updateStatus(widget.jobId, val);
                setState(() => _job = _job!.copyWith(status: val));
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'applied', child: Text('Mark Applied', style: TextStyle(color: AppTheme.textPrimary))),
              const PopupMenuItem(value: 'interview', child: Text('Mark Interview', style: TextStyle(color: AppTheme.warning))),
              const PopupMenuItem(value: 'offer', child: Text('Mark Offer', style: TextStyle(color: AppTheme.success))),
              const PopupMenuItem(value: 'rejected', child: Text('Mark Rejected', style: TextStyle(color: AppTheme.danger))),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppTheme.danger))),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header card
          AppCard(
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Center(
                    child: Text(
                      _job!.company[0].toUpperCase(),
                      style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_job!.title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 3),
                      Text(_job!.company, style: const TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                StatusBadge(status: _job!.status),
              ],
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 16),

          // Analyze button / loading / result
          if (_matchVm.result == null && !_matchVm.loading)
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Analyze Match with AI',
                icon: Icons.auto_awesome,
                onTap: () => _matchVm.analyzeMatch(
                  widget.jobId,
                  _job!.jobDescription,
                  () => setState(() {}),
                ),
              ),
            ).animate().fadeIn(delay: 100.ms)
          else if (_matchVm.loading)
            AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent),
                  ),
                  const SizedBox(width: 14),
                  Text('Analyzing your match...', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ).animate().fadeIn()
          else if (_matchVm.error != null)
            AppCard(
              child: Text(_matchVm.error!, style: const TextStyle(color: AppTheme.danger)),
            )
          else if (_matchVm.result != null)
            _MatchResult(result: _matchVm.result!).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 16),

          // Job description
          _Section(
            title: 'Job Description',
            child: Text(
              _job!.jobDescription,
              style: const TextStyle(color: AppTheme.textSecondary, height: 1.6, fontSize: 13),
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _MatchResult extends StatelessWidget {
  final MatchResultModel result;
  const _MatchResult({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Score card
        AppCard(
          child: Row(
            children: [
              ScoreGauge(score: result.matchScore),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Match Score', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      result.matchScore >= 70 ? 'Strong match 🎯' : result.matchScore >= 45 ? 'Moderate match' : 'Weak match',
                      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${result.matchedSkills.length} skills matched · ${result.skillGaps.length} gaps',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (result.matchedSkills.isNotEmpty) ...[
          _Section(
            title: 'Matched Skills',
            titleColor: AppTheme.success,
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: result.matchedSkills.map((s) => _Chip(label: s, color: AppTheme.success)).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (result.skillGaps.isNotEmpty) ...[
          _Section(
            title: 'Skill Gaps',
            titleColor: AppTheme.danger,
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: result.skillGaps.map((s) => _Chip(label: s, color: AppTheme.danger)).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (result.talkingPoints.isNotEmpty) ...[
          _Section(
            title: 'Talking Points for Interview',
            titleColor: AppTheme.accent,
            child: Column(
              children: result.talkingPoints.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20, height: 20,
                        margin: const EdgeInsets.only(top: 1, right: 10),
                        decoration: BoxDecoration(color: AppTheme.accentDim, borderRadius: BorderRadius.circular(6)),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: const TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(e.value, style: const TextStyle(color: AppTheme.textSecondary, height: 1.5, fontSize: 13)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (result.suggestedQuestions.isNotEmpty)
          _Section(
            title: 'Likely Interview Questions',
            child: Column(
              children: result.suggestedQuestions.map((q) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('?', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(q, style: const TextStyle(color: AppTheme.textSecondary, height: 1.5, fontSize: 13)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? titleColor;

  const _Section({required this.title, required this.child, this.titleColor});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: titleColor ?? AppTheme.textMuted,
              fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}
