// Qalculyn - Modular Arithmetic & Number Theory Suite
// Extended Euclidean Algorithm, Bézout identity, modular exponentiation, modular inverse, and Euler's totient

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/number_theory.dart';
import '../../shared/tool_widgets.dart';

class ModularMathScreen extends StatefulWidget {
  const ModularMathScreen({super.key});

  @override
  State<ModularMathScreen> createState() => _ModularMathScreenState();
}

class _ModularMathScreenState extends State<ModularMathScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Extended GCD controllers
  final _extA = TextEditingController(text: '240');
  final _extB = TextEditingController(text: '46');

  // Mod Pow controllers
  final _powBase = TextEditingController(text: '7');
  final _powExp = TextEditingController(text: '128');
  final _powMod = TextEditingController(text: '13');

  // Mod Inverse controllers
  final _invA = TextEditingController(text: '17');
  final _invM = TextEditingController(text: '43');

  // Totient controller
  final _totientN = TextEditingController(text: '360');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _extA.dispose();
    _extB.dispose();
    _powBase.dispose();
    _powExp.dispose();
    _powMod.dispose();
    _invA.dispose();
    _invM.dispose();
    _totientN.dispose();
    super.dispose();
  }

  void _showStepModal(String title, List<String> steps) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          decoration: BoxDecoration(
            color: isDark ? QColors.darkSurface : QColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(QSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: steps.length,
                  itemBuilder: (ctx, i) {
                    final s = steps[i];
                    final isHeader = s.endsWith(':') || s.startsWith('Step');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: isHeader ? 14 : 13,
                          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                          color: isHeader
                              ? QColors.primaryPurple
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontFamily: 'monospace',
                        ),
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

  Widget _buildCard({
    required String title,
    required String subtitle,
    required Widget resultWidget,
    required VoidCallback onShowSteps,
    required VoidCallback onCopy,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(QSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? QColors.darkCard : QColors.lightElevated,
        borderRadius: QRadius.borderRadiusLg,
        border: Border.all(color: QColors.primaryPurple.withValues(alpha: 0.2)),
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
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: QColors.primaryPurple),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    tooltip: 'Copy Result',
                    onPressed: onCopy,
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu_book_outlined, size: 20, color: QColors.primaryPurple),
                    tooltip: 'View Steps',
                    onPressed: onShowSteps,
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: QSpacing.sm),
          resultWidget,
        ],
      ),
    );
  }

  // TAB 1: Extended GCD
  Widget _buildExtendedGcdTab() {
    final a = BigInt.tryParse(_extA.text.trim()) ?? BigInt.zero;
    final b = BigInt.tryParse(_extB.text.trim()) ?? BigInt.zero;
    final res = NumberTheory.extendedGcd(a, b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(QSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ToolTextField(
                  controller: _extA,
                  label: 'Integer a',
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: QSpacing.md),
              Expanded(
                child: ToolTextField(
                  controller: _extB,
                  label: 'Integer b',
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: QSpacing.lg),
          _buildCard(
            title: 'Bézout\'s Identity',
            subtitle: 'a × x + b × y = GCD(a, b)',
            resultWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GCD($a, $b) = ${res.gcd}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: QSpacing.xs),
                Text(
                  'Bézout Coefficients: x = ${res.x},  y = ${res.y}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: QSpacing.xs),
                Text(
                  res.identity,
                  style: const TextStyle(fontSize: 14, color: QColors.primaryPurple, fontFamily: 'monospace'),
                ),
              ],
            ),
            onShowSteps: () => _showStepModal('Extended Euclidean Steps', res.steps),
            onCopy: () {
              Clipboard.setData(ClipboardData(text: '${res.identity}\nx = ${res.x}, y = ${res.y}'));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bézout identity copied')));
            },
          ),
        ],
      ),
    );
  }

  // TAB 2: Modular Exponentiation
  Widget _buildModPowTab() {
    final base = BigInt.tryParse(_powBase.text.trim()) ?? BigInt.zero;
    final exp = BigInt.tryParse(_powExp.text.trim()) ?? BigInt.zero;
    final mod = BigInt.tryParse(_powMod.text.trim()) ?? BigInt.one;
    final res = NumberTheory.modPowDetailed(base, exp, mod);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(QSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ToolTextField(
                  controller: _powBase,
                  label: 'Base (a)',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: QSpacing.sm),
              Expanded(
                child: ToolTextField(
                  controller: _powExp,
                  label: 'Exponent (b)',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: QSpacing.sm),
              Expanded(
                child: ToolTextField(
                  controller: _powMod,
                  label: 'Modulus (m)',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: QSpacing.lg),
          _buildCard(
            title: 'Modular Exponentiation Result',
            subtitle: '(a ^ b) mod m',
            resultWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${res.result}',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: QColors.primaryPurple),
                ),
                const SizedBox(height: QSpacing.xs),
                Text(
                  '($base ^ $exp) ≡ ${res.result} (mod $mod)',
                  style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                ),
              ],
            ),
            onShowSteps: () => _showStepModal('Repeated Squaring Derivation', res.steps),
            onCopy: () {
              Clipboard.setData(ClipboardData(text: '($base ^ $exp) mod $mod = ${res.result}'));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Result copied')));
            },
          ),
        ],
      ),
    );
  }

  // TAB 3: Modular Inverse
  Widget _buildModInverseTab() {
    final a = BigInt.tryParse(_invA.text.trim()) ?? BigInt.zero;
    final m = BigInt.tryParse(_invM.text.trim()) ?? BigInt.two;
    final res = NumberTheory.modInverseDetailed(a, m);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(QSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ToolTextField(
                  controller: _invA,
                  label: 'Integer (a)',
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: QSpacing.md),
              Expanded(
                child: ToolTextField(
                  controller: _invM,
                  label: 'Modulus (m)',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: QSpacing.lg),
          _buildCard(
            title: 'Modular Multiplicative Inverse',
            subtitle: 'Find x where (a × x) ≡ 1 (mod m)',
            resultWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (res.exists) ...[
                  Text(
                    'x = ${res.inverse}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: QColors.primaryPurple),
                  ),
                  const SizedBox(height: QSpacing.xs),
                  Text(
                    '($a × ${res.inverse}) ≡ 1 (mod $m)',
                    style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                  ),
                ] else ...[
                  const Text(
                    'No Inverse Exists',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  const SizedBox(height: QSpacing.xs),
                  Text(
                    'GCD($a, $m) ≠ 1. Numbers must be coprime to have a modular inverse.',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ],
            ),
            onShowSteps: () => _showStepModal('Modular Inverse Derivation', res.steps),
            onCopy: () {
              Clipboard.setData(ClipboardData(text: res.exists ? '$a⁻¹ mod $m = ${res.inverse}' : 'No inverse'));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Result copied')));
            },
          ),
        ],
      ),
    );
  }

  // TAB 4: Euler's Totient
  Widget _buildTotientTab() {
    final n = BigInt.tryParse(_totientN.text.trim()) ?? BigInt.one;
    final res = NumberTheory.eulerTotientDetailed(n);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(QSpacing.lg),
      child: Column(
        children: [
          ToolTextField(
            controller: _totientN,
            label: 'Positive Integer n',
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: QSpacing.lg),
          _buildCard(
            title: 'Euler\'s Totient Value',
            subtitle: 'Number of coprime integers up to n',
            resultWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'φ($n) = ${res.phi}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: QColors.primaryPurple),
                ),
                const SizedBox(height: QSpacing.xs),
                Text(
                  'Prime Factorization: ${NumberTheory.formatPrimeFactors(res.factors)}',
                  style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                ),
              ],
            ),
            onShowSteps: () => _showStepModal('Euler Totient Derivation', res.steps),
            onCopy: () {
              Clipboard.setData(ClipboardData(text: 'φ($n) = ${res.phi}'));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Totient value copied')));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modular Arithmetic'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: QColors.primaryPurple,
          indicatorColor: QColors.primaryPurple,
          tabs: const [
            Tab(text: 'Bézout / Ext GCD'),
            Tab(text: 'Modular Power'),
            Tab(text: 'Modular Inverse'),
            Tab(text: 'Euler\'s Totient φ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExtendedGcdTab(),
          _buildModPowTab(),
          _buildModInverseTab(),
          _buildTotientTab(),
        ],
      ),
    );
  }
}
