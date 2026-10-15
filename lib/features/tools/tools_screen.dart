// Qalculyn - Comprehensive Tools Hub Screen
// Central navigation with Smart Math Console, Favorites, Recents, and Category Filter

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/smart_math_command.dart';

// Everyday
import '../percentage/percentage_screen.dart';
import '../discount/discount_screen.dart';
import '../gst/gst_screen.dart';
import '../tip/tip_screen.dart';
import '../converters/converter_screen.dart';
import '../date_time/date_time_screen.dart';

// Number Theory & Algebra
import '../number_theory/lcm_screen.dart';
import '../number_theory/gcd_screen.dart';
import '../number_theory/monomial_screen.dart';
import '../algebra/polynomial_screen.dart';
import '../number_theory/prime_screen.dart';
import '../number_theory/fraction_screen.dart';
import '../number_theory/number_properties_screen.dart';
import '../algebra/algebra_screen.dart';
import '../number_theory/sequences_base_screen.dart';

// Advanced Mathematics
import '../calculus/calculus_screen.dart';
import '../linear_algebra/matrix_screen.dart';
import '../complex/complex_screen.dart';
import '../geometry/geometry_screen.dart';
import '../statistics/statistics_screen.dart';
import '../questions/universal_question_screen.dart';
import '../graphing/graphing_screen.dart';

// Finance
import '../emi/emi_screen.dart';
import '../interest/interest_screen.dart';
import '../savings/savings_screen.dart';
import '../sip/sip_screen.dart';
import '../currency/currency_screen.dart';
import '../settings/theme_customizer_screen.dart';
import 'constants_screen.dart';
import '../algebra/linear_system_screen.dart';
import '../algebra/polynomial_division_screen.dart';
import '../number_theory/modular_math_screen.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  final _searchController = TextEditingController();
  final _smartCommandController = TextEditingController(text: 'lcm(12, 18, 24)');
  String _searchQuery = '';
  SmartCommandResult? _commandResult;
  bool _showSmartConsole = true;

  Set<String> _favoriteToolNames = {};
  List<String> _recentToolNames = [];

  static final _tools = [
    // Everyday Tools
    _ToolItem('Percentage', 'Calculate percentages easily', Icons.percent, 'Everyday', const PercentageScreen(), ['percent', 'discount', '%']),
    _ToolItem('Discount', 'Calculate discounts & savings', Icons.local_offer_outlined, 'Everyday', const DiscountScreen(), ['sale', 'savings']),
    _ToolItem('GST', 'Indian GST calculations', Icons.receipt_long_outlined, 'Everyday', const GstScreen(), ['tax', 'cgst', 'sgst', 'igst']),
    _ToolItem('Tip & Split', 'Split bills fairly', Icons.restaurant_outlined, 'Everyday', const TipScreen(), ['bill', 'split', 'restaurant']),
    _ToolItem('Unit Converter', 'Convert between units', Icons.swap_horiz, 'Everyday', const ConverterScreen(), ['length', 'mass', 'convert', 'units']),
    _ToolItem('Date & Time', 'Date calculations', Icons.calendar_today_outlined, 'Everyday', const DateTimeScreen(), ['calendar', 'days', 'duration']),

    // Number Theory & Algebra
    _ToolItem('LCM', 'Least Common Multiple with prime factors', Icons.all_inclusive, 'Number Theory & Algebra', const LcmScreen(), ['lcm', 'multiple', 'least common']),
    _ToolItem('GCD / HCF', 'Greatest Common Divisor & Euclidean steps', Icons.hub_outlined, 'Number Theory & Algebra', const GcdScreen(), ['gcd', 'hcf', 'divisor', 'factor']),
    _ToolItem('Monomial LCM/GCD', 'Algebraic monomials with variable powers', Icons.pie_chart_outline, 'Number Theory & Algebra', const MonomialScreen(), ['monomial', 'algebra', 'variables']),
    _ToolItem('Polynomials', 'Polynomial Euclidean GCD, LCM & division', Icons.line_axis, 'Number Theory & Algebra', const PolynomialScreen(), ['polynomial', 'euclid', 'poly']),
    _ToolItem('Primes & Divisors', 'Prime test, factorization & divisors', Icons.auto_awesome_outlined, 'Number Theory & Algebra', const PrimeScreen(), ['prime', 'factorize', 'divisors']),
    _ToolItem('Fractions & Ratios', 'Fraction simplify, arithmetic & LCM/GCD', Icons.calculate_outlined, 'Number Theory & Algebra', const FractionScreen(), ['fraction', 'ratio', 'simplify']),
    _ToolItem('Number Properties', 'Parity, square/cube & modular arithmetic', Icons.numbers_outlined, 'Number Theory & Algebra', const NumberPropertiesScreen(), ['parity', 'even', 'odd', 'cube', 'modulo']),
    _ToolItem('Algebra & Equations', 'Linear & quadratic solvers, factoring', Icons.functions, 'Number Theory & Algebra', const AlgebraScreen(), ['equation', 'quadratic', 'linear', 'solve', 'factor']),
    _ToolItem('Simultaneous Equations', 'Solve 2x2 & 3x3 linear systems with step derivations', Icons.compare_arrows, 'Number Theory & Algebra', const LinearSystemScreen(), ['linear system', 'simultaneous', 'cramer', 'elimination', '2x2', '3x3', 'matrix']),
    _ToolItem('Polynomial Division', 'Polynomial long division & synthetic division', Icons.alt_route, 'Number Theory & Algebra', const PolynomialDivisionScreen(), ['polynomial division', 'quotient', 'remainder', 'synthetic', 'algebra']),
    _ToolItem('Modular Arithmetic', 'Extended Euclidean Bézout identity, mod power & inverse, Euler totient', Icons.vpn_key_outlined, 'Number Theory & Algebra', const ModularMathScreen(), ['modular', 'euclid', 'bezout', 'inverse', 'totient', 'mod', 'coprime']),
    _ToolItem('Sequences & Bases', 'Base conversion & arithmetic/Fibonacci', Icons.format_list_numbered, 'Number Theory & Algebra', const SequencesBaseScreen(), ['base', 'binary', 'hex', 'fibonacci', 'sequence']),

    // Advanced Mathematics
    _ToolItem('Scientific Constants', '40+ fundamental physics & chemistry constants with 1-tap insert', Icons.menu_book, 'Advanced Mathematics', const ConstantsScreen(), ['constant', 'speed of light', 'planck', 'gravity', 'physics', 'chemistry', 'codata']),
    _ToolItem('Calculus & Limits', 'Numerical derivatives, integrals & limits', Icons.insights, 'Advanced Mathematics', const CalculusScreen(), ['derivative', 'integral', 'limit', 'calculus']),
    _ToolItem('Matrices & Vectors', 'Determinant, inverse, dot & cross products', Icons.grid_4x4, 'Advanced Mathematics', const MatrixScreen(), ['matrix', 'determinant', 'vector', 'cross product']),
    _ToolItem('Complex Numbers', 'Rectangular, polar & Euler operations', Icons.change_circle_outlined, 'Advanced Mathematics', const ComplexScreen(), ['complex', 'imaginary', 'polar', 'i']),
    _ToolItem('Geometry & Shapes', 'All 2D & 3D shapes, Triangle Solver & questions', Icons.architecture, 'Advanced Mathematics', const GeometryScreen(), ['area', 'volume', 'triangle', 'sine', 'cosine', 'shapes', 'pythagorean', 'polygon', 'solids']),
    _ToolItem('Graphing Studio', '2D function plotter, tangent slope, roots & area', Icons.show_chart, 'Advanced Mathematics', const GraphingScreen(), ['graph', 'plot', 'function', 'cartesian', 'roots', 'extrema']),
    _ToolItem('Question & Problem Solver', 'Solve inverse word problems & questions across all categories', Icons.quiz_outlined, 'Advanced Mathematics', const UniversalQuestionScreen(), ['question', 'word problem', 'solver', 'inverse', 'formula', 'physics', 'all']),
    _ToolItem('Statistics & Probability', 'Mean, median, std dev, nPr, nCr & normal', Icons.bar_chart, 'Advanced Mathematics', const StatisticsScreen(), ['mean', 'median', 'std dev', 'probability', 'ncr', 'npr']),

    // Finance Tools
    _ToolItem('EMI', 'Loan EMI calculator', Icons.account_balance_outlined, 'Finance', const EmiScreen(), ['loan', 'emi', 'mortgage']),
    _ToolItem('Interest', 'Simple & compound interest', Icons.trending_up, 'Finance', const InterestScreen(), ['compound', 'interest', 'growth']),
    _ToolItem('Savings', 'Investment growth estimator', Icons.savings_outlined, 'Finance', const SavingsScreen(), ['deposit', 'savings', 'annuity']),
    _ToolItem('SIP', 'SIP returns estimator', Icons.show_chart, 'Finance', const SipScreen(), ['mutual fund', 'sip', 'cagr']),
    _ToolItem('Currency', 'Manual rate conversion', Icons.currency_exchange, 'Finance', const CurrencyScreen(), ['forex', 'exchange', 'usd', 'inr']),
    _ToolItem('Theme & Color Customizer', 'Palettes, AMOLED pure black, and button radius', Icons.color_lens_outlined, 'Everyday', const ThemeCustomizerScreen(), ['theme', 'color', 'amoled', 'palette', 'customizer']),
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _runSmartCommand();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteToolNames = (prefs.getStringList('favorite_tools') ?? []).toSet();
      _recentToolNames = prefs.getStringList('recent_tools') ?? [];
    });
  }

  Future<void> _toggleFavorite(String name) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteToolNames.contains(name)) {
        _favoriteToolNames.remove(name);
      } else {
        _favoriteToolNames.add(name);
      }
    });
    await prefs.setStringList('favorite_tools', _favoriteToolNames.toList());
  }

  Future<void> _recordToolVisit(String name) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentToolNames.remove(name);
      _recentToolNames.insert(0, name);
      if (_recentToolNames.length > 5) {
        _recentToolNames = _recentToolNames.sublist(0, 5);
      }
    });
    await prefs.setStringList('recent_tools', _recentToolNames);
  }

  void _runSmartCommand() {
    final input = _smartCommandController.text.trim();
    if (input.isNotEmpty) {
      setState(() {
        _commandResult = SmartMathCommand.execute(input);
      });
    }
  }

  List<_ToolItem> get _filteredTools {
    if (_searchQuery.isEmpty) return _tools;
    return _tools.where((t) =>
        t.name.toLowerCase().contains(_searchQuery) ||
        t.description.toLowerCase().contains(_searchQuery) ||
        t.category.toLowerCase().contains(_searchQuery) ||
        t.aliases.any((a) => a.toLowerCase().contains(_searchQuery))).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _smartCommandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredTools;

    final everyday = filtered.where((t) => t.category == 'Everyday').toList();
    final algebra = filtered.where((t) => t.category == 'Number Theory & Algebra').toList();
    final advanced = filtered.where((t) => t.category == 'Advanced Mathematics').toList();
    final finance = filtered.where((t) => t.category == 'Finance').toList();

    final favorites = _tools.where((t) => _favoriteToolNames.contains(t.name)).toList();
    final recents = _recentToolNames
        .map((name) => _tools.firstWhere((t) => t.name == name, orElse: () => _tools.first))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mathematics & Tools Hub'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_showSmartConsole ? Icons.terminal : Icons.terminal_outlined),
            tooltip: 'Toggle Smart Math Console',
            onPressed: () => setState(() => _showSmartConsole = !_showSmartConsole),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: QSpacing.lg, vertical: QSpacing.sm),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tools, LCM, GCD, calculus, matrices, stats...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: isDark ? QColors.darkSurfaceVariant : QColors.lightSurfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: QRadius.borderRadiusLg,
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: QSpacing.md),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),

          // Smart Math Command Console
          if (_showSmartConsole) _buildSmartConsole(context, isDark),

          // Main Tools List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                        const SizedBox(height: QSpacing.md),
                        Text('No tools matching \'$_searchQuery\'', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: QSpacing.lg),
                    children: [
                      // Favorites section (if any & no search query)
                      if (_searchQuery.isEmpty && favorites.isNotEmpty) ...[
                        _sectionHeader(context, '★ Favorites'),
                        _buildGrid(context, favorites, isDark),
                      ],

                      // Recents section (if any & no search query)
                      if (_searchQuery.isEmpty && recents.isNotEmpty) ...[
                        _sectionHeader(context, 'Recent Tools'),
                        _buildGrid(context, recents, isDark),
                      ],

                      if (algebra.isNotEmpty) ...[
                        _sectionHeader(context, 'Number Theory & Algebra'),
                        _buildGrid(context, algebra, isDark),
                      ],
                      if (advanced.isNotEmpty) ...[
                        _sectionHeader(context, 'Advanced Mathematics (Calculus & Linear Algebra)'),
                        _buildGrid(context, advanced, isDark),
                      ],
                      if (everyday.isNotEmpty) ...[
                        _sectionHeader(context, 'Everyday Mathematics'),
                        _buildGrid(context, everyday, isDark),
                      ],
                      if (finance.isNotEmpty) ...[
                        _sectionHeader(context, 'Finance Calculators'),
                        _buildGrid(context, finance, isDark),
                      ],
                      const SizedBox(height: QSpacing.xxl),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartConsole(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: QSpacing.lg, vertical: QSpacing.xs),
      padding: const EdgeInsets.all(QSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? QColors.darkCard : QColors.lightElevated,
        borderRadius: QRadius.borderRadiusLg,
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: QSpacing.xs),
              Text(
                'Smart Math Assistant',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _showSyntaxGuide,
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                child: const Text('Examples & Help', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Command input with execute button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _smartCommandController,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. area of circle radius 5, lcm(12, 18), or 2x + 5 = 15',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: QSpacing.md, vertical: QSpacing.sm),
                    filled: true,
                    fillColor: isDark ? QColors.darkSurfaceVariant : QColors.lightSurfaceVariant,
                    border: OutlineInputBorder(borderRadius: QRadius.borderRadiusSm, borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => _runSmartCommand(),
                ),
              ),
              const SizedBox(width: QSpacing.xs),
              IconButton(
                icon: Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.primary),
                onPressed: _runSmartCommand,
                tooltip: 'Calculate',
              ),
            ],
          ),

          // Autocomplete quick chips
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _commandChip('lcm(12, 18)'),
                _commandChip('solve(2x + 5 = 15)'),
                _commandChip('factor(x^2 - 9)'),
                _commandChip('det([[1,2],[3,4]])'),
                _commandChip('prime(997)'),
                _commandChip('fib(10)'),
                _commandChip('diff(x^2, 3)'),
                _commandChip('convert(100, cm, m)'),
              ],
            ),
          ),

          // Result display
          if (_commandResult != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(QSpacing.sm),
              decoration: BoxDecoration(
                color: _commandResult!.isSuccess
                    ? QColors.primaryPurple.withValues(alpha: 0.08)
                    : QColors.error.withValues(alpha: 0.08),
                borderRadius: QRadius.borderRadiusSm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _commandResult!.isSuccess ? _commandResult!.result : 'Error: ${_commandResult!.error}',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _commandResult!.isSuccess ? Theme.of(context).colorScheme.onSurface : QColors.error,
                          ),
                        ),
                        if (_commandResult!.explanation != null)
                          Text(
                            _commandResult!.explanation!,
                            style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                  if (_commandResult!.isSuccess)
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      tooltip: 'Copy',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _commandResult!.result));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Result copied')),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _commandChip(String cmd) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(cmd, style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        onPressed: () {
          _smartCommandController.text = cmd;
          _runSmartCommand();
        },
      ),
    );
  }

  void _showSyntaxGuide() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Math Assistant Examples & Tips'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You can type plain English questions or direct formulas:\n\n'
                '• Everyday & Shopping:\n'
                '  - "mrp 1180 with 18% gst" (pre-tax price)\n'
                '  - "original price of 75 discount 25%"\n'
                '  - "double money at 8%" (how many years)\n'
                '  - "sip for 1000000 at 12% in 10 years"\n\n'
                '• Geometry & Shapes:\n'
                '  - "area of circle radius 5"\n'
                '  - "hypotenuse 6 and 8"\n'
                '  - "missing leg hypotenuse 13 leg 5"\n'
                '  - "volume of sphere radius 6"\n\n'
                '• Equations & Numbers:\n'
                '  - "solve 2x + 5 = 15"\n'
                '  - "lcm(12, 18, 24)" or "gcd(36, 48)"\n'
                '  - "factor(360)" or "prime(997)"\n'
                '  - "mean(12, 15, 18, 21)"\n\n'
                '• Physics & Science:\n'
                '  - "speed distance 150 time 2"\n'
                '  - "voltage current 3 resistance 4"',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it')),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: QSpacing.lg, bottom: QSpacing.sm),
      child: Text(
        title,
        style: QTypography.labelLarge(context).copyWith(
          color: QColors.primaryPurple,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<_ToolItem> items, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.35,
        crossAxisSpacing: QSpacing.md,
        mainAxisSpacing: QSpacing.md,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final tool = items[index];
        final isFav = _favoriteToolNames.contains(tool.name);
        return _ToolCard(
          tool: tool,
          isDark: isDark,
          isFavorite: isFav,
          onFavoriteToggle: () => _toggleFavorite(tool.name),
          onTap: () {
            _recordToolVisit(tool.name);
            Navigator.push(context, MaterialPageRoute(builder: (_) => tool.screen));
          },
        );
      },
    );
  }
}

class _ToolItem {
  final String name;
  final String description;
  final IconData icon;
  final String category;
  final Widget screen;
  final List<String> aliases;

  const _ToolItem(this.name, this.description, this.icon, this.category, this.screen, [this.aliases = const []]);
}

class _ToolCard extends StatelessWidget {
  final _ToolItem tool;
  final bool isDark;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const _ToolCard({
    required this.tool,
    required this.isDark,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? QColors.darkCard : QColors.lightCard,
      borderRadius: QRadius.borderRadiusLg,
      child: InkWell(
        borderRadius: QRadius.borderRadiusLg,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(QSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(QSpacing.xs),
                    decoration: BoxDecoration(
                      color: QColors.primaryPurple.withValues(alpha: 0.12),
                      borderRadius: QRadius.borderRadiusSm,
                    ),
                    child: Icon(tool.icon, size: 18, color: QColors.primaryPurple),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      size: 16,
                      color: isFavorite ? Colors.amber : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onFavoriteToggle,
                    tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                  ),
                ],
              ),
              const SizedBox(height: QSpacing.sm),
              Text(
                tool.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                tool.description,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
