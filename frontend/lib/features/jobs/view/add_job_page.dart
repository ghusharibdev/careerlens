import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/jobs_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/widgets.dart';

class AddJobPage extends StatefulWidget {
  const AddJobPage({super.key});

  @override
  State<AddJobPage> createState() => _AddJobPageState();
}

class _AddJobPageState extends State<AddJobPage> {
  final _vm = JobsViewModel();
  final _titleCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _jdCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _jdCtrl.addListener(() => setState(() {}));
  }

  Future<void> _save() async {
    if (_titleCtrl.text.isEmpty || _companyCtrl.text.isEmpty || _jdCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    setState(() => _loading = true);
    await _vm.addJob(_titleCtrl.text.trim(), _companyCtrl.text.trim(), _jdCtrl.text.trim());
    if (mounted) {
      setState(() => _loading = false);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Job')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _Label('Job Title'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(hintText: 'e.g. Flutter Developer'),
            ),
            const SizedBox(height: 20),
            _Label('Company'),
            const SizedBox(height: 8),
            TextField(
              controller: _companyCtrl,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(hintText: 'e.g. Google'),
            ),
            const SizedBox(height: 20),
            _Label('Job Description'),
            const SizedBox(height: 8),
            TextField(
              controller: _jdCtrl,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: AppTheme.textPrimary, height: 1.5),
              maxLines: 12,
              decoration: const InputDecoration(
                hintText: 'Paste the full job description here...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${_jdCtrl.text.length} characters',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: AppButton(label: 'Save Job', icon: Icons.bookmark_outline, onTap: _save, loading: _loading),
            ),
          ].animate(interval: 60.ms).fadeIn().slideY(begin: 0.05),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textSecondary, fontSize: 13,
        fontWeight: FontWeight.w500, letterSpacing: 0.3,
      ),
    );
  }
}
