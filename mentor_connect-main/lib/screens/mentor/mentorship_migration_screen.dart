import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/mentorship_migration_service.dart';

/// ONE-TIME utility screen to fix old accepted submissions
/// Run this once, then you can remove it
class MentorshipMigrationScreen extends StatefulWidget {
  const MentorshipMigrationScreen({Key? key}) : super(key: key);

  @override
  State<MentorshipMigrationScreen> createState() =>
      _MentorshipMigrationScreenState();
}

class _MentorshipMigrationScreenState extends State<MentorshipMigrationScreen> {
  bool _isRunning = false;
  MigrationResult? _result;
  String _status = 'Ready to migrate';

  Future<void> _runMigration() async {
    setState(() {
      _isRunning = true;
      _status = 'Scanning accepted submissions...';
      _result = null;
    });

    try {
      final service = MentorshipMigrationService();
      final result = await service.migrateAcceptedSubmissions();

      setState(() {
        _result = result;
        _isRunning = false;
        _status = 'Migration complete!';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Created ${result.created} mentorships, skipped ${result.skipped}, errors: ${result.errors}',
            ),
            backgroundColor: result.errors == 0 ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isRunning = false;
        _status = 'Migration failed: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Migration failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fix Mentorships'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning Card
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'One-Time Fix',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This tool creates mentorships for students you accepted BEFORE the mentorship system was implemented.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Run this ONCE to fix existing data. Future acceptances will automatically create mentorships.',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (_isRunning)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      _result == null
                          ? Icons.info_outline
                          : _result!.errors == 0
                              ? Icons.check_circle
                              : Icons.warning,
                      color: _result == null
                          ? AppTheme.primaryColor
                          : _result!.errors == 0
                              ? Colors.green
                              : Colors.orange,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _status,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Results
            if (_result != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildResultRow(
                        Icons.add_circle,
                        'Created',
                        _result!.created.toString(),
                        Colors.green,
                      ),
                      _buildResultRow(
                        Icons.skip_next,
                        'Skipped (already exist)',
                        _result!.skipped.toString(),
                        Colors.blue,
                      ),
                      _buildResultRow(
                        Icons.error,
                        'Errors',
                        _result!.errors.toString(),
                        Colors.red,
                      ),
                      if (_result!.errorMessages.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          'Error Details:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._result!.errorMessages.map((msg) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• $msg',
                                style: const TextStyle(fontSize: 12),
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Success message
              if (_result!.created > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Successfully created ${_result!.created} mentorship${_result!.created == 1 ? '' : 's'}!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You can now view your mentees in the "My Mentees" screen.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
            ],

            const Spacer(),

            // Run Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isRunning ? null : _runMigration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isRunning
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Running migration...'),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow),
                          const SizedBox(width: 8),
                          Text(_result == null ? 'Run Migration' : 'Run Again'),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Close button
            if (_result != null && _result!.created > 0)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(
      IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
