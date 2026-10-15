# Qalculyn — Mathematical Specification & Numerical Algorithms

This document provides mathematical formulations, analytical algorithms, numerical stability bounds, and asymptotic complexities implemented within the **Qalculyn** engine.

---

## 1. Number Theory & Exact Arithmetic

### 1.1 Arbitrary-Precision Rational Arithmetic ($\mathbb{Q}$)
Rational numbers are represented as an irreducible ordered pair:
$$q = \frac{n}{d}, \quad n \in \mathbb{Z}, \quad d \in \mathbb{Z}^+, \quad \gcd(|n|, d) = 1$$

- **Addition & Subtraction:**
  $$\frac{n_1}{d_1} \pm \frac{n_2}{d_2} = \frac{n_1 d_2 \pm n_2 d_1}{\gcd(d_1, d_2)} \cdot \frac{1}{\text{lcm}(d_1, d_2)}$$
- **Multiplication & Division:**
  $$\frac{n_1}{d_1} \times \frac{n_2}{d_2} = \frac{n_1 n_2}{d_1 d_2}, \qquad \frac{n_1}{d_1} \div \frac{n_2}{d_2} = \frac{n_1 d_2}{d_1 n_2} \quad (n_2 \neq 0)$$

### 1.2 Euclidean Algorithm & Fundamental Identity
- **Greatest Common Divisor ($\gcd$):**
  $$\gcd(a, 0) = |a|, \qquad \gcd(a, b) = \gcd(b, a \bmod b)$$
  *Complexity:* $O(\log(\min(|a|, |b|)))$ steps.
- **Least Common Multiple ($\text{lcm}$):**
  $$\text{lcm}(a, b) = \frac{|a \cdot b|}{\gcd(a, b)}$$
- **Fraction $\gcd$ and $\text{lcm}$:**
  $$\gcd\left(\frac{a}{b}, \frac{c}{d}\right) = \frac{\gcd(a, c)}{\text{lcm}(b, d)}, \qquad \text{lcm}\left(\frac{a}{b}, \frac{c}{d}\right) = \frac{\text{lcm}(a, c)}{\gcd(b, d)}$$

### 1.3 Primality & Factorization
- **Deterministic Primality Test:** Trial division optimized with $6k \pm 1$ wheel factorization up to $\lfloor\sqrt{n}\rfloor$.
  $$n \text{ is prime } \iff \forall d \in \{2, 3\} \cup \{6k \pm 1 \mid 5 \le 6k - 1 \le \sqrt{n}\}, \quad n \not\equiv 0 \pmod d$$

---

## 2. Analytical Algebra & Polynomial Solvers

### 2.1 Univariate Polynomials ($\mathbb{Q}[x]$)
A polynomial $P(x) \in \mathbb{Q}[x]$ of degree $n$ is represented by exact coefficients:
$$P(x) = \sum_{i=0}^n c_i x^i, \quad c_n \neq 0$$
- **Euclidean Polynomial Division:**
  $$A(x) = Q(x) B(x) + R(x), \quad \deg(R) < \deg(B)$$
- **Monic Normalization:**
  $$\gcd(A(x), B(x)) = \frac{1}{\text{lead}(G(x))} G(x)$$

### 2.2 Quadratic Equation Analytical Solution
For $ax^2 + bx + c = 0$ ($a \neq 0$):
$$\Delta = b^2 - 4ac$$
- **Case 1 ($\Delta > 0$):** Two distinct real roots:
  $$x_{1,2} = \frac{-b \pm \sqrt{\Delta}}{2a}$$
- **Case 2 ($\Delta = 0$):** One real root with multiplicity 2:
  $$x = -\frac{b}{2a}$$
- **Case 3 ($\Delta < 0$):** Conjugate complex roots in $\mathbb{C}$:
  $$x_{1,2} = -\frac{b}{2a} \pm i \frac{\sqrt{-\Delta}}{2a}$$

---

## 3. Complex Number Engine ($\mathbb{C}$)

### 3.1 Representations
- **Rectangular Form:** $z = a + bi$ ($a, b \in \mathbb{R}$)
- **Polar / Euler Form:**
  $$z = r e^{i\theta} = r (\cos\theta + i\sin\theta)$$
  $$r = |z| = \sqrt{a^2 + b^2}, \qquad \theta = \text{Arg}(z) = \text{atan2}(b, a) \in (-\pi, \pi]$$

### 3.2 Operations
- **Multiplication & Division:**
  $$z_1 z_2 = (a_1 a_2 - b_1 b_2) + (a_1 b_2 + a_2 b_1)i$$
  $$\frac{z_1}{z_2} = \frac{(a_1 a_2 + b_1 b_2) + (b_1 a_2 - a_1 b_2)i}{a_2^2 + b_2^2} \quad (z_2 \neq 0)$$
- **De Moivre's Theorem for Powers & Roots:**
  $$z^n = r^n \left(\cos(n\theta) + i\sin(n\theta)\right)$$
  $$\sqrt{z} = \sqrt{r} \left(\cos\frac{\theta}{2} + i\sin\frac{\theta}{2}\right)$$

---

## 4. Linear Algebra & 3D Vectors

### 4.1 Matrices
- **Matrix Product:** For $A \in \mathbb{R}^{m \times p}$ and $B \in \mathbb{R}^{p \times n}$:
  $$C_{ij} = \sum_{k=1}^p A_{ik} B_{kj}$$
- **Determinants ($\det A$):**
  - $2 \times 2$: $\det A = ad - bc$
  - $3 \times 3$: Sarrus rule / Laplace cofactor expansion.
  - $n \times n$: $LU$ Decomposition with row swaps ($PA = LU$):
    $$\det A = (-1)^S \prod_{i=1}^n U_{ii}$$

### 4.2 3D Vector Geometry
For $\vec{u} = (u_x, u_y, u_z)$ and $\vec{v} = (v_x, v_y, v_z)$:
- **Dot Product:** $\vec{u} \cdot \vec{v} = u_x v_x + u_y v_y + u_z v_z$
- **Cross Product:**
  $$\vec{u} \times \vec{v} = (u_y v_z - u_z v_y)\hat{i} + (u_z v_x - u_x v_z)\hat{j} + (u_x v_y - u_y v_x)\hat{k}$$
- **Magnitude & Angle:**
  $$\|\vec{u}\| = \sqrt{u_x^2 + u_y^2 + u_z^2}, \qquad \theta = \arccos\left(\frac{\vec{u} \cdot \vec{v}}{\|\vec{u}\| \|\vec{v}\|}\right)$$

---

## 5. Numerical Analysis & Calculus

### 5.1 Numerical Differentiation (5-Point Central Stencil)
Evaluates $f'(x_0)$ with fourth-order truncation error $O(h^4)$:
$$f'(x_0) = \frac{-f(x_0 + 2h) + 8f(x_0 + h) - 8f(x_0 - h) + f(x_0 - 2h)}{12h} + \mathcal{E}_{\text{trunc}}$$
$$\text{Truncation error bound: } |\mathcal{E}_{\text{trunc}}| \le \frac{h^4}{30} \max_{\xi \in [x_0 - 2h, x_0 + 2h]} |f^{(5)}(\xi)|$$
*Operating parameter:* $h = 10^{-5}$.

### 5.2 Numerical Quadrature (Composite Simpson's 1/3 Rule)
For a uniform partition $x_i = a + i h$ with step $h = \frac{b - a}{N}$ ($N = 1000$ even):
$$\int_a^b f(x)\,dx = \frac{h}{3} \left[ f(a) + 4\sum_{j=1}^{N/2} f(x_{2j-1}) + 2\sum_{j=1}^{N/2 - 1} f(x_{2j}) + f(b) \right] + \mathcal{E}_{\text{int}}$$
$$\text{Error bound: } |\mathcal{E}_{\text{int}}| \le \frac{(b - a) h^4}{180} \max_{\xi \in [a, b]} |f^{(4)}(\xi)|$$

### 5.3 Bisection Root Finding
For an interval $[a, b]$ where $f(a) \cdot f(b) \le 0$:
$$c_k = \frac{a_k + b_k}{2}$$
$$|c_k - x^*| \le \frac{b - a}{2^{k+1}} < \epsilon = 10^{-6}$$
Guarantees global linear convergence without derivative requirements.

---

## 6. Analytic Geometry & Triangle Trigonometry

### 6.1 Analytic Triangle Solvers
- **Law of Cosines:**
  $$c = \sqrt{a^2 + b^2 - 2ab\cos C}$$
  $$C = \arccos\left(\frac{a^2 + b^2 - c^2}{2ab}\right)$$
- **Law of Sines:**
  $$\frac{a}{\sin A} = \frac{b}{\sin B} = \frac{c}{\sin C} = 2R$$
- **Heron's Formula:**
  $$s = \frac{a + b + c}{2}, \qquad \text{Area} = \sqrt{s(s - a)(s - b)(s - c)}$$
- **Radii:**
  $$\text{Inradius } r = \frac{\text{Area}}{s}, \qquad \text{Circumradius } R = \frac{abc}{4 \cdot \text{Area}}$$

---

## 7. Statistics & Probability

### 7.1 Descriptive Statistics
Given a dataset $X = \{x_1, x_2, \dots, x_N\}$:
- **Sample Variance ($s^2$):**
  $$s^2 = \frac{1}{N - 1} \sum_{i=1}^N (x_i - \bar{x})^2$$
- **Population Variance ($\sigma^2$):**
  $$\sigma^2 = \frac{1}{N} \sum_{i=1}^N (x_i - \mu)^2$$

### 7.2 Gaussian Normal Distribution
- **Probability Density Function (PDF):**
  $$f(x \mid \mu, \sigma) = \frac{1}{\sigma \sqrt{2\pi}} \exp\left(-\frac{(x - \mu)^2}{2\sigma^2}\right)$$
- **Cumulative Distribution Function (CDF):**
  $$\Phi(z) = \frac{1}{2} \left[1 + \text{erf}\left(\frac{z}{\sqrt{2}}\right)\right], \quad z = \frac{x - \mu}{\sigma}$$
  where $\text{erf}(x)$ is computed via the Winitzki numerical rational approximation with maximal relative error $< 1.2 \times 10^{-7}$.

---

## 8. Financial Formulations

### 8.1 Equated Monthly Installment (EMI)
$$\text{EMI} = P \cdot r \cdot \frac{(1 + r)^n}{(1 + r)^n - 1}$$
where:
- $P$ = Principal loan amount
- $r$ = Monthly interest rate ($\frac{\text{Annual Rate}}{12 \times 100}$)
- $n$ = Loan duration in total months

### 8.2 Systematic Investment Plan (SIP)
$$\text{FV} = M \cdot \left[ \frac{(1 + r)^n - 1}{r} \right] \cdot (1 + r)$$
where:
- $M$ = Monthly investment installment
- $r$ = Periodic monthly interest rate
- $n$ = Total number of monthly installments
- $\text{FV}$ = Future value of investment corpus

### 8.3 Reverse GST Formulation
$$\text{Base Price} = \frac{\text{MRP}}{1 + \frac{\text{Rate}}{100}}, \qquad \text{GST Amount} = \text{MRP} - \text{Base Price}$$
$$\text{CGST} = \text{SGST} = \frac{\text{GST Amount}}{2}$$
