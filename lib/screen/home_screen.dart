import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:tsena/utility/large_button.dart';
import 'package:tsena/utility/textformfield.dart';
import 'package:tsena/screen/loading_screen.dart';
import 'package:tsena/screen/nodata_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _allResults = [];
  List<dynamic> _visibleResults = [];
  List<dynamic> _selectedItems = [];

  bool _isLoading = false;
  int _visibleCount = 10;

  String getRealUrl(String link) {
    try {
      Uri uri = Uri.parse(link);
      if (uri.host.contains('google.com') && uri.queryParameters.containsKey('q')) {
        return uri.queryParameters['q']!.toLowerCase();
      }
      return link.toLowerCase();
    } catch (_) {
      return link.toLowerCase();
    }
  }

  Future<void> searchProduct(String query) async {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('What are you searching?')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _allResults.clear();
      _visibleResults.clear();
      _selectedItems.clear();
      _visibleCount = 10;
    });

    final url = Uri.parse('https://pricer.p.rapidapi.com/str?q=$query');
    try {
      final response = await http.get(
        url,
        headers: {
          'x-rapidapi-host': 'pricer.p.rapidapi.com',
          'x-rapidapi-key': dotenv.env['token'] ?? '',
        },
      );

      if (response.statusCode != 200) {
        setState(() => _isLoading = false);
        return;
      }

      List<dynamic> data = jsonDecode(response.body);
      final allowedDomains = [
        '.in', '.com', 'flipkart', 'amazon.in', 'amazon.com', 'tatacliq',
        'reliance', 'croma', 'paytmmall', 'myntra', 'ajio', 'snapdeal', 'shopclues',
      ];

      data = data.where((item) {
        final rawLink = getRealUrl((item['link'] ?? '').toString());
        final shop = (item['shop'] ?? '').toString().toLowerCase();
        return allowedDomains.any((domain) => rawLink.contains(domain) || shop.contains(domain));
      }).toList();

      const double usdToInrRate = 83.0;
      for (var item in data) {
        final rawPrice = item['price'] ?? '';
        final usdPrice = double.tryParse(rawPrice.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
        final inrPrice = (usdPrice * usdToInrRate).round();
        item['price'] = '₹$inrPrice';
      }

      data.sort((a, b) {
        final aPrice = double.tryParse(a['price'].replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
        final bPrice = double.tryParse(b['price'].replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
        return aPrice.compareTo(bPrice);
      });

      setState(() {
        _allResults = data;
        _visibleResults = _allResults.take(_visibleCount).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _loadMore() {
    setState(() {
      _visibleCount += 10;
      _visibleResults = _allResults.take(_visibleCount).toList();
    });
  }

  void _toggleSelection(item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  void _showAIComparisonPopup() {
    final prompt = "Compare these products: " +
        _selectedItems.map((e) => e['title']).join(', ');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.psychology, size: 28, color: Colors.deepOrange),
                    SizedBox(width: 8),
                    Text("AI Comparison",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(),
                RealAIComparison(prompt),
              ],
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B5998),
      floatingActionButton: _selectedItems.length >= 2
          ? Padding(
        padding: const EdgeInsets.only(bottom: 70.0), // 👈 Prevents overlap
        child: FloatingActionButton(
          onPressed: _showAIComparisonPopup,
          backgroundColor: Colors.black87,
          child: const Icon(Icons.auto_awesome, color: Colors.white), // Gemini-like icon
          tooltip: 'Compare with AI',
        ),
      )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.compare_rounded, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        'Deal Hunt AI',
                        style: GoogleFonts.inter(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  MyTextFormField(
                    labelText: 'Item name',
                    icon: Icons.search_rounded,
                    obscureText: false,
                    controller: _searchController,
                  ),
                  const SizedBox(height: 25),
                  LargeButton(
                    icon: Icons.shopping_cart_rounded,
                    text: 'Search Item',
                    function: () => searchProduct(_searchController.text),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: _isLoading
                    ? const Center(child: LoadingScreen())
                    : _visibleResults.isEmpty
                    ? const Center(child: NodataScreen())
                    : Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _visibleResults.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.52,
                        ),
                        itemBuilder: (context, index) {
                          final item = _visibleResults[index];
                          final isSelected = _selectedItems.contains(item);

                          return GestureDetector(
                            onTap: () => _toggleSelection(item),
                            child: Stack(
                              children: [
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 120,
                                          width: double.infinity,
                                          child: Image.network(
                                            item['img'] ?? '',
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.image, size: 60),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item['title'] ?? 'No title',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        Text(
                                          item['price'] ?? 'N/A',
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          item['shop']?.replaceFirst('from ', '') ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          item['shipping'] ?? 'No shipping info',
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 4),
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            final url = item['link'];
                                            if (url != null && await canLaunchUrl(Uri.parse(url))) {
                                              await launchUrl(Uri.parse(url),
                                                  mode: LaunchMode.externalApplication);
                                            }
                                          },
                                          icon: const Icon(Icons.shopping_cart, size: 16),
                                          label: const Text('Buy Now'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange.shade700,
                                            minimumSize: const Size(double.infinity, 36),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    backgroundColor:
                                    isSelected ? Colors.green : Colors.grey.shade300,
                                    radius: 14,
                                    child: Icon(
                                      isSelected ? Icons.check : Icons.add,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    if (_visibleResults.length < _allResults.length)
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ElevatedButton.icon(
                          onPressed: _loadMore,
                          icon: const Icon(Icons.expand_more),
                          label: const Text('Load More'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class RealAIComparison extends StatefulWidget {
  final String prompt;
  const RealAIComparison(this.prompt, {super.key});

  @override
  State<RealAIComparison> createState() => _RealAIComparisonState();
}

class _RealAIComparisonState extends State<RealAIComparison> {
  String _response = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getAIResponse();
  }

  Future<void> getAIResponse() async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=${dotenv.env['GEMINI_API_KEY']}',
    );

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "contents": [
        {"parts": [{"text": widget.prompt}]}
      ]
    });

    try {
      final resp = await http.post(uri, headers: headers, body: body);
      final data = jsonDecode(resp.body);

      if (resp.statusCode == 200) {
        final reply = data['candidates'][0]['content']['parts'][0]['text'];
        setState(() {
          _response = reply.trim();
          _isLoading = false;
        });
      } else {
        setState(() {
          _response = '❌ Failed: ${data['error']['message']}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _response = '⚠️ Error: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildChatBubble(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 14, height: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🤖 AI Recommendation",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildChatBubble(_response),
          ],
        ),
      ),
    );
  }
}
