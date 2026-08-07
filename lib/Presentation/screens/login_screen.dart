import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/domain.dart';
import '../../config/theme/app_theme.dart';
import '../../infrastructure/datasource/mysql_connection.dart';
import '../widgets/glass_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Local static database of users to persist registered accounts during session
  static final List<FamilyUser> _users = [
    const FamilyUser(name: 'Papá', username: 'papa@hometask.com', password: 'Password123!', role: 'padre'),
    const FamilyUser(name: 'Carlos', username: 'carlos@hometask.com', password: 'Password123!', role: 'hijo'),
  ];

  bool _isRegisterMode = false;
  String _selectedRole = 'padre'; // Only used in register mode
  String _name = '';
  String _username = '';
  String _password = '';

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final cleanedUsername = _username.trim().toLowerCase();
      
      if (_isRegisterMode) {
        // Registration Logic
        try {
          final registered = await MySqlDbHelper.registerUser(
            FamilyUser(
              name: _name.trim(),
              username: _username.trim(),
              password: _password,
              role: _selectedRole,
            ),
          );

          if (!registered) {
            _showFeedback('El usuario "$_username" ya existe.', isError: true);
            return;
          }

          setState(() {
            _isRegisterMode = false;
          });
          _showFeedback('Usuario registrado en MySQL con éxito. ¡Inicia sesión!', isError: false);
        } catch (dbError) {
          // Fallback to in-memory registration
          final userExists = _users.any((u) => u.username.toLowerCase() == cleanedUsername);
          if (userExists) {
            _showFeedback('El usuario "$_username" ya existe (En Memoria).', isError: true);
            return;
          }

          setState(() {
            _users.add(
              FamilyUser(
                name: _name.trim(),
                username: _username.trim(),
                password: _password,
                role: _selectedRole,
              ),
            );
            _isRegisterMode = false;
          });
          _showFeedback('MySQL desconectado. Registrado en memoria local.', isError: false);
        }
      } else {
        // Login Logic
        try {
          final user = await MySqlDbHelper.validateLogin(_username, _password);
          if (user != null) {
            if (mounted) {
              context.go('/home/0?role=${user.role}&email=${user.username}&name=${Uri.encodeComponent(user.name)}');
            }
          } else {
            _showFeedback('Usuario o contraseña incorrectos.', isError: true);
          }
        } catch (dbError) {
          // Fallback to in-memory login
          final userIndex = _users.indexWhere(
            (u) => u.username.toLowerCase() == cleanedUsername && u.password == _password
          );

          if (userIndex != -1) {
            final user = _users[userIndex];
            _showFeedback('Iniciando sesión local (MySQL fuera de línea)...', isError: false);
            if (mounted) {
              context.go('/home/0?role=${user.role}&email=${user.username}&name=${Uri.encodeComponent(user.name)}');
            }
          } else {
            _showFeedback('Usuario o contraseña incorrectos (En Memoria).', isError: true);
          }
        }
      }
    }
  }

  void _showFeedback(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isError ? Colors.redAccent : AppTheme.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(seconds: 20),
        builder: (context, value, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [AppTheme.glassCyan, AppTheme.glassPurple, AppTheme.deepNavy],
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment(value - 1, value - 1),
                end: Alignment(1 - value, 1 - value),
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top Branding
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.2),
                              blurRadius: 24,
                              spreadRadius: 4,
                            )
                          ]
                        ),
                        child: const Text(
                          '🏆',
                          style: TextStyle(fontSize: 64),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'HomeTask Smart',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontSize: 34,
                              letterSpacing: -1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gestión Colaborativa del Hogar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Login/Register Card
                  GlassCard(
                    blur: 24,
                    borderRadius: 32,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    borderColor: Colors.white.withValues(alpha: 0.3),
                    padding: const EdgeInsets.all(28.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isRegisterMode ? 'Crear Cuenta' : 'Iniciar Sesión',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isRegisterMode 
                                ? 'Regístrate y selecciona tu rol familiar.' 
                                : 'Ingresa tus credenciales para continuar.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Name Field (Only in Register Mode)
                          if (_isRegisterMode) ...[
                            _buildTextField(
                              label: 'Nombre Completo',
                              hint: 'ej. Carlos',
                              icon: Icons.person_outline_rounded,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor ingresa tu nombre';
                                }
                                final lettersOnlyRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ]+$');
                                if (!lettersOnlyRegex.hasMatch(value.trim())) {
                                  return 'Solo letras (sin espacios ni signos)';
                                }
                                return null;
                              },
                              onSaved: (value) => _name = value!,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Username Field (Email Address)
                          _buildTextField(
                            label: 'Correo Electrónico',
                            hint: 'ejemplo@correo.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor ingresa tu correo';
                              }
                              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Ingresa un correo válido';
                              }
                              return null;
                            },
                            onSaved: (value) => _username = value!,
                          ),
                          const SizedBox(height: 16),

                          // Password Field (Strict Validations)
                          _buildTextField(
                            label: 'Contraseña',
                            hint: 'Tu contraseña secreta',
                            icon: Icons.lock_outline_rounded,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contraseña';
                              }
                              if (value.length < 8 || value.length > 20) {
                                return 'Debe tener entre 8 y 20 caracteres';
                              }
                              if (value.contains(' ')) {
                                return 'No debe contener espacios';
                              }
                              if (!value.contains(RegExp(r'[A-Z]'))) {
                                return 'Al menos una mayúscula';
                              }
                              if (!value.contains(RegExp(r'[a-z]'))) {
                                return 'Al menos una minúscula';
                              }
                              if (!value.contains(RegExp(r'[0-9]'))) {
                                return 'Al menos un número';
                              }
                              if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
                                return 'Al menos un carácter especial';
                              }
                              return null;
                            },
                            onSaved: (value) => _password = value!,
                          ),
                          const SizedBox(height: 24),

                          // Role Selector (Only in Register Mode)
                          if (_isRegisterMode) ...[
                            Text(
                              'Selecciona tu Rol',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildRoleOption(
                              role: 'padre',
                              title: 'Papá / Mamá',
                              icon: Icons.supervisor_account_rounded,
                            ),
                            const SizedBox(height: 10),
                            _buildRoleOption(
                              role: 'hijo',
                              title: 'Hijo / Hija',
                              icon: Icons.child_care_rounded,
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.glassCyan,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                                shadowColor: Colors.black.withValues(alpha: 0.2),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isRegisterMode ? 'Registrarse' : 'Ingresar',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Mode Switcher Link
                          Center(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _isRegisterMode = !_isRegisterMode;
                                  _formKey.currentState?.reset();
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                _isRegisterMode
                                    ? '¿Ya tienes cuenta? Inicia Sesión'
                                    : '¿No tienes cuenta? Regístrate',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_done_rounded, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Sincronizado en tiempo real',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
  }) {
    return TextFormField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.danger, width: 1.5),
        ),
        errorStyle: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }

  Widget _buildRoleOption({
    required String role,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
            width: 2,
          ),
          color: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
