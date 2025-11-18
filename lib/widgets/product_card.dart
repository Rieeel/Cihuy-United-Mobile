import 'package:flutter/material.dart';
import 'package:cihuy_united/models/product_entry.dart';

const String _baseUrl = 'http://localhost:8000';

class ProductCard extends StatelessWidget {
  final ProductEntry product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: const Color(0xFF2C3E50), // Dark blue like Django
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name header
            Container(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // Featured badge and metadata
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  if (product.isFeatured)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Featured',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  // Date
                  Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    '16 Nov 2025 09:57',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                  const SizedBox(width: 12),
                  // Views
                  Icon(Icons.visibility, size: 12, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    '${product.views}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
              ),
              child: (product.thumbnail.isNotEmpty)
                  ? Image.network(
                      _buildImageUrl(product.thumbnail),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 180,
                          color: const Color(0xFF34495E),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: const Color(0xFF34495E),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      height: 180,
                      width: double.infinity,
                      color: const Color(0xFF34495E),
                      child: const Center(
                        child: Icon(Icons.image, color: Colors.white54),
                      ),
                    ),
            ),

            // Product info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Text(
                    'Rp ${product.price}',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Stock
                  Text(
                    'Stock: ${product.stock}',
                    style: TextStyle(fontSize: 13.0, color: Colors.grey[300]),
                  ),
                  const SizedBox(height: 8),

                  // Description preview
                  Text(
                    product.description.length > 80
                        ? '${product.description.substring(0, 80)}...'
                        : product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.0, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 12),

                  // Read More button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498DB), // Blue button
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Read More',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
