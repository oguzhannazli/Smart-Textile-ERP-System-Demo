import 'package:flutter/material.dart';

void main() {
  runApp(const FinanceApp());
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
  final int salesCount;

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

  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Wireless Earbuds Pro',
      price: 89.99,
      cost: 30.0,
      commissionRate: 15.0,
      shippingCost: 5.0,
      advertisingCost: 10.0,
      returnRate: 5.0,
      salesCount: 1432,
    ),
    Product(
      id: '2',
      name: 'Smart Watch Series 5',
      price: 199.00,
      cost: 90.0,
      commissionRate: 12.0,
      shippingCost: 8.0,
      advertisingCost: 15.0,
      returnRate: 4.0,
      salesCount: 892,
    ),
    Product(
      id: '3',
      name: 'Laptop Stand Aluminum',
      price: 34.50,
      cost: 12.0,
      commissionRate: 15.0,
      shippingCost: 6.0,
      advertisingCost: 8.0,
      returnRate: 3.0,
      salesCount: 2104,
    ),
    Product(
      id: '4',
      name: 'USB-C Hub 8-in-1',
      price: 45.00,
      cost: 25.0,
      commissionRate: 15.0,
      shippingCost: 4.0,
      advertisingCost: 12.0,
      returnRate: 8.0,
      salesCount: 540,
    ),
    Product(
      id: '5',
      name: 'Mechanical Keyboard',
      price: 120.00,
      cost: 50.0,
      commissionRate: 15.0,
      shippingCost: 8.0,
      advertisingCost: 10.0,
      returnRate: 2.0,
      salesCount: 320,
    ),
  ];

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
          ? MainDashboard(
              isDarkMode: _isDarkMode,
              onThemeChanged: _toggleTheme,
              products: _products,
              onAddProduct: _addProduct,
              onLogout: () {
                setState(() {
                  _isAuthenticated = false;
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
            )
          : LoginScreen(
              onLoginSuccess: (name, email) {
                setState(() {
                  _isAuthenticated = true;
                  _userName = name;
                  _userEmail = email;
                  _isGuest = false;
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
      MaterialPageRoute(builder: (context) => Placeholder()),
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(
        onSimulateTap: _navigateToSimulation,
        products: widget.products,
        onAddProductTap: _navigateToAddProduct,
        onSeeAllTap: () => _onTabTapped(1),
        onAiInsightsTap: () => _onTabTapped(3),
      ),
      ProductsScreen(
        products: widget.products,
        onAddProductTap: _navigateToAddProduct,
      ),
      const AnalyticsScreen(),
      const AIAssistantScreen(),
      ProfileScreen(
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
        onLogout: widget.onLogout,
        userName: widget.userName,
        userEmail: widget.userEmail,
        isGuest: widget.isGuest,
        onProfileUpdated: widget.onProfileUpdated,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: screens[_currentIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// REUSABLE WIDGETS
// -----------------------------------------------------------------------------

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
  final List<Product> products;
  final VoidCallback onAddProductTap;
  final VoidCallback onSeeAllTap;
  final VoidCallback onAiInsightsTap;

  const DashboardScreen({
    super.key,
    required this.onSimulateTap,
    required this.products,
    required this.onAddProductTap,
    required this.onSeeAllTap,
    required this.onAiInsightsTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    double totalRevenue = products.fold(0, (sum, p) => sum + p.totalRevenue);
    double totalProfit = products.fold(0, (sum, p) => sum + p.totalNetProfit);
    double overallMargin = totalRevenue > 0
        ? (totalProfit / totalRevenue) * 100
        : 0;
    double totalAdSpend = products.fold(0, (sum, p) => sum + p.totalAdSpend);
    double totalRoas = totalAdSpend > 0 ? totalRevenue / totalAdSpend : 0;

    final topProducts = List<Product>.from(products)
      ..sort((a, b) => b.totalNetProfit.compareTo(a.totalNetProfit));
    final displayTopProducts = topProducts.take(3).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientHeader(
            title: 'Dashboard',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                  ),
                  onPressed: onAddProductTap,
                ),
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                  ),
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
                // Stat Cards Grid
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.2,
                  children: [
                    _buildStatCard(
                      context,
                      'Net Profit',
                      '\$${totalProfit.toStringAsFixed(0)}',
                      '+12%',
                      Colors.green,
                    ),
                    _buildStatCard(
                      context,
                      'Profit Margin',
                      '${overallMargin.toStringAsFixed(1)}%',
                      '+2.1%',
                      Colors.green,
                    ),
                    _buildStatCard(
                      context,
                      'Total ROAS',
                      '${totalRoas.toStringAsFixed(1)}x',
                      '-0.5%',
                      Colors.red,
                    ),
                    _buildStatCard(
                      context,
                      'Products',
                      '${products.length}',
                      '+1',
                      Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // AI Insights Banner
                InkWell(
                  onTap: onAiInsightsTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                Colors.purple.shade900.withOpacity(0.5),
                                Colors.blue.shade900.withOpacity(0.5),
                              ]
                            : [Colors.purple.shade50, Colors.blue.shade50],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.purple.shade800
                            : Colors.purple.shade100,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: Colors.purple.shade400,
                          ),
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'We found 3 ways to improve your margin.',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.purple.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Run Simulation Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: onSimulateTap,
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Run Scenario Simulation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Cost Breakdown
                Text(
                  'Average Cost Breakdown',
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
                        _buildProgressRow(
                          context,
                          'Product Cost',
                          0.40,
                          Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        _buildProgressRow(
                          context,
                          'Shipping',
                          0.15,
                          Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        _buildProgressRow(
                          context,
                          'Advertising',
                          0.25,
                          Colors.purple,
                        ),
                        const SizedBox(height: 12),
                        _buildProgressRow(
                          context,
                          'Platform Fees',
                          0.20,
                          Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Top Products
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: onSeeAllTap,
                      child: const Text('See All'),
                    ),
                  ],
                ),
                ...displayTopProducts.map(
                  (p) => _buildTopProductItem(
                    context,
                    p.name,
                    '\$${p.price.toStringAsFixed(2)}',
                    '${p.salesCount} sales',
                  ),
                ),
                const SizedBox(height: 30),
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
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: changeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                change,
                style: TextStyle(
                  color: changeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildTopProductItem(
    BuildContext context,
    String name,
    String price,
    String sales,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.inventory_2, color: Colors.blue.shade400),
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
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Text(
          price,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
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
      MaterialPageRoute(builder: (context) => Placeholder()),
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
      );
      widget.onSave(p);
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
  final Function(String, String) onProfileUpdated;

  const ProfileScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onLogout,
    required this.userName,
    required this.userEmail,
    required this.isGuest,
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Personal Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onProfileUpdated(nameCtrl.text, emailCtrl.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
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

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Notifications'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    value: _pushNotifs,
                    onChanged: (val) {
                      setDialogState(() => _pushNotifs = val);
                      setState(() => _pushNotifs = val);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Email Notifications'),
                    value: _emailNotifs,
                    onChanged: (val) {
                      setDialogState(() => _emailNotifs = val);
                      setState(() => _emailNotifs = val);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Profit Alerts'),
                    value: _profitAlerts,
                    onChanged: (val) {
                      setDialogState(() => _profitAlerts = val);
                      setState(() => _profitAlerts = val);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('AI Insight Alerts'),
                    value: _aiInsights,
                    onChanged: (val) {
                      setDialogState(() => _aiInsights = val);
                      setState(() => _aiInsights = val);
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

  void _showLanguageRegionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Language & Region'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Language',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedLang,
                    items: ['English', 'Turkish']
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => _selectedLang = val);
                        setState(() => _selectedLang = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Currency',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCurrency,
                    items: ['USD', 'EUR', 'TRY']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => _selectedCurrency = val);
                        setState(() => _selectedCurrency = val);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showHelpCenter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help Center'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Q: How do I add a product?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('A: Tap the + button on the Dashboard.'),
            SizedBox(height: 12),
            Text(
              'Q: What does ROAS mean?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('A: Return On Ad Spend.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsPrivacy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Privacy'),
        content: const Text(
          'By using Finance Analysis, you agree to our Terms of Service and Privacy Policy. '
          'We do not share your local data with any third parties.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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
  final Function(String, String) onLoginSuccess;
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
                                    if (email.isEmpty)
                                      email = 'user@finance.app';
                                    String name = email.split('@')[0];
                                    widget.onLoginSuccess(name, email);
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
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton(
                                  onPressed: widget.onGuestLogin,
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Continue as Guest'),
                                ),
                              ),
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
                                      widget.onLoginSuccess(name, email);
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
                              String name = _nameCtrl.text;
                              String email = _emailCtrl.text;
                              if (name.isEmpty) name = 'New User';
                              if (email.isEmpty) email = 'user@finance.app';
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
