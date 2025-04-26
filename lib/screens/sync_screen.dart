import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import '../services/sync_service.dart';
import '../repositories/google_drive_character_repository.dart';

class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Settings'),
      ),
      body: Consumer<SyncService>(
        builder: (context, syncService, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSyncStatus(syncService),
                const SizedBox(height: 16),
                _buildSyncControls(syncService),
                const SizedBox(height: 16),
                _buildLastSyncInfo(syncService),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSyncStatus(SyncService syncService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  syncService.isEnabled ? Icons.cloud_done : Icons.cloud_off,
                  color: syncService.isEnabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  syncService.isEnabled ? 'Enabled' : 'Disabled',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            if (syncService.isEnabled) ...[
              const SizedBox(height: 8),
              Text(
                'Account: ${syncService.currentAccount ?? 'Unknown'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSyncControls(SyncService syncService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Controls',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (syncService.isEnabled)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: syncService.isSyncing
                        ? null
                        : () async {
                            try {
                              await syncService.syncNow();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Sync completed successfully'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Sync failed: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    child: syncService.isSyncing
                        ? const CircularProgressIndicator()
                        : const Text('Sync Now'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: syncService.isSyncing
                        ? null
                        : () async {
                            try {
                              await syncService.removeCloudData();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Cloud data removed successfully'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to remove cloud data: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Remove Cloud Data'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: syncService.isSyncing
                        ? null
                        : () async {
                            try {
                              await syncService.disableSync();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Sync disabled successfully'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to disable sync: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    child: const Text('Disable Sync'),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: syncService.isSyncing
                    ? null
                    : () async {
                        try {
                          await syncService.enableSync();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sync enabled successfully'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to enable sync: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                child: syncService.isSyncing
                    ? const CircularProgressIndicator()
                    : const Text('Enable Sync'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastSyncInfo(SyncService syncService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Sync',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              syncService.lastSyncTime != null
                  ? 'Last synced: ${syncService.lastSyncTime!.toString()}'
                  : 'Never synced',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (syncService.hasPendingChanges) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ Changes pending sync',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.orange,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 