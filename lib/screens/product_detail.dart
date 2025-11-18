import 'package:flutter/material.dart';
import 'package:cihuy_united/models/product_entry.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:cihuy_united/user_session.dart';
import 'package:cihuy_united/screens/product_form.dart';
import 'package:cihuy_united/screens/product_list.dart';

const String _baseUrl = 'http://localhost:8000';

class ProductDetailPage extends StatefulWidget {
  final ProductEntry product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String _buildImageUrl(String thumbnail) {
    if (thumbnail.isEmpty) return '';
    // If already a complete URL
    if (thumbnail.startsWith('http://') || thumbnail.startsWith('https://')) {
      return thumbnail;
    }
    // If relative path (e.g., /media/...)
    if (thumbnail.startsWith('/')) {
      return '$_baseUrl$thumbnail';
    }
    // Otherwise assume it needs base URL
    return '$_baseUrl/$thumbnail';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}, '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _deleteProduct(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C3E50),
        title: const Text(
          'Delete Product',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this product?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!context.mounted) return;
    final request = context.read<CookieRequest>();

    try {
      final response = await request.postJson(
        "$_baseUrl/delete-flutter/${widget.product.id}/",
        '{}',
      );

      if (!context.mounted) return;

      // Check if response is valid and has success status
      if (response is Map && response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully!')),
        );
        // Navigate back to product list
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProductListPage()),
        );
      } else {
        // Show error - endpoint might not exist or returned HTML
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Delete endpoint not configured in Django. Please add delete-flutter endpoint.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      // More helpful error message
      String errorMessage = 'Error deleting product';
      if (e.toString().contains('<!DOCTYPE') ||
          e.toString().contains('SyntaxError') ||
          e.toString().contains('Unexpected token')) {
        errorMessage =
            'Django endpoint /delete-flutter/${widget.product.id}/ not found. '
            'Please create the endpoint in Django first.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.product.user == UserSession.username;

    return Scaffold(
      backgroundColor: const Color(0xFF1A252F),
      appBar: AppBar(
        title: const Text('Product Detail'),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        actions: isOwner
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductFormPage(product: widget.product),
                      ),
                    );
                  },
                  tooltip: 'Edit Product',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteProduct(context),
                  tooltip: 'Delete Product',
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail image
            if (widget.product.thumbnail.isNotEmpty)
              Image.network(
                _buildImageUrl(widget.product.thumbnail),
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 250,
                    color: const Color(0xFF34495E),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3498DB),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: const Color(0xFF34495E),
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            // Product info card
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured badge
                  if (widget.product.isFeatured)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6.0,
                      ),
                      margin: const EdgeInsets.only(bottom: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.star, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Featured',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Name
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Text(
                    'Rp ${widget.product.price}',
                    style: const TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3498DB),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category and Stock
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF34495E),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          widget.product.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: widget.product.stock > 0
                              ? Colors.green[700]
                              : Colors.red[700],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          'Stock: ${widget.product.stock}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Created at and Views
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(widget.product.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.visibility, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.product.views} views',
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Seller info
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        'Seller: ${widget.product.user}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),

                  const Divider(height: 32, color: Color(0xFF34495E)),

                  // Description title
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Full description
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 16.0,
                      height: 1.6,
                      color: Colors.grey[300],
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),

                  // Back button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Product List'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        backgroundColor: const Color(0xFF3498DB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
