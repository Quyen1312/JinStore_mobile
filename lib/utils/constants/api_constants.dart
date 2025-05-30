class ApiConstants {
  // BASE_URL này phải là địa chỉ và cổng của BACKEND API của bạn
  static const String BASE_URL = "http://localhost:1000/api"; 

  // Authentication
  static const String LOGIN = "/auth/login";
  static const String REGISTER = "/auth/register";
  static const String LOGOUT = "/auth/logout";
  static const String AUTH_LOGIN_SUCCESS = "/auth/login/success"; // Dùng cho OAuth redirects
  static const String AUTH_GOOGLE = "/auth/google";
  static const String AUTH_GOOGLE_CALLBACK = "/auth/google/callback";
  static const String REFRESH_TOKEN = "/auth/refresh"; 
  static const String GOOGLE_TOKEN_SIGN_IN = "/auth/google/token-signin";

  // User related API Endpoints
  static const String USERS_BASE_PATH = "/users"; 
  static const String USERS_GET_CURRENT_INFO = "/users/info-user";   // GET (Lấy thông tin user hiện tại qua token)
  static const String USERS_UPDATE_CURRENT_INFO = "/users/info-user/update"; // PATCH (User tự cập nhật thông tin)
  
  // Password Management for logged-in user
  static const String USERS_CHANGE_PASSWORD = "/users/change-password";  // PATCH (User đã đăng nhập tự đổi mật khẩu)

  // --- Chức năng Quên Mật Khẩu đã được BỎ ---
  // static const String FORGET_PASSWORD_REQUEST = "/auth/forgot-password"; 
  // static const String COMPLETE_PASSWORD_RESET = "/users/reset-password";    

  // OTP Verification (/api/otp) - Vẫn giữ lại nếu OTP được dùng cho mục đích khác (ví dụ: xác thực đăng ký)
  static const String OTP_SEND = "/otp/send-otp";                  // POST
  static const String OTP_VERIFY = "/otp/verify-otp";                // POST

  // Products (/api/products)
  static const String PRODUCTS_GET_ALL = "/products/";               // GET (Lấy tất cả sản phẩm)
  static const String PRODUCTS_BASE = "/products";                 // Base cho GET /products/:id
  static const String PRODUCTS_BY_CATEGORY_BASE = "/products/category";  // GET /products/category/:idCategory

  // Categories (/api/categories)
  static const String CATEGORIES_GET_ALL = "/categories/";           // GET (Lấy tất cả danh mục)
  static const String CATEGORIES_BASE = "/categories";             // Base cho GET /categories/:id

  // Discounts (/api/discounts)
  static const String DISCOUNTS_GET_ALL = "/discounts/all";          // GET
  static const String DISCOUNTS_BASE = "/discounts";                 // Base cho GET /discounts/:id

  // Reviews (/api/reviews)
  static const String REVIEWS_CREATE = "/reviews/";                // POST (Tạo review mới)
  static const String REVIEWS_GET_CURRENT_USER = "/reviews/user";    // GET (Lấy review của user đã đăng nhập)
  static const String REVIEWS_BY_PRODUCT_ID_BASE = "/reviews/product"; // GET /reviews/product/:productId
  static const String REVIEWS_UPDATE_BASE = "/reviews/update";       // PATCH /reviews/update/:reviewId (User cập nhật review của mình)
  static const String REVIEWS_DELETE_BASE = "/reviews/delete";       // DELETE /reviews/delete/:reviewId (User xóa review của mình)

  // Addresses (/api/addresses)
  static const String ADDRESSES_GET_ALL_CURRENT_USER = "/addresses/user/all"; 
  static const String ADDRESSES_BASE = "/addresses";                 
  static const String ADDRESSES_ADD = "/addresses/add";              
  static const String ADDRESSES_SET_DEFAULT_BASE = "/addresses";     
  static const String ADDRESSES_ACTION_SET_DEFAULT = "/set-default"; 

  // Cart (/api/carts)
  static const String CART_GET_USER = "/carts/";                   
  static const String CART_ADD_ITEM = "/carts/add";                
  static const String CART_UPDATE_ITEM = "/carts/update";            
  static const String CART_REMOVE_ITEM_BASE = "/carts/remove";       
  static const String CART_CLEAR = "/carts/clear";                 

  // Orders (/api/orders)
  static const String ORDERS_CREATE = "/orders/create";              
  static const String ORDERS_GET_CURRENT_USER = "/orders/my-order";  
  static const String ORDERS_GET_DETAILS_BASE = "/orders/details";   

  // Payments (/api/payments)
  static const String PAYMENTS_VNPAY_CREATE_URL = "/payments/vnpay/create_url"; 
  static const String PAYMENTS_VNPAY_RETURN_URL = "/payments/vnpay/return_url"; 

  // --- SharedPreferences Keys ---
  static const String TOKEN = 'token';
  static const String IS_FIRST_TIME = 'IsFirstTime';
  static const String USER_ID = 'userId'; 

  // --- API Status Codes ---
  static const int SUCCESS = 200;
  static const int CREATED = 201;
  static const int NO_CONTENT = 204;
  static const int BAD_REQUEST = 400;
  static const int UNAUTHORIZED = 401;
  static const int FORBIDDEN = 403;
  static const int NOT_FOUND = 404; 
  static const int CONFLICT = 409;
  static const int INTERNAL_SERVER_ERROR = 500;

  // --- Headers ---
  static const String HEADER_CONTENT_TYPE = 'Content-Type';
  static const String APPLICATION_JSON = 'application/json';
}
