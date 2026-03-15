import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import '../viewmodel/resume_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/widgets.dart';

class ResumePage extends StatefulWidget {
  const ResumePage({super.key});

  @override
  State<ResumePage> createState() => _ResumePageState();
}

class _ResumePageState extends State<ResumePage> {
  final _vm = ResumeViewModel();

  @override
  void initState() {
    super.initState();
    _vm.loadResume().then((_) => setState(() {}));
  }

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      await _vm.uploadResumeBytes(
        result.files.single.bytes!,
        result.files.single.name,
        () => setState(() {}),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Resume')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _vm.resume != null
              ? _ResumeUploaded(vm: _vm)
              : _ResumeEmpty(vm: _vm, onPick: _pick),
        ),
      ),
    );
  }
}

class _ResumeEmpty extends StatelessWidget {
  final ResumeViewModel vm;
  final VoidCallback onPick;
  const _ResumeEmpty({required this.vm, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        GestureDetector(
          onTap: vm.loading ? null : onPick,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: vm.loading ? AppTheme.accent : AppTheme.border,
                width: vm.loading ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.accentDim,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: vm.loading
                      ? const Padding(
                          padding: EdgeInsets.all(18),
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: AppTheme.accent),
                        )
                      : const Icon(Icons.upload_file_outlined,
                          color: AppTheme.accent, size: 30),
                ),
                const SizedBox(height: 20),
                Text(
                  vm.loading
                      ? (vm.statusMessage ?? 'Processing...')
                      : 'Upload your resume',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  vm.loading ? 'This may take a moment' : 'PDF format only',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ).animate().fadeIn().slideY(begin: 0.1),
        if (vm.error != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.danger.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
            ),
            child: Text(vm.error!,
                style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
          ),
        ],
        const SizedBox(height: 32),
        AppCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppTheme.accentDim,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.auto_awesome,
                    color: AppTheme.accent, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your resume is embedded with AI so every job match is grounded in your actual skills.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 13),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }
}

class _ResumeUploaded extends StatelessWidget {
  final ResumeViewModel vm;
  const _ResumeUploaded({required this.vm});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tileColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      leading: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppTheme.success.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.description_outlined,
            color: AppTheme.success, size: 22),
      ),
      title: Text(
        vm.resume!.fileName,
        style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: const Text('Embedded & ready',
          style: TextStyle(color: AppTheme.success, fontSize: 12)),
      trailing: const Icon(Icons.check_circle_outline,
          color: AppTheme.success, size: 22),
    ).animate().fadeIn();
  }
}