ROUTES_EXCLUDE = [
  "/api/users/login",
  "/api/users/register",
  "/shops/offers/:lat/:lon",
  "/shops/:lat/:lon",
  "/shop/:shop_id/offers",
  "/shop/offer/:offer_id",
]

ONLY_ROUTES = [
  "/api/users/profile",
  "/api/users/logout",
  "/api/users/update/profile",
  "/api/shop",
  "/shops/:shop_id/update/images",
  "/shops/:shop_id/image",
  "/shop/:shop_id/comment",
  "/shop/:shop_id/comments",
  "/find/shops/:lat/:lon",
  "/shop/offers",
  "/shop/offers/:offer_id",
  "/api/images/avatar",
  "/api/images/shop/logo",
  "/api/images/shop/cover",
  "/api/images/shop",
  "/api/shop/:shop_id",
  "/shop/:shop_id/update",
  "/shop/lock/:shop_id",
]
