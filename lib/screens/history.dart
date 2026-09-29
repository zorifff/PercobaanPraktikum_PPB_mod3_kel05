import 'package:flutter/material.dart';
import '../services/history_manager.dart';
import 'detail.dart';
import 'home.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua Riwayat'),
        content: const Text(
          'Apakah kamu yakin ingin menghapus semua riwayat kunjungan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              HistoryManager.instance.clearHistory();
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteItem(BuildContext context, Country country) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Riwayat'),
        content: Text('Hapus "${country.name}" dari riwayat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              HistoryManager.instance.removeHistory(country);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyManager = HistoryManager.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          ListenableBuilder(
            listenable: historyManager,
            builder: (context, child) {
              if (historyManager.historyList.isEmpty) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Hapus Semua Riwayat',
                onPressed: () => _confirmClearAll(context),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: historyManager,
        builder: (context, child) {
          final history = historyManager.historyList;

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat kunjungan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kunjungi halaman detail negara untuk menyimpan riwayat',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              final Country country = entry['country'];
              final DateTime visitedAt = entry['visitedAt'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: country.flagsPng != null
                      ? Image.network(
                          country.flagsPng!,
                          width: 50,
                          errorBuilder: (context, error, stackTrace) {
                            if (country.alpha2Code != null &&
                                country.alpha2Code!.isNotEmpty) {
                              return Image.network(
                                'https://flagcdn.com/w320/${country.alpha2Code!.toLowerCase()}.png',
                                width: 50,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.flag, size: 50),
                              );
                            }
                            return const Icon(Icons.flag, size: 50);
                          },
                        )
                      : const SizedBox(width: 50),
                  title: Text(country.name),
                  subtitle: Text('${country.region} · ${_formatDate(visitedAt)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Hapus dari riwayat',
                    onPressed: () => _confirmDeleteItem(context, country),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(country: country),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
