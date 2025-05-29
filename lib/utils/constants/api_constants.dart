class ApiConstants {
  // BASE_URL này phải là địa chỉ và cổng của BACKEND API của bạn
  static const String BASE_URL = "http://localhost:1000/api"; 

  // User related
  static const String LOGIN = "/auth/login";
  static const String REGISTER = "/auth/register";
  static const String LOGOUT = "/auth/logout";
  static const String USER_INFO = "/user/info-user"; // Endpoint để lấy thông tin user hiện tại (qua token)
                                          // Hoặc có thể là /auth/me, /users/profile tùy theo backend
  static const String EDIT_INFO_USER = "/users/info-user/update"; // Cần sửa: không hardcode ID
                                                                            // Nên là "/user" hoặc "/users/update" (PUT)
  // OTP
  static const String VERIFY_OTP = "/otp/verify-otp";
  static const String SEND_OTP = "/otp/send-otp"; // Để gửi/gửi lại OTP

  // Password // Endpoint backend cho quên mật khẩu
  static const String RESET_PASSWORD = "/users/reset-password";   // Endpoint backend cho đặt lại mật khẩu mới
  static const String CHANGE_PASSWORD = "/users/change-password"; // Endpoint backend để user tự đổi mật khẩu khi đã đăng nhập

  // Products
  static const String ALL_PRODUCT_URI = "/products"; // Để lấy tất cả sản phẩm
  static const String PRODUCT_BY_CATEGORY_URI_BASE = "/products/category"; // Đường dẫn cơ sở để lấy sản phẩm theo categoryId (GET /products/category/:categoryId)
  // static const String PRODUCT_DETAIL_URI = "/products"; // Nếu lấy chi tiết là GET /products/:productId

  // Categories
  static const String ALL_CATEGORY_URI = "/categories"; // Lấy tất cả category
  // static const String CATEGORY_DETAIL_URI = "/category"; // Nếu lấy chi tiết là GET /category/:categoryId

  // Discounts / Coupons
  static const String DISCOUNT = "/discounts/all"; // Lấy tất cả discount
  static const String SINGLE_DISCOUNT_URI_BASE = "/discounts/single"; // URI cơ sở cho GET /discounts/single/:discountId
                                                                   // (ApiConstants.ALL_DISCOUNT cũ là "/discounts/single/65eef68a023a14930c0e8159")
  // Endpoint lấy coupon của user (qua token)


  // Addresses
  static const String ADDRESSES_BY_USER_BASE_URI = "/addresses/user/all"; // Đường dẫn cơ sở để lấy địa chỉ theo userId (GET /addresses/user/:userId)
  static const String ADD_ADDRESS_URI = "/addresses/add"; // Endpoint để thêm địa chỉ mới (POST /addresses/)
                                                       // (ApiConstants.ADD_ADDRESS cũ là "/addresses/add")
  static const String SET_DEFAULT_ADDRESS_BASE_URI = "/addresses"; // (PATCH /addresses/:addressId/set-default)
  // static const String DELETE_ADDRESS_BASE_URI = "/addresses";    // (DELETE /addresses/:addressId)
  // static const String UPDATE_ADDRESS_BASE_URI = "/addresses";    // (PUT /addresses/:addressId)


  // Orders
  static const String ORDERS_BY_USER_URI = "/orders/user";    // Endpoint lấy orders của user (qua token hoặc userId)
  static const String CREATE_ORDER_URI = "/orders/create";    // Endpoint tạo order mới
  // static const String ORDER_DETAIL_URI = "/orders";      // Nếu lấy chi tiết order là GET /orders/:orderId


  // Cart
  static const String CART_URI = "/cart"; // Endpoint chính cho cart (GET, POST, PUT, DELETE tùy theo action)
                                        // Ví dụ: GET /cart (lấy giỏ hàng của user qua token)
                                        // POST /cart (thêm sản phẩm vào giỏ)
                                        // PUT /cart/item/:itemId (cập nhật số lượng)
                                        // DELETE /cart/item/:itemId (xóa item)

  // Payment Methods
  static const String PAYMENT_METHODS_URI = "/payment-methods"; // Lấy danh sách phương thức thanh toán

  // SharedPreferences Keys
  static const String TOKEN = 'token';
  static const String IS_FIRST_TIME = 'IsFirstTime';
  static const String USER_ID = 'userId'; // Key để lưu user ID nếu cần

  // API Status
  static const int SUCCESS = 200;
  static const int CREATED = 201;
  static const int BAD_REQUEST = 400;
  static const int UNAUTHORIZED = 401;
  static const int FORBIDDEN = 403;
  static const String NOT_FOUND = "404"; // Giữ lại kiểu String nếu bạn parse string, hoặc int nếu parse int
  static const int CONFLICT = 409;
  static const int INTERNAL_SERVER_ERROR = 500;

  // Headers
  static const String HEADER_CONTENT_TYPE = 'Content-Type';
  static const String APPLICATION_JSON = 'application/json';
}
