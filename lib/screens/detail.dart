import 'package:flutter/material.dart';
import '../services/favorite_manager.dart';
import '../services/history_manager.dart';
import 'home.dart';

class DetailPage extends StatefulWidget {
  final Country country;
  const DetailPage({super.key, required this.country});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  void initState() {
    super.initState();
    // Catat riwayat saat halaman detail dibuka
    HistoryManager.instance.addHistory(widget.country);
  }

  @override
  Widget build(BuildContext context) {
    final favoriteManager = FavoriteManager.instance;
    final country = widget.country;

    return Scaffold(
      appBar: AppBar(
        title: Text(country.name),
        actions: [
          ListenableBuilder(
            listenable: favoriteManager,
            builder: (context, child) {
              final isFav = favoriteManager.isFavorite(country);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : null,
                ),
                tooltip: isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                onPressed: () {
                  favoriteManager.toggleFavorite(country);
                  final message = isFav
                      ? '${country.name} dihapus dari favorit'
                      : '${country.name} ditambahkan ke favorit';
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (country.flagsPng != null)
              Center(
                child: Image.network(
                  country.flagsPng!,
                  width: 200,
                  errorBuilder: (context, error, stackTrace) {
                    if (country.alpha2Code != null &&
                        country.alpha2Code!.isNotEmpty) {
                      return Image.network(
                        'https://flagcdn.com/w320/${country.alpha2Code!.toLowerCase()}.png',
                        width: 200,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.flag, size: 100),
                      );
                    }
                    return const Icon(Icons.flag, size: 100);
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text('Name: ${country.name}', style: const TextStyle(fontSize: 18)),
            Text(
              'Capital: ${country.capital ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Region: ${country.region}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Population: ${country.population}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Languages: ${country.languages?.join(', ') ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Currencies: ${country.currencies?.join(', ') ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
