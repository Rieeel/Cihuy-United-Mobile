import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:cihuy_united/screens/menu.dart';
import 'package:cihuy_united/models/product_entry.dart';

// Inline base URL (remove config.dart usage)
const String _baseUrl = 'http://localhost:8000';

class ProductFormPage extends StatefulWidget {
  final ProductEntry? product; // For edit mode

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  int _price = 0;
  String _description = "";
  String _thumbnail = "";
  String _category = "";
  bool _isFeatured = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill form if editing
    if (widget.product != null) {
      _name = widget.product!.name;
      _price = widget.product!.price;
      _description = widget.product!.description;
      _thumbnail = widget.product!.thumbnail;
      _category = widget.product!.category;
      _isFeatured = widget.product!.isFeatured;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isEditing = widget.product != null;

    return Scaffold(
      backgroundColor: const Color(0xFF1A252F),
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: const Color(0xFF2C3E50),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: _name,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFF34495E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _name = value ?? "";
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Name cannot be empty!";
                      }
                      if (value.length < 5) {
                        return "Name must be at least 5 characters!";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _price > 0 ? _price.toString() : "",
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Price",
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      prefixText: "Rp ",
                      prefixStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: const Color(0xFF34495E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (String? value) {
                      setState(() {
                        _price = int.tryParse(value ?? "") ?? 0;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Price cannot be empty!";
                      }
                      if (int.tryParse(value) == null) {
                        return "Price must be a number!";
                      }
                      if (int.parse(value) <= 0) {
                        return "Price must be positive!";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _description,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Description",
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFF34495E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: 4,
                    onChanged: (String? value) {
                      setState(() {
                        _description = value ?? "";
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Description cannot be empty!";
                      }
                      if (value.length < 10) {
                        return "Description must be at least 10 characters!";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _thumbnail,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Thumbnail URL",
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFF34495E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _thumbnail = value ?? "";
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Thumbnail URL cannot be empty!";
                      }
                      bool isValidUrl =
                          Uri.tryParse(value)?.isAbsolute ?? false;
                      if (!isValidUrl) {
                        return "Please enter a valid URL!";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _category,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Category",
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFF34495E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _category = value ?? "";
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Category cannot be empty!";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF34495E),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        "Featured Product",
                        style: TextStyle(color: Colors.white),
                      ),
                      value: _isFeatured,
                      activeColor: const Color(0xFF3498DB),
                      onChanged: (bool value) {
                        setState(() {
                          _isFeatured = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498DB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final url = isEditing
                              ? "$_baseUrl/edit-flutter/${widget.product!.id}/"
                              : "$_baseUrl/create-flutter/";

                          final response = await request.postJson(
                            url,
                            jsonEncode({
                              "name": _name,
                              "price": _price,
                              "description": _description,
                              "thumbnail": _thumbnail,
                              "category": _category,
                              "is_featured": _isFeatured,
                            }),
                          );
                          if (context.mounted) {
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEditing
                                        ? "Product successfully updated!"
                                        : "Product successfully saved!",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MenuPage(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Something went wrong, please try again.",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: Text(
                        isEditing ? "Update Product" : "Save Product",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
