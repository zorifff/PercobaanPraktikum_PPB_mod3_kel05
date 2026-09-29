import 'package:flutter/material.dart';
import '../services/favorite_manager.dart';
import 'detail.dart';
import 'home.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  void _confirmRemove(BuildContext context, Country country) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Favorit'),
        content: Text('Hapus "${country.name}" dari favorit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              FavoriteManager.instance.removeFavorite(country);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${country.name} dihapus dari favorit'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua Favorit'),
        content: const Text(
          'Apakah kamu yakin ingin menghapus semua negara favorit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final manager = FavoriteManager.instance;
              final favorites =
                  List.from(manager.favoriteCountries);
              for (final c in favorites) {
                manager.removeFavorite(c);
              }
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteManager = FavoriteManager.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit'),
        actions: [
          ListenableBuilder(
            listenable: favoriteManager,
            builder: (context, child) {
              if (favoriteManager.favoriteCountries.isEmpty) {
                return const SizedBox();
              }
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Hapus Semua Favorit',
                onPressed: () => _confirmClearAll(context),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: favoriteManager,
        builder: (context, child) {
          final favorites = favoriteManager.favoriteCountries;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada negara favorit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tambahkan negara ke favorit dari halaman detail',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final Country country = favorites[index];
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
                  subtitle: Text(country.region),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Hapus dari favorit',
                    onPressed: () => _confirmRemove(context, country),
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
