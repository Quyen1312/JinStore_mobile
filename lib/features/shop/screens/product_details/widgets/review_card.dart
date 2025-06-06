import 'package:flutter/material.dart';
import 'package:flutter_application_jin/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:flutter_application_jin/features/personalization/models/user_model.dart';
import 'package:flutter_application_jin/features/shop/models/review_model.dart';
import 'package:flutter_application_jin/utils/constants/colors.dart';
import 'package:flutter_application_jin/utils/constants/images.dart';
import 'package:flutter_application_jin/utils/constants/sizes.dart';
import 'package:flutter_application_jin/utils/helpers/helper_functions.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';

class ReviewCardWidget extends StatelessWidget {
  // Nhận cả review và user (optional) để hiển thị thông tin người dùng
  const ReviewCardWidget({
    super.key, 
    required this.review,
    this.user, // Optional: nếu có thông tin user thì hiển thị, không thì hiển thị ẩn danh
  });

  final Review review;
  final User? user;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    
    // Xác định thông tin người dùng
    final userName = user?.username ?? 'Người dùng ẩn danh';
    final userAvatarUrl = user?.avatar.url ?? '';
    final bool hasUserAvatar = userAvatarUrl.isNotEmpty && userAvatarUrl != '';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md, horizontal: AppSizes.xs),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkerGrey.withOpacity(0.5) : AppColors.lightContainer,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
        border: Border.all(color: dark ? AppColors.darkGrey : AppColors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: AppSizes.iconLg,
                    backgroundImage: hasUserAvatar
                        ? NetworkImage(userAvatarUrl)
                        : const AssetImage(Images.user) as ImageProvider,
                    onBackgroundImageError: hasUserAvatar ? (_, __) {
                      debugPrint('Lỗi tải avatar: $userAvatarUrl');
                    } : null,
                    backgroundColor: AppColors.grey.withOpacity(0.3),
                    child: !hasUserAvatar ? Icon(
                      Iconsax.user_copy,
                      color: AppColors.grey,
                      size: AppSizes.iconLg,
                    ) : null,
                  ),
                  const SizedBox(width: AppSizes.spaceBtwItems),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(review.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Menu tùy chọn
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Iconsax.more_copy, 
                  size: AppSizes.iconMd,
                  color: AppColors.darkGrey,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'report':
                      _handleReportReview(context);
                      break;
                    case 'edit':
                      _handleEditReview(context);
                      break;
                    case 'delete':
                      _handleDeleteReview(context);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Iconsax.flag_copy, size: 16),
                        SizedBox(width: 8),
                        Text('Báo cáo'),
                      ],
                    ),
                  ),
                  // TODO: Chỉ hiển thị Edit/Delete nếu là review của user hiện tại
                  // Cần truyền currentUserId để so sánh với review.userId
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceBtwItems * 0.8),

          // Rating Stars
          RatingBarIndicator(
            rating: review.rating.toDouble(),
            itemSize: AppSizes.iconMd,
            unratedColor: AppColors.grey.withOpacity(0.5),
            itemBuilder: (_, __) => const Icon(
              Iconsax.star_1, 
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: AppSizes.spaceBtwItems * 0.8),

          // Review Comment
          if (review.comment != null && review.comment!.trim().isNotEmpty)
            ReadMoreText(
              review.comment!,
              trimLines: 3,
              colorClickableText: AppColors.primary,
              trimMode: TrimMode.Line,
              trimCollapsedText: ' Xem thêm',
              trimExpandedText: ' Ẩn bớt',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: dark ? AppColors.light : AppColors.dark,
              ),
              moreStyle: const TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.bold, 
                color: AppColors.primary,
              ),
              lessStyle: const TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.bold, 
                color: AppColors.primary,
              ),
            )
          else
            Text(
              'Không có bình luận.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic, 
                color: AppColors.darkGrey,
              ),
            ),
          
          // Hiển thị thời gian cập nhật nếu khác với createdAt
          if (review.updatedAt.difference(review.createdAt).inMinutes > 1)
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.xs),
              child: Text(
                'Đã chỉnh sửa ${DateFormat('dd/MM/yyyy HH:mm').format(review.updatedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.darkGrey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleReportReview(BuildContext context) {
    // TODO: Implement report functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng báo cáo đang được phát triển')),
    );
  }

  void _handleEditReview(BuildContext context) {
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng chỉnh sửa đang được phát triển')),
    );
  }

  void _handleDeleteReview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa đánh giá'),
        content: const Text('Bạn có chắc chắn muốn xóa đánh giá này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Call ReviewController.deleteUserReview
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng xóa đang được phát triển')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

// Widget với context của current user để kiểm tra quyền
class ReviewCardWithContextWidget extends StatelessWidget {
  const ReviewCardWithContextWidget({
    super.key, 
    required this.review,
    this.user, // User của review
    this.currentUserId, // ID của user hiện tại để kiểm tra quyền
  });

  final Review review;
  final User? user;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    final userName = user?.username;
    final userAvatarUrl = user?.avatar.url ?? '';
    final bool hasUserAvatar = userAvatarUrl.isNotEmpty && userAvatarUrl != '';
    final bool isOwnReview = currentUserId != null && review.userId == currentUserId;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md, horizontal: AppSizes.xs),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkerGrey.withOpacity(0.5) : AppColors.lightContainer,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
        border: Border.all(color: dark ? AppColors.darkGrey : AppColors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: AppSizes.iconLg,
                    backgroundImage: hasUserAvatar
                        ? NetworkImage(userAvatarUrl)
                        : const AssetImage(Images.user) as ImageProvider,
                    backgroundColor: AppColors.grey.withOpacity(0.3),
                    child: !hasUserAvatar ? Icon(
                      Iconsax.user_copy,
                      color: AppColors.grey,
                      size: AppSizes.iconLg,
                    ) : null,
                  ),
                  const SizedBox(width: AppSizes.spaceBtwItems),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName!,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(review.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Menu tùy chọn
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Iconsax.more_copy, 
                  size: AppSizes.iconMd,
                  color: AppColors.darkGrey,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'report':
                      _handleReportReview(context);
                      break;
                    case 'edit':
                      _handleEditReview(context);
                      break;
                    case 'delete':
                      _handleDeleteReview(context);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Iconsax.flag_copy, size: 16),
                        SizedBox(width: 8),
                        Text('Báo cáo'),
                      ],
                    ),
                  ),
                  // Chỉ hiển thị Edit/Delete nếu là review của user hiện tại
                  if (isOwnReview) ...[
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Iconsax.edit_copy, size: 16),
                          SizedBox(width: 8),
                          Text('Chỉnh sửa'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Iconsax.trash_copy, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceBtwItems * 0.8),

          // Rating Stars
          RatingBarIndicator(
            rating: review.rating.toDouble(),
            itemSize: AppSizes.iconMd,
            unratedColor: AppColors.grey.withOpacity(0.5),
            itemBuilder: (_, __) => const Icon(
              Iconsax.star_1, 
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: AppSizes.spaceBtwItems * 0.8),

          // Review Comment
          if (review.comment != null && review.comment!.trim().isNotEmpty)
            ReadMoreText(
              review.comment!,
              trimLines: 3,
              colorClickableText: AppColors.primary,
              trimMode: TrimMode.Line,
              trimCollapsedText: ' Xem thêm',
              trimExpandedText: ' Ẩn bớt',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: dark ? AppColors.light : AppColors.dark,
              ),
              moreStyle: const TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.bold, 
                color: AppColors.primary,
              ),
              lessStyle: const TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.bold, 
                color: AppColors.primary,
              ),
            )
          else
            Text(
              'Không có bình luận.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic, 
                color: AppColors.darkGrey,
              ),
            ),
          
          // Hiển thị thời gian cập nhật nếu khác với createdAt
          if (review.updatedAt.difference(review.createdAt).inMinutes > 1)
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.xs),
              child: Text(
                'Đã chỉnh sửa ${DateFormat('dd/MM/yyyy HH:mm').format(review.updatedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.darkGrey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleReportReview(BuildContext context) {
    // TODO: Implement report functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng báo cáo đang được phát triển')),
    );
  }

  void _handleEditReview(BuildContext context) {
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng chỉnh sửa đang được phát triển')),
    );
  }

  void _handleDeleteReview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa đánh giá'),
        content: const Text('Bạn có chắc chắn muốn xóa đánh giá này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Call ReviewController.deleteUserReview
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng xóa đang được phát triển')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}