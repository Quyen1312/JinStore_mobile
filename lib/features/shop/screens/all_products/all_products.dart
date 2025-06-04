import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/appbar/appbar.dart';
import 'package:flutter_application_jin/common/widgets/layouts/grid_layout.dart';
import 'package:flutter_application_jin/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:flutter_application_jin/common/widgets/shimmer/vertical_product_shimmer.dart';
import 'package:flutter_application_jin/features/shop/controllers/product_controller.dart';
import 'package:flutter_application_jin/features/shop/models/product_model.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:get/get.dart';

class AllProductScreen extends StatefulWidget {
  final String title;
  final String? categoryId;
  final List<ProductModel>? products;
  final VoidCallback? onRetry;

  const AllProductScreen({
    super.key,
    required this.title,
    this.categoryId,
    this.products,
    this.onRetry,
  });

  @override
  State<AllProductScreen> createState() => _AllProductScreenState();
}

class _AllProductScreenState extends State<AllProductScreen> {
  late final ProductController productController;
  bool isInitialized = false;
  String _sortBy = 'name'; // Default sort
  List<String> _activeFilters = [];

  @override
  void initState() {
    super.initState();
    productController = Get.find<ProductController>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  /// Load data based on screen type
  Future<void> _loadData() async {
    if (isInitialized) return;
    
    try {
      if (widget.categoryId != null) {
        print('🔍 Loading products for category: ${widget.categoryId}');
        await productController.fetchProductsByCategoryId(widget.categoryId!);
      } else if (widget.products == null) {
        print('🔍 Loading all products');
        await productController.fetchAllProducts();
      }
      
      setState(() {
        isInitialized = true;
      });
    } catch (e) {
      print('❌ Error loading data: $e');
      setState(() {
        isInitialized = true;
      });
    }
  }

  /// Retry loading data
  Future<void> _retry() async {
    setState(() {
      isInitialized = false;
    });
    
    if (widget.onRetry != null) {
      widget.onRetry!();
    } else {
      await _loadData();
    }
  }

  /// Get products to display based on screen type
  List<ProductModel> _getProductsToDisplay() {
    List<ProductModel> products;
    
    if (widget.products != null) {
      products = widget.products!;
    } else if (widget.categoryId != null) {
      products = productController.productsByCategory;
    } else {
      products = productController.allProducts;
    }

    // Apply filters
    products = _applyFilters(products);
    
    // Apply sorting
    products = _applySorting(products);
    
    return products;
  }

  /// Apply filters to products
  List<ProductModel> _applyFilters(List<ProductModel> products) {
    List<ProductModel> filteredProducts = List.from(products);
    
    for (String filter in _activeFilters) {
      switch (filter) {
        case 'in_stock':
          filteredProducts = filteredProducts.where((p) => p.quantity > 0).toList();
          break;
        case 'on_sale':
          filteredProducts = filteredProducts.where((p) => p.discount > 0).toList();
          break;
        case 'price_low':
          filteredProducts = filteredProducts.where((p) => p.price <= 100000).toList();
          break;
        case 'price_medium':
          filteredProducts = filteredProducts.where((p) => p.price > 100000 && p.price <= 500000).toList();
          break;
        case 'price_high':
          filteredProducts = filteredProducts.where((p) => p.price > 500000).toList();
          break;
      }
    }
    
    return filteredProducts;
  }

  /// Apply sorting to products
  List<ProductModel> _applySorting(List<ProductModel> products) {
    List<ProductModel> sortedProducts = List.from(products);
    
    switch (_sortBy) {
      case 'name':
        sortedProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price_low_high':
        sortedProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high_low':
        sortedProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'discount':
        sortedProducts.sort((a, b) => b.discount.compareTo(a.discount));
        break;
      case 'newest':
        sortedProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    
    return sortedProducts;
  }

  /// Get loading state based on screen type
  bool _isLoading() {
    if (widget.products != null) {
      return false;
    } else if (widget.categoryId != null) {
      return productController.isLoadingCategoryProducts.value;
    } else {
      return productController.isLoadingAllProducts.value;
    }
  }

  /// Build product grid with improved spacing for new card design
  Widget _buildProductGrid(List<ProductModel> products) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.categoryId != null 
                  ? Icons.category_outlined 
                  : Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              widget.categoryId != null 
                  ? 'Danh mục trống'
                  : 'Không có sản phẩm nào',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateMessage(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.grey),
            ),
            if (_shouldShowActionButton()) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _getActionButtonCallback(),
                child: Text(_getActionButtonText()),
              ),
            ],
          ],
        ),
      );
    }

    return GridLayout(
      itemCount: products.length,
      itemBuilder: (_, index) => ProductCardVertical(
        product: products[index],
      ),
    );
  }

  /// Get appropriate empty state message based on context
  String _getEmptyStateMessage() {
    if (widget.categoryId != null) {
      // Category-specific empty state
      if (!isInitialized || _isLoading()) {
        return 'Đang tải sản phẩm...';
      }
      return 'Danh mục "${widget.title}" hiện chưa có sản phẩm nào.\nVui lòng quay lại sau hoặc khám phá danh mục khác.';
    }
    
    if (_activeFilters.isNotEmpty) {
      return 'Không có sản phẩm nào phù hợp với bộ lọc hiện tại.\nThử điều chỉnh hoặc xóa bộ lọc để xem thêm sản phẩm.';
    }
    
    return 'Hiện tại chưa có sản phẩm nào để hiển thị.\nVui lòng thử tải lại trang.';
  }

  /// Determine if action button should be shown
  bool _shouldShowActionButton() {
    if (widget.categoryId != null) {
      // For category pages, show "Browse all products" button
      return isInitialized;
    }
    
    if (_activeFilters.isNotEmpty) {
      // Show clear filters button
      return true;
    }
    
    // Show retry button for general errors
    return true;
  }

  /// Get action button callback
  VoidCallback _getActionButtonCallback() {
    if (widget.categoryId != null && isInitialized) {
      // Navigate to all products
      return () {
        Get.toNamed('/all-products', arguments: {
          'title': 'Tất cả sản phẩm'
        });
      };
    }
    
    if (_activeFilters.isNotEmpty) {
      // Clear filters
      return _clearFilters;
    }
    
    // Retry loading
    return _retry;
  }

  /// Get action button text
  String _getActionButtonText() {
    if (widget.categoryId != null && isInitialized) {
      return 'Xem tất cả sản phẩm';
    }
    
    if (_activeFilters.isNotEmpty) {
      return 'Xóa bộ lọc';
    }
    
    return 'Tải lại';
  }

  /// Clear all filters
  void _clearFilters() {
    setState(() {
      _activeFilters.clear();
    });
  }

  /// Build error widget
  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Lỗi tải dữ liệu',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _retry,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build filter chips
  Widget _buildFilterChips() {
    if (_activeFilters.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _activeFilters.length + 1, // +1 for clear all button
        itemBuilder: (context, index) {
          if (index == _activeFilters.length) {
            // Clear all button
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: const Text('Xóa tất cả'),
                onPressed: _clearFilters,
                backgroundColor: AppColors.error.withOpacity(0.1),
                labelStyle: const TextStyle(color: AppColors.error),
              ),
            );
          }
          
          final filter = _activeFilters[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getFilterDisplayName(filter)),
              selected: true,
              onSelected: (selected) {
                setState(() {
                  _activeFilters.remove(filter);
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.1),
              checkmarkColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  /// Get display name for filter
  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'in_stock': return 'Còn hàng';
      case 'on_sale': return 'Đang giảm giá';
      case 'price_low': return 'Dưới 100k';
      case 'price_medium': return '100k - 500k';
      case 'price_high': return 'Trên 500k';
      default: return filter;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbar(
        title: Text(
          widget.title, 
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _retry,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _retry,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.defaultSpace),
            child: Column(
              children: [
                // Header with product count and controls
                Obx(() {
                  final products = _getProductsToDisplay();
                  final isLoading = _isLoading();
                  
                  if (!isLoading && (products.isNotEmpty || _activeFilters.isNotEmpty)) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${products.length} sản phẩm',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                // Sort button
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.sort, color: AppColors.primary),
                                    onPressed: _showSortOptions,
                                    tooltip: 'Sắp xếp',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Filter button
                                Container(
                                  decoration: BoxDecoration(
                                    color: _activeFilters.isNotEmpty 
                                        ? AppColors.primary 
                                        : AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.filter_list, 
                                      color: _activeFilters.isNotEmpty 
                                          ? Colors.white 
                                          : AppColors.primary,
                                    ),
                                    onPressed: _showFilterOptions,
                                    tooltip: 'Bộ lọc',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildFilterChips(),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),
                
                // Main content
                Obx(() {
                  final products = _getProductsToDisplay();
                  final isLoading = _isLoading();
                  final error = productController.error.value;

                  // Show loading
                  if (!isInitialized || (isLoading && products.isEmpty)) {
                    return const VerticalProductShimmer(itemCount: 6);
                  }

                  // Show error
                  if (error.isNotEmpty && products.isEmpty) {
                    return _buildErrorWidget(error);
                  }

                  // Show products
                  return _buildProductGrid(products);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show sort options
  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sắp xếp theo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildSortOption('name', 'Tên A-Z', Icons.sort_by_alpha),
            _buildSortOption('price_low_high', 'Giá thấp đến cao', Icons.trending_up),
            _buildSortOption('price_high_low', 'Giá cao đến thấp', Icons.trending_down),
            _buildSortOption('discount', 'Giảm giá nhiều nhất', Icons.local_offer),
            _buildSortOption('newest', 'Mới nhất', Icons.fiber_new),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon) {
    final isSelected = _sortBy == value;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.grey,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : null,
          fontWeight: isSelected ? FontWeight.w600 : null,
        ),
      ),
      trailing: isSelected 
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Get.back();
      },
    );
  }

  /// Show filter options
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Bộ lọc',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildFilterOption('in_stock', 'Còn hàng', Icons.inventory),
            _buildFilterOption('on_sale', 'Đang giảm giá', Icons.local_offer),
            const Divider(),
            Text(
              'Khoảng giá',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            _buildFilterOption('price_low', 'Dưới 100.000đ', Icons.attach_money),
            _buildFilterOption('price_medium', '100.000đ - 500.000đ', Icons.attach_money),
            _buildFilterOption('price_high', 'Trên 500.000đ', Icons.attach_money),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String value, String label, IconData icon) {
    final isSelected = _activeFilters.contains(value);
    return CheckboxListTile(
      secondary: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.grey,
      ),
      title: Text(label),
      value: isSelected,
      activeColor: AppColors.primary,
      onChanged: (selected) {
        setState(() {
          if (selected == true) {
            _activeFilters.add(value);
          } else {
            _activeFilters.remove(value);
          }
        });
      },
    );
  }
}