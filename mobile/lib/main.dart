import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const FullcartApp());
}

class FullcartApp extends StatelessWidget {
  const FullcartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fullcart Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF232F3E), // Amazon Blue
        scaffoldBackgroundColor: const Color(0xFFEAEDED), // Amazon Background Gray
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF232F3E),
          secondary: const Color(0xFFFEBD69), // Amazon Yellow
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF232F3E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const AuthCheck(),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.containsKey('user');
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn ? const HomePage() : const LoginScreen();
  }
}

// --- SHARED LOGIN/REGISTER ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://fullcart-backend.onrender.com/api/auth/login.php'),
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(result['user']));
        await prefs.setString('token', result['token']);
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Login failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error. Please try again.')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Fullcart', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    Text('.in', style: TextStyle(fontSize: 24, color: Color(0xFFF08804))),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sign in', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 20),
                    const Text('Email or mobile phone number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD814),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Center(child: Text('Sign-In')),
                    ),
                    const SizedBox(height: 20),
                    const Text('By continuing, you agree to Fullcart\'s Conditions of Use and Privacy Notice.', style: TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('New to Fullcart?', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                child: const Text('Create your Fullcart account', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  _register() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://fullcart-backend.onrender.com/api/auth/register.php'),
        body: jsonEncode({
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created! Please login.')),
          );
          Navigator.pop(context);
        }
      } else {
        final result = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Registration failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection error. Please try again.')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Fullcart', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
            Text('.in', style: TextStyle(fontSize: 18, color: Color(0xFFF08804))),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),
              const Text('Your name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12), isDense: true),
              ),
              const SizedBox(height: 15),
              const Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12), isDense: true),
              ),
              const SizedBox(height: 15),
              const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12), isDense: true, hintText: 'At least 6 characters'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD814),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Center(child: Text('Verify email')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- HOME PAGE ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = '';
  int _userId = 0;
  List _products = [];
  bool _isLoading = true;
  int _cartCount = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _dummyDeals = [
    {
      "title": "Apple iPhone 15 (128 GB) - Blue",
      "price": "69,999",
      "image": "https://m.media-amazon.com/images/I/71X8X4tWNEL._AC_UY327_FMwebp_QL65_.jpg",
      "rating": "4.5",
      "reviews": "42,503",
      "tag": "15% off"
    },
    {
      "title": "Sony WH-1000XM5 Headphones",
      "price": "24,990",
      "image": "https://m.media-amazon.com/images/I/61N98Xh+cCL._AC_UY327_FMwebp_QL65_.jpg",
      "rating": "4.8",
      "reviews": "12,890",
      "tag": "20% off"
    },
    {
      "title": "Samsung Galaxy S24 Ultra 5G",
      "price": "1,29,999",
      "image": "https://m.media-amazon.com/images/I/718V385D+3L._AC_UY327_FMwebp_QL65_.jpg",
      "rating": "4.6",
      "reviews": "5,211",
      "tag": "10% off"
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchProducts();
  }

  _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final user = jsonDecode(userJson);
      setState(() {
        _userName = user['name'];
        _userId = user['id'];
      });
      _fetchCartCount();
    }
  }

  _fetchCartCount() async {
    try {
      final url = Uri.parse('https://fullcart-backend.onrender.com/api/cart/index.php?user_id=$_userId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List records = data['records'] ?? [];
        int count = 0;
        for (var item in records) {
          count += int.parse(item['quantity'].toString());
        }
        setState(() {
          _cartCount = count;
        });
      }
    } catch(e) {}
  }

  _fetchProducts({String search = ''}) async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('https://fullcart-backend.onrender.com/api/products/list.php?search=$search');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _products = data['records'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _products = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  _addToCart(int productId) async {
    try {
      final response = await http.post(
        Uri.parse('https://fullcart-backend.onrender.com/api/cart/index.php'),
        body: jsonEncode({
          'user_id': _userId,
          'product_id': productId,
          'quantity': 1,
        }),
      );
      if (mounted) {
        _fetchCartCount();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added to cart!'), duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      print('Add to cart error: $e');
    }
  }

  _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          color: const Color(0xFF232F3E),
          child: SafeArea(
            child: Column(
              children: [
                // Top Nav
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    children: [
                      Row(
                        children: const [
                          Text('Fullcart', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('.in', style: TextStyle(fontSize: 16, color: Color(0xFFF08804))),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.mic_none, color: Colors.white),
                      const SizedBox(width: 15),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())).then((_) => _fetchCartCount());
                            },
                          ),
                          Positioned(
                            right: 4,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Color(0xFFF08804), shape: BoxShape.circle),
                              child: Text('$_cartCount', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(Icons.search, color: Colors.black54),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: (val) => _fetchProducts(search: val),
                            decoration: const InputDecoration(
                              hintText: 'Search Fullcart.in',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Container(
                          width: 45,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEBD69),
                            borderRadius: BorderRadius.horizontal(right: Radius.circular(6)),
                          ),
                          child: const Icon(Icons.search, color: Colors.black),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 50, left: 20, bottom: 20),
              color: const Color(0xFF232F3E),
              child: Row(
                children: [
                  const Icon(Icons.account_circle, color: Colors.white, size: 30),
                  const SizedBox(width: 10),
                  Text('Hello, ${_userName.split(' ').first}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(title: const Text('Home', style: TextStyle(fontWeight: FontWeight.bold)), onTap: () => Navigator.pop(context)),
            ListTile(title: const Text('Your Orders'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersScreen()))),
            ListTile(title: const Text('Your Cart'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()))),
            const Divider(),
            const Padding(padding: EdgeInsets.all(16), child: Text('Settings', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
            ListTile(title: const Text('Sign Out'), onTap: _logout),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              color: const Color(0xFF37475A),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.white, size: 18),
                  const SizedBox(width: 5),
                  Text('Deliver to ${_userName.split(' ').first} - India', style: const TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
            ),
            
            // Sub-nav Categories
            Container(
              height: 40,
              color: const Color(0xFF232F3E).withOpacity(0.9),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Center(child: Text('Prime', style: TextStyle(color: Colors.white)))),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Center(child: Text('Mobiles', style: TextStyle(color: Colors.white)))),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Center(child: Text('Fashion', style: TextStyle(color: Colors.white)))),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Center(child: Text('Electronics', style: TextStyle(color: Colors.white)))),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Center(child: Text('Home', style: TextStyle(color: Colors.white)))),
                ],
              ),
            ),

            // Hero Banner
            Image.network('https://m.media-amazon.com/images/I/61lwJy4B8PL._SX3000_.jpg', fit: BoxFit.cover, height: 200, width: double.infinity),

            // Today's Deals (Dummy Data)
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Today's Deals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _dummyDeals.length,
                      itemBuilder: (context, index) {
                        final deal = _dummyDeals[index];
                        return Container(
                          width: 150,
                          margin: const EdgeInsets.only(right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(8)),
                                child: Image.network(deal['image'], fit: BoxFit.contain),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFCC0C39), borderRadius: BorderRadius.circular(2)),
                                child: Text(deal['tag'], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 5),
                              Text('₹${deal['price']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(deal['title'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Backend Products
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Explore Marketplace", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : _products.isEmpty 
                      ? const Text('No products found.')
                      : GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(color: Color(0xFFF7F7F7)),
                                      child: Image.network(product['image_url'], fit: BoxFit.contain),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(product['title'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: const [
                                            Icon(Icons.star, color: Color(0xFFFFA41C), size: 14),
                                            Icon(Icons.star, color: Color(0xFFFFA41C), size: 14),
                                            Icon(Icons.star, color: Color(0xFFFFA41C), size: 14),
                                            Icon(Icons.star, color: Color(0xFFFFA41C), size: 14),
                                            Icon(Icons.star_half, color: Color(0xFFFFA41C), size: 14),
                                            SizedBox(width: 4),
                                            Text('1,204', style: TextStyle(fontSize: 11, color: Color(0xFF007185))),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Text('\$', style: TextStyle(fontSize: 12)),
                                            Text('${product['price']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const Text('FREE Delivery', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                        const SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () => _addToCart(product['id']),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFFFD814),
                                            foregroundColor: Colors.black,
                                            minimumSize: const Size(double.infinity, 32),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            elevation: 0,
                                          ),
                                          child: const Text('Add to Cart', style: TextStyle(fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- CART SCREEN ---
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List _items = [];
  bool _isLoading = true;
  double _total = 0;
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  _fetchCart() async {
    final prefs = await SharedPreferences.getInstance();
    final user = jsonDecode(prefs.getString('user')!);
    _userId = user['id'];
    final url = Uri.parse('https://fullcart-backend.onrender.com/api/cart/index.php?user_id=$_userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _items = data['records'] ?? [];
        _total = _items.fold(0, (sum, item) => sum + (double.parse(item['price'].toString()) * int.parse(item['quantity'].toString())));
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  _placeOrder() async {
    if (_items.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://fullcart-backend.onrender.com/api/orders/index.php'),
        body: jsonEncode({
          'user_id': _userId,
          'shipping_address': 'My Default Home Address',
        }),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed successfully!')));
        Navigator.pop(context);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalItems = _items.fold(0, (sum, item) => sum + int.parse(item['quantity'].toString()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: const Color(0xFF232F3E),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Subtotal ', style: TextStyle(fontSize: 18)),
                        Text('\$${_total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _items.isEmpty ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD814),
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: Text('Proceed to Buy ($totalItems items)'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: _items.isEmpty
                    ? const Center(child: Text('Your Amazon Cart is empty.'))
                    : ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(item['image_url'], width: 80, height: 80, fit: BoxFit.contain),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['title'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                                      const SizedBox(height: 5),
                                      Text('\$${item['price']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 5),
                                      const Text('In stock', style: TextStyle(color: Colors.green, fontSize: 12)),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            child: Text('Qty: ${item['quantity']}'),
                                          ),
                                          const SizedBox(width: 15),
                                          const Text('Delete', style: TextStyle(color: Color(0xFF007185))),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                ),
              ),
            ],
          ),
    );
  }
}

// --- ORDERS SCREEN ---
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  _fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final user = jsonDecode(prefs.getString('user')!);
    final url = Uri.parse('https://fullcart-backend.onrender.com/api/orders/index.php?user_id=${user['id']}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _orders = data['records'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
        backgroundColor: const Color(0xFF232F3E),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _orders.isEmpty
          ? const Center(child: Text('No orders found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Order #${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('\$${order['total_amount']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text('Status: ${order['status'].toString().toUpperCase()}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        Text('Placed on: ${order['created_at'].toString().split(' ')[0]}', style: const TextStyle(color: Colors.grey)),
                        const Divider(height: 20),
                        ...(order['items'] as List).map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Image.network(item['image_url'], width: 50, height: 50, fit: BoxFit.contain),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['title'], maxLines: 1, overflow: TextOverflow.ellipsis),
                                      Text('Qty: ${item['quantity']} | \$${item['price']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
