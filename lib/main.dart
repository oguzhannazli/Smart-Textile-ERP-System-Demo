import 'package:flutter/material.dart';

void main() {
  runApp(const FinanceApp());
}

// -----------------------------------------------------------------------------
// CHAT SERVICE (Global Shared State)
// -----------------------------------------------------------------------------
class ChatMessage {
  final String text;
  final bool isClient;
  final String time;

  ChatMessage({required this.text, required this.isClient, required this.time});
}

class ChatSession {
  final String clientName;
  final List<ChatMessage> messages;
  int unreadByOwner;

  ChatSession({
    required this.clientName,
    required this.messages,
    this.unreadByOwner = 0,
  });
}

class ChatService extends ChangeNotifier {
  static final ChatService instance = ChatService._internal();

  ChatService._internal() {
    _sessions.add(ChatSession(
      clientName: 'Alex Johnson',
      messages: [
        ChatMessage(text: 'Do you have the Wireless Earbuds in black?', isClient: true, time: '10:30'),
        ChatMessage(text: 'Yes, we have 50 units left.', isClient: false, time: '10:35'),
      ],
      unreadByOwner: 0,
    ));
    _sessions.add(ChatSession(
      clientName: 'Sarah Miller',
      messages: [
        ChatMessage(text: 'Can I get an invoice for my last order?', isClient: true, time: '11:15'),
      ],
      unreadByOwner: 1,
    ));
    _sessions.add(ChatSession(
      clientName: 'Current Client',
      messages: [
        ChatMessage(text: 'Hello! Welcome to our store. How can I assist you today?', isClient: false, time: '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}'),
      ],
      unreadByOwner: 0,
    ));
  }

  final List<ChatSession> _sessions = [];

  List<ChatSession> get sessions => _sessions;

  ChatSession getSession(String clientName) {
    return _sessions.firstWhere((s) => s.clientName == clientName);
  }

  int get totalUnreadByOwner {
    return _sessions.fold(0, (sum, s) => sum + s.unreadByOwner);
  }

  void sendMessage(String clientName, String text, bool isClient) {
    final session = getSession(clientName);
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    session.messages.add(ChatMessage(text: text, isClient: isClient, time: timeStr));
    
    if (isClient) {
      session.unreadByOwner += 1;
    }
    notifyListeners();
  }

  void markAsReadByOwner(String clientName) {
    final session = getSession(clientName);
    if (session.unreadByOwner > 0) {
      session.unreadByOwner = 0;
      notifyListeners();
    }
  }
}

// -----------------------------------------------------------------------------
// MODELS
// -----------------------------------------------------------------------------
class Product {
  final String id;
  final String name;
  final double price;
  final double cost;
  final double commissionRate;
  final double shippingCost;
  final double advertisingCost;
  final double returnRate;
  int salesCount;
  int stock; // Added stock for real-time B2B integration

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.cost,
    required this.commissionRate,
    required this.shippingCost,
    required this.advertisingCost,
    required this.returnRate,
    required this.salesCount,
    required this.stock,
  });

  double get commissionFee => price * (commissionRate / 100);
  double get adCost => price * (advertisingCost / 100);
  double get returnCost => price * (returnRate / 100);

  double get netProfitPerUnit =>
      price - cost - commissionFee - shippingCost - adCost - returnCost;
  double get totalNetProfit => netProfitPerUnit * salesCount;
  double get totalRevenue => price * salesCount;
  double get profitMargin => price > 0 ? (netProfitPerUnit / price) * 100 : 0.0;

  double get totalAdSpend => adCost * salesCount;
  double get roas => totalAdSpend > 0 ? totalRevenue / totalAdSpend : 0.0;

  String get status {
    if (profitMargin >= 30) return 'Excellent';
    if (profitMargin >= 15) return 'Profitable';
    if (profitMargin > 0) return 'Moderate';
    return 'Loss';
  }

  Color getStatusColor(bool isDark) {
    if (profitMargin >= 30)
      return isDark ? Colors.green.shade400 : Colors.green;
    if (profitMargin >= 15) return isDark ? Colors.blue.shade400 : Colors.blue;
    if (profitMargin > 0)
      return isDark ? Colors.orange.shade400 : Colors.orange;
    return isDark ? Colors.red.shade400 : Colors.red;
  }
}

// Global Products list for absolute dynamic state across all screens
List<Product> globalProducts = [
  Product(
    id: '1',
    name: 'Oversized Cotton Hoodie',
    price: 49.99,
    cost: 15.0,
    commissionRate: 10.0,
    shippingCost: 4.0,
    advertisingCost: 8.0,
    returnRate: 6.0,
    salesCount: 2450,
    stock: 240,
  ),
  Product(
    id: '2',
    name: 'Slim Fit Denim Jacket',
    price: 79.99,
    cost: 28.0,
    commissionRate: 10.0,
    shippingCost: 5.0,
    advertisingCost: 12.0,
    returnRate: 4.0,
    salesCount: 1240,
    stock: 85,
  ),
  Product(
    id: '3',
    name: 'Linen Summer Shirt',
    price: 39.99,
    cost: 11.0,
    commissionRate: 12.0,
    shippingCost: 4.5,
    advertisingCost: 7.0,
    returnRate: 5.0,
    salesCount: 3120,
    stock: 400,
  ),
  Product(
    id: '4',
    name: 'Premium Fleece Joggers',
    price: 44.99,
    cost: 13.0,
    commissionRate: 10.0,
    shippingCost: 4.0,
    advertisingCost: 6.0,
    returnRate: 8.0,
    salesCount: 1850,
    stock: 180,
  ),
  Product(
    id: '5',
    name: 'Classic Crewneck Tee',
    price: 24.99,
    cost: 6.0,
    commissionRate: 15.0,
    shippingCost: 3.5,
    advertisingCost: 4.0,
    returnRate: 3.0,
    salesCount: 4200,
    stock: 500,
  ),
];

class FinanceApp extends StatefulWidget {
  const FinanceApp({super.key});

  @override
  State<FinanceApp> createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp> {
  bool _isDarkMode = false;
  bool _showSplash = true;
  bool _isAuthenticated = false;
  String _userName = '';
  String _userEmail = '';
  bool _isGuest = false;
  String? _selectedRole;

  final List<Product> _products = globalProducts;

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  void _addProduct(Product p) {
    setState(() {
      _products.add(p);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Analytics',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E293B), // Dark navy
          brightness: Brightness.light,
          primary: const Color(0xFF1E293B),
          secondary: const Color(0xFF8B5CF6), // Purple
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E293B),
          brightness: Brightness.dark,
          primary: const Color(0xFF8B5CF6),
          secondary: const Color(0xFF8B5CF6),
          surface: const Color(0xFF1E293B),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFF1E293B),
        ),
      ),
      home: _showSplash
          ? SplashScreen(
              onInitializationComplete: () {
                setState(() {
                  _showSplash = false;
                });
              },
            )
          : _isAuthenticated
          ? (_selectedRole == null
                ? RoleSelectionScreen(
                    userName: _userName,
                    isGuest: _isGuest,
                    onRoleSelected: (role) {
                      setState(() {
                        _selectedRole = role;
                      });
                    },
                  )
                : MainDashboard(
                    isDarkMode: _isDarkMode,
                    onThemeChanged: _toggleTheme,
                    products: _products,
                    selectedRole: _selectedRole!,
                    onAddProduct: _addProduct,
                    onLogout: () {
                      setState(() {
                        _isAuthenticated = false;
                        _selectedRole = null;
                      });
                    },
                    userName: _userName,
                    userEmail: _userEmail,
                    isGuest: _isGuest,
                    onProfileUpdated: (name, email) {
                      setState(() {
                        _userName = name;
                        _userEmail = email;
                      });
                    },
                  ))
          : LoginScreen(
              onLoginSuccess: (name, email, role) {
                setState(() {
                  _isAuthenticated = true;
                  _userName = name;
                  _userEmail = email;
                  _isGuest = false;
                  _selectedRole = role; // Role selection ekranÄ±nÄ± atla
                });
              },
              onGuestLogin: () {
                setState(() {
                  _isAuthenticated = true;
                  _userName = 'Guest User';
                  _userEmail = 'guest@finance.app';
                  _isGuest = true;
                });
              },
            ),
    );
  }
}

class MainDashboard extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final List<Product> products;
  final String selectedRole;
  final ValueChanged<Product> onAddProduct;
  final VoidCallback onLogout;
  final String userName;
  final String userEmail;
  final bool isGuest;
  final Function(String, String) onProfileUpdated;

  const MainDashboard({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.products,
    required this.selectedRole,
    required this.onAddProduct,
    required this.onLogout,
    required this.userName,
    required this.userEmail,
    required this.isGuest,
    required this.onProfileUpdated,
  });

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToSimulation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScenarioSimulationScreen()),
    );
  }

  void _navigateToCompletedSale() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CompletedSaleProfitScreen(),
      ),
    );
  }

  void _navigateToTotalProfit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TotalBusinessProfitScreen(),
      ),
    );
  }

  void _navigateToAiStockAdvisor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AiStockAdvisorScreen()),
    );
  }

  void _navigateToAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          onSave: (product) {
            widget.onAddProduct(product);
          },
        ),
      ),
    );
  }

  Widget _buildRoleDashboard() {
    switch (widget.selectedRole) {
      case 'Admin':
        return AdminDashboardScreen(
          userEmail: widget.userEmail,
          userName: widget.userName,
        );
      case 'Client':
        return ClientDashboardScreen(
          userEmail: widget.userEmail,
          userName: widget.userName,
        );
      case 'Supplier':
        return SupplierDashboardScreen(
          userEmail: widget.userEmail,
          userName: widget.userName,
        );
      case 'Owner':
      default:
        return DashboardScreen(
          onSimulateTap: _navigateToSimulation,
          onCompletedSaleTap: _navigateToCompletedSale,
          onTotalProfitTap: _navigateToTotalProfit,
          onAiStockAdvisorTap: _navigateToAiStockAdvisor,
          products: widget.products,
          onAddProductTap: _navigateToAddProduct,
          onSeeAllTap: () => _onTabTapped(1),
          onAiInsightsTap: () => _onTabTapped(3),
          userEmail: widget.userEmail,
          userName: widget.userName,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [];
    List<NavigationDestination> destinations = [];

    Widget profileScreen = ProfileScreen(
      isDarkMode: widget.isDarkMode,
      onThemeChanged: widget.onThemeChanged,
      onLogout: widget.onLogout,
      userName: widget.userName,
      userEmail: widget.userEmail,
      isGuest: widget.isGuest,
      selectedRole: widget.selectedRole,
      onProfileUpdated: widget.onProfileUpdated,
    );

    if (widget.selectedRole == 'Client') {
      screens = [
        _buildRoleDashboard(),
        const ClientProductCatalogScreen(),
        const MyOffersScreen(),
        const AIAssistantScreen(),
        profileScreen,
      ];
      destinations = const [
        NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: 'Catalog'),
        NavigationDestination(icon: Icon(Icons.local_offer_outlined), selectedIcon: Icon(Icons.local_offer), label: 'Offers'),
        NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'AI'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ];
    } else if (widget.selectedRole == 'Supplier') {
      screens = [
        _buildRoleDashboard(),
        SupplierOpenRequestsScreen(supplierName: widget.userName),
        const AIAssistantScreen(),
        profileScreen,
      ];
      destinations = const [
        NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Requests'),
        NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'AI'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ];
    } else if (widget.selectedRole == 'Admin') {
      screens = [
        AdminDashboardScreen(
          userEmail: widget.userEmail,
          userName: widget.userName,
          initialTab: 0,
        ),
        AdminDashboardScreen(
          userEmail: widget.userEmail,
          userName: widget.userName,
          initialTab: 2,
        ),
        profileScreen,
      ];
      destinations = const [
        NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.confirmation_number_outlined), selectedIcon: Icon(Icons.confirmation_number), label: 'Tickets'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ];
    } else {
      // Owner
      screens = [
        _buildRoleDashboard(),
        ProductsScreen(products: widget.products, onAddProductTap: _navigateToAddProduct),
        const AnalyticsScreen(),
        const AIAssistantScreen(),
        profileScreen,
      ];
      destinations = const [
        NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Products'),
        NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Analytics'),
        NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'AI'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ];
    }

    // Handle index out of bounds if switching roles
    int currentIndex = _currentIndex;
    if (currentIndex >= screens.length) {
      currentIndex = 0;
    }

    return Scaffold(
      body: SafeArea(child: screens[currentIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: _onTabTapped,
        destinations: destinations,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// REUSABLE WIDGETS
// -----------------------------------------------------------------------------

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GradientHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final double? height;
  final bool showBackButton;

  const GradientHeader({
    super.key,
    required this.title,
    this.trailing,
    this.height,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF4C1D95)], // Navy to dark purple
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showBackButton)
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. DASHBOARD SCREEN
// -----------------------------------------------------------------------------
class DashboardScreen extends StatelessWidget {
  final VoidCallback onSimulateTap;
  final VoidCallback onCompletedSaleTap;
  final VoidCallback onTotalProfitTap;
  final VoidCallback onAiStockAdvisorTap;
  final List<Product> products;
  final VoidCallback onAddProductTap;
  final VoidCallback onSeeAllTap;
  final VoidCallback onAiInsightsTap;
  final String userEmail;
  final String userName;

  const DashboardScreen({
    super.key,
    required this.onSimulateTap,
    required this.onCompletedSaleTap,
    required this.onTotalProfitTap,
    required this.onAiStockAdvisorTap,
    required this.products,
    required this.onAddProductTap,
    required this.onSeeAllTap,
    required this.onAiInsightsTap,
    required this.userEmail,
    required this.userName,
  });

  IconData _getProductIcon(String name) {
    if (name.contains('Hoodie')) return Icons.checkroom;
    if (name.contains('Jacket')) return Icons.dry_cleaning;
    if (name.contains('Shirt')) return Icons.layers;
    if (name.contains('Joggers')) return Icons.style;
    return Icons.shopping_bag;
  }

  Color _getProductColor(String name) {
    if (name.contains('Hoodie')) return Colors.indigo;
    if (name.contains('Jacket')) return Colors.blueGrey;
    if (name.contains('Shirt')) return Colors.amber;
    if (name.contains('Joggers')) return Colors.teal;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    double totalRevenue = products.fold(0, (sum, p) => sum + p.totalRevenue);
    double totalProfit = products.fold(0, (sum, p) => sum + p.totalNetProfit);
    double overallMargin = totalRevenue > 0 ? (totalProfit / totalRevenue) * 100 : 0;
    double totalAdSpend = products.fold(0, (sum, p) => sum + p.totalAdSpend);
    double totalRoas = totalAdSpend > 0 ? totalRevenue / totalAdSpend : 0;

    final topProducts = List<Product>.from(products)
      ..sort((a, b) => b.totalNetProfit.compareTo(a.totalNetProfit));
    final displayTopProducts = topProducts.take(3).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- PREMIUM GRADIENT HEADER ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF3B0764)], // Slate to Deep Violet
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Owner Console',
                          style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                          onPressed: onAddProductTap,
                          tooltip: 'Add Product',
                        ),
                        const SizedBox(width: 8),
                        StatefulBuilder(
                          builder: (context, setState) {
                            final unreadCount = globalOwnerNotifications.where((n) => !n['read']).length;
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const OwnerNotificationsScreen()),
                                ).then((_) => setState(() {}));
                              },
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.white.withOpacity(0.1),
                                    child: const Icon(Icons.notifications_none_outlined, color: Colors.white),
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          unreadCount.toString(),
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- NEON GLOW METRICS ---
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.35,
                  children: [
                    _buildStatCard(
                      context,
                      'Net Profit',
                      '\$${totalProfit.toStringAsFixed(0)}',
                      '+12% Today',
                      Colors.teal,
                      Icons.trending_up,
                      isDark,
                    ),
                    _buildStatCard(
                      context,
                      'Profit Margin',
                      '${overallMargin.toStringAsFixed(1)}%',
                      '+2.1% MoM',
                      Colors.teal,
                      Icons.pie_chart_outline,
                      isDark,
                    ),
                    _buildStatCard(
                      context,
                      'Total ROAS',
                      '${totalRoas.toStringAsFixed(1)}x',
                      '-0.5% vs LW',
                      Colors.redAccent,
                      Icons.auto_graph,
                      isDark,
                    ),
                    _buildStatCard(
                      context,
                      'Products Count',
                      '${products.length} Active',
                      '+1 Added',
                      Colors.blue,
                      Icons.shopping_bag_outlined,
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- PROMIMENT ADD TEXTILE PRODUCT BANNER ---
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: InkWell(
                    onTap: onAddProductTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4C1D95), Color(0xFF2563EB)], // Purple to Royal Blue
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF4C1D95).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_business, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Add New Textile Product',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white, letterSpacing: -0.2),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Launch catalog insertion. Add new hoodies, jackets, shirts, joggers.',
                                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),

                // --- PROMIMENT B2B SUPPLY ORDERS BANNER ---
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OwnerSupplyRequestsScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFFC084FC)], // Violet to Lavender
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Wholesale Supply Listings',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white, letterSpacing: -0.2),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Launch supply listings & manage proposals from active suppliers.',
                                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),

                // --- PENDING CLIENT OFFERS ACTION CARD ---
                StatefulBuilder(
                  builder: (context, setState) {
                    final pendingCount = globalClientOffers.where((o) => o['status'] == 'Pending').length;
                    if (pendingCount == 0) return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OwnerClientOffersScreen()),
                          ).then((_) => setState(() {}));
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEA580C), Color(0xFFC2410C)], // Rich Orange
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                child: const Icon(Icons.handshake_outlined, color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Incoming Client Offers!',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$pendingCount offers are waiting. Accept to update stocks!',
                                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // --- AI INSIGHTS BANNER ---
                InkWell(
                  onTap: onAiInsightsTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E1B4B), const Color(0xFF311042)]
                            : [const Color(0xFFF3E8FF), const Color(0xFFE0F2FE)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? Colors.purple.shade900 : Colors.purple.shade100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white12 : Colors.white70,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.auto_awesome_outlined, color: Colors.purple.shade400, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Insights Available',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'We found 3 ways to optimize your margins.',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.purple.shade400),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // --- OPERATIONS HUB GRID (MODERNIZED & SYMMETRICAL) ---
                Text(
                  'Operations Hub',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.88,
                  children: [
                    _buildHubCard(
                      context,
                      'Simulator',
                      'Predict price effects',
                      Icons.model_training_outlined,
                      const [Color(0xFF6366F1), Color(0xFF4F46E5)], // Indigo
                      onSimulateTap,
                    ),
                    _buildHubCard(
                      context,
                      'Profit Charts',
                      'Real-time stats',
                      Icons.donut_large_outlined,
                      const [Color(0xFF2563EB), Color(0xFF1D4ED8)], // Blue
                      onTotalProfitTap,
                    ),
                    _buildHubCard(
                      context,
                      'Stock Advisor',
                      'Reorder forecasts',
                      Icons.psychology_outlined,
                      const [Color(0xFF4F46E5), Color(0xFF7C3AED)], // Purple
                      onAiStockAdvisorTap,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Beautiful Premium Support Helpdesk Banner
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserSupportTicketsScreen(
                        userEmail: userEmail,
                        userName: userName,
                        userRole: 'Owner',
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF0D9488)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.teal.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.support_agent, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Support & Help Center',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Submit a ticket directly to system administrators.',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // --- TOP PRODUCTS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top Performing Products',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextButton(
                      onPressed: onSeeAllTap,
                      child: const Text('See All', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...displayTopProducts.map(
                  (p) => _buildTopProductItem(
                    context,
                    p.name,
                    '\$${p.price.toStringAsFixed(2)}',
                    '${p.salesCount} sales completed',
                    isDark,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    String change,
    Color changeColor,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(icon, size: 18, color: changeColor.withOpacity(0.8)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              change,
              style: TextStyle(
                color: changeColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHubCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B).withOpacity(0.6) : const Color(0xFFF4F6F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.02) : Colors.black.withOpacity(0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(
    BuildContext context,
    String label,
    double value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
          color: color,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _buildTopProductItem(
    BuildContext context,
    String name,
    String price,
    String sales,
    bool isDark,
  ) {
    final themeColor = _getProductColor(name);
    final icon = _getProductIcon(name);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: themeColor, size: 22),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          sales,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
          ),
        ),
        trailing: Text(
          price,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: themeColor,
          ),
        ),
      ),
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  final String userName;
  final bool isGuest;
  final ValueChanged<String> onRoleSelected;

  const RoleSelectionScreen({
    super.key,
    required this.userName,
    required this.isGuest,
    required this.onRoleSelected,
  });

  Widget _buildRoleCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color1,
    Color color2,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: color1.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => onRoleSelected(title),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color1.withOpacity(0.1), color2.withOpacity(0.05)],
            ),
            border: Border.all(color: color1.withOpacity(0.2)),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color1, color2]),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const GradientHeader(title: 'Select Role', showBackButton: false),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, $userName!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please select your role to continue to your customized dashboard.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildRoleCard(
                      context,
                      'Owner',
                      'Full access to analytics, AI insights, and products.',
                      Icons.admin_panel_settings,
                      Colors.purple,
                      Colors.deepPurple,
                    ),
                    _buildRoleCard(
                      context,
                      'Admin',
                      'Manage users, products, orders, and offers.',
                      Icons.manage_accounts,
                      Colors.blue,
                      Colors.indigo,
                    ),
                    _buildRoleCard(
                      context,
                      'Client',
                      'Browse products, send offers, and track orders.',
                      Icons.person,
                      Colors.teal,
                      Colors.green,
                    ),
                    _buildRoleCard(
                      context,
                      'Supplier',
                      'Manage stock capacity and supply proposals.',
                      Icons.local_shipping,
                      Colors.orange,
                      Colors.deepOrange,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  final String userEmail;
  final String userName;
  final int initialTab;

  const AdminDashboardScreen({
    super.key,
    required this.userEmail,
    required this.userName,
    this.initialTab = 0,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Navigation: 0 = Stats, 1 = User Directory, 2 = Support Tickets
  late int _adminTab;

  @override
  void initState() {
    super.initState();
    _adminTab = widget.initialTab;
  }

  @override
  void didUpdateWidget(AdminDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _adminTab = widget.initialTab;
    }
  }

  // Search & Filter state for Users
  String _userSearchQuery = '';
  String _roleFilter = 'All Roles';
  String _statusFilter = 'All Statuses';
  String _sortOption = 'Name A-Z';

  // Search & Filter state for Tickets
  String _ticketStatusFilter = 'All Tickets';

  // Ticket reply controllers
  final _replyCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Premium Header with Title
        Container(
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)], // Professional dark navy
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SYSTEM ADMINISTRATION',
                        style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Welcome, ${widget.userName}',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.blueAccent.withOpacity(0.2),
                    radius: 20,
                    child: const Icon(Icons.security, color: Colors.blueAccent, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Symmetrical modern horizontal tabs
              Row(
                children: [
                  _buildTabButton(0, 'Overview', Icons.dashboard_outlined),
                  const SizedBox(width: 8),
                  _buildTabButton(1, 'Directory', Icons.people_outline),
                  const SizedBox(width: 8),
                  _buildTabButton(2, 'Tickets', Icons.confirmation_number_outlined),
                ],
              ),
            ],
          ),
        ),
        
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _buildSelectedTabContent(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _adminTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _adminTab = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.white70),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent(bool isDark) {
    switch (_adminTab) {
      case 1:
        return _buildUserDirectoryView(isDark);
      case 2:
        return _buildSupportTicketsView(isDark);
      case 0:
      default:
        return _buildOverviewStatsView(isDark);
    }
  }

  // --- 1. OVERVIEW STATS TAB ---
  Widget _buildOverviewStatsView(bool isDark) {
    // Dynamic real-time calculation
    final totalUsers = globalAccounts.length;
    final totalOwners = globalAccounts.where((a) => a['role'] == 'Owner').length;
    final totalSuppliers = globalAccounts.where((a) => a['role'] == 'Supplier').length;
    final totalClients = globalAccounts.where((a) => a['role'] == 'Client').length;
    final activeUsers = globalAccounts.where((a) => a['status'] == 'Active').length;
    final inactiveUsers = globalAccounts.where((a) => a['status'] == 'Inactive').length;

    final pendingTkts = globalTickets.where((t) => t['status'] == 'Pending').length;
    final progressTkts = globalTickets.where((t) => t['status'] == 'In Progress').length;
    final resolvedTkts = globalTickets.where((t) => t['status'] == 'Resolved').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'System Overview Stats',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDynamicStatCard(
                'Total Users',
                '$totalUsers',
                'Registered',
                Icons.people,
                Colors.blue,
                isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDynamicStatCard(
                'Active Users',
                '$activeUsers',
                'Status: Active',
                Icons.check_circle_outline,
                Colors.green,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDynamicStatCard(
                'Store Owners',
                '$totalOwners',
                'Active Retailers',
                Icons.storefront,
                Colors.indigo,
                isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDynamicStatCard(
                'Suppliers',
                '$totalSuppliers',
                'Manufacturers',
                Icons.business,
                Colors.teal,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDynamicStatCard(
                'Wholesale Clients',
                '$totalClients',
                'Buyers',
                Icons.shopping_bag_outlined,
                Colors.purple,
                isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDynamicStatCard(
                'Deactivated',
                '$inactiveUsers',
                'Soft Deleted',
                Icons.block,
                Colors.red,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Support Desk Stats',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade100),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              _buildTicketStatRow('Pending Admin Review', pendingTkts, Colors.orange),
              const Divider(height: 24),
              _buildTicketStatRow('Under Investigation (In Progress)', progressTkts, Colors.blue),
              const Divider(height: 24),
              _buildTicketStatRow('Resolved Issues', resolvedTkts, Colors.green),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketStatRow(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }

  // --- 2. USER DIRECTORY TAB ---
  Widget _buildUserDirectoryView(bool isDark) {
    // Apply filters, search and sort
    final List<Map<String, String>> filteredUsers = globalAccounts.where((user) {
      final name = (user['name'] ?? '').toLowerCase();
      final email = (user['email'] ?? '').toLowerCase();
      final query = _userSearchQuery.toLowerCase();
      final matchesQuery = name.contains(query) || email.contains(query);

      final matchesRole = _roleFilter == 'All Roles' || user['role'] == _roleFilter;
      final matchesStatus = _statusFilter == 'All Statuses' || user['status'] == _statusFilter;

      return matchesQuery && matchesRole && matchesStatus;
    }).toList();

    // Sorting
    filteredUsers.sort((a, b) {
      if (_sortOption == 'Name A-Z') {
        return (a['name'] ?? '').compareTo(b['name'] ?? '');
      } else if (_sortOption == 'Name Z-A') {
        return (b['name'] ?? '').compareTo(a['name'] ?? '');
      } else {
        // Date
        return (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? '');
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('User Management Directory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // Search Box
        TextField(
          onChanged: (val) => setState(() => _userSearchQuery = val),
          decoration: InputDecoration(
            labelText: 'Search by name or email...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            filled: true,
            fillColor: isDark ? Colors.white10 : Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 12),

        // Filters Row
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _roleFilter,
                decoration: InputDecoration(
                  labelText: 'Filter Role',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: ['All Roles', 'Owner', 'Supplier', 'Client'].map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (val) => setState(() => _roleFilter = val ?? 'All Roles'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _statusFilter,
                decoration: InputDecoration(
                  labelText: 'Filter Status',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: ['All Statuses', 'Active', 'Inactive'].map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (val) => setState(() => _statusFilter = val ?? 'All Statuses'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Sorting Row
        DropdownButtonFormField<String>(
          value: _sortOption,
          decoration: InputDecoration(
            labelText: 'Sort Directory By',
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: ['Name A-Z', 'Name Z-A', 'Registration Date'].map((opt) {
            return DropdownMenuItem(value: opt, child: Text(opt));
          }).toList(),
          onChanged: (val) => setState(() => _sortOption = val ?? 'Name A-Z'),
        ),
        const SizedBox(height: 16),

        Text(
          'Found ${filteredUsers.length} users:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 12),

        filteredUsers.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('No users match your filters.', style: TextStyle(color: Colors.grey)),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredUsers.length,
                itemBuilder: (context, idx) {
                  final user = filteredUsers[idx];
                  final name = user['name'] ?? '';
                  final email = user['email'] ?? '';
                  final role = user['role'] ?? '';
                  final status = user['status'] ?? 'Active';
                  final date = user['createdAt'] ?? 'N/A';

                  Color roleColor = Colors.blue;
                  if (role == 'Admin') roleColor = Colors.red;
                  if (role == 'Supplier') roleColor = Colors.teal;
                  if (role == 'Client') roleColor = Colors.purple;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: roleColor.withOpacity(0.12),
                          radius: 22,
                          child: Text(
                            name.isNotEmpty ? name.substring(0, 1) : 'U',
                            style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text(email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: roleColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      role,
                                      style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 10),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: status == 'Active' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: status == 'Active' ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Joined: $date', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
                        if (role != 'Admin') ...[
                          IconButton(
                            icon: Icon(
                              status == 'Active' ? Icons.block : Icons.check_circle_outline,
                              color: status == 'Active' ? Colors.amber : Colors.green,
                              size: 20,
                            ),
                            tooltip: status == 'Active' ? 'Deactivate User' : 'Activate User',
                            onPressed: () => _showUserStatusDialog(user),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            tooltip: 'Permanently Delete User',
                            onPressed: () => _showPermanentDeleteDialog(user),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }

  void _showUserStatusDialog(Map<String, String> user) {
    final name = user['name'] ?? '';
    final status = user['status'] ?? 'Active';
    final newStatus = status == 'Active' ? 'Inactive' : 'Active';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(status == 'Active' ? 'Deactivate User?' : 'Activate User?'),
          content: Text(
            status == 'Active'
                ? 'Are you sure you want to deactivate $name? This is a secure soft delete. They will not be able to log in until re-activated.'
                : 'Are you sure you want to activate $name? They will recover full login access.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: status == 'Active' ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  user['status'] = newStatus;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$name status successfully set to $newStatus!'),
                    backgroundColor: newStatus == 'Active' ? Colors.green : Colors.red,
                  ),
                );
              },
              child: Text(status == 'Active' ? 'Deactivate' : 'Activate'),
            ),
          ],
        );
      },
    );
  }

  void _showPermanentDeleteDialog(Map<String, String> user) {
    final name = user['name'] ?? '';
    final email = user['email'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Permanently Delete User?'),
          content: Text(
            'Are you sure you want to permanently delete $name ($email) from the database? This action is irreversible and will completely remove their account.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  globalAccounts.removeWhere((acc) => acc['email'] == email);
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$name has been permanently removed from the system.'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Delete Permanently'),
            ),
          ],
        );
      },
    );
  }

  // --- 3. SUPPORT TICKETS TAB ---
  Widget _buildSupportTicketsView(bool isDark) {
    final filteredTkts = globalTickets.where((t) {
      if (_ticketStatusFilter == 'All Tickets') return true;
      return t['status'] == _ticketStatusFilter;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Support Helpdesk System', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // Status filter chips
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['All Tickets', 'Pending', 'In Progress', 'Resolved'].map((filterName) {
              final isSelected = _ticketStatusFilter == filterName;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filterName),
                  selected: isSelected,
                  selectedColor: Colors.blueAccent,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _ticketStatusFilter = filterName;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Showing ${filteredTkts.length} support requests:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 12),

        filteredTkts.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('No support tickets in this section.', style: TextStyle(color: Colors.grey)),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredTkts.length,
                itemBuilder: (context, idx) {
                  final t = filteredTkts[idx];
                  final String id = t['id'] ?? '';
                  final String name = t['userName'] ?? '';
                  final String role = t['userRole'] ?? '';
                  final String title = t['title'] ?? '';
                  final String desc = t['description'] ?? '';
                  final String status = t['status'] ?? 'Pending';
                  final String date = t['createdAt'] ?? '';

                  Color statusColor = Colors.orange;
                  if (status == 'In Progress') statusColor = Colors.blue;
                  if (status == 'Resolved') statusColor = Colors.green;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            desc,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'By: $name ($role) • $id',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                              ),
                              Text(
                                date,
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () => _showTicketDetailDialog(t),
                    ),
                  );
                },
              ),
      ],
    );
  }

  void _showTicketDetailDialog(Map<String, dynamic> ticket) {
    _replyCtrl.text = ticket['reply'] ?? '';
    String currentStatus = ticket['status'] ?? 'Pending';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.support_agent, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Text('Ticket Detail ${ticket['id']}'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Submitted By:', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('${ticket['userName']} (${ticket['userRole']})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(ticket['userEmail'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 12),
                    const Text('Title:', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(ticket['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('Problem Description:', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(ticket['description'] ?? ''),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Update Status segment
                    const Text('Update Ticket Status:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: currentStatus,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: ['Pending', 'In Progress', 'Resolved'].map((st) {
                        return DropdownMenuItem(value: st, child: Text(st));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            currentStatus = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Reply Field
                    const Text('Admin Response:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _replyCtrl,
                      decoration: InputDecoration(
                        hintText: 'Enter solution explanation for the user...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      ticket['status'] = currentStatus;
                      ticket['reply'] = _replyCtrl.text;
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ticket ${ticket['id']} successfully resolved/updated!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('Save & Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class ClientDashboardScreen extends StatefulWidget {
  final String userEmail;
  final String userName;

  const ClientDashboardScreen({
    super.key,
    required this.userEmail,
    required this.userName,
  });

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF3B0764)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Client Portal',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      radius: 24,
                      child: const Icon(Icons.person, color: Colors.white, size: 28),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                // Featured Action Card
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientProductCatalogScreen()));
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Browse Catalog', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('View new wholesale deals', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionTile(
                        context,
                        'My Offers',
                        '\ Active',
                        Icons.local_offer_outlined,
                        Colors.orange,
                        () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOffersScreen()));
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionTile(
                        context,
                        'Market Prediction',
                        'Try AI Tool',
                        Icons.auto_graph,
                        Colors.teal,
                        () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const PredictionDemoScreen()));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserSupportTicketsScreen(
                        userEmail: widget.userEmail,
                        userName: widget.userName,
                        userRole: 'Client',
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF0D9488)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.teal.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.support_agent, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Partner Support Desk',
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Need help? Message system administrators.',
                                style: TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientProductCatalogScreen())),
                      child: const Text('See All'),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: globalProducts.length > 3 ? 3 : globalProducts.length,
                    itemBuilder: (context, index) {
                      final prod = globalProducts[index];
                      IconData getIcon(String name) {
                        if (name.contains('Hoodie')) return Icons.checkroom;
                        if (name.contains('Jacket')) return Icons.dry_cleaning;
                        if (name.contains('Shirt')) return Icons.layers;
                        if (name.contains('Joggers')) return Icons.style;
                        return Icons.shopping_bag;
                      }
                      Color getColor(String name) {
                        if (name.contains('Hoodie')) return Colors.indigo;
                        if (name.contains('Jacket')) return Colors.blueGrey;
                        if (name.contains('Shirt')) return Colors.amber;
                        if (name.contains('Joggers')) return Colors.teal;
                        return Colors.purple;
                      }
                      final color = getColor(prod.name);
                      
                      return Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 60,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(child: Icon(getIcon(prod.name), color: color, size: 28)),
                            ),
                            const Spacer(),
                            Text(prod.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text('\$${prod.price.toStringAsFixed(2)}', style: TextStyle(color: Colors.green.shade600, fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class SupplierDashboardScreen extends StatefulWidget {
  final String userEmail;
  final String userName;

  const SupplierDashboardScreen({
    super.key,
    required this.userEmail,
    required this.userName,
  });

  @override
  State<SupplierDashboardScreen> createState() => _SupplierDashboardScreenState();
}

class _SupplierDashboardScreenState extends State<SupplierDashboardScreen> {
  void _showStockCapacitySheet(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(Icons.warehouse, color: Colors.teal, size: 28),
                  SizedBox(width: 12),
                  Text('Warehouse Stock Capacity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 24),
              const Text(
                'Detailed breakdown of wholesale product stocks against our standard warehouse limits (500 units capacity per item).',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: globalProducts.length,
                  itemBuilder: (context, index) {
                    final p = globalProducts[index];
                    final double capacityPercent = (p.stock / 500.0).clamp(0.0, 1.0);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('${p.stock} / 500 pcs (${(capacityPercent * 100).toStringAsFixed(0)}%)', 
                                   style: TextStyle(color: Colors.teal.shade400, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: capacityPercent,
                              backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade400),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final suppliedCount = globalSupplierProposals.where((p) => p['supplier'] == widget.userName && p['status'] == 'Delivered').length;
    final pendingDeliveriesCount = globalSupplierProposals.where((p) => p['supplier'] == widget.userName && p['status'] == 'Accepted').length;
    final pendingOrdersCount = globalSupplierProposals.where((p) => p['supplier'] == widget.userName && p['status'] == 'Pending').length;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF047857)], // Dark Blue to Emerald Green
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Supplier Portal',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      radius: 24,
                      child: const Icon(Icons.local_shipping, color: Colors.white, size: 28),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                // Highlighted Action Card
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SupplierOpenRequestsScreen(supplierName: widget.userName)));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.assignment, color: Colors.orangeAccent, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Open Requests', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('Owner needs wholesale products', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Capacity & Production', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        'Supplied',
                        '$suppliedCount Orders',
                        Icons.inventory,
                        Colors.blue,
                        isDark,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SupplierSuppliedHistoryScreen(supplierName: widget.userName, initialTab: 1)),
                          ).then((_) => setState(() {}));
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        'Stock Cap',
                        'View Levels',
                        Icons.warehouse,
                        Colors.teal,
                        isDark,
                        onTap: () => _showStockCapacitySheet(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        'Pending Deliveries',
                        '$pendingDeliveriesCount Orders',
                        Icons.delivery_dining,
                        Colors.purple,
                        isDark,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SupplierSuppliedHistoryScreen(supplierName: widget.userName, initialTab: 0)),
                          ).then((_) => setState(() {}));
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        'Active Bids',
                        '$pendingOrdersCount Bids',
                        Icons.hourglass_empty,
                        Colors.orange,
                        isDark,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SupplierOpenRequestsScreen(supplierName: widget.userName)),
                          ).then((_) => setState(() {}));
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // --- NEW FINANCIAL OVERVIEW FOR SUPPLIER ---
                const Text('Financial Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF334155)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFinanceCol('Total Revenue', '\$124,500', Colors.greenAccent),
                          Container(height: 40, width: 1, color: Colors.white.withOpacity(0.2)),
                          _buildFinanceCol('Net Earnings', '\$48,200', Colors.white),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: Colors.white24),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFinanceCol('Logistics Cost', '\$12,400', Colors.redAccent),
                          Container(height: 40, width: 1, color: Colors.white.withOpacity(0.2)),
                          _buildFinanceCol('Pending Receivables', '\$18,000', Colors.orangeAccent),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                // AI insights button for supplier
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AIAssistantScreen()));
                    },
                    icon: const Icon(Icons.auto_awesome, color: Colors.white),
                    label: const Text(
                      'AI Logistics Optimizer',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF10B981), // Emerald green
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserSupportTicketsScreen(
                        userEmail: widget.userEmail,
                        userName: widget.userName,
                        userRole: 'Supplier',
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF0D9488)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.teal.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.support_agent, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Supplier Support Desk',
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Need help? Message system administrators.',
                                style: TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceCol(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 20)),
      ],
    );
  }
  Widget _buildInfoCard(BuildContext context, String title, String subtitle, IconData icon, Color color, bool isDark, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(subtitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. PRODUCTS SCREEN
// -----------------------------------------------------------------------------
class ProductsScreen extends StatefulWidget {
  final List<Product> products;
  final VoidCallback onAddProductTap;

  const ProductsScreen({
    super.key,
    required this.products,
    required this.onAddProductTap,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _searchQuery = '';

  void _showFilterSortModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sort & Filter',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.sort),
                  title: const Text('Sort by Highest Profit'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.sort),
                  title: const Text('Sort by Highest Margin'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.filter_alt_outlined),
                  title: const Text('Show Only Profitable'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToDetail(Product p) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductDetailScreen(product: p)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredProducts = widget.products
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Column(
      children: [
        GradientHeader(
          title: 'Products',
          trailing: IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: widget.onAddProductTap,
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: _showFilterSortModal,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final p = filteredProducts[index];
                    return _buildProductCard(
                      context,
                      p,
                      p.name,
                      '\$${p.price.toStringAsFixed(2)}',
                      p.salesCount.toString(),
                      '\$${p.totalNetProfit.toStringAsFixed(0)}',
                      '${p.profitMargin.toStringAsFixed(1)}%',
                      p.status,
                      p.getStatusColor(isDark),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product p,
    String name,
    String price,
    String sales,
    String netProfit,
    String margin,
    String status,
    Color statusColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToDetail(p),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildProductStat(context, 'Price', price),
                  _buildProductStat(context, 'Sales', sales),
                  _buildProductStat(context, 'Margin', margin),
                  _buildProductStat(
                    context,
                    'Net Profit',
                    netProfit,
                    isHighlight: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductStat(
    BuildContext context,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isHighlight
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// PRODUCT DETAIL SCREEN
// -----------------------------------------------------------------------------
class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _barAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _barAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color statusColor = p.getStatusColor(isDark);

    // Hesaplamalar
    final double commFee = p.commissionFee;
    final double adCost = p.adCost;
    final double retCost = p.returnCost;
    final double totalExpenses =
        p.cost + commFee + p.shippingCost + adCost + retCost;
    final double breakEven = p.price > 0
        ? (p.cost + p.shippingCost) /
            (1 - (p.commissionRate / 100) - (p.advertisingCost / 100) - (p.returnRate / 100))
        : 0.0;

    // Maliyet bar oranlarÄ±
    final double maxCost = totalExpenses > 0 ? totalExpenses : 1.0;
    final costItems = [
      _CostItem('Product Cost', p.cost, Colors.blue),
      _CostItem('Platform Commission', commFee, Colors.red),
      _CostItem('Shipping', p.shippingCost, Colors.orange),
      _CostItem('Advertising', adCost, Colors.purple),
      _CostItem('Returns', retCost, Colors.teal),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // â”€â”€ Gradient Header â”€â”€
            Container(
              padding: const EdgeInsets.fromLTRB(8, 16, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF4C1D95)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          p.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          p.status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // â”€â”€ 4 Metrik KartÄ± â”€â”€
                  Row(
                    children: [
                      _buildHeaderStat('\$${p.price.toStringAsFixed(2)}', 'Sell Price'),
                      _buildHeaderStat('\$${p.netProfitPerUnit.toStringAsFixed(2)}', 'Profit/Unit'),
                      _buildHeaderStat('${p.profitMargin.toStringAsFixed(1)}%', 'Margin'),
                      _buildHeaderStat('${p.roas.toStringAsFixed(1)}x', 'ROAS'),
                    ],
                  ),
                ],
              ),
            ),

            // â”€â”€ Ä°Ã§erik â”€â”€
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Ã–zet Kartlar
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          'Total Revenue',
                          '\$${p.totalRevenue.toStringAsFixed(0)}',
                          Icons.account_balance_wallet_outlined,
                          Colors.blue,
                          isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          'Total Net Profit',
                          '\$${p.totalNetProfit.toStringAsFixed(0)}',
                          Icons.trending_up,
                          p.totalNetProfit >= 0 ? Colors.green : Colors.red,
                          isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          'Sales Count',
                          '${p.salesCount}',
                          Icons.shopping_cart_outlined,
                          Colors.purple,
                          isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          'Break-even Price',
                          '\$${breakEven.toStringAsFixed(2)}',
                          Icons.balance,
                          Colors.orange,
                          isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // â”€â”€ Maliyet DÃ¶kÃ¼mÃ¼ â”€â”€
                  _buildSectionTitle(context, 'Cost Breakdown per Unit'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: AnimatedBuilder(
                        animation: _barAnimation,
                        builder: (context, _) {
                          return Column(
                            children: [
                              ...costItems.map(
                                (item) => _buildAnimatedCostBar(
                                  context,
                                  item.label,
                                  item.value,
                                  maxCost,
                                  item.color,
                                  _barAnimation.value,
                                ),
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Expenses / Unit',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  Text(
                                    '\$${totalExpenses.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.red.shade400,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Net Profit / Unit',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  Text(
                                    '\$${p.netProfitPerUnit.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: p.netProfitPerUnit >= 0
                                          ? Colors.green.shade400
                                          : Colors.red.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // â”€â”€ SatÄ±ÅŸ SimÃ¼lasyonu â”€â”€
                  _buildSectionTitle(context, 'Sales Performance'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildPerfRow(context, 'Selling Price',
                              '\$${p.price.toStringAsFixed(2)}', null),
                          _buildPerfRow(context, 'Units Sold',
                              '${p.salesCount}', null),
                          _buildPerfRow(context, 'Ad Spend (Total)',
                              '\$${p.totalAdSpend.toStringAsFixed(2)}', null),
                          _buildPerfRow(context, 'Return Rate',
                              '${p.returnRate.toStringAsFixed(1)}%',
                              p.returnRate > 5 ? Colors.red : Colors.green),
                          _buildPerfRow(context, 'Commission Rate',
                              '${p.commissionRate.toStringAsFixed(1)}%', null),
                          const Divider(height: 24),
                          _buildPerfRow(
                            context,
                            'Total Revenue',
                            '\$${p.totalRevenue.toStringAsFixed(2)}',
                            Colors.blue,
                          ),
                          _buildPerfRow(
                            context,
                            'Total Net Profit',
                            '\$${p.totalNetProfit.toStringAsFixed(2)}',
                            p.totalNetProfit >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // â”€â”€ AI Ã–nerileri â”€â”€
                  _buildSectionTitle(context, 'AI Insights'),
                  const SizedBox(height: 12),
                  ..._buildInsights(context, p, isDark),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.55),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildAnimatedCostBar(
    BuildContext context,
    String label,
    double value,
    double maxValue,
    Color color,
    double animValue,
  ) {
    final ratio = maxValue > 0 ? (value / maxValue) * animValue : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                '\$${value.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              backgroundColor:
                  Theme.of(context).dividerColor.withOpacity(0.12),
              color: color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerfRow(
      BuildContext context, String label, String value, Color? valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInsights(
      BuildContext context, Product p, bool isDark) {
    final insights = <Map<String, dynamic>>[];

    if (p.profitMargin < 10) {
      insights.add({
        'icon': Icons.warning_amber_rounded,
        'color': Colors.red,
        'text':
            'Profit margin is critically low (${p.profitMargin.toStringAsFixed(1)}%). Consider raising the price or reducing costs.',
      });
    } else if (p.profitMargin >= 30) {
      insights.add({
        'icon': Icons.star_rounded,
        'color': Colors.amber,
        'text':
            'Excellent margin of ${p.profitMargin.toStringAsFixed(1)}%! This is a star product â€” consider scaling ad spend.',
      });
    }

    if (p.returnRate > 5) {
      insights.add({
        'icon': Icons.undo,
        'color': Colors.orange,
        'text':
            'High return rate (${p.returnRate.toStringAsFixed(1)}%). Investigate product quality or listing accuracy.',
      });
    }

    if (p.roas < 2.0 && p.advertisingCost > 0) {
      insights.add({
        'icon': Icons.campaign_outlined,
        'color': Colors.purple,
        'text':
            'ROAS of ${p.roas.toStringAsFixed(1)}x is below 2.0x benchmark. Optimize or pause underperforming ads.',
      });
    }

    if (p.commissionRate > 15) {
      insights.add({
        'icon': Icons.percent,
        'color': Colors.blue,
        'text':
            'Commission rate is ${p.commissionRate.toStringAsFixed(1)}%. Look for lower-fee platforms or negotiate rates.',
      });
    }

    if (insights.isEmpty) {
      insights.add({
        'icon': Icons.check_circle_outline,
        'color': Colors.green,
        'text':
            'This product looks healthy! Keep monitoring its performance over time.',
      });
    }

    return insights
        .map(
          (ins) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                  color: (ins['color'] as Color).withOpacity(0.3)),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(ins['icon'] as IconData,
                      color: ins['color'] as Color, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ins['text'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }
}

class _CostItem {
  final String label;
  final double value;
  final Color color;
  _CostItem(this.label, this.value, this.color);
}

// -----------------------------------------------------------------------------
// ADD PRODUCT SCREEN
// -----------------------------------------------------------------------------
class AddProductScreen extends StatefulWidget {
  final ValueChanged<Product> onSave;

  const AddProductScreen({super.key, required this.onSave});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _commController = TextEditingController();
  final _shipController = TextEditingController();
  final _adController = TextEditingController();
  final _retController = TextEditingController();
  final _salesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _priceController.addListener(_updateCalculations);
    _costController.addListener(_updateCalculations);
    _commController.addListener(_updateCalculations);
    _shipController.addListener(_updateCalculations);
    _adController.addListener(_updateCalculations);
    _retController.addListener(_updateCalculations);
    _salesController.addListener(_updateCalculations);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _commController.dispose();
    _shipController.dispose();
    _adController.dispose();
    _retController.dispose();
    _salesController.dispose();
    super.dispose();
  }

  void _updateCalculations() {
    setState(() {});
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final p = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        price: double.parse(_priceController.text),
        cost: double.parse(_costController.text),
        commissionRate: double.parse(_commController.text),
        shippingCost: double.parse(_shipController.text),
        advertisingCost: double.parse(_adController.text),
        returnRate: double.parse(_retController.text),
        salesCount: int.parse(_salesController.text),
        stock: 100, // New products start with a default simulated stock of 100 units
      );
      widget.onSave(p);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          if (isNumber && double.tryParse(value) == null) {
            return 'Invalid number';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double price = double.tryParse(_priceController.text) ?? 0.0;
    double cost = double.tryParse(_costController.text) ?? 0.0;
    double comm = double.tryParse(_commController.text) ?? 0.0;
    double ship = double.tryParse(_shipController.text) ?? 0.0;
    double ad = double.tryParse(_adController.text) ?? 0.0;
    double ret = double.tryParse(_retController.text) ?? 0.0;

    double commFee = price * (comm / 100);
    double adCost = price * (ad / 100);
    double retCost = price * (ret / 100);

    double netProfit = price - cost - commFee - ship - adCost - retCost;
    double margin = price > 0 ? (netProfit / price) * 100 : 0.0;
    double roas = adCost > 0 ? price / adCost : 0.0;

    double divisor = 1 - (comm / 100) - (ad / 100) - (ret / 100);
    double breakEven = divisor > 0 ? (cost + ship) / divisor : 0.0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const GradientHeader(title: 'Add Product', showBackButton: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        'Product Name',
                        _nameController,
                        isNumber: false,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Selling Price (\$)',
                              _priceController,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              'Product Cost (\$)',
                              _costController,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Commission (%)',
                              _commController,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              'Shipping (\$)',
                              _shipController,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Advertising (%)',
                              _adController,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              'Return Rate (%)',
                              _retController,
                            ),
                          ),
                        ],
                      ),
                      _buildTextField(
                        'Estimated Sales Count',
                        _salesController,
                      ),

                      const SizedBox(height: 16),
                      Text(
                        'Live Calculations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).dividerColor.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildCalcRow(
                              'Net Profit per Unit',
                              '\$${netProfit.toStringAsFixed(2)}',
                              isHighlight: netProfit > 0,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(),
                            ),
                            _buildCalcRow(
                              'Profit Margin',
                              '${margin.toStringAsFixed(1)}%',
                            ),
                            const SizedBox(height: 8),
                            _buildCalcRow(
                              'ROAS',
                              '${roas.toStringAsFixed(2)}x',
                            ),
                            const SizedBox(height: 8),
                            _buildCalcRow(
                              'Break-even Price',
                              '\$${breakEven.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _saveProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Save Product',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalcRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isHighlight
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 3. ANALYTICS SCREEN
// -----------------------------------------------------------------------------
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const GradientHeader(title: 'Analytics'),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tabs
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: _buildTab(context, 'Overview', _selectedTab == 0),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: _buildTab(context, 'Products', _selectedTab == 1),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => setState(() => _selectedTab = 2),
                      child: _buildTab(context, 'Metrics', _selectedTab == 2),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (_selectedTab == 0) ...[
                  // Revenue Trend Chart (Fake)
                  Text(
                    'Revenue & Profit Trend',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendItem(context, 'Revenue', Colors.blue),
                              const SizedBox(width: 24),
                              _buildLegendItem(
                                context,
                                'Profit',
                                Colors.purple,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 180,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildTrendBar(80, 40),
                                _buildTrendBar(100, 50),
                                _buildTrendBar(120, 70),
                                _buildTrendBar(90, 45),
                                _buildTrendBar(140, 85),
                                _buildTrendBar(160, 100),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildMonthText(context, 'Jan'),
                              _buildMonthText(context, 'Feb'),
                              _buildMonthText(context, 'Mar'),
                              _buildMonthText(context, 'Apr'),
                              _buildMonthText(context, 'May'),
                              _buildMonthText(context, 'Jun'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Monthly Sales Volume (Fake)
                  Text(
                    'Monthly Sales Volume',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 150,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildSingleBar(60, Colors.indigo),
                            _buildSingleBar(80, Colors.indigo),
                            _buildSingleBar(110, Colors.indigo),
                            _buildSingleBar(90, Colors.indigo),
                            _buildSingleBar(130, Colors.indigo),
                            _buildSingleBar(150, Colors.indigo),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sales by Category (Fake Pie Chart replacement)
                  Text(
                    'Sales by Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Container(
                                  height: 24,
                                  color: Colors.blue,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  height: 24,
                                  color: Colors.purple,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 24,
                                  color: Colors.orange,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  height: 24,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildCategoryRow(
                            context,
                            'Electronics',
                            '40%',
                            Colors.blue,
                          ),
                          _buildCategoryRow(
                            context,
                            'Accessories',
                            '30%',
                            Colors.purple,
                          ),
                          _buildCategoryRow(
                            context,
                            'Home & Office',
                            '20%',
                            Colors.orange,
                          ),
                          _buildCategoryRow(
                            context,
                            'Other',
                            '10%',
                            Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ] else if (_selectedTab == 1) ...[
                  const SizedBox(height: 60),
                  Center(
                    child: Text(
                      'Product Analytics coming soon...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 60),
                  Center(
                    child: Text(
                      'Detailed Metrics coming soon...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthText(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String title, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? null
            : Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.2),
              ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendBar(double h1, double h2) {
    return Row(
      children: [
        Container(width: 10, height: h1, color: Colors.blue.shade300),
        Container(width: 10, height: h2, color: Colors.purple.shade400),
      ],
    );
  }

  Widget _buildSingleBar(double height, Color color) {
    return Container(
      width: 24,
      height: height,
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }

  Widget _buildCategoryRow(
    BuildContext context,
    String title,
    String percent,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Text(
            percent,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. AI ASSISTANT SCREEN
// -----------------------------------------------------------------------------
class ChatMessageData {
  final String text;
  final bool isUser;
  final Widget? customContent;

  ChatMessageData({
    required this.text,
    required this.isUser,
    this.customContent,
  });
}

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late List<ChatMessageData> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [
      ChatMessageData(
        text:
            'Hello! I analyzed your recent sales data. Would you like to see how to improve your overall profit margin by 3.5% this month?',
        isUser: false,
      ),
    ];
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessageData(text: text, isUser: true));
      _controller.clear();
    });

    _scrollToBottom();

    // Dummy AI response
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessageData(
              text:
                  'Based on your data, reducing the advertising spend on underperforming products and negotiating shipping rates can yield a significant increase.',
              isUser: false,
            ),
          );
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        GradientHeader(
          title: 'AI Assistant',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.bolt, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(
                  'Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            itemCount:
                _messages.length +
                2, // +1 for date header, +1 for suggestions if at end
            itemBuilder: (context, index) {
              if (index == 0) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      'Today, 10:42 AM',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }

              if (index == _messages.length + 1) {
                if (_messages.length == 1) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSuggestionChip(context, 'Yes, show me how'),
                        _buildSuggestionChip(
                          context,
                          'Analyze advertising efficiency',
                        ),
                        _buildSuggestionChip(
                          context,
                          'Which products to focus on?',
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox(height: 20);
              }

              final msg = _messages[index - 1];
              return _buildMessageBubble(context, msg, isDark);
            },
          ),
        ),
        // Chat Input Bar
        Container(
          padding: const EdgeInsets.all(
            16,
          ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: _sendMessage,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask AI Assistant...',
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E293B)
                        : Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ChatMessageData msg,
    bool isDark,
  ) {
    if (msg.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(
                    16,
                  ).copyWith(topRight: const Radius.circular(4)),
                ),
                child: Text(
                  msg.text,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: isDark
                  ? Colors.purple.shade900
                  : Colors.purple.shade100,
              child: Icon(
                Icons.auto_awesome,
                color: isDark ? Colors.purple.shade200 : Colors.purple.shade700,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(
                    16,
                  ).copyWith(topLeft: const Radius.circular(4)),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  msg.text,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSuggestionChip(BuildContext context, String text) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.purple.shade400 : Colors.purple.shade200,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.purple.shade300 : Colors.purple.shade700,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 5. PROFILE SCREEN
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// 5. PROFILE SCREEN
// -----------------------------------------------------------------------------
class ProfileScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onLogout;
  final String userName;
  final String userEmail;
  final bool isGuest;
  final String selectedRole;
  final Function(String, String) onProfileUpdated;

  const ProfileScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onLogout,
    required this.userName,
    required this.userEmail,
    required this.isGuest,
    required this.selectedRole,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Local state for preferences
  bool _prodUpdates = true;
  bool _weeklyReports = false;
  bool _promoEmails = true;

  bool _pushNotifs = true;
  bool _emailNotifs = true;
  bool _profitAlerts = true;
  bool _aiInsights = false;

  String _selectedLang = 'English';
  String _selectedCurrency = 'USD';

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title, {
    Widget? trailing,
    VoidCallback? onTap,
    String? subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.05),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.secondary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              )
            : null,
        trailing:
            trailing ??
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
        onTap: onTap,
      ),
    );
  }

  void _showPersonalInfoDialog() {
    final nameCtrl = TextEditingController(text: widget.userName);
    final emailCtrl = TextEditingController(text: widget.userEmail);
    final roleCtrl = TextEditingController(
      text: widget.isGuest ? 'Guest' : widget.selectedRole,
    );
    final planCtrl = TextEditingController(
      text: widget.isGuest ? 'Free' : 'Pro Plan',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: planCtrl,
                decoration: const InputDecoration(
                  labelText: 'Membership Plan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.star_outline),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    widget.onProfileUpdated(nameCtrl.text, emailCtrl.text);
                    Navigator.pop(context);
                  },
                  child: const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmailPrefsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Email Preferences'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Product Updates'),
                    value: _prodUpdates,
                    onChanged: (val) {
                      setDialogState(() => _prodUpdates = val);
                      setState(() => _prodUpdates = val);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Weekly Reports'),
                    value: _weeklyReports,
                    onChanged: (val) {
                      setDialogState(() => _weeklyReports = val);
                      setState(() => _weeklyReports = val);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Promotional Emails'),
                    value: _promoEmails,
                    onChanged: (val) {
                      setDialogState(() => _promoEmails = val);
                      setState(() => _promoEmails = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSecurityDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            String errorMsg = '';
            return AlertDialog(
              title: const Text('Change Password'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: currentCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Current Password',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                      ),
                    ),
                    if (errorMsg.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          errorMsg,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (currentCtrl.text.isEmpty || newCtrl.text.isEmpty) {
                      setDialogState(
                        () => errorMsg = 'Fields cannot be empty.',
                      );
                      return;
                    }
                    if (newCtrl.text != confirmCtrl.text) {
                      setDialogState(
                        () => errorMsg = 'Passwords do not match.',
                      );
                      return;
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password changed successfully'),
                      ),
                    );
                  },
                  child: const Text('Change'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildModernSwitch(
    String title,
    bool value,
    IconData icon,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: SwitchListTile(
        title: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _showNotificationsDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildModernSwitch(
                    'Push Notifications',
                    _pushNotifs,
                    Icons.notifications_active_outlined,
                    (val) {
                      setSheetState(() => _pushNotifs = val);
                      setState(() => _pushNotifs = val);
                    },
                  ),
                  _buildModernSwitch(
                    'Email Notifications',
                    _emailNotifs,
                    Icons.email_outlined,
                    (val) {
                      setSheetState(() => _emailNotifs = val);
                      setState(() => _emailNotifs = val);
                    },
                  ),
                  _buildModernSwitch(
                    'Profit Alerts',
                    _profitAlerts,
                    Icons.trending_up_outlined,
                    (val) {
                      setSheetState(() => _profitAlerts = val);
                      setState(() => _profitAlerts = val);
                    },
                  ),
                  _buildModernSwitch(
                    'AI Insight Alerts',
                    _aiInsights,
                    Icons.auto_awesome_outlined,
                    (val) {
                      setSheetState(() => _aiInsights = val);
                      setState(() => _aiInsights = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Save & Done'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLanguageRegionDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Language & Region',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Language',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    isExpanded: true,
                    value: _selectedLang,
                    items: ['English', 'Turkish']
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setSheetState(() => _selectedLang = val);
                        setState(() => _selectedLang = val);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Currency',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    isExpanded: true,
                    value: _selectedCurrency,
                    items: ['USD', 'EUR', 'TRY']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setSheetState(() => _selectedCurrency = val);
                        setState(() => _selectedCurrency = val);
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFaqItem(String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(a, style: const TextStyle(color: Colors.grey, height: 1.4)),
        ],
      ),
    );
  }

  void _showHelpCenter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Help Center & FAQ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    _buildFaqItem(
                      'How do I add a new product?',
                      'Navigate to the Dashboard and tap the "+" icon in the top right corner. Fill in the product details and cost metrics to instantly calculate margins.',
                    ),
                    _buildFaqItem(
                      'What does ROAS stand for?',
                      'Return On Ad Spend. It measures the revenue generated for every dollar spent on advertising. A ROAS of 3.0 means you earn \$3 for every \$1 spent.',
                    ),
                    _buildFaqItem(
                      'How is Net Profit calculated?',
                      'Net Profit = Total Revenue - (Product Cost + Shipping + Ad Spend + Commission Fees + Return Costs). Our app calculates this automatically.',
                    ),
                    _buildFaqItem(
                      'Can I change my default currency?',
                      'Yes, go to Profile > Language & Region, and select your preferred currency (USD, EUR, TRY).',
                    ),
                    _buildFaqItem(
                      'How do AI Insights work?',
                      'Our AI analyzes your profit margins, ad spend, and sales volume to provide actionable recommendations to improve your business efficiency.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsPrivacy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Terms & Privacy',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: const [
                    Text(
                      '1. Terms of Service',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'By using Finance Analysis, you agree to these terms. Our app is designed to help you analyze business metrics and predict profitability. You are responsible for the accuracy of the data entered.',
                      style: TextStyle(height: 1.5),
                    ),
                    SizedBox(height: 24),
                    Text(
                      '2. Privacy Policy',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'We value your privacy. All your business data, product metrics, and personal information are stored locally on your device. We do not transmit or sell your data to any third-party services.',
                      style: TextStyle(height: 1.5),
                    ),
                    SizedBox(height: 24),
                    Text(
                      '3. Data Security',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Since your data remains strictly on your device, its security is tied to your device\'s security. We recommend using a passcode or biometric lock on your mobile device to protect your business information.',
                      style: TextStyle(height: 1.5),
                    ),
                    SizedBox(height: 24),
                    Text(
                      '4. App Usage',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This app provides financial estimates and AI-generated suggestions. These are for informational purposes only and do not constitute professional financial advice. Always verify calculations before making major business decisions.',
                      style: TextStyle(height: 1.5),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('I Understand'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const GradientHeader(title: 'Profile'),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar & Info
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.userName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.userEmail,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Plan Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade600, Colors.indigo.shade600],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isGuest ? 'Guest / Free' : 'Pro Plan',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.isGuest
                                ? 'Create account to upgrade'
                                : 'Member since 2023',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      if (!widget.isGuest)
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Premium Plan'),
                                content: const Text(
                                  'Unlock all features for \$9.99/month.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Upgrade'),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.purple.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Upgrade'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Settings List
                _buildSectionHeader(context, 'Account'),
                _buildSettingsTile(
                  context,
                  Icons.person_outline,
                  'Personal Information',
                  onTap: _showPersonalInfoDialog,
                ),
                _buildSettingsTile(
                  context,
                  Icons.email_outlined,
                  'Email Preferences',
                  onTap: _showEmailPrefsDialog,
                ),
                _buildSettingsTile(
                  context,
                  Icons.security_outlined,
                  'Security',
                  onTap: _showSecurityDialog,
                ),

                const SizedBox(height: 24),
                _buildSectionHeader(context, 'App Settings'),
                _buildSettingsTile(
                  context,
                  Icons.notifications_outlined,
                  'Notifications',
                  onTap: _showNotificationsDialog,
                ),
                _buildSettingsTile(
                  context,
                  Icons.dark_mode_outlined,
                  'Dark Mode',
                  trailing: Switch(
                    value: widget.isDarkMode,
                    onChanged: widget.onThemeChanged,
                    activeColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                _buildSettingsTile(
                  context,
                  Icons.language_outlined,
                  'Language & Region',
                  subtitle: '$_selectedLang, $_selectedCurrency',
                  onTap: _showLanguageRegionDialog,
                ),

                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Support'),
                _buildSettingsTile(
                  context,
                  Icons.help_outline,
                  'Help Center',
                  onTap: _showHelpCenter,
                ),
                _buildSettingsTile(
                  context,
                  Icons.privacy_tip_outlined,
                  'Terms & Privacy',
                  onTap: _showTermsPrivacy,
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text(
                            'Are you sure you want to sign out?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onLogout();
                              },
                              child: const Text(
                                'Sign Out',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// AUTHENTICATION & SPLASH SCREENS
// -----------------------------------------------------------------------------

class SplashScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashScreen({super.key, required this.onInitializationComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onInitializationComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF4C1D95)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.show_chart,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Finance Analysis',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Insights for Growth',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final Function(String, String, String) onLoginSuccess; // name, email, role
  final VoidCallback onGuestLogin;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onGuestLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  static const _demoAccounts = [
    {'role': 'Owner',    'email': 'owner@finance.com',    'color': Color(0xFF4C1D95), 'icon': Icons.business},
    {'role': 'Admin',    'email': 'admin@finance.com',    'color': Color(0xFF0369A1), 'icon': Icons.admin_panel_settings},
    {'role': 'Client',   'email': 'client@finance.com',   'color': Color(0xFF065F46), 'icon': Icons.person},
    {'role': 'Supplier', 'email': 'supplier@finance.com', 'color': Color(0xFF92400E), 'icon': Icons.local_shipping},
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFF1E293B), const Color(0xFF4C1D95)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      const Icon(
                        Icons.account_balance_wallet,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue to Finance Analysis',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: _emailCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _passwordCtrl,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                      ),
                                      const Text('Remember me'),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text('Forgot Password?'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF4C1D95),
                                      Color(0xFF8B5CF6),
                                    ],
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    String email = _emailCtrl.text;
                                    String password = _passwordCtrl.text;
                                    
                                    try {
                                      final account = globalAccounts.firstWhere(
                                        (acc) => acc['email'] == email && acc['password'] == password,
                                      );
                                      widget.onLoginSuccess(account['name']!, account['email']!, account['role'] ?? 'Owner');
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Invalid email or password'), backgroundColor: Colors.red),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Quick Login — tap a role',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _DemoTile(role:'Owner',    email:'owner@finance.com',    icon:Icons.business,             color:Color(0xFF4C1D95), onTap:(){setState((){_emailCtrl.text='owner@finance.com';    _passwordCtrl.text='123456';});}),
                              _DemoTile(role:'Admin',    email:'admin@finance.com',    icon:Icons.admin_panel_settings, color:Color(0xFF0369A1), onTap:(){setState((){_emailCtrl.text='admin@finance.com';    _passwordCtrl.text='123456';});}),
                              _DemoTile(role:'Client',   email:'client@finance.com',   icon:Icons.person,               color:Color(0xFF065F46), onTap:(){setState((){_emailCtrl.text='client@finance.com';   _passwordCtrl.text='123456';});}),
                              _DemoTile(role:'Supplier', email:'supplier@finance.com', icon:Icons.local_shipping,       color:Color(0xFF92400E), onTap:(){setState((){_emailCtrl.text='supplier@finance.com'; _passwordCtrl.text='123456';});}),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account?',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterScreen(
                                    onRegisterSuccess: (name, email) {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Quick-login demo tile widget
class _DemoTile extends StatelessWidget {
  final String role;
  final String email;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DemoTile({
    required this.role,
    required this.email,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
                  Text(email, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 12, color: color.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  final Function(String, String) onRegisterSuccess;

  const RegisterScreen({super.key, required this.onRegisterSuccess});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFF1E293B), const Color(0xFF4C1D95)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join Finance Analysis today',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 40),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailCtrl,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _confirmPasswordCtrl,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4C1D95), Color(0xFF8B5CF6)],
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              String name = _nameCtrl.text.trim();
                              String email = _emailCtrl.text.trim();
                              String password = _passwordCtrl.text;
                              String confirm = _confirmPasswordCtrl.text;
                              
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name cannot be empty'), backgroundColor: Colors.red));
                                return;
                              }
                              if (!email.contains('@')) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email must contain @'), backgroundColor: Colors.red));
                                return;
                              }
                              if (password.length < 6) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters'), backgroundColor: Colors.red));
                                return;
                              }
                              if (password != confirm) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red));
                                return;
                              }
                              
                              globalAccounts.add({
                                'name': name,
                                'email': email,
                                'password': password,
                              });
                              
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created successfully'), backgroundColor: Colors.green));
                              widget.onRegisterSuccess(name, email);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Global memory for accounts (name, email, password, role, status, createdAt)
List<Map<String, String>> globalAccounts = [
  {'name': 'Alex Owner',    'email': 'owner@finance.com',    'password': '123456', 'role': 'Owner', 'status': 'Active', 'createdAt': '2026-01-10'},
  {'name': 'Admin Sarah',   'email': 'admin@finance.com',    'password': '123456', 'role': 'Admin', 'status': 'Active', 'createdAt': '2026-01-01'},
  {'name': 'Client John',   'email': 'client@finance.com',   'password': '123456', 'role': 'Client', 'status': 'Active', 'createdAt': '2026-02-14'},
  {'name': 'Supplier Mike', 'email': 'supplier@finance.com', 'password': '123456', 'role': 'Supplier', 'status': 'Active', 'createdAt': '2026-02-20'},
  {'name': 'Elite Textile', 'email': 'elite@finance.com',    'password': '123456', 'role': 'Supplier', 'status': 'Active', 'createdAt': '2026-03-01'},
  {'name': 'Trend Fashion Boutique', 'email': 'boutique@finance.com', 'password': '123456', 'role': 'Owner', 'status': 'Active', 'createdAt': '2026-03-10'},
  {'name': 'Dina Wholesale Client', 'email': 'dina@finance.com', 'password': '123456', 'role': 'Client', 'status': 'Active', 'createdAt': '2026-03-15'},
  {'name': 'Inactive Supplier Partner', 'email': 'old_partner@finance.com', 'password': '123456', 'role': 'Supplier', 'status': 'Inactive', 'createdAt': '2025-12-01'},
];

// Global memory for support tickets
List<Map<String, dynamic>> globalTickets = [
  {
    'id': 'TKT-1001',
    'userEmail': 'owner@finance.com',
    'userName': 'Alex Owner',
    'userRole': 'Owner',
    'title': 'Stok kapasitesi hesaplama hatası',
    'description': 'Stok kapasitesi alanındaki doluluk oranı ürün eklediğim halde güncellenmiyordu.',
    'status': 'Resolved',
    'reply': 'Merhabalar Alex, bu sorun son güncelleme ile çözülmüştür, opening request üzerinden beslenmektedir.',
    'createdAt': '2026-05-18 14:30',
  },
  {
    'id': 'TKT-1002',
    'userEmail': 'supplier@finance.com',
    'userName': 'Supplier Mike',
    'userRole': 'Supplier',
    'title': 'Sipariş detaylarında fiyat gözükmüyor',
    'description': 'Yeni toptan sipariş geldiğinde bazı ürünlerin birim fiyatı boş çıkıyor.',
    'status': 'In Progress',
    'reply': '',
    'createdAt': '2026-05-19 09:15',
  },
  {
    'id': 'TKT-1003',
    'userEmail': 'client@finance.com',
    'userName': 'Client John',
    'userRole': 'Client',
    'title': 'Ödeme ekranında donma sorunu',
    'description': 'Wholesale teklifini onayladıktan sonra ödeme sayfasına geçerken donma yaşıyorum.',
    'status': 'Pending',
    'reply': '',
    'createdAt': '2026-05-19 18:00',
  },
];

// Global memory for offers
List<Map<String, dynamic>> globalClientOffers = [
  {
    'productName': 'Oversized Cotton Hoodie',
    'quantity': 50,
    'offeredPrice': 45.0,
    'message': 'Wholesale discount for retail chain store.',
    'status': 'Pending',
  },
  {
    'productName': 'Slim Fit Denim Jacket',
    'quantity': 30,
    'offeredPrice': 70.0,
    'message': 'Express logistics requested.',
    'status': 'Pending',
  },
];

// Global memory for supply requests (Supply Listings) and proposals (Supplier Offers)
List<Map<String, dynamic>> globalSupplyRequests = [
  {
    'id': 'req_1',
    'product': 'Oversized Cotton Hoodie',
    'quantity': 150,
    'targetPrice': 15.0,
    'deadline': '2026-06-01',
    'notes': 'High quality organic combed cotton fabric with customized inside printing.',
    'supplier': null,
    'status': 'Offer Received',
  },
  {
    'id': 'req_2',
    'product': 'Slim Fit Denim Jacket',
    'quantity': 80,
    'targetPrice': 28.0,
    'deadline': '2026-06-15',
    'notes': 'Metal heavy-duty buttons and stonewash styling. Indigo color.',
    'supplier': 'Skein Weaver',
    'status': 'Supplier Selected',
  },
  {
    'id': 'req_3',
    'product': 'Linen Summer Shirt',
    'quantity': 200,
    'targetPrice': 11.5,
    'deadline': '2026-06-10',
    'notes': 'Light beige and white colors. Premium breathable pure linen fabric.',
    'supplier': null,
    'status': 'Open',
  },
];

List<Map<String, dynamic>> globalSupplierProposals = [
  {
    'id': 'prop_1',
    'reqId': 'req_1',
    'supplier': 'TextileMaster Ltd.',
    'offeredPrice': '14.5',
    'quantity': 150,
    'deliveryTime': '2026-06-01',
    'message': 'We can deliver high-quality cotton hoodies on time with our express logistics.',
    'status': 'Pending',
    'date': '2026-05-19',
  },
  {
    'id': 'prop_2',
    'reqId': 'req_1',
    'supplier': 'Skein Weaver',
    'offeredPrice': '16.0',
    'quantity': 150,
    'deliveryTime': '2026-05-28',
    'message': 'Premium stitching and softest organic cotton. Can deliver 3 days earlier!',
    'status': 'Pending',
    'date': '2026-05-19',
  },
  {
    'id': 'prop_3',
    'reqId': 'req_2',
    'supplier': 'Skein Weaver',
    'offeredPrice': '27.5',
    'quantity': 80,
    'deliveryTime': '2026-06-12',
    'message': 'Includes heavy duty metal buttons and custom stonewash styling.',
    'status': 'Accepted',
    'date': '2026-05-19',
  },
];
List<Map<String, dynamic>> globalOwnerNotifications = [];
List<Map<String, dynamic>> globalOperationalCosts = [];


// 1. ClientProductCatalogScreen
class ClientProductCatalogScreen extends StatefulWidget {
  const ClientProductCatalogScreen({super.key});
  @override
  State<ClientProductCatalogScreen> createState() =>
      _ClientProductCatalogScreenState();
}

class _ClientProductCatalogScreenState
    extends State<ClientProductCatalogScreen> {
  final List<String> globalOwners = ['Luxe Apparel Store', 'Urban Threads Boutique', 'Velvet Streetwear'];
  String _selectedOwnerFilter = 'All Owners';

  IconData _getIcon(String name) {
    if (name.contains('Hoodie')) return Icons.checkroom;
    if (name.contains('Jacket')) return Icons.dry_cleaning;
    if (name.contains('Shirt')) return Icons.layers;
    if (name.contains('Joggers')) return Icons.style;
    return Icons.shopping_bag;
  }

  Color _getColor(String name) {
    if (name.contains('Hoodie')) return Colors.indigo;
    if (name.contains('Jacket')) return Colors.blueGrey;
    if (name.contains('Shirt')) return Colors.amber;
    if (name.contains('Joggers')) return Colors.teal;
    return Colors.purple;
  }

  String _getFabric(String name) {
    if (name.contains('Hoodie')) return '100% Premium Cotton';
    if (name.contains('Jacket')) return 'Organic Denim';
    if (name.contains('Shirt')) return 'Pure Linen Blend';
    if (name.contains('Joggers')) return 'Fleece Cotton';
    return 'Cotton Blend';
  }

  void _showOfferSheet(Product product, String ownerName) {
    final qtyCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final msgCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final color = _getColor(product.name);
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getIcon(product.name), color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Store Owner: $ownerName',
                          style: const TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              const Text('Enter Offer Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtyCtrl,
                      decoration: InputDecoration(
                        labelText: 'Quantity (pcs)',
                        prefixIcon: const Icon(Icons.shopping_basket_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: isDark ? Colors.white10 : Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: priceCtrl,
                      decoration: InputDecoration(
                        labelText: 'Unit Price (\$)',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: isDark ? Colors.white10 : Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: msgCtrl,
                decoration: InputDecoration(
                  labelText: 'Special requests or custom measurements...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.grey.shade50,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6), // Purple accent
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (qtyCtrl.text.isEmpty || priceCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter Quantity and Price')),
                      );
                      return;
                    }
                    globalClientOffers.add({
                      'productName': product.name,
                      'quantity': qtyCtrl.text,
                      'offeredPrice': priceCtrl.text,
                      'message': msgCtrl.text,
                      'status': 'Pending',
                      'owner': ownerName,
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Offer submitted successfully!'), backgroundColor: Colors.green),
                    );
                    setState(() {});
                  },
                  child: const Text('Submit Wholesale Offer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Dynamically filter products by Owner
    final List<Map<String, dynamic>> filteredItems = [];
    for (int i = 0; i < globalProducts.length; i++) {
      final p = globalProducts[i];
      final owner = globalOwners[i % globalOwners.length];
      if (_selectedOwnerFilter == 'All Owners' || owner == _selectedOwnerFilter) {
        filteredItems.add({'product': p, 'owner': owner});
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Textile Catalog'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF3B0764)],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Elegant horizontal Owner filter chips
          Container(
            height: 58,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All Owners', ...globalOwners].map((filterName) {
                final isSelected = _selectedOwnerFilter == filterName;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filterName),
                    selected: isSelected,
                    selectedColor: const Color(0xFF8B5CF6),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedOwnerFilter = filterName;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(child: Text('No products matching this owner filter.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final p = filteredItems[index]['product'] as Product;
                      final ownerName = filteredItems[index]['owner'] as String;
                      final color = _getColor(p.name);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade100),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(_getIcon(p.name), color: color, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: color.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                _getFabric(p.name),
                                                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Owner Badge!
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.blueAccent.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.storefront, size: 10, color: Colors.blueAccent),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    ownerName,
                                                    style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Suggested Unit Price', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      const SizedBox(height: 2),
                                      Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Available Stock', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      const SizedBox(height: 2),
                                      Text('${p.stock} units', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showOfferSheet(p, ownerName),
                                  icon: const Icon(Icons.local_offer, size: 18),
                                  label: const Text('Make Wholesale Offer', style: TextStyle(fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: color,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// 2. MyOffersScreen
class MyOffersScreen extends StatelessWidget {
  const MyOffersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Offers'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF3B0764)],
            ),
          ),
        ),
      ),
      body: globalClientOffers.isEmpty
          ? const Center(child: Text('No offers submitted yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: globalClientOffers.length,
              itemBuilder: (context, index) {
                final o = globalClientOffers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                o['productName'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: Text(
                                o['status'],
                                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildInfoCol('Quantity', o['quantity'].toString()),
                            const SizedBox(width: 24),
                            _buildInfoCol('Offered Price', '\$${o['offeredPrice']}'),
                          ],
                        ),
                        if (o['message'].toString().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text('Message: ${o['message']}', style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                        ],
                        const Divider(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ClientChatScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.support_agent, color: Color(0xFF8B5CF6)),
                            label: const Text('Contact Representative', style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold)),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }
}

// Owner Client Offers Screen (For Owner to review Client Offers)
class OwnerClientOffersScreen extends StatefulWidget {
  const OwnerClientOffersScreen({super.key});

  @override
  State<OwnerClientOffersScreen> createState() => _OwnerClientOffersScreenState();
}

class _OwnerClientOffersScreenState extends State<OwnerClientOffersScreen> {
  void _updateOfferStatus(int index, String newStatus) {
    final offer = globalClientOffers[index];
    final String pName = offer['productName'];
    final int qty = int.tryParse(offer['quantity'].toString()) ?? 0;

    if (newStatus == 'Accepted') {
      // Find matching product in globalProducts to update stock dynamically
      final pIndex = globalProducts.indexWhere((p) => p.name == pName);
      if (pIndex != -1) {
        final p = globalProducts[pIndex];
        if (p.stock < qty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Insufficient Stock to accept this offer!'),
            backgroundColor: Colors.amber,
          ));
          return;
        }
        setState(() {
          p.stock -= qty;
          p.salesCount += qty;
          globalClientOffers[index]['status'] = newStatus;
          
          // Add a real SaleData record into globalSalesData for dynamic business profits charting
          final double offPrice = double.tryParse(offer['offeredPrice'].toString()) ?? p.price;
          globalSalesData.insert(0, SaleData(
            productName: pName,
            saleDate: DateTime.now(),
            revenue: offPrice * qty,
            expenses: p.cost * qty,
          ));
        });
      } else {
        setState(() {
          globalClientOffers[index]['status'] = newStatus;
        });
      }
    } else {
      setState(() {
        globalClientOffers[index]['status'] = newStatus;
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Offer $newStatus!'),
      backgroundColor: newStatus == 'Accepted' ? Colors.green : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final pendingOffers = globalClientOffers.asMap().entries.where((e) => e.value['status'] == 'Pending').toList();
    final historyOffers = globalClientOffers.asMap().entries.where((e) => e.value['status'] != 'Pending').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Client Offers Review'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOffersList(pendingOffers, true),
            _buildOffersList(historyOffers, false),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersList(List<MapEntry<int, Map<String, dynamic>>> offers, bool isPending) {
    if (offers.isEmpty) {
      return const Center(child: Text('No offers here.', style: TextStyle(fontSize: 16, color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      itemBuilder: (context, idx) {
        final entry = offers[idx];
        final o = entry.value;
        final realIndex = entry.key;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(o['productName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPending ? Colors.orange.withOpacity(0.15) : (o['status'] == 'Accepted' ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        o['status'],
                        style: TextStyle(color: isPending ? Colors.orange : (o['status'] == 'Accepted' ? Colors.green : Colors.red), fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildCol('Client', 'Client User')),
                    Expanded(child: _buildCol('Quantity', o['quantity'].toString())),
                    Expanded(child: _buildCol('Offer Price', '\$${o['offeredPrice']}')),
                  ],
                ),
                if (o['message'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('Msg: ${o['message']}', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
                  ),
                ],
                if (isPending) ...[
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _updateOfferStatus(realIndex, 'Rejected'),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _updateOfferStatus(realIndex, 'Accepted'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCol(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

// 3. ClientChatScreen
class ClientChatScreen extends StatefulWidget {
  const ClientChatScreen({super.key});
  @override
  State<ClientChatScreen> createState() => _ClientChatScreenState();
}

class _ClientChatScreenState extends State<ClientChatScreen> {
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! Welcome to our store. How can I assist you today?',
      'isMe': false,
      'time':
          '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
    },
  ];
  final _ctrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add({'text': text, 'isMe': true, 'time': timeStr});
      _isTyping = true;
    });
    _ctrl.clear();
    _scrollToBottom();

    // Determine smart reply
    String replyText =
        "Thank you for your message. Our team will respond shortly.";
    final lowerText = text.toLowerCase();
    if (lowerText.contains('reduce') ||
        lowerText.contains('price') ||
        lowerText.contains('discount')) {
      replyText = "We can offer a discount for bulk purchases.";
    } else if (lowerText.contains('stock') || lowerText.contains('available')) {
      replyText = "Current stock is available and ready for shipment.";
    } else if (lowerText.contains('delivery') || lowerText.contains('time')) {
      replyText = "Estimated delivery is 3-5 business days.";
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            'text': replyText,
            'isMe': false,
            'time':
                '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
          });
        });
        _scrollToBottom();
      }
    });
  }

  Widget _buildQuickAction(String label, String message) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        onPressed: () {
          _send(message);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Gradient Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF4C1D95)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.store, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Business Chat',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Online â€¢ Client â†” Owner',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final m = _messages[index];
                  final isMe = m['isMe'] as bool;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isMe) ...[
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.indigo.shade100,
                            child: Icon(
                              Icons.store,
                              size: 18,
                              color: Colors.indigo.shade800,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isMe ? 16 : 0),
                                bottomRight: Radius.circular(isMe ? 0 : 16),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m['text'],
                                  style: TextStyle(
                                    color: isMe
                                        ? Colors.white
                                        : (isDark
                                              ? Colors.white
                                              : Colors.black87),
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  m['time'],
                                  style: TextStyle(
                                    color: isMe ? Colors.white70 : Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2),
                            child: Icon(
                              Icons.person,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // Typing Indicator
            if (_isTyping)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 32),
                    Text(
                      'Owner is typing...',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            // Quick Actions
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildQuickAction(
                    'Ask for discount',
                    'Can you reduce the price?',
                  ),
                  _buildQuickAction('Ask stock status', 'Do you have stock?'),
                  _buildQuickAction(
                    'Ask delivery time',
                    'What is delivery time?',
                  ),
                  _buildQuickAction(
                    'Request invoice',
                    'Can I get an invoice for my order?',
                  ),
                ],
              ),
            ),

            // Input Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade900
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: TextField(
                          controller: _ctrl,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(fontSize: 14),
                          ),
                          onSubmitted: _send,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _send(_ctrl.text),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. PredictionDemoScreen
class PredictionDemoScreen extends StatefulWidget {
  const PredictionDemoScreen({super.key});
  @override
  State<PredictionDemoScreen> createState() => _PredictionDemoScreenState();
}

class _PredictionDemoScreenState extends State<PredictionDemoScreen> {
  final _sellPriceCtrl = TextEditingController(text: '100');
  final _costCtrl = TextEditingController(text: '40');
  final _adCostCtrl = TextEditingController(text: '10');
  final _commCtrl = TextEditingController(text: '15');
  final _salesCtrl = TextEditingController(text: '500');

  double _revenue = 0;
  double _profit = 0;
  double _margin = 0;

  @override
  void initState() {
    super.initState();
    _calc();
  }

  void _calc() {
    final sp = double.tryParse(_sellPriceCtrl.text) ?? 0;
    final c = double.tryParse(_costCtrl.text) ?? 0;
    final ac = double.tryParse(_adCostCtrl.text) ?? 0;
    final comm = double.tryParse(_commCtrl.text) ?? 0;
    final sales = double.tryParse(_salesCtrl.text) ?? 0;

    final commissionAmount = sp * (comm / 100);
    final profitPerUnit = sp - c - ac - commissionAmount;

    setState(() {
      _revenue = sp * sales;
      _profit = profitPerUnit * sales;
      _margin = sp > 0 ? (profitPerUnit / sp) * 100 : 0;
    });
  }

  Widget _input(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: (_) => _calc(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profit Prediction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _input('Selling Price (\$)', _sellPriceCtrl),
            _input('Product Cost (\$)', _costCtrl),
            _input('Ad Cost per Unit (\$)', _adCostCtrl),
            _input('Commission Rate (%)', _commCtrl),
            _input('Expected Sales Count', _salesCtrl),
            const SizedBox(height: 24),
            Card(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.purple.shade900
                  : Colors.purple,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Expected Revenue: \$${_revenue.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Expected Net Profit: \$${_profit.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Profit Margin: ${_margin.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 5. Scenario Simulation Screen
class ScenarioSimulationScreen extends StatefulWidget {
  const ScenarioSimulationScreen({super.key});

  @override
  State<ScenarioSimulationScreen> createState() =>
      _ScenarioSimulationScreenState();
}

class _ScenarioSimulationScreenState extends State<ScenarioSimulationScreen> {
  // Baseline values
  final double _basePrice = 100.0;
  final double _baseCost = 40.0;
  final double _baseCommRate = 15.0; // %
  final double _baseShipping = 10.0;
  final double _baseAdCost = 5.0;
  final double _baseReturnRate = 2.0; // %

  // Current values
  late double _price;
  late double _cost;
  late double _commRate;
  late double _shipping;
  late double _adCost;
  late double _returnRate;

  @override
  void initState() {
    super.initState();
    _price = _basePrice;
    _cost = _baseCost;
    _commRate = _baseCommRate;
    _shipping = _baseShipping;
    _adCost = _baseAdCost;
    _returnRate = _baseReturnRate;
  }

  double _calcNetProfit(
    double price,
    double cost,
    double commRate,
    double shipping,
    double adCost,
    double returnRate,
  ) {
    double commFee = price * (commRate / 100);
    double retCost = price * (returnRate / 100);
    return price - cost - commFee - shipping - adCost - retCost;
  }

  double _calcMargin(double netProfit, double price) {
    if (price <= 0) return 0;
    return (netProfit / price) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final baseProfit = _calcNetProfit(
      _basePrice,
      _baseCost,
      _baseCommRate,
      _baseShipping,
      _baseAdCost,
      _baseReturnRate,
    );
    final baseMargin = _calcMargin(baseProfit, _basePrice);

    final simProfit = _calcNetProfit(
      _price,
      _cost,
      _commRate,
      _shipping,
      _adCost,
      _returnRate,
    );
    final simMargin = _calcMargin(simProfit, _price);

    final profitDiff = simProfit - baseProfit;
    final isImproved = profitDiff >= 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. Gradient Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF4C1D95)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Scenario Simulation',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Test different pricing and cost scenarios',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Results Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildResultCard(
                            'Baseline',
                            baseProfit,
                            baseMargin,
                            Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildResultCard(
                            'Simulated',
                            simProfit,
                            simMargin,
                            isImproved ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 5. Impact Summary Card
                    Card(
                      color: isImproved
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isImproved ? Colors.green : Colors.red,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              isImproved
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color: isImproved ? Colors.green : Colors.red,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isImproved
                                        ? 'Profit Improvement'
                                        : 'Profit Decline',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isImproved
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  Text(
                                    '${profitDiff > 0 ? '+' : ''}\$${profitDiff.toStringAsFixed(2)} per unit',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isImproved
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. Adjustable Sliders
                    const Text(
                      'Adjust Variables',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSlider(
                      'Selling Price',
                      _price,
                      10,
                      500,
                      '\$',
                      (val) => setState(() => _price = val),
                    ),
                    _buildSlider(
                      'Product Cost',
                      _cost,
                      1,
                      200,
                      '\$',
                      (val) => setState(() => _cost = val),
                    ),
                    _buildSlider(
                      'Commission Rate',
                      _commRate,
                      0,
                      50,
                      '%',
                      (val) => setState(() => _commRate = val),
                    ),
                    _buildSlider(
                      'Shipping Cost',
                      _shipping,
                      0,
                      50,
                      '\$',
                      (val) => setState(() => _shipping = val),
                    ),
                    _buildSlider(
                      'Advertising Cost',
                      _adCost,
                      0,
                      100,
                      '\$',
                      (val) => setState(() => _adCost = val),
                    ),
                    _buildSlider(
                      'Return Rate',
                      _returnRate,
                      0,
                      100,
                      '%',
                      (val) => setState(() => _returnRate = val),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(
    String title,
    double profit,
    double margin,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Profit: \$${profit.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Margin: ${margin.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 14, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    String prefix,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              prefix == '\$'
                  ? '\$${value.toStringAsFixed(2)}'
                  : '${value.toStringAsFixed(1)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: const Color(0xFF8B5CF6),
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// 6. Completed Sale Profit Screen
class CompletedSaleProfitScreen extends StatefulWidget {
  const CompletedSaleProfitScreen({super.key});

  @override
  State<CompletedSaleProfitScreen> createState() =>
      _CompletedSaleProfitScreenState();
}

class _CompletedSaleProfitScreenState extends State<CompletedSaleProfitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _shippingCtrl = TextEditingController();
  final _adCtrl = TextEditingController();
  final _commCtrl = TextEditingController();
  final _returnCtrl = TextEditingController();

  double _totalRevenue = 0;
  double _totalProductCost = 0;
  double _commissionCost = 0;
  double _totalExpenses = 0;
  double _netProfit = 0;
  double _profitPerUnit = 0;
  double _profitMargin = 0;
  bool _calculated = false;

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    int qty = int.tryParse(_qtyCtrl.text) ?? 0;
    double price = double.tryParse(_priceCtrl.text) ?? 0;
    double cost = double.tryParse(_costCtrl.text) ?? 0;
    double shipping = double.tryParse(_shippingCtrl.text) ?? 0;
    double ad = double.tryParse(_adCtrl.text) ?? 0;
    double commRate = double.tryParse(_commCtrl.text) ?? 0;
    double ret = double.tryParse(_returnCtrl.text) ?? 0;

    setState(() {
      _totalRevenue = price * qty;
      _totalProductCost = cost * qty;
      _commissionCost = _totalRevenue * (commRate / 100);
      _totalExpenses =
          _totalProductCost + shipping + ad + _commissionCost + ret;
      _netProfit = _totalRevenue - _totalExpenses;
      _profitPerUnit = qty > 0 ? _netProfit / qty : 0;
      _profitMargin = _totalRevenue > 0
          ? (_netProfit / _totalRevenue) * 100
          : 0;
      _calculated = true;
    });
  }

  void _reset() {
    _formKey.currentState?.reset();
    _nameCtrl.clear();
    _qtyCtrl.clear();
    _priceCtrl.clear();
    _costCtrl.clear();
    _shippingCtrl.clear();
    _adCtrl.clear();
    _commCtrl.clear();
    _returnCtrl.clear();
    setState(() {
      _calculated = false;
    });
  }

  Widget _buildInput(
    String label,
    TextEditingController ctrl, {
    bool isNumber = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Required';
          if (isNumber && double.tryParse(value) == null)
            return 'Invalid number';
          return null;
        },
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profitColor = _netProfit >= 0 ? Colors.green : Colors.red;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF4C1D95)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Completed Sale Profit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Calculate actual profit after sales',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sale Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInput('Product Name', _nameCtrl, isNumber: false),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInput('Quantity Sold', _qtyCtrl),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInput(
                              'Unit Selling Price',
                              _priceCtrl,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInput('Unit Product Cost', _costCtrl),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInput(
                              'Commission Rate (%)',
                              _commCtrl,
                            ),
                          ),
                        ],
                      ),
                      _buildInput('Total Shipping Cost', _shippingCtrl),
                      _buildInput('Total Advertising Cost', _adCtrl),
                      _buildInput('Total Return / Refund Cost', _returnCtrl),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _reset,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Reset',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _calculate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Calculate Profit',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      if (_calculated) ...[
                        const Divider(),
                        const SizedBox(height: 16),
                        const Text(
                          'Calculation Results',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _buildResultRow(
                                  'Total Revenue',
                                  '\$${_totalRevenue.toStringAsFixed(2)}',
                                ),
                                _buildResultRow(
                                  'Total Product Cost',
                                  '-\$${_totalProductCost.toStringAsFixed(2)}',
                                ),
                                _buildResultRow(
                                  'Commission Cost',
                                  '-\$${_commissionCost.toStringAsFixed(2)}',
                                ),
                                _buildResultRow(
                                  'Total Shipping Cost',
                                  '-\$${double.tryParse(_shippingCtrl.text) ?? 0}',
                                ),
                                _buildResultRow(
                                  'Total Adv. Cost',
                                  '-\$${double.tryParse(_adCtrl.text) ?? 0}',
                                ),
                                _buildResultRow(
                                  'Total Return Cost',
                                  '-\$${double.tryParse(_returnCtrl.text) ?? 0}',
                                ),
                                const Divider(height: 24),
                                _buildResultRow(
                                  'Total Expenses',
                                  '\$${_totalExpenses.toStringAsFixed(2)}',
                                  isBold: true,
                                ),
                                _buildResultRow(
                                  'Net Profit',
                                  '\$${_netProfit.toStringAsFixed(2)}',
                                  isBold: true,
                                  color: profitColor,
                                ),
                                _buildResultRow(
                                  'Profit Per Unit',
                                  '\$${_profitPerUnit.toStringAsFixed(2)}',
                                  color: profitColor,
                                ),
                                _buildResultRow(
                                  'Profit Margin',
                                  '${_profitMargin.toStringAsFixed(2)}%',
                                  color: profitColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          color: _netProfit >= 0
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: _netProfit >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  _netProfit >= 0
                                      ? Icons.check_circle
                                      : Icons.warning,
                                  color: profitColor,
                                  size: 32,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    _netProfit >= 0
                                        ? 'This sale is profitable'
                                        : 'This sale needs review',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: profitColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 7. Total Business Profit Screen
class SaleData {
  final String productName;
  final DateTime saleDate;
  final double revenue;
  final double expenses;

  SaleData({
    required this.productName,
    required this.saleDate,
    required this.revenue,
    required this.expenses,
  });
}

// Global sales records to draw real-time B2B/B2C charts dynamically
List<SaleData> globalSalesData = [];

class TotalBusinessProfitScreen extends StatefulWidget {
  const TotalBusinessProfitScreen({super.key});

  @override
  State<TotalBusinessProfitScreen> createState() =>
      _TotalBusinessProfitScreenState();
}

class _TotalBusinessProfitScreenState extends State<TotalBusinessProfitScreen> {
  String _selectedDateRange = 'This Month';
  String _selectedProduct = 'All Products';
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  List<SaleData> get _allSales => globalSalesData;

  final List<String> _dateRanges = [
    'Today',
    'This Week',
    'This Month',
    'This Year',
    'Custom Range'
  ];

  final List<String> _products = [
    'All Products',
    'Oversized Cotton Hoodie',
    'Slim Fit Denim Jacket',
    'Linen Summer Shirt',
    'Premium Fleece Joggers'
  ];

  @override
  void initState() {
    super.initState();
    if (globalSalesData.isEmpty) {
      _generateDummyData();
    }
  }

  void _generateDummyData() {
    final now = DateTime.now();
    final products = [
      'Oversized Cotton Hoodie',
      'Slim Fit Denim Jacket',
      'Linen Summer Shirt',
      'Premium Fleece Joggers'
    ];

    // Generate specific dummy data so it's consistent and covers ranges
    for (int i = 0; i < 1000; i++) {
      // distribute more towards recent days
      int daysAgo;
      if (i < 100) daysAgo = 0; // Today
      else if (i < 300) daysAgo = i % 7; // This week
      else if (i < 600) daysAgo = i % 30; // This month
      else daysAgo = i % 365; // This year

      final saleDate = now.subtract(Duration(days: daysAgo));
      final product = products[i % products.length];

      double basePrice = 0;
      double baseExpense = 0;
      switch (product) {
        case 'Oversized Cotton Hoodie':
          basePrice = 49.99;
          baseExpense = 19.0;
          break;
        case 'Slim Fit Denim Jacket':
          basePrice = 79.99;
          baseExpense = 33.0;
          break;
        case 'Linen Summer Shirt':
          basePrice = 39.99;
          baseExpense = 15.5;
          break;
        case 'Premium Fleece Joggers':
          basePrice = 44.99;
          baseExpense = 17.0;
          break;
      }

      _allSales.add(SaleData(
        productName: product,
        saleDate: saleDate,
        revenue: basePrice,
        expenses: baseExpense,
      ));
    }
  }

  List<SaleData> _getFilteredSales() {
    final now = DateTime.now();
    return _allSales.where((sale) {
      // Product Filter
      if (_selectedProduct != 'All Products' &&
          sale.productName != _selectedProduct) {
        return false;
      }

      // Date Filter
      if (_selectedDateRange == 'Today') {
        return sale.saleDate.year == now.year &&
            sale.saleDate.month == now.month &&
            sale.saleDate.day == now.day;
      } else if (_selectedDateRange == 'This Week') {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return sale.saleDate.isAfter(startOfWeek.subtract(const Duration(days: 1)));
      } else if (_selectedDateRange == 'This Month') {
        return sale.saleDate.year == now.year &&
            sale.saleDate.month == now.month;
      } else if (_selectedDateRange == 'This Year') {
        return sale.saleDate.year == now.year;
      } else if (_selectedDateRange == 'Custom Range') {
        if (_customStartDate != null && _customEndDate != null) {
          final start = _customStartDate!.subtract(const Duration(days: 1));
          final end = _customEndDate!.add(const Duration(days: 1));
          return sale.saleDate.isAfter(start) && sale.saleDate.isBefore(end);
        }
      }

      return true;
    }).toList();
  }

  void _openCustomDateBottomSheet() {
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();

    if (_customStartDate != null) {
      startCtrl.text = "${_customStartDate!.year}-${_customStartDate!.month.toString().padLeft(2, '0')}-${_customStartDate!.day.toString().padLeft(2, '0')}";
    }
    if (_customEndDate != null) {
      endCtrl.text = "${_customEndDate!.year}-${_customEndDate!.month.toString().padLeft(2, '0')}-${_customEndDate!.day.toString().padLeft(2, '0')}";
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Custom Date Range',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: startCtrl,
                decoration: const InputDecoration(
                  labelText: 'Start Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: endCtrl,
                decoration: const InputDecoration(
                  labelText: 'End Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    try {
                      final start = DateTime.parse(startCtrl.text);
                      final end = DateTime.parse(endCtrl.text);
                      setState(() {
                        _customStartDate = start;
                        _customEndDate = end;
                        _selectedDateRange = 'Custom Range';
                      });
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid date format. Use YYYY-MM-DD')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Apply', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedDateRange = 'This Month';
      _selectedProduct = 'All Products';
      _customStartDate = null;
      _customEndDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredSales = _getFilteredSales();

    double totalRevenue = 0;
    double totalExpenses = 0;
    for (var sale in filteredSales) {
      totalRevenue += sale.revenue;
      totalExpenses += sale.expenses;
    }
    double netProfit = totalRevenue - totalExpenses;
    int totalSales = filteredSales.length;
    double margin = totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0;

    // Trend bars calculation
    List<double> trendData = List.filled(6, 0.0);
    if (filteredSales.isNotEmpty) {
      // Divide filtered sales into 6 chunks
      int chunkSize = (filteredSales.length / 6).ceil();
      if (chunkSize == 0) chunkSize = 1;
      for (int i = 0; i < filteredSales.length; i++) {
        int trendIndex = (i / chunkSize).floor();
        if (trendIndex > 5) trendIndex = 5;
        trendData[trendIndex] += (filteredSales[i].revenue - filteredSales[i].expenses);
      }
    }
    double maxTrend = trendData.isNotEmpty ? trendData.reduce((a, b) => a > b ? a : b) : 1;
    if (maxTrend <= 0) maxTrend = 1;

    // Product performance
    Map<String, double> productProfits = {};
    for (var sale in filteredSales) {
      productProfits[sale.productName] = (productProfits[sale.productName] ?? 0) + (sale.revenue - sale.expenses);
    }
    
    var sortedProducts = productProfits.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    String bestSelling = sortedProducts.isNotEmpty ? sortedProducts.first.key : 'N/A';
    String lowPerforming = sortedProducts.isNotEmpty ? sortedProducts.last.key : 'N/A';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. Gradient Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF4C1D95)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Total Business Profit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Analyze your profit with filters',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filters',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: _resetFilters,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Reset Filters'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Date Filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _dateRanges.map((range) {
                          final isSelected = _selectedDateRange == range;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(range),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  if (range == 'Custom Range') {
                                    _openCustomDateBottomSheet();
                                  } else {
                                    setState(() => _selectedDateRange = range);
                                  }
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Product Filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _products.map((product) {
                          final isSelected = _selectedProduct == product;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(product),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedProduct = product);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Active Filters Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          label: Text('Date: $_selectedDateRange'),
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        ),
                        Chip(
                          label: Text('Product: $_selectedProduct'),
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),

                    // 3. Main Stats Grid
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.2,
                      children: [
                        _buildStatCard(
                          'Total Revenue',
                          '\$${totalRevenue.toStringAsFixed(0)}',
                          Icons.account_balance_wallet,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Total Expenses',
                          '\$${totalExpenses.toStringAsFixed(0)}',
                          Icons.money_off,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          'Net Profit',
                          '\$${netProfit.toStringAsFixed(0)}',
                          Icons.attach_money,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Total Sales',
                          '$totalSales',
                          Icons.shopping_cart,
                          Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Summary card for average profit margin
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.pie_chart,
                            color: Colors.green.shade600,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Average Profit Margin',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${margin.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. Trend Bars
                    const Text(
                      'Profit Trend',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(6, (index) {
                          double barProfit = trendData[index];
                          double normalizedHeight = 40.0;
                          if (barProfit > 0) {
                             normalizedHeight = 40.0 + (barProfit / maxTrend) * 100.0;
                          }
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 30,
                                height: normalizedHeight.clamp(10.0, 140.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.8),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'T${index + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 5. Product Performance
                    const Text(
                      'Product Performance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPerformanceRow(
                      'Best Selling / Profitable',
                      bestSelling,
                      Icons.star,
                      Colors.orange,
                    ),
                    _buildPerformanceRow(
                      'Low Performing',
                      lowPerforming,
                      Icons.trending_down,
                      Colors.red,
                    ),
                    const SizedBox(height: 24),

                    // 6. Insight Cards
                    const Text(
                      'AI Insights',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInsightCard(
                      'Your filtering is working correctly. Watch closely on "$lowPerforming".',
                      Icons.auto_graph,
                      Colors.green,
                    ),
                    _buildInsightCard(
                      'Advertising cost is higher than last month. Consider optimizing campaigns.',
                      Icons.warning_amber_rounded,
                      Colors.orange,
                    ),
                    _buildInsightCard(
                      '$bestSelling is driving the most net margin.',
                      Icons.lightbulb_outline,
                      Colors.blue,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceRow(
    String label,
    String product,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  product,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String message, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

// 8. AI Stock Advisor Screen
class AiStockAdvisorScreen extends StatelessWidget {
  const AiStockAdvisorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. Gradient Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF4C1D95)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'AI Stock Advisor',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Smart recommendations for stock and production',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI Summary section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.indigo.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Colors.indigo.shade600,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'AI recommends increasing stock for fast-moving products and reviewing low-margin items.',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Top Recommendations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildRecommendationCard(
                      'Oversized Cotton Hoodie',
                      'This product is selling fast. Consider ordering or producing 300 more units.',
                      'High',
                      'Order more units',
                      '+18% revenue potential',
                      Colors.red,
                    ),
                    _buildRecommendationCard(
                      'Slim Fit Denim Jacket',
                      'High margin product. Increase advertising budget by 12%.',
                      'High',
                      'Increase ads',
                      '+9% profit margin improvement',
                      Colors.red,
                    ),
                    _buildRecommendationCard(
                      'Linen Summer Shirt',
                      'Low profit margin detected. Review supplier cost or increase price.',
                      'Medium',
                      'Review pricing',
                      'Reduce margin loss',
                      Colors.orange,
                    ),
                    _buildRecommendationCard(
                      'Premium Fleece Joggers',
                      'Stable demand. Keep current stock level.',
                      'Low',
                      'Maintain stock',
                      'Maintain stable sales',
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(
    String product,
    String text,
    String priority,
    String action,
    String impact,
    Color priorityColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: priorityColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    priority,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(text, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.flash_on, size: 16, color: Colors.amber),
                const SizedBox(width: 6),
                Text(
                  'Action: $action',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.trending_up, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  'Impact: $impact',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// NEW: SUPPLY REQUEST SYSTEM
// -----------------------------------------------------------------------------

// 1. Owner Supply Requests Screen
// 1. Owner Supply Requests Screen
// 1. Owner Supply Requests Screen (Supply Listings Hub / İlanlarım)
class OwnerSupplyRequestsScreen extends StatefulWidget {
  const OwnerSupplyRequestsScreen({super.key});
  @override
  State<OwnerSupplyRequestsScreen> createState() => _OwnerSupplyRequestsScreenState();
}

class _OwnerSupplyRequestsScreenState extends State<OwnerSupplyRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final openCount = globalSupplyRequests.where((r) => r['status'] == 'Open' || r['status'] == 'Waiting for Offers' || r['status'] == 'Offer Received').length;
    final selectedCount = globalSupplyRequests.where((r) => r['status'] == 'Supplier Selected' || r['status'] == 'Closed').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supply Listings Hub'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF3B0764)],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Symmetrical Statistics Panel
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Text('$openCount Listings', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent)),
                        const SizedBox(height: 4),
                        const Text('Active Market Bids', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.teal.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Text('$selectedCount Selected', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                        const SizedBox(height: 4),
                        const Text('Closed Contracts', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: globalSupplyRequests.isEmpty
                ? const Center(child: Text('No supply listings created yet. Click "+" to create one!'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: globalSupplyRequests.length,
                    itemBuilder: (context, index) {
                      final req = globalSupplyRequests[index];
                      final String status = req['status'] ?? 'Open';
                      final String reqId = req['id'] ?? '';
                      
                      // Count offers bidded
                      final offersCount = globalSupplierProposals.where((p) => p['reqId'] == reqId).length;

                      Color statusColor = Colors.blue;
                      IconData statusIcon = Icons.campaign_outlined;
                      
                      if (status == 'Open') {
                        statusColor = Colors.blue;
                        statusIcon = Icons.campaign_outlined;
                      } else if (status == 'Waiting for Offers') {
                        statusColor = Colors.orange;
                        statusIcon = Icons.hourglass_empty_rounded;
                      } else if (status == 'Offer Received') {
                        statusColor = Colors.indigoAccent;
                        statusIcon = Icons.mark_email_unread_outlined;
                      } else if (status == 'Supplier Selected') {
                        statusColor = Colors.teal;
                        statusIcon = Icons.handshake_outlined;
                      } else if (status == 'Closed') {
                        statusColor = Colors.grey;
                        statusIcon = Icons.lock_outline;
                      } else if (status == 'Cancelled') {
                        statusColor = Colors.redAccent;
                        statusIcon = Icons.cancel_outlined;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      req['product'] ?? 'Unknown Product',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(statusIcon, color: statusColor, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          status,
                                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Target Quantity', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                      const SizedBox(height: 4),
                                      Text('${req['quantity']} units', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text('Target Price', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                      const SizedBox(height: 4),
                                      Text('\$${req['targetPrice']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Bids Received', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                      const SizedBox(height: 4),
                                      Text('$offersCount bids', style: TextStyle(fontWeight: FontWeight.bold, color: offersCount > 0 ? Colors.indigoAccent : Colors.grey, fontSize: 13)),
                                    ],
                                  ),
                                ],
                              ),
                              if (req['notes'] != null && req['notes'].toString().isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Guidelines: ${req['notes']}',
                                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Deadline: ${req['deadline']}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  Row(
                                    children: [
                                      if (status == 'Open' || status == 'Waiting for Offers' || status == 'Offer Received') ...[
                                        TextButton.icon(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('Cancel Listing?'),
                                                content: const Text('Are you sure you want to cancel this supply listing? Suppliers will no longer be able to place bids.'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Back')),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                    onPressed: () {
                                                      setState(() {
                                                        req['status'] = 'Cancelled';
                                                      });
                                                      Navigator.pop(ctx);
                                                    },
                                                    child: const Text('Cancel Listing'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.redAccent),
                                          label: const Text('Cancel', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => OwnerProposalReviewScreen(requestIndex: index),
                                            ),
                                          ).then((_) => setState(() {}));
                                        },
                                        icon: const Icon(Icons.compare_arrows, size: 14),
                                        label: Text(status == 'Supplier Selected' ? 'View Selected' : 'Compare Bids ($offersCount)'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: status == 'Supplier Selected' ? Colors.teal : const Color(0xFF4C1D95),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateSupplyRequestScreen()),
          ).then((_) => setState(() {}));
        },
        label: const Text('Create Listing'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF4C1D95),
      ),
    );
  }
}

// 2. Create Supply Request Screen (Supply Listing Oluşturma)
class CreateSupplyRequestScreen extends StatefulWidget {
  const CreateSupplyRequestScreen({super.key});
  @override
  State<CreateSupplyRequestScreen> createState() => _CreateSupplyRequestScreenState();
}

class _CreateSupplyRequestScreenState extends State<CreateSupplyRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _deadlineCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  void _publishListing() {
    if (_formKey.currentState!.validate()) {
      globalSupplyRequests.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'product': _productCtrl.text,
        'quantity': int.tryParse(_qtyCtrl.text) ?? 100,
        'targetPrice': double.tryParse(_priceCtrl.text) ?? 10.0,
        'deadline': _deadlineCtrl.text,
        'notes': _notesCtrl.text,
        'supplier': null,
        'status': 'Open',
      });

      // Insert notification
      globalOwnerNotifications.insert(0, {
        'title': 'Supply Listing Created',
        'message': 'New wholesale purchase requirement for ${_productCtrl.text} published to the Supplier Market.',
        'type': 'Supply Process',
        'read': false,
        'timestamp': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Listing for ${_productCtrl.text} successfully published!'),
          backgroundColor: Colors.indigo,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildPremiumField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = true,
    String? hintText,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.indigo.withOpacity(0.7)),
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          if (isNumber && double.tryParse(value) == null) {
            return 'Invalid number';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const GradientHeader(title: 'Create Supply Listing', showBackButton: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.indigo.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.indigo.withOpacity(0.12)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.indigo, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Publish an open supply requirement. Any registered supplier can see it and submit pricing & delivery proposals.',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Catalog Quick-Select:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigo),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 72,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: globalProducts.length,
                          itemBuilder: (context, idx) {
                            final p = globalProducts[idx];
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _productCtrl.text = p.name;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                                  ],
                                  border: Border.all(
                                    color: _productCtrl.text == p.name ? Colors.indigo : (isDark ? Colors.white10 : Colors.grey.shade200),
                                    width: _productCtrl.text == p.name ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      p.name,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _productCtrl.text == p.name ? Colors.indigo : null),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.inventory_2_outlined, size: 12, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Current: ${p.stock} units',
                                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildPremiumField('Product Name / Description', _productCtrl, Icons.shopping_bag_outlined, isNumber: false),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildPremiumField('Target Quantity', _qtyCtrl, Icons.numbers),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildPremiumField('Target Unit Price (\$)', _priceCtrl, Icons.attach_money),
                          ),
                        ],
                      ),

                      _buildPremiumField('Delivery Target Date / Deadline', _deadlineCtrl, Icons.date_range, isNumber: false, hintText: 'e.g. 2026-06-30'),
                      
                      _buildPremiumField('Fabrication Requirements / Guidelines', _notesCtrl, Icons.text_snippet_outlined, isNumber: false, maxLines: 3),
                      
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _publishListing,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4C1D95),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: const Text('Publish Supply Listing', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. Supplier Open Requests Screen (B2B Listings Market & Bids Hub)
class SupplierOpenRequestsScreen extends StatefulWidget {
  final String supplierName;
  const SupplierOpenRequestsScreen({super.key, required this.supplierName});
  @override
  State<SupplierOpenRequestsScreen> createState() => _SupplierOpenRequestsScreenState();
}

class _SupplierOpenRequestsScreenState extends State<SupplierOpenRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter listings that are open
    final openListings = globalSupplyRequests.where((r) => r['status'] == 'Open' || r['status'] == 'Waiting for Offers' || r['status'] == 'Offer Received').toList();

    // Filter my bids
    final myBids = globalSupplierProposals.where((p) => p['supplier'] == widget.supplierName).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('B2B Wholesale Market'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF065F46)],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.tealAccent,
          tabs: [
            Tab(text: 'Browse Listings (${openListings.length})'),
            Tab(text: 'My Active Bids (${myBids.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // TAB 1: BROWSE OPEN LISTINGS
          openListings.isEmpty
              ? const Center(child: Text('No active listings found in the market.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: openListings.length,
                  itemBuilder: (context, index) {
                    final req = openListings[index];
                    final reqId = req['id'] ?? '';
                    
                    // Check if I bidded
                    final hasBidded = myBids.any((b) => b['reqId'] == reqId);
                    final mySpecificBid = hasBidded ? myBids.firstWhere((b) => b['reqId'] == reqId) : null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    req['product'] ?? 'No Product Title',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Accepting Bids',
                                    style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Quantity Target', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                    const SizedBox(height: 4),
                                    Text('${req['quantity']} units', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text('Target Price', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                    const SizedBox(height: 4),
                                    Text('\$${req['targetPrice']} /unit', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Total Budget', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${((double.tryParse(req['targetPrice'].toString()) ?? 0.0) * (double.tryParse(req['quantity'].toString()) ?? 0.0)).toStringAsFixed(0)}', 
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (req['notes'] != null && req['notes'].toString().isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text('Guidelines: "${req['notes']}"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.grey)),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Deadline: ${req['deadline']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                if (hasBidded) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Your Bid: \$${mySpecificBid?['offeredPrice']}',
                                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ] else ...[
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SupplierSubmitProposalScreen(
                                            reqId: reqId,
                                            supplierName: widget.supplierName,
                                          ),
                                        ),
                                      ).then((_) => setState(() {}));
                                    },
                                    icon: const Icon(Icons.gavel, size: 14),
                                    label: const Text('Submit Bid Offer'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ],
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),

          // TAB 2: MY SUBMITTED BIDS
          myBids.isEmpty
              ? const Center(child: Text('You haven\'t placed any bids yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: myBids.length,
                  itemBuilder: (context, index) {
                    final bid = myBids[index];
                    final String bidStatus = bid['status'] ?? 'Pending';
                    final reqId = bid['reqId'] ?? '';

                    // Find corresponding listing
                    final associatedReq = globalSupplyRequests.firstWhere(
                      (r) => r['id'] == reqId,
                      orElse: () => {'product': 'Archived Listing'},
                    );

                    Color statusColor = Colors.orange;
                    IconData statusIcon = Icons.hourglass_empty_rounded;
                    String statusText = 'Pending Review';

                    if (bidStatus == 'Accepted') {
                      statusColor = Colors.teal;
                      statusIcon = Icons.check_circle_outline;
                      statusText = 'Winner! Bid Accepted';
                    } else if (bidStatus == 'Rejected') {
                      statusColor = Colors.redAccent;
                      statusIcon = Icons.cancel_outlined;
                      statusText = 'Bid Not Selected';
                    } else if (bidStatus == 'Cancelled') {
                      statusColor = Colors.grey;
                      statusIcon = Icons.block_outlined;
                      statusText = 'Cancelled';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade100),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    associatedReq['product'] ?? '',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(statusIcon, color: statusColor, size: 12),
                                      const SizedBox(width: 4),
                                      Text(
                                        statusText,
                                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('My Bid: \$${bid['offeredPrice']} per unit', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('Qty: ${bid['quantity']} units', style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Est. Delivery Time: ${bid['deliveryTime']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            if (bid['message'] != null && bid['message'].toString().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text('Proposal Note: "${bid['message']}"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.grey)),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

// 4. Supplier Submit Proposal Screen (Teklif Gönderme Ekranı)
class SupplierSubmitProposalScreen extends StatefulWidget {
  final String reqId;
  final String supplierName;
  const SupplierSubmitProposalScreen({super.key, required this.reqId, required this.supplierName});
  @override
  State<SupplierSubmitProposalScreen> createState() => _SupplierSubmitProposalScreenState();
}

class _SupplierSubmitProposalScreenState extends State<SupplierSubmitProposalScreen> {
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _deliveryCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  void _sendProposal() {
    if (_priceCtrl.text.isEmpty || _qtyCtrl.text.isEmpty || _deliveryCtrl.text.isEmpty) return;
    
    globalSupplierProposals.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'reqId': widget.reqId,
      'supplier': widget.supplierName,
      'offeredPrice': _priceCtrl.text,
      'quantity': int.tryParse(_qtyCtrl.text) ?? 100,
      'deliveryTime': _deliveryCtrl.text,
      'message': _msgCtrl.text,
      'status': 'Pending',
      'date': DateTime.now().toString().substring(0, 10),
    });

    // Update the supply request status to Offer Received
    final reqIndex = globalSupplyRequests.indexWhere((r) => r['id'] == widget.reqId);
    if (reqIndex != -1) {
      globalSupplyRequests[reqIndex]['status'] = 'Offer Received';
    }

    final req = globalSupplyRequests.firstWhere(
      (r) => r['id'] == widget.reqId, 
      orElse: () => {'product': 'Unknown Product'}
    );
    
    globalOwnerNotifications.insert(0, {
      'title': 'New B2B Bid Offer Received!',
      'message': '${widget.supplierName} submitted a bid of \$${_priceCtrl.text} per unit for ${req['product']}.',
      'type': 'Supply Proposal',
      'read': false,
      'timestamp': DateTime.now(),
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bid Offer sent successfully to Owner!'), backgroundColor: Colors.teal),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Find associated req to pre-fill target stats
    final associatedReq = globalSupplyRequests.firstWhere((r) => r['id'] == widget.reqId, orElse: () => {});

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit B2B Offer'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF065F46)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Listing Targets', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(associatedReq['product'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Target Quantity: ${associatedReq['quantity']} units'),
                  Text('Target B2B Price: \$${associatedReq['targetPrice']} /unit'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _priceCtrl,
              decoration: const InputDecoration(labelText: 'My Unit Price Bid (\$)', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _qtyCtrl,
              decoration: const InputDecoration(labelText: 'Quantity I Can Deliver', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _deliveryCtrl,
              decoration: const InputDecoration(labelText: 'Delivery Timeframe (e.g. 10 days, 2026-06-05)', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _msgCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description / Message to Owner', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _sendProposal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Transmit Bid Proposal', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 5. Owner Proposal Review Screen (İlan Detayı, Teklif Karşılaştırma & Kabul/Ret)
class OwnerProposalReviewScreen extends StatefulWidget {
  final int requestIndex;
  const OwnerProposalReviewScreen({super.key, required this.requestIndex});
  @override
  State<OwnerProposalReviewScreen> createState() => _OwnerProposalReviewScreenState();
}

class _OwnerProposalReviewScreenState extends State<OwnerProposalReviewScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final req = globalSupplyRequests[widget.requestIndex];
    final reqId = req['id'] ?? '';
    final String listingStatus = req['status'] ?? 'Open';

    // Find all bids for this listing
    final proposals = globalSupplierProposals.where((p) => p['reqId'] == reqId).toList();

    // Find lowest bidded price (Best Offer Highlight)
    double lowestPrice = 999999.9;
    String lowestSupplier = '';
    for (var p in proposals) {
      final val = double.tryParse(p['offeredPrice'].toString()) ?? 999999.9;
      if (val < lowestPrice) {
        lowestPrice = val;
        lowestSupplier = p['supplier'] ?? '';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare B2B Bids'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF3B0764)],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Listing Header
          Container(
            padding: const EdgeInsets.all(20),
            color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Listing Details', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(req['product'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Target Qty: ${req['quantity']} units', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(width: 16),
                    Text('Target Price: \$${req['targetPrice']}', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                if (req['notes'] != null && req['notes'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('My guidelines: "${req['notes']}"', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 12)),
                ]
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: proposals.isEmpty
                ? const Center(child: Text('No supplier bids received for this listing yet.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: proposals.length,
                    itemBuilder: (context, index) {
                      final prop = proposals[index];
                      final String bidStatus = prop['status'] ?? 'Pending';
                      final String supplier = prop['supplier'] ?? '';

                      Color statusColor = Colors.orange;
                      if (bidStatus == 'Accepted') statusColor = Colors.teal;
                      if (bidStatus == 'Rejected') statusColor = Colors.red;

                      final double priceVal = double.tryParse(prop['offeredPrice'].toString()) ?? 0.0;
                      final int qtyVal = int.tryParse(prop['quantity'].toString()) ?? 0;
                      final double totalCost = priceVal * qtyVal;

                      final isBestPrice = supplier == lowestSupplier && proposals.length > 1;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isBestPrice ? Colors.green : (isDark ? Colors.white12 : Colors.grey.shade100),
                            width: isBestPrice ? 2 : 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(supplier, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      if (isBestPrice) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                                          child: const Text('BEST PRICE', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                                        )
                                      ]
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      bidStatus,
                                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Offered Unit Price', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                      const SizedBox(height: 4),
                                      Text('\$$priceVal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text('Offer Quantity', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                      const SizedBox(height: 4),
                                      Text('$qtyVal units', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Total Transaction', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                      const SizedBox(height: 4),
                                      Text('\$${totalCost.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text('Estimated Delivery: ${prop['deliveryTime']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              if (prop['message'].toString().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text('"${prop['message']}"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.grey)),
                              ],
                              
                              if (bidStatus == 'Pending' && (listingStatus == 'Open' || listingStatus == 'Offer Received' || listingStatus == 'Waiting for Offers')) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            prop['status'] = 'Rejected';
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Bid Offer rejected'), backgroundColor: Colors.redAccent),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.redAccent,
                                          side: const BorderSide(color: Colors.redAccent),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        child: const Text('Reject Bid'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          final String pName = req['product'] ?? '';
                                          final int finalQty = qtyVal;
                                          
                                          // Find and update global product stock dynamically
                                          final pIndex = globalProducts.indexWhere((p) => p.name.toLowerCase().contains(pName.toLowerCase()) || pName.toLowerCase().contains(p.name.toLowerCase()));
                                          if (pIndex != -1) {
                                            globalProducts[pIndex].stock += finalQty;
                                          } else {
                                            // If product doesn't exist, create it dynamically
                                            globalProducts.add(Product(
                                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                                              name: pName,
                                              price: priceVal * 1.5, // 50% profit margin markup for owner resell
                                              cost: priceVal, // Owner's purchase cost is the wholesale B2B price
                                              commissionRate: 15.0, // Standard marketplace commission
                                              shippingCost: 5.5, // Standard average shipping cost
                                              advertisingCost: 10.0, // Standard target ROAS allocation
                                              returnRate: 4.0, // Standard e-commerce return expectation
                                              salesCount: 0,
                                              stock: finalQty,
                                            ));
                                          }

                                          // Log transaction operational cost
                                          globalOperationalCosts.add({
                                            'title': 'Wholesale Supply Purchase ($pName)',
                                            'amount': totalCost,
                                            'category': 'Supply',
                                            'date': DateTime.now().toString().substring(0, 10),
                                          });
                                          
                                          setState(() {
                                            // Winner set to Accepted
                                            prop['status'] = 'Accepted';
                                            
                                            // All other bids for this request set to Rejected
                                            for (var other in globalSupplierProposals) {
                                              if (other['reqId'] == reqId && other['id'] != prop['id']) {
                                                other['status'] = 'Rejected';
                                              }
                                            }

                                            // Listing status set to Supplier Selected / Closed
                                            req['status'] = 'Supplier Selected';
                                            req['supplier'] = supplier;
                                          });

                                          // Notify selected winner
                                          globalOwnerNotifications.insert(0, {
                                            'title': 'B2B Contract Signed!',
                                            'message': 'Congratulations! Owner accepted your offer of \$${priceVal} for $pName. Production contract is active!',
                                            'type': 'Supply Success',
                                            'read': false,
                                            'timestamp': DateTime.now(),
                                          });
                                          
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            content: Text('Offer from $supplier accepted! $finalQty units added to stock.'),
                                            backgroundColor: Colors.teal,
                                          ));

                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        child: const Text('Accept Offer'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// 6. Owner Notifications Screen
class OwnerNotificationsScreen extends StatefulWidget {
  const OwnerNotificationsScreen({super.key});
  @override
  State<OwnerNotificationsScreen> createState() => _OwnerNotificationsScreenState();
}

class _OwnerNotificationsScreenState extends State<OwnerNotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF4C1D95)],
            ),
          ),
        ),
      ),
      body: globalOwnerNotifications.isEmpty
          ? const Center(child: Text('No notifications yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: globalOwnerNotifications.length,
              itemBuilder: (context, index) {
                final notif = globalOwnerNotifications[index];
                final isUnread = !(notif['read'] as bool);
                
                return Card(
                  color: isUnread ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.handshake, color: Colors.white, size: 20),
                    ),
                    title: Text(
                      notif['title'], 
                      style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.normal),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notif['message']),
                        const SizedBox(height: 4),
                        Text(
                          notif['timestamp'].toString().substring(0, 16),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: isUnread ? Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ) : null,
                    onTap: () {
                      setState(() {
                        notif['read'] = true;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OwnerSupplyRequestsScreen(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

// -----------------------------------------------------------------------------
// NEW: OPERATIONAL COSTS SYSTEM
// -----------------------------------------------------------------------------

class OwnerOperationalCostsScreen extends StatefulWidget {
  final List<Product> products;
  const OwnerOperationalCostsScreen({super.key, required this.products});

  @override
  State<OwnerOperationalCostsScreen> createState() => _OwnerOperationalCostsScreenState();
}

class _OwnerOperationalCostsScreenState extends State<OwnerOperationalCostsScreen> {
  String _filter = 'All';

  final List<String> _categories = [
    'Rent', 'Electricity', 'Water', 'Internet', 'Salaries', 
    'Packaging', 'Warehouse', 'Maintenance', 'Other'
  ];

  IconData _getCategoryIcon(String cat) {
    switch(cat) {
      case 'Rent': return Icons.home_work;
      case 'Electricity': return Icons.electrical_services;
      case 'Water': return Icons.water_drop;
      case 'Internet': return Icons.wifi;
      case 'Salaries': return Icons.people;
      case 'Packaging': return Icons.inventory;
      case 'Warehouse': return Icons.warehouse;
      case 'Maintenance': return Icons.build;
      default: return Icons.money;
    }
  }

  void _showAddCostSheet() {
    final formKey = GlobalKey<FormState>();
    final amountCtrl = TextEditingController();
    final dueDateCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String selectedCat = _categories.first;
    String selectedStatus = 'Unpaid';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16, right: 16, top: 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Add Operational Cost', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedCat,
                        decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setModalState(() => selectedCat = v!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: amountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: dueDateCtrl,
                        decoration: const InputDecoration(labelText: 'Due Date (e.g. YYYY-MM-DD)', border: OutlineInputBorder()),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                        items: ['Paid', 'Unpaid'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setModalState(() => selectedStatus = v!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: notesCtrl,
                        decoration: const InputDecoration(labelText: 'Notes (Optional)', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                globalOperationalCosts.add({
                                  'category': selectedCat,
                                  'amount': double.tryParse(amountCtrl.text) ?? 0.0,
                                  'dueDate': dueDateCtrl.text,
                                  'status': selectedStatus,
                                  'notes': notesCtrl.text,
                                });
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cost Added!'), backgroundColor: Colors.green),
                              );
                            }
                          },
                          child: const Text('Add Cost', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalNetProfit = widget.products.fold(0.0, (sum, p) => sum + p.totalNetProfit);
    double totalCost = globalOperationalCosts.fold(0.0, (sum, c) => sum + (c['amount'] as double));
    double paidCost = globalOperationalCosts.where((c) => c['status'] == 'Paid').fold(0.0, (sum, c) => sum + (c['amount'] as double));
    double unpaidCost = totalCost - paidCost;
    double profitAfterCosts = totalNetProfit - totalCost;

    List<Map<String, dynamic>> filteredList = globalOperationalCosts;
    if (_filter == 'Paid') filteredList = globalOperationalCosts.where((c) => c['status'] == 'Paid').toList();
    if (_filter == 'Unpaid') filteredList = globalOperationalCosts.where((c) => c['status'] == 'Unpaid').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operational Costs'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF4C1D95)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surface,
              child: const Text('Track fixed and monthly business expenses', style: TextStyle(fontSize: 14)),
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Summary grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      Card(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('Total Monthly', style: TextStyle(fontSize: 12)),
                        Text('\$${totalCost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ])),
                      Card(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('Next Due', style: TextStyle(fontSize: 12)),
                        Text('\$${unpaidCost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      ])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Profit After Costs
                  Card(
                    color: profitAfterCosts >= 0 ? Colors.green.shade900 : Colors.red.shade900,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Profit After Costs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('\$${profitAfterCosts.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _filter == 'All',
                        onSelected: (_) => setState(() => _filter = 'All'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Paid'),
                        selected: _filter == 'Paid',
                        onSelected: (_) => setState(() => _filter = 'Paid'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Unpaid'),
                        selected: _filter == 'Unpaid',
                        onSelected: (_) => setState(() => _filter = 'Unpaid'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (filteredList.isEmpty)
                    const Padding(padding: EdgeInsets.all(24), child: Text('No costs found.'))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final cost = filteredList[index];
                        final isPaid = cost['status'] == 'Paid';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isPaid ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                              child: Icon(_getCategoryIcon(cost['category']), color: isPaid ? Colors.green : Colors.red),
                            ),
                            title: Text(cost['category'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Due: ${cost['dueDate']}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('\$${(cost['amount'] as double).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                if (!isPaid)
                                  InkWell(
                                    onTap: () {
                                      setState(() { cost['status'] = 'Paid'; });
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as Paid'), backgroundColor: Colors.green));
                                    },
                                    child: const Text('Mark Paid', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                                  )
                                else
                                  const Text('Paid', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCostSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add Cost'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}

// --- NEW SUPPLIER PROPOSALS SCREEN ---
class SupplierProposalsScreen extends StatefulWidget {
  const SupplierProposalsScreen({super.key});

  @override
  State<SupplierProposalsScreen> createState() => _SupplierProposalsScreenState();
}

class _SupplierProposalsScreenState extends State<SupplierProposalsScreen> {
  IconData _getIcon(String name) {
    if (name.contains('Hoodie')) return Icons.checkroom;
    if (name.contains('Jacket')) return Icons.dry_cleaning;
    if (name.contains('Shirt')) return Icons.layers;
    if (name.contains('Joggers')) return Icons.style;
    return Icons.shopping_bag;
  }

  Color _getColor(String name) {
    if (name.contains('Hoodie')) return Colors.indigo;
    if (name.contains('Jacket')) return Colors.blueGrey;
    if (name.contains('Shirt')) return Colors.amber;
    if (name.contains('Joggers')) return Colors.teal;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pending = globalSupplierProposals.where((p) => p['status'] == 'Pending').toList();
    final history = globalSupplierProposals.where((p) => p['status'] != 'Pending').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Supply Proposals'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF065F46)], // Dark slate to green
              ),
            ),
          ),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Pending Review'),
              Tab(text: 'History'),
            ],
            indicatorColor: Colors.teal.shade400,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
          ),
        ),
        body: TabBarView(
          children: [
            _buildProposalsList(pending, isDark),
            _buildProposalsList(history, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildProposalsList(List<Map<String, dynamic>> list, bool isDark) {
    if (list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.handshake_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No proposals in this section.', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final p = list[index];
        final String pName = p['productName'] ?? p['product'] ?? 'Textile Product';
        final int qty = int.tryParse(p['quantity'].toString()) ?? 0;
        final double price = double.tryParse((p['price'] ?? p['offeredPrice'] ?? 0.0).toString()) ?? 0.0;
        final String status = p['status'] ?? 'Pending';
        final String date = p['date'] ?? p['deliveryTime'] ?? '2026-05-19';

        Color statusColor = Colors.orange;
        if (status == 'Accepted') statusColor = Colors.green;
        if (status == 'Rejected') statusColor = Colors.red;

        final themeColor = _getColor(pName);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
            border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade100),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_getIcon(pName), color: themeColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Submitted on $date', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Proposed Quantity', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('$qty pcs', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Unit Price', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('\$${price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Total Value', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('\$${(qty * price).toStringAsFixed(2)}', style: TextStyle(color: Colors.teal.shade600, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SupplierSuppliedHistoryScreen extends StatefulWidget {
  final String supplierName;
  final int initialTab;
  const SupplierSuppliedHistoryScreen({super.key, required this.supplierName, this.initialTab = 0});

  @override
  State<SupplierSuppliedHistoryScreen> createState() => _SupplierSuppliedHistoryScreenState();
}

class _SupplierSuppliedHistoryScreenState extends State<SupplierSuppliedHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Pending Deliveries: Bids accepted by owner (status == 'Accepted') for this supplier
    final pendingDeliveries = globalSupplierProposals.where((p) => p['supplier'] == widget.supplierName && p['status'] == 'Accepted').toList();
    
    // Completed Deliveries: Bids delivered by supplier (status == 'Delivered') for this supplier
    final completedDeliveries = globalSupplierProposals.where((p) => p['supplier'] == widget.supplierName && p['status'] == 'Delivered').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deliveries Hub & History'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF065F46)],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.tealAccent,
          tabs: [
            Tab(text: 'Pending Deliveries (${pendingDeliveries.length})'),
            Tab(text: 'Supplied History (${completedDeliveries.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // TAB 1: PENDING DELIVERIES (Bekleyen Teslimatlar)
          pendingDeliveries.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.checkroom_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No pending deliveries. You are all caught up!', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pendingDeliveries.length,
                  itemBuilder: (context, index) {
                    final bid = pendingDeliveries[index];
                    final reqId = bid['reqId'] ?? '';
                    final associatedReq = globalSupplyRequests.firstWhere(
                      (r) => r['id'] == reqId,
                      orElse: () => {'product': 'Archived Request'},
                    );
                    final double priceVal = double.tryParse(bid['offeredPrice'].toString()) ?? 0.0;
                    final int qtyVal = int.tryParse(bid['quantity'].toString()) ?? 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    associatedReq['product'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Contract Active',
                                    style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Quantity', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                    const SizedBox(height: 4),
                                    Text('$qtyVal units', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text('Unit Price', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                    const SizedBox(height: 4),
                                    Text('\$$priceVal /unit', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Contract Value', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${(priceVal * qtyVal).toStringAsFixed(0)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('Delivery Target: ${bid['deliveryTime'] ?? 'Immediate'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            if (bid['message'] != null && bid['message'].toString().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text('My Memo: "${bid['message']}"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.grey)),
                            ],
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    // Mark bid as Delivered
                                    bid['status'] = 'Delivered';
                                    
                                    // Update globalSupplyRequests as Closed
                                    final reqIndex = globalSupplyRequests.indexWhere((r) => r['id'] == reqId);
                                    if (reqIndex != -1) {
                                      globalSupplyRequests[reqIndex]['status'] = 'Closed';
                                    }
                                  });
                                  
                                  // Notify Owner
                                  globalOwnerNotifications.insert(0, {
                                    'title': '🚚 Supply Order Delivered!',
                                    'message': 'Supplier ${widget.supplierName} has shipped and delivered $qtyVal units of ${associatedReq['product']}. Inventory restock is fully operational!',
                                    'type': 'Supply Success',
                                    'read': false,
                                    'timestamp': DateTime.now(),
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Delivery marked as completed! Inventory updated.'),
                                      backgroundColor: Colors.teal,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.local_shipping, size: 16),
                                label: const Text('Mark as Shipped & Delivered'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),

          // TAB 2: COMPLETED DELIVERIES (Supplied History)
          completedDeliveries.isEmpty
              ? const Center(child: Text('No completed supply orders yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: completedDeliveries.length,
                  itemBuilder: (context, index) {
                    final bid = completedDeliveries[index];
                    final reqId = bid['reqId'] ?? '';
                    final associatedReq = globalSupplyRequests.firstWhere(
                      (r) => r['id'] == reqId,
                      orElse: () => {'product': 'Archived Request'},
                    );
                    final double priceVal = double.tryParse(bid['offeredPrice'].toString()) ?? 0.0;
                    final int qtyVal = int.tryParse(bid['quantity'].toString()) ?? 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    associatedReq['product'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                const Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.teal, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      'Delivered',
                                      style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Delivered Qty', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                    const SizedBox(height: 4),
                                    Text('$qtyVal units', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text('Unit Value', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                    const SizedBox(height: 4),
                                    Text('\$$priceVal', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Total Value', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${(priceVal * qtyVal).toStringAsFixed(0)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('Fulfilled on: ${bid['deliveryTime'] ?? 'Completed'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// USER SUPPORT TICKETS SCREEN (Partner Ticket Center)
// -----------------------------------------------------------------------------
class UserSupportTicketsScreen extends StatefulWidget {
  final String userEmail;
  final String userName;
  final String userRole;

  const UserSupportTicketsScreen({
    super.key,
    required this.userEmail,
    required this.userName,
    required this.userRole,
  });

  @override
  State<UserSupportTicketsScreen> createState() => _UserSupportTicketsScreenState();
}

class _UserSupportTicketsScreenState extends State<UserSupportTicketsScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submitTicket() {
    if (_formKey.currentState!.validate()) {
      final ticketId = 'TKT-${1000 + globalTickets.length + 1}';
      setState(() {
        globalTickets.insert(0, {
          'id': ticketId,
          'userEmail': widget.userEmail,
          'userName': widget.userName,
          'userRole': widget.userRole,
          'title': _titleCtrl.text,
          'description': _descCtrl.text,
          'status': 'Pending',
          'reply': '',
          'createdAt': DateTime.now().toString().substring(0, 16),
        });
      });

      _titleCtrl.clear();
      _descCtrl.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Support ticket $ticketId created! Admin will review it shortly.'),
          backgroundColor: Colors.teal,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final myTickets = globalTickets.where((t) => t['userEmail'] == widget.userEmail).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Center'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF0D9488)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () => _showCreateTicketSheet(),
            tooltip: 'Create Ticket',
          ),
        ],
      ),
      body: myTickets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.support_agent, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No support tickets yet.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Have an issue? Click the button below to ask for help.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateTicketSheet(),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Support Ticket'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myTickets.length,
              itemBuilder: (context, index) {
                final ticket = myTickets[index];
                final String status = ticket['status'] ?? 'Pending';
                final String date = ticket['createdAt'] ?? '';

                Color statusColor = Colors.orange;
                if (status == 'In Progress') statusColor = Colors.blue;
                if (status == 'Resolved') statusColor = Colors.green;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ExpansionTile(
                    shape: const Border(),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        status == 'Resolved' ? Icons.check_circle_outline : Icons.help_outline,
                        color: statusColor,
                      ),
                    ),
                    title: Text(
                      ticket['title'] ?? 'Support Issue',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('ID: ${ticket['id']} • Date: $date', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(ticket['description'] ?? '', style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 16),
                            const Text('Admin Response:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.black26 : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
                              ),
                              child: Text(
                                ticket['reply'] != null && ticket['reply'].toString().isNotEmpty
                                    ? ticket['reply']
                                    : 'Awaiting admin response...',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontStyle: ticket['reply'] != null && ticket['reply'].toString().isNotEmpty
                                      ? FontStyle.normal
                                      : FontStyle.italic,
                                  color: ticket['reply'] != null && ticket['reply'].toString().isNotEmpty
                                      ? (isDark ? Colors.white.withOpacity(0.9) : Colors.black87)
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showCreateTicketSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Create Support Ticket',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Describe your issue and the admin team will solve it as soon as possible.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Subject / Title',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  decoration: InputDecoration(
                    labelText: 'Describe your issue details...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 4,
                  validator: (v) => v == null || v.isEmpty ? 'Description is required' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _submitTicket,
                    child: const Text('Submit Support Ticket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
