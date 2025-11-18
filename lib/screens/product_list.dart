import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:cihuy_united/models/product_entry.dart';
import 'package:cihuy_united/widgets/left_drawer.dart';
import 'package:cihuy_united/widgets/product_card.dart';
import 'package:cihuy_united/screens/product_detail.dart';
import 'package:cihuy_united/user_session.dart';

// Inline base URL (removed config.dart)
const String _baseUrl = 'http://localhost:8000';

class ProductListPage extends StatefulWidget {
  final bool all; // true = show all products, false = only user-owned
  const ProductListPage({super.key, this.all = false});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  Future<List<ProductEntry>> fetchProducts(CookieRequest request) async {
    List<dynamic> response = [];
    // Try chosen endpoint, fallback if "all" endpoint fails (404 or other)
    final endpoint = widget.all ? '$_baseUrl/json/all/' : '$_baseUrl/json/';
    try {
      response = await request.get(endpoint);
    } catch (e) {
      if (widget.all) {
        // Fallback to regular endpoint
        try {
          response = await request.get('$_baseUrl/json/');
        } catch (_) {
          rethrow; // propagate original error if fallback also fails
        }
      } else {
        rethrow;
      }
    }

    final List<ProductEntry> listProduct = [];
    for (var d in response) {
      if (d != null) {
        listProduct.add(ProductEntry.fromJson(d));
      }
    }

    // If showing "My Products", filter by current username if available.
    if (!widget.all) {
      final currentUsername = UserSession.username;
      if (currentUsername != null && currentUsername.isNotEmpty) {
        listProduct.retainWhere((p) => p.user == currentUsername);
      }
    }

    return listProduct;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      backgroundColor: const Color(0xFF1A252F), // Dark background like Django
      appBar: AppBar(
        title: Text(widget.all ? 'All Products' : 'My Products'),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder<List<ProductEntry>>(
        future: fetchProducts(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load products',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No products yet.',
                    style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start by adding your first product!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, index) => ProductCard(
              product: items[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetailPage(product: items[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
