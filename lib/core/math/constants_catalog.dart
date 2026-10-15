// Qalculyn - Scientific & Physical Constants Catalog
// 40+ Fundamental CODATA physical, astronomical, and chemical constants with SI units and definitions

class ScientificConstant {
  final String name;
  final String symbol;
  final double value;
  final String formattedValue;
  final String unit;
  final String category;
  final String description;

  const ScientificConstant({
    required this.name,
    required this.symbol,
    required this.value,
    required this.formattedValue,
    required this.unit,
    required this.category,
    required this.description,
  });
}

class ConstantsCatalog {
  static const List<ScientificConstant> all = [
    // ==========================================
    // 1. UNIVERSAL CONSTANTS
    // ==========================================
    ScientificConstant(
      name: 'Speed of Light in Vacuum',
      symbol: 'c',
      value: 299792458.0,
      formattedValue: '299,792,458',
      unit: 'm / s',
      category: 'Universal',
      description: 'Exact speed at which light and all electromagnetic waves propagate in vacuum.',
    ),
    ScientificConstant(
      name: 'Newtonian Constant of Gravitation',
      symbol: 'G',
      value: 6.67430e-11,
      formattedValue: '6.67430 × 10⁻¹¹',
      unit: 'm³ / (kg · s²)',
      category: 'Universal',
      description: 'Empirical physical constant involved in calculation of gravitational force.',
    ),
    ScientificConstant(
      name: 'Planck Constant',
      symbol: 'h',
      value: 6.62607015e-34,
      formattedValue: '6.62607015 × 10⁻³⁴',
      unit: 'J · s',
      category: 'Universal',
      description: 'Fundamental quantum physical constant relating photon energy to its frequency.',
    ),
    ScientificConstant(
      name: 'Reduced Planck Constant (Dirac)',
      symbol: 'ħ',
      value: 1.054571817e-34,
      formattedValue: '1.054571817 × 10⁻³⁴',
      unit: 'J · s',
      category: 'Universal',
      description: 'Planck constant divided by 2π (h / 2π), central to quantum mechanics.',
    ),

    // ==========================================
    // 2. ELECTROMAGNETISM
    // ==========================================
    ScientificConstant(
      name: 'Elementary Charge',
      symbol: 'e',
      value: 1.602176634e-19,
      formattedValue: '1.602176634 × 10⁻¹⁹',
      unit: 'C',
      category: 'Electromagnetism',
      description: 'Electric charge carried by a single proton or the negative charge on an electron.',
    ),
    ScientificConstant(
      name: 'Vacuum Permittivity',
      symbol: 'ε₀',
      value: 8.8541878128e-12,
      formattedValue: '8.8541878128 × 10⁻¹²',
      unit: 'F / m',
      category: 'Electromagnetism',
      description: 'Capability of vacuum to permit electric field lines; electric constant.',
    ),
    ScientificConstant(
      name: 'Vacuum Permeability',
      symbol: 'μ₀',
      value: 1.25663706212e-6,
      formattedValue: '1.25663706212 × 10⁻⁶',
      unit: 'N / A²',
      category: 'Electromagnetism',
      description: 'Magnetic constant measuring the resistance of vacuum against magnetic fields.',
    ),
    ScientificConstant(
      name: 'Coulomb Constant',
      symbol: 'kₑ',
      value: 8.9875517923e9,
      formattedValue: '8.9875517923 × 10⁹',
      unit: 'N · m² / C²',
      category: 'Electromagnetism',
      description: 'Proportionality factor in electrostatics: 1 / (4πε₀).',
    ),
    ScientificConstant(
      name: 'Characteristic Impedance of Vacuum',
      symbol: 'Z₀',
      value: 376.730313668,
      formattedValue: '376.730313668',
      unit: 'Ω',
      category: 'Electromagnetism',
      description: 'Wave impedance for plane electromagnetic waves in free space: √(μ₀/ε₀).',
    ),

    // ==========================================
    // 3. ATOMIC & NUCLEAR
    // ==========================================
    ScientificConstant(
      name: 'Electron Rest Mass',
      symbol: 'mₑ',
      value: 9.1093837015e-31,
      formattedValue: '9.1093837015 × 10⁻³¹',
      unit: 'kg',
      category: 'Atomic & Nuclear',
      description: 'Invariant mass of a stationary electron (approx. 0.510998 MeV/c²).',
    ),
    ScientificConstant(
      name: 'Proton Rest Mass',
      symbol: 'mₚ',
      value: 1.67262192369e-27,
      formattedValue: '1.67262192369 × 10⁻²⁷',
      unit: 'kg',
      category: 'Atomic & Nuclear',
      description: 'Invariant rest mass of a free proton (approx. 938.272 MeV/c²).',
    ),
    ScientificConstant(
      name: 'Neutron Rest Mass',
      symbol: 'mₙ',
      value: 1.67492749804e-27,
      formattedValue: '1.67492749804 × 10⁻²⁷',
      unit: 'kg',
      category: 'Atomic & Nuclear',
      description: 'Invariant rest mass of a free neutron (approx. 939.565 MeV/c²).',
    ),
    ScientificConstant(
      name: 'Unified Atomic Mass Unit (Dalton)',
      symbol: 'u',
      value: 1.66053906660e-27,
      formattedValue: '1.66053906660 × 10⁻²⁷',
      unit: 'kg',
      category: 'Atomic & Nuclear',
      description: 'Standard unit of atomic mass: exactly 1/12th the mass of an unbound carbon-12 atom.',
    ),
    ScientificConstant(
      name: 'Fine-Structure Constant',
      symbol: 'α',
      value: 7.2973525693e-3,
      formattedValue: '1 / 137.035999084',
      unit: 'dimensionless',
      category: 'Atomic & Nuclear',
      description: 'Fundamental coupling constant characterizing electromagnetic interaction strength.',
    ),
    ScientificConstant(
      name: 'Rydberg Constant',
      symbol: 'R∞',
      value: 10973731.568160,
      formattedValue: '10,973,731.568160',
      unit: 'm⁻¹',
      category: 'Atomic & Nuclear',
      description: 'Limiting highest wavenumber of any photon that can be emitted from hydrogen atom.',
    ),
    ScientificConstant(
      name: 'Bohr Radius',
      symbol: 'a₀',
      value: 5.29177210903e-11,
      formattedValue: '5.29177210903 × 10⁻¹¹',
      unit: 'm',
      category: 'Atomic & Nuclear',
      description: 'Most probable distance between the nucleus and the electron in a hydrogen ground state.',
    ),

    // ==========================================
    // 4. THERMODYNAMICS & PHYSICAL CHEMISTRY
    // ==========================================
    ScientificConstant(
      name: 'Avogadro Constant',
      symbol: 'N_A',
      value: 6.02214076e23,
      formattedValue: '6.02214076 × 10²³',
      unit: 'mol⁻¹',
      category: 'Thermodynamics',
      description: 'Number of constituent particles per mole of a given substance.',
    ),
    ScientificConstant(
      name: 'Boltzmann Constant',
      symbol: 'k_B',
      value: 1.380649e-23,
      formattedValue: '1.380649 × 10⁻²³',
      unit: 'J / K',
      category: 'Thermodynamics',
      description: 'Relates the average kinetic energy of gas particles to temperature.',
    ),
    ScientificConstant(
      name: 'Molar Gas Constant',
      symbol: 'R',
      value: 8.314462618,
      formattedValue: '8.314462618',
      unit: 'J / (mol · K)',
      category: 'Thermodynamics',
      description: 'Proportionality constant in ideal gas law PV = nRT: R = N_A · k_B.',
    ),
    ScientificConstant(
      name: 'Faraday Constant',
      symbol: 'F',
      value: 96485.33212,
      formattedValue: '96,485.33212',
      unit: 'C / mol',
      category: 'Thermodynamics',
      description: 'Magnitude of electric charge per mole of electrons: F = N_A · e.',
    ),
    ScientificConstant(
      name: 'Stefan-Boltzmann Constant',
      symbol: 'σ',
      value: 5.670374419e-8,
      formattedValue: '5.670374419 × 10⁻⁸',
      unit: 'W / (m² · K⁴)',
      category: 'Thermodynamics',
      description: 'Total radiation emitted by a black body per unit surface area per unit time.',
    ),
    ScientificConstant(
      name: 'Wien Displacement Law Constant',
      symbol: 'b',
      value: 2.897771955e-3,
      formattedValue: '2.897771955 × 10⁻³',
      unit: 'm · K',
      category: 'Thermodynamics',
      description: 'Relates the black body emission peak wavelength to its absolute temperature.',
    ),
    ScientificConstant(
      name: 'Standard Atmospheric Pressure',
      symbol: 'atm',
      value: 101325.0,
      formattedValue: '101,325',
      unit: 'Pa',
      category: 'Thermodynamics',
      description: 'Nominal atmospheric pressure at mean sea level.',
    ),

    // ==========================================
    // 5. ASTRONOMICAL & PLANETARY
    // ==========================================
    ScientificConstant(
      name: 'Standard Earth Gravity',
      symbol: 'g₀',
      value: 9.80665,
      formattedValue: '9.80665',
      unit: 'm / s²',
      category: 'Astronomy',
      description: 'Standard nominal acceleration due to Earth gravity at sea level.',
    ),
    ScientificConstant(
      name: 'Astronomical Unit',
      symbol: 'au',
      value: 149597870700.0,
      formattedValue: '149,597,870,700',
      unit: 'm',
      category: 'Astronomy',
      description: 'Mean distance from the Earth to the Sun (approx. 149.6 million km).',
    ),
    ScientificConstant(
      name: 'Light Year',
      symbol: 'ly',
      value: 9.4607304725808e15,
      formattedValue: '9.4607304725808 × 10¹⁵',
      unit: 'm',
      category: 'Astronomy',
      description: 'Distance that light travels in vacuum in one Julian year (approx. 9.46 trillion km).',
    ),
    ScientificConstant(
      name: 'Parsec',
      symbol: 'pc',
      value: 3.08567758149137e16,
      formattedValue: '3.08567758149137 × 10¹⁶',
      unit: 'm',
      category: 'Astronomy',
      description: 'Distance at which one astronomical unit subtends an angle of one arcsecond (~3.26 ly).',
    ),
    ScientificConstant(
      name: 'Solar Mass',
      symbol: 'M_☉',
      value: 1.98847e30,
      formattedValue: '1.98847 × 10³⁰',
      unit: 'kg',
      category: 'Astronomy',
      description: 'Standard unit of mass in astronomy, equal to the mass of the Sun.',
    ),
    ScientificConstant(
      name: 'Earth Mass',
      symbol: 'M_⊕',
      value: 5.9722e24,
      formattedValue: '5.9722 × 10²⁴',
      unit: 'kg',
      category: 'Astronomy',
      description: 'Mass of the planet Earth.',
    ),
    ScientificConstant(
      name: 'Mean Earth Radius',
      symbol: 'R_⊕',
      value: 6371000.0,
      formattedValue: '6,371,000',
      unit: 'm',
      category: 'Astronomy',
      description: 'Volumetric mean radius of the Earth.',
    ),
  ];

  static List<String> get categories => [
    'All',
    'Universal',
    'Electromagnetism',
    'Atomic & Nuclear',
    'Thermodynamics',
    'Astronomy',
  ];
}
