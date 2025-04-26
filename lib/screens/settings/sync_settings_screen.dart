import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/sync_service.dart';

class SyncSettingsScreen extends StatelessWidget {
  const SyncSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Sync Settings'),
      ),
      body: Consumer<SyncService>(
        builder: (context, syncService, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Sync Enable/Disable Switch
              SwitchListTile(
                title: const Text('Google Drive Sync'),
                subtitle: Text(syncService.isEnabled 
                  ? 'Sync enabled - Last sync: ${_formatDate(syncService.lastSyncTime)}'
                  : 'Sync disabled - Using local storage only'),
                value: syncService.isEnabled,
                onChanged: (bool value) => _toggleSync(context, syncService, value),
              ),
              
              const Divider(),
              
              // Sync Status
              if (syncService.isEnabled) ...[
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: Text(syncService.currentAccount ?? 'Not signed in'),
                  subtitle: const Text('Google Account'),
                ),
                
                ListTile(
                  leading: const Icon(Icons.sync),
                  title: Text(syncService.isSyncing 
                    ? 'Syncing...' 
                    : syncService.hasPendingChanges
                      ? 'Changes pending...'
                      : 'Last synced: ${_formatDate(syncService.lastSyncTime)}'),
                  trailing: syncService.isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : syncService.hasPendingChanges
                      ? const Icon(Icons.sync_problem, color: Colors.orange)
                      : const Icon(Icons.check_circle, color: Colors.green),
                ),
                
                // Manual Sync Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: syncService.isSyncing
                      ? null
                      : () => _manualSync(context, syncService),
                    child: Text(syncService.hasPendingChanges 
                      ? 'Sync Now (Changes Pending)'
                      : 'Sync Now'),
                  ),
                ),
                
                // Auto-sync Info
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Changes are automatically synced after a short delay. '
                    'You can also tap "Sync Now" to sync immediately.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
                
                // Remove Cloud Data Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextButton(
                    onPressed: () => _removeCloudData(context, syncService),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: const Text('Remove Cloud Data'),
                  ),
                ),
              ],
              
              // Help Text
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Enable Google Drive sync to backup your characters and access them '
                  'on other devices. Your data remains primarily stored on this device '
                  'and will continue to work without an internet connection.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Never';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  Future<void> _toggleSync(
    BuildContext context, 
    SyncService syncService, 
    bool enable
  ) async {
    try {
      if (enable) {
        print('\n=== Attempting to enable sync ===');
        await syncService.enableSync();
        print('✓ Sync enabled successfully');
      } else {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Disable Sync?'),
            content: const Text(
              'Disabling sync will stop syncing with Google Drive. '
              'Your local data will be kept, but changes won\'t be '
              'synced until you enable sync again.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Disable Sync'),
              ),
            ],
          ),
        );
        
        if (confirm == true) {
          await syncService.disableSync();
        }
      }
    } catch (e, stackTrace) {
      print('\n=== Sync Settings Screen Error ===');
      print('Error occurred while ${enable ? 'enabling' : 'disabling'} sync:');
      print('Error type: ${e.runtimeType}');
      print('Error details: $e');
      print('Stack trace:');
      print(stackTrace);
      print('===============================\n');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _manualSync(BuildContext context, SyncService syncService) async {
    try {
      await syncService.syncNow();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync completed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _removeCloudData(
    BuildContext context, 
    SyncService syncService
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Cloud Data?'),
        content: const Text(
          'This will remove all your data from Google Drive but keep '
          'your local data intact. This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await syncService.removeCloudData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cloud data removed')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
} 