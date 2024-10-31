// cart_model.dart

class CartModel {
  static final CartModel _instance = CartModel._internal();
  List<Map<String, dynamic>> _cartItems = [];

  factory CartModel() {
    return _instance;
  }

  CartModel._internal();

  List<Map<String, dynamic>> get cartItems => _cartItems;

  void addItem(Map<String, dynamic> item) {
    _cartItems.add(item);
  }

  void removeItem(int index) {
    _cartItems.removeAt(index);
  }

  void clearCart() {
    _cartItems.clear();
  }
}
