import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Country>> countries;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedContinent = 'Semua';

  // Daftar benua yang tersedia
  static const List<String> _continents = [
    'Semua',
    'Africa',
    'Americas',
    'Asia',
    'Europe',
    'Oceania',
    'Polar',
  ];

  @override
  void initState() {
    super.initState();
    countries = fetchCountries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Country>> fetchCountries() async {
    final uri = Uri.parse('https://www.apicountries.com/countries');
    final request = await HttpClient().getUrl(uri);
    final response = await request.close();
    if (response.statusCode == 200) {
      final respBody = await response.transform(utf8.decoder).join();
      final List jsonData = jsonDecode(respBody);
      return jsonData.map((j) => Country.fromJson(j)).toList();
    } else {
      throw Exception('Failed to load countries: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countries')),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari negara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filter berdasarkan benua
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _continents.length,
              itemBuilder: (context, index) {
                final continent = _continents[index];
                final isSelected = _selectedContinent == continent;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(continent),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedContinent = continent;
                      });
                    },
                    selectedColor: const Color.fromARGB(255, 98, 160, 240),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    checkmarkColor: Colors.white,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 6),

          Expanded(
            child: FutureBuilder<List<Country>>(
              future: countries,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No countries found'));
                }

                final list = snapshot.data!;
                final filteredList = list.where((country) {
                  final query = _searchQuery.toLowerCase();
                  final nameMatch = country.name.toLowerCase().contains(query);
                  final regionMatch =
                      country.region.toLowerCase().contains(query);
                  final capitalMatch = country.capital != null &&
                      country.capital!.toLowerCase().contains(query);
                  final searchOk = nameMatch || regionMatch || capitalMatch;

                  // Filter benua
                  final continentOk = _selectedContinent == 'Semua' ||
                      country.region == _selectedContinent;

                  return searchOk && continentOk;
                }).toList();

                if (filteredList.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada negara yang ditemukan',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, i) {
                    final country = filteredList[i];
                    return Card(
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
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.flag, size: 50),
                                    );
                                  }
                                  return const Icon(Icons.flag, size: 50);
                                },
                              )
                            : const SizedBox(width: 50),
                        title: Text(country.name),
                        subtitle: Text(country.region),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailPage(country: country),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Country {
  final String name;
  final String region;
  final String? capital;
  final int population;
  final String? flagsPng;
  final String? alpha2Code;
  final List<dynamic>? languages;
  final List<dynamic>? currencies;

  Country({
    required this.name,
    required this.region,
    required this.population,
    this.capital,
    this.flagsPng,
    this.alpha2Code,
    this.languages,
    this.currencies,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    List<dynamic>? langs;
    if (json['languages'] != null) {
      langs = (json['languages'] as List)
          .map((l) => l['name'].toString())
          .toList();
    }
    List<dynamic>? cur;
    if (json['currencies'] != null) {
      cur = (json['currencies'] as List)
          .map((c) => c['name'].toString())
          .toList();
    }
    return Country(
      name: json['name'] ?? 'N/A',
      region: json['region'] ?? 'N/A',
      population: json['population'] ?? 0,
      capital: json['capital'],
      flagsPng: json['flags'] != null ? json['flags']['png'] : null,
      alpha2Code: json['alpha2Code'],
      languages: langs,
      currencies: cur,
    );
  }
}