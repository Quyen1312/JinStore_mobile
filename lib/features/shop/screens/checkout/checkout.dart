import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:flutter_application_jin/features/authentication/controllers/auth/auth_controller.dart';
import 'package:flutter_application_jin/features/shop/screens/cart/widgets/cart_items.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:get/get.dart';
import '../../../../utils/helpers/helper_functions.dart';
import 'package:flutter_application_jin/features/shop/controllers/cart_controller.dart';
import 'package:flutter_application_jin/features/shop/controllers/payment_controller.dart';
import 'package:flutter_application_jin/features/shop/controllers/order_controller.dart';
import 'package:flutter_application_jin/features/shop/controllers/discount_controller.dart';
import 'package:flutter_application_jin/features/personalization/controllers/address_controller.dart';
import 'package:flutter_application_jin/features/shop/models/order_model.dart';
import 'package:flutter_application_jin/features/shop/models/discount_model.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_application_jin/features/shop/screens/checkout/widgets/payment_webview.dart';
import 'package:flutter_application_jin/features/shop/screens/checkout/widgets/billing_address_section.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  /// Format tiền tệ theo định dạng Việt Nam
  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]},'
    )}đ';
  }

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;
    final paymentController = PaymentController.instance;
    final orderController = Get.find<OrderController>();
    final discountController = Get.put(DiscountController()); // Initialize discount controller
    final dark = HelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            children: [
              // Selected Cart Items ONLY - No checkboxes, no quantity controls
              RoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(AppSizes.md),
                backgroundColor: dark ? AppColors.dark : AppColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sản phẩm đã chọn',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Obx(() => Text(
                          '${cartController.selectedItemsCount} sản phẩm',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    // Cart Items widget with checkout configuration
                    const CartItems(
                      showAddRemoveButtons: false, // No quantity controls in checkout
                      showCheckboxes: false, // No checkboxes in checkout
                      selectedItemsOnly: true, // Only show selected items
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),
              
              // Billing Address Section
              const BillingAddressSection(),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Coupon Section - UPDATED
              RoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(AppSizes.md),
                backgroundColor: dark ? AppColors.dark : AppColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mã giảm giá',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    
                    // Show selected coupon or input field
                    Obx(() {
                      final selectedDiscount = discountController.selectedDiscountForCart.value;
                      
                      if (selectedDiscount != null) {
                        // Show selected coupon
                        return Container(
                          padding: const EdgeInsets.all(AppSizes.md),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Iconsax.discount_shape,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: AppSizes.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedDiscount.code,
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    Text(
                                      discountController.formatDiscountValue(selectedDiscount),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.green.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  discountController.removeSelectedDiscount();
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.green.shade700,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Show input field and apply button
                        return Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.md,
                                  vertical: AppSizes.sm,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Iconsax.discount_shape,
                                      color: Colors.grey,
                                      size: 16,
                                    ),
                                    const SizedBox(width: AppSizes.sm),
                                    Text(
                                      'Chọn mã giảm giá',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSizes.sm),
                            SizedBox(
                              width: 80,
                              child: ElevatedButton(
                                onPressed: () => _showCouponSelectionDialog(
                                  context, 
                                  discountController, 
                                  cartController.cartTotalAmount.value
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(AppSizes.md),
                                ),
                                child: const Text('Chọn'),
                              ),
                            ),
                          ],
                        );
                      }
                    }),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Order Summary - UPDATED with discount calculation
              RoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(AppSizes.md),
                backgroundColor: dark ? AppColors.dark : AppColors.white,
                child: Obx(() {
                  final subtotal = cartController.cartTotalAmount.value;
                  final shippingFee = 30000.0;
                  final discountAmount = discountController.calculatedDiscountAmountForCart.value;
                  final finalTotal = subtotal + shippingFee - discountAmount;
                  
                  return Column(
                    children: [
                      // Subtotal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tạm tính',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            formatCurrency(subtotal),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spaceBtwItems),

                      // Shipping Fee
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Phí vận chuyển',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            formatCurrency(shippingFee),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spaceBtwItems),

                      // Discount if applied
                      if (discountAmount > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Giảm giá',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              '-${formatCurrency(discountAmount)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.spaceBtwItems),
                      ],
                      
                      const Divider(),
                      const SizedBox(height: AppSizes.spaceBtwItems),

                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tổng thanh toán',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            formatCurrency(finalTotal),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Payment Methods
              RoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(AppSizes.md),
                backgroundColor: dark ? AppColors.dark : AppColors.white,
                child: Column(
                  children: [
                    Text(
                      'Phương thức thanh toán',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    
                    // VNPay Option - FIXED VERSION
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 45,
                        height: 30,
                        padding: const EdgeInsets.all(AppSizes.xs),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.xs),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2), // VNPay blue color
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              'VNPay',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      title: const Text('Thanh toán VNPay'),
                      subtitle: Text(kIsWeb 
                        ? 'Thanh toán qua trang web VNPay' 
                        : 'Thanh toán qua ví điện tử VNPay'),
                      trailing: Obx(() => paymentController.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Iconsax.arrow_right_3)),
                      onTap: paymentController.isLoading.value ? null : () => _handleVNPayPayment(
                        cartController: cartController,
                        paymentController: paymentController,
                        orderController: orderController,
                        discountController: discountController,
                      ),
                    ),
                    
                    const Divider(),
                    
                    // COD Option
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 45,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(AppSizes.xs),
                        ),
                        child: const Icon(Iconsax.money, size: 20),
                      ),
                      title: const Text('Thanh toán khi nhận hàng'),
                      trailing: const Icon(Iconsax.arrow_right_3),
                      onTap: () => _handleCODPayment(
                        cartController: cartController,
                        orderController: orderController,
                        discountController: discountController,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),
              
              // Back to Cart Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Iconsax.arrow_left),
                  label: const Text('Quay lại giỏ hàng'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // COUPON SELECTION DIALOG
  // ================================================================
  
  void _showCouponSelectionDialog(BuildContext context, DiscountController discountController, double cartAmount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chọn mã giảm giá',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            
            // Selected discount info
            Obx(() {
              final selectedDiscount = discountController.selectedDiscountForCart.value;
              return selectedDiscount != null
                ? Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    margin: const EdgeInsets.only(bottom: AppSizes.spaceBtwItems),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Text(
                            'Đã chọn: ${selectedDiscount.code}',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink();
            }),
            
            // Coupon list
            Expanded(
              child: Obx(() {
                if (discountController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final availableDiscounts = discountController.userAvailableDiscounts;
                
                if (availableDiscounts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.discount_shape,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: AppSizes.spaceBtwItems),
                        Text(
                          'Không có mã giảm giá',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSizes.spaceBtwItems / 2),
                        Text(
                          'Hiện tại bạn chưa có mã giảm giá khả dụng',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: availableDiscounts.length,
                  itemBuilder: (context, index) {
                    final discount = availableDiscounts[index];
                    final isSelected = discountController.selectedDiscountForCart.value?.id == discount.id;
                    final isEligible = discount.isValid && cartAmount >= discount.minOrderAmount;
                    final discountAmount = discount.calculateDiscountAmount(cartAmount);
                    
                    // Get eligibility text
                    String eligibilityText;
                    if (!discount.isActive) {
                      eligibilityText = 'Mã không khả dụng';
                    } else if (DateTime.now().isAfter(discount.expirationDate)) {
                      eligibilityText = 'Mã đã hết hạn';
                    } else if (discount.quantityUsed >= discount.quantityLimit) {
                      eligibilityText = 'Mã đã hết lượt sử dụng';
                    } else if (cartAmount < discount.minOrderAmount) {
                      eligibilityText = 'Đơn hàng tối thiểu ${formatCurrency(discount.minOrderAmount)}';
                    } else {
                      eligibilityText = 'Có thể áp dụng';
                    }
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.spaceBtwItems),
                      elevation: isSelected ? 3 : 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : isEligible 
                              ? Colors.transparent
                              : Colors.red.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(AppSizes.md),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isEligible
                              ? (isSelected 
                                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1))
                              : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Iconsax.discount_shape,
                            color: isEligible
                              ? (isSelected 
                                  ? Theme.of(context).primaryColor
                                  : Colors.green)
                              : Colors.red,
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                discount.code,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Expanded(
                              child: Text(
                                discountController.formatDiscountValue(discount),
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            if (isEligible && discountAmount > 0) ...[
                              Text(
                                'Tiết kiệm: ${formatCurrency(discountAmount)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            Text(
                              eligibilityText,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isEligible ? Colors.green : Colors.red,
                              ),
                            ),
                            Text(
                              'HSD: ${discountController.formatDate(discount.expirationDate)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: isEligible 
                          ? (isSelected 
                              ? Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                )
                              : null)
                          : Icon(
                              Icons.block,
                              color: Colors.red.withOpacity(0.5),
                              size: 20,
                            ),
                        enabled: isEligible,
                        onTap: isEligible ? () {
                          if (isSelected) {
                            discountController.removeSelectedDiscount();
                          } else {
                            discountController.selectDiscountForCart(discount, cartAmount);
                          }
                        } : null,
                      ),
                    );
                  },
                );
              }),
            ),
            
            // Confirm button
            const SizedBox(height: AppSizes.spaceBtwItems),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(AppSizes.md),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Obx(() {
                  final selectedDiscount = discountController.selectedDiscountForCart.value;
                  return Text(
                    selectedDiscount != null 
                      ? 'Xác nhận (${selectedDiscount.code})'
                      : 'Xác nhận',
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // VNPAY PAYMENT HANDLER - WITH WEB SUPPORT
  // ================================================================
  
  Future<void> _handleVNPayPayment({
    required CartController cartController,
    required PaymentController paymentController,
    required OrderController orderController,
    required DiscountController discountController,
  }) async {
    try {
      // 1. Comprehensive validation before processing
      await _validateOrderCreation(cartController);
      
      // 2. Create validated order items FROM SELECTED ITEMS ONLY
      final orderItems = _createValidatedOrderItems(cartController);
      
      // 3. Get selected address
      final addressController = Get.find<AddressController>();
      final selectedAddress = addressController.selectedAddress.value!;
      
      // 4. Calculate final total with discount
      final subtotal = cartController.cartTotalAmount.value;
      final shippingFee = 30000.0;
      final discountAmount = discountController.calculatedDiscountAmountForCart.value;
      final finalTotal = subtotal + shippingFee - discountAmount;
      
      // 5. Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      // 6. Create order in database first
      final order = await orderController.processNewOrder(
        orderItems: orderItems,
        shippingAddress: selectedAddress.id,
        shippingFee: 30000,
        paymentMethod: 'vnpay',
        totalAmount: finalTotal, // Use final total with discount
        source: 'cart',
      );
      
      // 7. Close loading dialog
      Get.back();
      
      if (order != null) {
        // 8. Create VNPay payment URL
        final paymentUrl = await paymentController.initiateVNPayPayment(
          orderId: order.id,
          language: 'vn',
        );
        
        if (paymentUrl != null) {
          // 9. Handle different platforms
          if (kIsWeb) {
            // Web: Use url_launcher
            await _handleWebPayment(paymentUrl, order.id, finalTotal, cartController, discountController);
          } else {
            // Mobile: Use WebView
            final result = await Get.to(() => PaymentWebView(
              paymentUrl: paymentUrl,
              orderId: order.id,
            ));
            
            if (result == true) {
              // 10. Payment successful
              _handlePaymentSuccess(cartController, discountController);
            } else {
              // 11. Payment failed or cancelled
              _handlePaymentFailure();
            }
          }
        } else {
          throw 'Không thể tạo URL thanh toán VNPay';
        }
      } else {
        throw 'Không thể tạo đơn hàng';
      }
      
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      _handleOrderError(e, context: 'thanh toán VNPay');
    }
  }

  // ================================================================
  // WEB PAYMENT HANDLER
  // ================================================================
  
  Future<void> _handleWebPayment(
    String paymentUrl, 
    String orderId, 
    double amount,
    CartController cartController,
    DiscountController discountController,
  ) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Thanh toán VNPay'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn sẽ được chuyển đến trang thanh toán VNPay.'),
            const SizedBox(height: 12),
            Text('Số tiền: ${formatCurrency(amount)}'),
            Text('Mã đơn: #${orderId.substring(0, 8).toUpperCase()}'),
            const SizedBox(height: 12),
            const Text('Sau khi thanh toán xong, vui lòng quay lại và xác nhận.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Mở VNPay trong tab mới
              final uri = Uri.parse(paymentUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              Get.back(result: null);
            },
            child: const Text('Mở VNPay'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed == false) {
      _handlePaymentFailure();
      return;
    }

    // Hiển thị dialog xác nhận sau khi user quay lại
    await Future.delayed(const Duration(seconds: 2));
    
    final paymentResult = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Xác nhận thanh toán'),
        content: const Text('Bạn đã hoàn thành thanh toán VNPay chưa?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Chưa/Thất bại'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Đã thanh toán'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (paymentResult == true) {
      _handlePaymentSuccess(cartController, discountController);
    } else {
      _handlePaymentFailure();
    }
  }

  // ================================================================
  // COD PAYMENT HANDLER
  // ================================================================
  
  Future<void> _handleCODPayment({
    required CartController cartController,
    required OrderController orderController,
    required DiscountController discountController,
  }) async {
    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Xác nhận đặt hàng'),
        content: const Text('Bạn có chắc chắn muốn đặt hàng và thanh toán khi nhận hàng?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // 1. Comprehensive validation
        await _validateOrderCreation(cartController);
        
        // 2. Create validated order items FROM SELECTED ITEMS ONLY
        final orderItems = _createValidatedOrderItems(cartController);
        
        // 3. Get selected address
        final addressController = Get.find<AddressController>();
        final selectedAddress = addressController.selectedAddress.value!;
        
        // 4. Calculate final total with discount
        final subtotal = cartController.cartTotalAmount.value;
        final shippingFee = 30000.0;
        final discountAmount = discountController.calculatedDiscountAmountForCart.value;
        final finalTotal = subtotal + shippingFee - discountAmount;
        
        // 5. Create COD order
        final order = await orderController.processNewOrder(
          orderItems: orderItems,
          shippingAddress: selectedAddress.id,
          shippingFee: 30000,
          paymentMethod: 'cod',
          totalAmount: finalTotal, // Use final total with discount
          source: 'cart',
        );
        
        if (order != null) {
          // 6. Handle success
          _handlePaymentSuccess(cartController, discountController);
        } else {
          throw 'Không thể tạo đơn hàng COD';
        }
        
      } catch (e) {
        _handleOrderError(e, context: 'đặt hàng COD');
      }
    }
  }

  // ================================================================
  // VALIDATION HELPERS
  // ================================================================
  
  Future<void> _validateOrderCreation(CartController cartController) async {
    // 1. Check authentication
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn.value) {
      throw 'Vui lòng đăng nhập để đặt hàng';
    }

    // 2. Validate address selection
    final addressController = Get.find<AddressController>();
    if (addressController.selectedAddress.value == null) {
      throw 'Vui lòng chọn địa chỉ giao hàng';
    }
    
    // 3. Validate selected cart items (not all cart items)
    final selectedItems = cartController.displayCartItems.where((item) => item.isSelected).toList();
    if (selectedItems.isEmpty) {
      throw 'Vui lòng chọn ít nhất một sản phẩm để thanh toán';
    }

    // 4. Validate cart total amount for selected items
    if (cartController.cartTotalAmount.value <= 0) {
      throw 'Tổng giá trị đơn hàng không hợp lệ';
    }

    // 5. Validate individual selected cart items
    for (final item in selectedItems) {
      if (item.productId.isEmpty) {
        throw 'Sản phẩm "${item.name}" không có ID hợp lệ';
      }
      if (item.name.isEmpty) {
        throw 'Có sản phẩm thiếu tên';
      }
      if (item.price <= 0) {
        throw 'Sản phẩm "${item.name}" có giá không hợp lệ';
      }
      if (item.quantity <= 0) {
        throw 'Sản phẩm "${item.name}" có số lượng không hợp lệ';
      }
    }
  }

  List<OrderItemModel> _createValidatedOrderItems(CartController cartController) {
    // Create order items FROM SELECTED ITEMS ONLY
    final selectedItems = cartController.displayCartItems.where((item) => item.isSelected).toList();
    return selectedItems.map((item) => 
      OrderItemModel(
        productId: item.productId,
        name: item.name,
        price: item.discountPrice, // Use discounted price
        quantity: item.quantity,
      )
    ).toList();
  }

  // ================================================================
  // SUCCESS/ERROR HANDLERS
  // ================================================================
  
  void _handlePaymentSuccess(CartController cartController, DiscountController discountController) async {
    // Clear ONLY selected items from cart (not all cart)
    final selectedItems = cartController.displayCartItems.where((item) => item.isSelected).toList();
    for (final item in selectedItems) {
      await cartController.removeItemFromCart(item.productId);
    }
    
    // Clear selected discount
    discountController.removeSelectedDiscount();
    
    // Show success message
    Get.snackbar(
      'Thành công',
      'Đặt hàng thành công! Cảm ơn bạn đã mua hàng.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
    
    // Navigate to success screen
    Get.offAllNamed('/payment-success');
  }
  
  void _handlePaymentFailure() {
    Get.snackbar(
      'Thanh toán thất bại',
      'Thanh toán không thành công. Đơn hàng vẫn được lưu, bạn có thể thanh toán sau.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }
  
  void _handleOrderError(dynamic error, {String? context}) {
    String errorMessage;
    String title = 'Lỗi đặt hàng';
    
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('chọn ít nhất một sản phẩm')) {
      title = 'Chưa chọn sản phẩm';
      errorMessage = 'Vui lòng quay lại giỏ hàng và chọn ít nhất một sản phẩm để thanh toán.';
    } else if (errorString.contains('giỏ hàng trống')) {
      title = 'Giỏ hàng trống';
      errorMessage = 'Vui lòng thêm sản phẩm vào giỏ hàng trước khi đặt hàng.';
    } else if (errorString.contains('địa chỉ')) {
      title = 'Thiếu địa chỉ giao hàng';
      errorMessage = 'Vui lòng chọn địa chỉ giao hàng trong phần "Địa chỉ giao hàng".';
    } else if (errorString.contains('đăng nhập')) {
      title = 'Chưa đăng nhập';
      errorMessage = 'Vui lòng đăng nhập để thực hiện đặt hàng.';
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      title = 'Lỗi kết nối';
      errorMessage = 'Kiểm tra kết nối mạng và thử lại.';
    } else if (errorString.contains('timeout')) {
      title = 'Hết thời gian chờ';
      errorMessage = 'Kết nối quá chậm. Vui lòng thử lại.';
    } else if (errorString.contains('server') || errorString.contains('500')) {
      title = 'Lỗi server';
      errorMessage = 'Server đang gặp sự cố. Vui lòng thử lại sau ít phút.';
    } else if (errorString.contains('unauthorized') || errorString.contains('401')) {
      title = 'Phiên đăng nhập hết hạn';
      errorMessage = 'Vui lòng đăng nhập lại.';
    } else {
      // Generic error
      errorMessage = context != null 
        ? 'Có lỗi xảy ra khi $context. Vui lòng thử lại.'
        : 'Có lỗi xảy ra. Vui lòng thử lại sau.';
    }
    
    Get.snackbar(
      title,
      errorMessage,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
      margin: const EdgeInsets.all(16),
    );
  }
}