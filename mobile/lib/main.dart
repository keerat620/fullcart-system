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
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ProfilePage(),
    const CartScreen(),
    const MenuPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF007185), // Amazon teal
        unselectedItemColor: Colors.black54,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'You'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
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
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
            (route) => false,
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
          const SnackBar(content: Text('Connection error. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Fullcart', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
            Text('.in', style: TextStyle(fontSize: 18, color: Color(0xFFF08804))),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Welcome', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sign in', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    const Text('Email or mobile phone number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
                      decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12), isDense: true),
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
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Text('Continue'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('New to Fullcart?', style: TextStyle(fontSize: 12, color: Colors.grey))),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created! Please login.')));
          Navigator.pop(context);
        }
      } else {
        final result = jsonDecode(response.body);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Registration failed')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection error. Please try again.')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),
              const Text('Your name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(controller: _nameController, decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12), isDense: true)),
              const SizedBox(height: 15),
              const Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(controller: _emailController, decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12), isDense: true)),
              const SizedBox(height: 15),
              const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12), isDense: true, hintText: 'At least 6 characters')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD814), foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Text('Verify email'),
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
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _dummyDeals = [
    {"title": "Apple iPhone 15 (128 GB) - Blue", "price": "69,999", "image": "https://m.media-amazon.com/images/I/71X8X4tWNEL._AC_UY327_FMwebp_QL65_.jpg", "tag": "15% off"},
    {"title": "Sony WH-1000XM5 Headphones", "price": "24,990", "image": "https://m.media-amazon.com/images/I/61N98Xh+cCL._AC_UY327_FMwebp_QL65_.jpg", "tag": "20% off"},
    {"title": "Samsung Galaxy S24 Ultra", "price": "1,29,999", "image": "https://m.media-amazon.com/images/I/718V385D+3L._AC_UY327_FMwebp_QL65_.jpg", "tag": "10% off"}
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
        _userName = user['name'] ?? 'User';
        _userId = user['id'] ?? 0;
      });
    }
  }

  _fetchProducts({String search = ''}) async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('https://fullcart-backend.onrender.com/api/products/list.php?search=$search');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _products = data['records'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() { _products = []; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          color: const Color(0xFF232F3E),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      children: [
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Icon(Icons.search, color: Colors.black54)),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: (val) => _fetchProducts(search: val),
                            decoration: const InputDecoration(hintText: 'Search Fullcart.in', border: InputBorder.none),
                          ),
                        ),
                        Container(
                          width: 45,
                          decoration: const BoxDecoration(color: Color(0xFFFEBD69), borderRadius: BorderRadius.horizontal(right: Radius.circular(6))),
                          child: const Icon(Icons.camera_alt_outlined, color: Colors.black54),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              color: const Color(0xFF37475A),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.white, size: 18),
                  const SizedBox(width: 5),
                  Expanded(child: Text('Deliver to ${_userName.isNotEmpty ? _userName.split(' ').first : 'Guest'} - India', style: const TextStyle(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
            Container(
              height: 40,
              color: const Color(0xFF232F3E).withOpacity(0.9),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Center(child: Text('Prime', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Center(child: Text('Mobiles', style: TextStyle(color: Colors.white)))),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Center(child: Text('Fashion', style: TextStyle(color: Colors.white)))),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Center(child: Text('Electronics', style: TextStyle(color: Colors.white)))),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Center(child: Text('MiniTV', style: TextStyle(color: Colors.white)))),
                ],
              ),
            ),
            Image.network('https://m.media-amazon.com/images/I/61lwJy4B8PL._SX3000_.jpg', fit: BoxFit.cover, height: 200, width: double.infinity),
            const Padding(padding: EdgeInsets.all(15), child: Text("Deal of the Day", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: _dummyDeals.length,
                itemBuilder: (context, index) {
                  final deal = _dummyDeals[index];
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(4)),
                            child: Image.network(deal['image'], fit: BoxFit.contain),
                          )
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFCC0C39), borderRadius: BorderRadius.circular(2)),
                          child: Text(deal['tag'], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 5),
                        Text('₹${deal['price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(deal['title'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Padding(padding: EdgeInsets.all(15), child: Text("Explore Marketplace", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            _isLoading 
              ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              : GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsPage(product: product, userId: _userId)));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Container(width: double.infinity, padding: const EdgeInsets.all(8), color: const Color(0xFFF7F7F7), child: Image.network(product['image_url'], fit: BoxFit.contain))),
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
                                  Text('\$${product['price']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const Text('prime', style: TextStyle(color: Color(0xFF00A8E1), fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// --- PRODUCT DETAILS PAGE (NEW) ---
class ProductDetailsPage extends StatefulWidget {
  final Map product;
  final int userId;
  const ProductDetailsPage({super.key, required this.product, required this.userId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool _isAdding = false;

  _addToCart() async {
    if (widget.userId == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      return;
    }
    setState(() => _isAdding = true);
    try {
      await http.post(
        Uri.parse('https://fullcart-backend.onrender.com/api/cart/index.php'),
        body: jsonEncode({
          'user_id': widget.userId,
          'product_id': widget.product['id'],
          'quantity': 1,
        }),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Cart'), backgroundColor: Colors.green));
      }
    } catch (e) {} finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF232F3E),
        title: const Text('Product Details', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery placeholder
            Container(
              height: 300,
              width: double.infinity,
              color: const Color(0xFFF7F7F7),
              child: Stack(
                children: [
                  Center(child: Image.network(widget.product['image_url'], fit: BoxFit.contain, height: 280)),
                  Positioned(top: 10, right: 10, child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]), child: const Icon(Icons.share, size: 20))),
                  Positioned(bottom: 10, left: 10, child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]), child: const Icon(Icons.favorite_border, size: 20))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product['title'], style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4)),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Icon(Icons.star, color: Color(0xFFFFA41C), size: 20),
                      Icon(Icons.star, color: Color(0xFFFFA41C), size: 20),
                      Icon(Icons.star, color: Color(0xFFFFA41C), size: 20),
                      Icon(Icons.star, color: Color(0xFFFFA41C), size: 20),
                      Icon(Icons.star_half, color: Color(0xFFFFA41C), size: 20),
                      SizedBox(width: 5),
                      Text('1,204 ratings', style: TextStyle(color: Color(0xFF007185))),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: const Color(0xFF232F3E),
                    child: const Text("Amazon's Choice", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  const Divider(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('\$', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.5)),
                      Text('${widget.product['price']}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(text: 'FREE delivery ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: 'Tomorrow, March 19', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: '. Order within 5 hrs 30 mins. '),
                        TextSpan(text: 'Details', style: TextStyle(color: Color(0xFF007185))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text('In Stock', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _isAdding ? null : _addToCart,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD814), foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
                    child: _isAdding ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Text('Add to Cart'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFA41C), foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
                    child: const Text('Buy Now'),
                  ),
                  const SizedBox(height: 20),
                  Row(children: const [Icon(Icons.lock_outline, size: 16, color: Colors.grey), SizedBox(width: 5), Text('Secure transaction', style: TextStyle(color: Color(0xFF007185)))]),
                  const Divider(height: 30),
                  const Text('Product Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(widget.product['description'] ?? 'No description available.', style: const TextStyle(height: 1.5)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PROFILE PAGE (YOU TAB) ---
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = 'Guest';
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final user = jsonDecode(userJson);
      setState(() {
        _userName = user['name'] ?? 'User';
        _isLoggedIn = true;
      });
    }
  }

  _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Account')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD814), foregroundColor: Colors.black),
            child: const Text('Sign In'),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: const [
              Text('Fullcart', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
              Text('.in', style: TextStyle(fontSize: 16, color: Color(0xFFF08804))),
            ],
          ),
          actions: [
            IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black), onPressed: () {}),
            IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hello, ${_userName.split(' ').first}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w400)),
                  const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(child: _buildActionBtn('Your Orders', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersScreen())))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildActionBtn('Buy Again', () {})),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(child: _buildActionBtn('Your Account', () {})),
                  const SizedBox(width: 10),
                  Expanded(child: _buildActionBtn('Your Lists', () {})),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 4, color: Color(0xFFEAEDED)),
            ListTile(title: const Text('Sign Out', style: TextStyle(color: Colors.red)), onTap: _logout),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(String title, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
    );
  }
}

// --- MENU PAGE ---
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Menu', style: TextStyle(color: Colors.black)),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(15),
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 1.5,
        children: [
          _buildMenuCard('Amazon Pay', 'https://m.media-amazon.com/images/G/31/img19/AmazonPay/GTM/2022/June/SBC_En_1x._CB633890372_.jpg'),
          _buildMenuCard('Mobiles & Gadgets', 'https://m.media-amazon.com/images/I/71X8X4tWNEL._AC_UY327_FMwebp_QL65_.jpg'),
          _buildMenuCard('Electronics', 'https://images-eu.ssl-images-amazon.com/images/G/31/img22/Electronics/Clearance/SBC_En_1x._CB627310065_.jpg'),
          _buildMenuCard('Home & Kitchen', 'https://images-eu.ssl-images-amazon.com/images/G/31/IMG15/IHT/PC_SBC_1L._CB584517173_.jpg'),
        ],
      ),
    );
  }

  Widget _buildMenuCard(String title, String imgUrl) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(8)), child: Image.network(imgUrl, fit: BoxFit.cover))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          )
        ],
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
    final userJson = prefs.getString('user');
    if (userJson == null) {
      setState(() => _isLoading = false);
      return;
    }
    final user = jsonDecode(userJson);
    _userId = user['id'];
    final url = Uri.parse('https://fullcart-backend.onrender.com/api/cart/index.php?user_id=$_userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _items = data['records'] ?? [];
        _total = 0;
        for (var item in _items) {
          _total += (double.parse(item['price'].toString()) * int.parse(item['quantity'].toString()));
        }
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
        _fetchCart();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cart')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD814), foregroundColor: Colors.black),
            child: const Text('Sign In to view Cart'),
          ),
        ),
      );
    }

    int totalItems = _items.fold(0, (sum, item) => sum + int.parse(item['quantity'].toString()));

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: const [
                      Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Icon(Icons.search, color: Colors.black54)),
                      Expanded(child: Text('Search Fullcart.in', style: TextStyle(color: Colors.grey, fontSize: 14))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
                                            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8), color: const Color(0xFFF0F2F2)),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            child: Text('Qty: ${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                          const SizedBox(width: 15),
                                          const Text('Delete', style: TextStyle(color: Color(0xFF007185))),
                                          const SizedBox(width: 15),
                                          const Text('Save for later', style: TextStyle(color: Color(0xFF007185))),
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
    final userJson = prefs.getString('user');
    if (userJson == null) return;
    final user = jsonDecode(userJson);
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
      appBar: AppBar(title: const Text('Your Orders', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black), elevation: 1),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _orders.isEmpty
          ? const Center(child: Text('No orders found.'))
          : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.white,
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
                      Text('Arriving soon', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      const Divider(height: 20),
                      ...(order['items'] as List).map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Image.network(item['image_url'], width: 60, height: 60, fit: BoxFit.contain),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['title'], maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 5),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD814), minimumSize: const Size(120, 30), padding: const EdgeInsets.symmetric(horizontal: 15)),
                                      child: const Text('Buy it again', style: TextStyle(color: Colors.black, fontSize: 12)),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
