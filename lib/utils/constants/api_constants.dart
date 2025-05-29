class ApiConstants {
 static const String APP_NAME = "JinStore";
 static const int APP_VERSION = 1;

 static const String BASE_URL = "http://localhost:1000/api";

 static const String ALL_PRODUCT_URI = "/products";
 static const String PRODUCT_BY_CATEGORY_URI = "/products/category/67d2a46e241283a7f8614ccc";

 static const String ALL_CATEGORY = "/categories";
 static const String CATEGORY = "/categories/CAT-002";

 static const String SEND_OTP = "/otp/send-otp";
 static const String VERIFY_OTP = "/otp/verify-otp";

 static const String CART = "/carts";
 static const String ADD_CART = "/carts/add";
 static const String UPDATE_CART = "/carts/update";
 static const String REMOVE_CART = "/carts/remove/:productId";
 static const String CLEAR_CART = "/carts/clear";

 static const String LOGIN = "/auth/login";
 static const String REGISTER = "/auth/register";
 static const String LOGOUT = "/auth/logout";
 static const String USER_INFO = "/user";
 static const String EDIT_INFO_USER = "/user/67d8deba5f7fcdac23db0e96";
 static const String RESET_PASSWORD = "/users/reset-password";
 static const String CHANGE_PASSWORD = "/users/change-password";

 static const String ADDRESS = "/addresses/user/all";
 static const String ADD_ADDRESS = "/addresses/add";

 static const String DISCOUNT = "/discounts/all";
 static const String ALL_DISCOUNT = "/discounts/single/681f4eb8901f5e482207188a";

 static const String ORDER_BY_USERiD = "/orders/67fc7c670ebf83cb124aef5a?status=all";
 static const String ALL_ORDER = "/orders/list?status=paid"; 

  static const String TOKEN = "jtoken";
}