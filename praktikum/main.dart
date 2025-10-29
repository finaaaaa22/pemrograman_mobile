import 'dart:async';

/// ===============================
/// MODEL DAN ENUM
/// ===============================

/// Enum Role: Admin atau Customer
enum Role { Admin, Customer }

/// Exception khusus saat produk habis
class OutOfStockException implements Exception {
  final String message;
  OutOfStockException(this.message);

  @override
  String toString() => 'OutOfStockException: $message';
}

/// Model Product
class Product {
  final String productName; // Nama produk
  final double price; // Harga produk
  bool inStock; // Status stok

  Product({
    required this.productName,
    required this.price,
    this.inStock = true,
  });

  /// Override operator == dan hashCode agar Set<Product> bisa mendeteksi duplikat
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          productName == other.productName;

  @override
  int get hashCode => productName.hashCode;

  @override
  String toString() =>
      'Product(name: $productName, price: $price, inStock: $inStock)';
}

/// ===============================
/// BASE USER
/// ===============================
class User {
  final String name; // Nama user
  final int age; // Umur user
  Role? role; // Role bisa null dulu

  late List<Product> products; // late init, baru diinisialisasi nanti
  List<Product>?
      productsNullableBackup; // Nullable untuk demonstrasi operator ?

  User(this.name, this.age, {this.role});

  /// Inisialisasi products setelah objek dibuat
  void initProducts(List<Product> pList) {
    products = pList;
    productsNullableBackup = pList;
  }

  /// Menampilkan informasi user
  void showInfo() {
    print('User: $name, Age: $age, Role: ${role?.name ?? "Belum di-set"}');
    try {
      print('Jumlah produk: ${products.length}');
    } catch (e) {
      print('Produk belum diinisialisasi.');
    }
  }
}

/// ===============================
/// ADMIN USER
/// ===============================
class AdminUser extends User {
  AdminUser(String name, int age) : super(name, age) {
    role = Role.Admin;
  }

  /// Tambah produk ke katalog umum
  void addToCatalog(Map<String, Product> catalog, Product product) {
    catalog[product.productName] = product;
    print('Admin menambahkan produk: ${product.productName}');
  }

  /// Hapus produk dari katalog
  void removeFromCatalog(Map<String, Product> catalog, String productName) {
    if (catalog.containsKey(productName)) {
      catalog.remove(productName);
      print('Admin menghapus produk: $productName');
    } else {
      print('Produk $productName tidak ditemukan di katalog.');
    }
  }

  /// Tambah produk ke user
  Future<void> addProductToUser(User user, Product product) async {
    try {
      // cek stok
      if (!product.inStock) {
        throw OutOfStockException(
            'Produk "${product.productName}" habis stok.');
      }

      // pastikan products sudah inisialisasi
      try {
        user.products;
      } catch (e) {
        user.initProducts([]);
      }

      // Gunakan Set agar produk unik
      final existingSet = Set<Product>.from(user.products);
      final added = existingSet.add(product);
      if (added) {
        user.products = existingSet.toList();
        user.productsNullableBackup = user.products;
        print(
            'Produk "${product.productName}" berhasil ditambahkan ke ${user.name}.');
      } else {
        print(
            'Produk "${product.productName}" sudah ada dalam daftar ${user.name}.');
      }
    } on OutOfStockException catch (e) {
      print('Gagal menambahkan: ${e.toString()}');
    } catch (e) {
      print('Terjadi error: $e');
    }
  }

  /// Hapus produk dari daftar user
  void removeProductFromUser(User user, String productName) {
    try {
      user.products;
    } catch (e) {
      print('Daftar produk user belum diinisialisasi.');
      return;
    }

    final before = user.products.length;
    user.products =
        user.products.where((p) => p.productName != productName).toList();
    user.productsNullableBackup = user.products;
    final after = user.products.length;

    if (after < before) {
      print('Produk "$productName" dihapus dari ${user.name}.');
    } else {
      print('Produk "$productName" tidak ditemukan pada ${user.name}.');
    }
  }
}

/// ===============================
/// CUSTOMER USER
/// ===============================
class CustomerUser extends User {
  CustomerUser(String name, int age) : super(name, age) {
    role = Role.Customer;
  }

  /// Lihat produk user
  void viewProducts() {
    if (productsNullableBackup == null) {
      print('$name belum memiliki produk.');
      return;
    }
    try {
      if (products.isEmpty) {
        print('$name: habis.');
      } else {
        print('$name melihat produk (${products.length}):');
        for (var p in products) {
          print(
              '- ${p.productName} | Rp ${p.price.toStringAsFixed(0)} | InStock: ${p.inStock}');
        }
      }
    } catch (e) {
      print('Produk belum diinisialisasi untuk $name.');
    }
  }
}

/// ===============================
/// ASYNC SIMULASI FETCH
/// ===============================
Future<Product> fetchProductDetails(
    String productName, Map<String, Product> catalog) async {
  await Future.delayed(Duration(seconds: 2)); // simulasi delay
  if (catalog.containsKey(productName)) {
    final p = catalog[productName]!;
    return Product(
        productName: p.productName, price: p.price, inStock: p.inStock);
  } else {
    throw Exception('Produk $productName tidak ditemukan di server.');
  }
}

/// ===============================
/// MAIN FUNCTION
/// ===============================
Future<void> main() async {
  // Map untuk katalog produk
  final Map<String, Product> catalog = {};

  // Buat beberapa produk
  final jilbab = Product(productName: 'Jilbab', price: 75000);
  final baju = Product(productName: 'Baju', price: 125000, inStock: false);
  final boneka = Product(productName: 'Boneka', price: 90000);

  // Buat Admin dan Customer
  final admin = AdminUser('Safina', 20);
  final customer = CustomerUser('Deya', 20);

  // Admin menambahkan produk ke katalog
  admin.addToCatalog(catalog, jilbab);
  admin.addToCatalog(catalog, baju);
  admin.addToCatalog(catalog, boneka);

  print('\n--- Katalog saat ini ---');
  catalog.forEach((k, v) => print('$k => $v'));

  // Inisialisasi produk customer
  customer.initProducts([]);

  // Admin menambahkan produk ke customer
  await admin.addProductToUser(customer, baju); // sukses
  await admin.addProductToUser(customer, baju); // gagal, stok habis

  // Customer melihat produk
  customer.viewProducts();

  // Admin hapus produk dari katalog
  admin.removeFromCatalog(catalog, 'Baju');

  print('\n--- Katalog setelah penghapusan ---');
  catalog.forEach((k, v) => print('$k => $v'));

  // Demo fetch produk asinkron
  print('\nFetching detail produk "Boneka"...');
  try {
    final fetched = await fetchProductDetails('Boneka', catalog);
    print('Diterima dari server: $fetched');
  } catch (e) {
    print('Fetch gagal: $e');
  }
}
