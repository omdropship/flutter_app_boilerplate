import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';

@RoutePage()
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedGender = 'male';

  // Dropdown tanggal lahir
  int? _selectedDay = 1;
  int? _selectedMonth = 1;
  int? _selectedYear = DateTime.now().year - 13;

  String? _usernameMessage;
  bool _isUsernameAvailable = false;
  bool _isCheckingUsername = false;

  @override
  void dispose() {
    _fullnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkUsername() async {
    final username = _usernameController.text.trim();
    if (username.length < 3) {
      setState(() {
        _usernameMessage = 'Minimal 3 karakter';
        _isUsernameAvailable = false;
      });
      return;
    }
    setState(() {
      _isCheckingUsername = true;
      _usernameMessage = null;
    });
    try {
      final available = await _authService.checkUsername(username);
      setState(() {
        _isUsernameAvailable = available;
        _usernameMessage = available ? 'Username tersedia' : 'Username tidak tersedia';
      });
    } catch (e) {
      setState(() {
        _isUsernameAvailable = false;
        _usernameMessage = 'Gagal mengecek username';
      });
    } finally {
      setState(() => _isCheckingUsername = false);
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isUsernameAvailable) {
      _showError('Silakan gunakan username yang tersedia');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        fullname: _fullnameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        gender: _selectedGender,
        birthdate:
            '${_selectedDay.toString().padLeft(2, '0')}/${_selectedMonth.toString().padLeft(2, '0')}/$_selectedYear',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pendaftaran berhasil!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Auto‑login sudah dilakukan di AuthService.register, langsung ke Nearby
        context.router.replaceNamed('/nearby');
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    String clean = message;
    if (message.contains('Exception:')) {
      clean = message.split('Exception:').last.trim();
    } else if (message.contains('ServerException:')) {
      clean = message.split('ServerException:').last.trim();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(clean),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Bergabung dengan ChatTeman',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Nama Lengkap
                TextFormField(
                  controller: _fullnameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Harap isi nama lengkap' : null,
                ),
                const SizedBox(height: 16),

                // Username dengan cek ketersediaan
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.alternate_email),
                    suffixIcon: _isCheckingUsername
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : _usernameMessage != null
                            ? Icon(
                                _isUsernameAvailable ? Icons.check_circle : Icons.cancel,
                                color: _isUsernameAvailable ? Colors.green : Colors.red,
                              )
                            : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  onChanged: (_) => _checkUsername(),
                  validator: (v) => (v == null || v.trim().length < 3) ? 'Minimal 3 karakter' : null,
                ),
                if (_usernameMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 12),
                    child: Text(
                      _usernameMessage!,
                      style: TextStyle(
                        color: _isUsernameAvailable ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Email tidak valid' : null,
                ),
                const SizedBox(height: 16),

                // Jenis Kelamin
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Jenis Kelamin',
                    prefixIcon: const Icon(Icons.people_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
                    DropdownMenuItem(value: 'female', child: Text('Perempuan')),
                  ],
                  onChanged: _isLoading ? null : (v) => setState(() => _selectedGender = v!),
                ),
                const SizedBox(height: 16),

                // Tanggal Lahir
                Text(
                  'Tanggal Lahir',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedDay,
                        decoration: InputDecoration(
                          labelText: 'Tgl',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: List.generate(31, (i) => i + 1)
                            .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
                            .toList(),
                        onChanged: _isLoading ? null : (v) => setState(() => _selectedDay = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedMonth,
                        decoration: InputDecoration(
                          labelText: 'Bulan',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: [
                          'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                          'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
                        ].asMap().entries.map((e) =>
                            DropdownMenuItem(value: e.key + 1, child: Text(e.value))).toList(),
                        onChanged: _isLoading ? null : (v) => setState(() => _selectedMonth = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedYear,
                        decoration: InputDecoration(
                          labelText: 'Tahun',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: List.generate(80, (i) => DateTime.now().year - 13 - i)
                            .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                            .toList(),
                        onChanged: _isLoading ? null : (v) => setState(() => _selectedYear = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi (min. 6 karakter)',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  textInputAction: TextInputAction.done,
                  enabled: !_isLoading,
                  onFieldSubmitted: (_) => _handleRegister(),
                  validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
                ),
                const SizedBox(height: 24),

                // Tombol Daftar
                FilledButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Daftar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
                const SizedBox(height: 20),

                // Link ke Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () => context.router.pushNamed('/login'),
                      child: Text(
                        'Masuk',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
