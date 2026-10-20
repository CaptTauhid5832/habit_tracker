import 'dart:convert';
import 'package:http/http.dart' as http;

/// REST Countries API. The /all endpoint requires a `fields` parameter.
const String _countriesUrl =
    'https://restcountries.com/v3.1/all?fields=name,capital,region,population,flag';

/// One country returned by the API.
class Country {
  final String name;
  final String capital;
  final String region;
  final int population;
  final String flag;

  Country({
    required this.name,
    required this.capital,
    required this.region,
    required this.population,
    required this.flag,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    final capitals = json['capital'] as List<dynamic>? ?? [];
    return Country(
      name: json['name']?['common'] as String? ?? 'Unknown',
      capital: capitals.isNotEmpty ? capitals.first.toString() : 'N/A',
      region: json['region'] as String? ?? 'N/A',
      population: (json['population'] as num?)?.toInt() ?? 0,
      flag: json['flag'] as String? ?? '',
    );
  }
}

/// Fetches full country details from the API, sorted by name.
Future<List<Country>> fetchCountryDetails() async {
  final response = await http.get(Uri.parse(_countriesUrl));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    final countries = data
        .map((item) => Country.fromJson(item as Map<String, dynamic>))
        .toList();
    countries.sort((a, b) => a.name.compareTo(b.name));
    return countries;
  } else {
    throw Exception('Failed to load countries (status ${response.statusCode})');
  }
}

/// Fetches just the country names (used by the Personal Info dropdown).
Future<List<String>> fetchCountries() async {
  final countries = await fetchCountryDetails();
  return countries.map((c) => c.name).toList();
}
