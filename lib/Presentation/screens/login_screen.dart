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
    const FamilyUser(username: 'papa@hometask.com', password: 'Password123!', role: 'padre'),
    const FamilyUser(username: 'carlos@hometask.com', password: 'Password123!', role: 'hijo'),
  ];

  bool _isRegisterMode = false;
  String _selectedRole = 'padre'; // Only used in register mode
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
              context.go('/home/0?role=${user.role}&email=${user.username}');
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
              context.go('/home/0?role=${user.role}&email=${user.username}');
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.headerGradient,
        ),
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
                      const Text(
                        '🏆',
                        style: TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'HomeTask Smart',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontSize: 32,
                              letterSpacing: -1.0,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gestión Colaborativa del Hogar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Login/Register Card
                  GlassCard(
                    blur: 20,
                    borderRadius: 32,
                    backgroundColor: Colors.white.withValues(alpha: 0.85),
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isRegisterMode ? 'Crear Cuenta' : 'Iniciar Sesión',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isRegisterMode 
                                ? 'Regístrate y selecciona tu rol familiar.' 
                                : 'Ingresa tus credenciales para continuar.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Username Field (Email Address)
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Correo Electrónico',
                              hintText: 'ejemplo@correo.com',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor ingresa tu correo';
                              }
                              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Ingresa un correo electrónico válido';
                              }
                              return null;
                            },
                            onSaved: (value) => _username = value!,
                          ),
                          const SizedBox(height: 16),

                          // Password Field (Strict Validations)
                          TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contraseña';
                              }
                              if (value.length < 8 || value.length > 20) {
                                return 'La contraseña debe tener entre 8 y 20 caracteres';
                              }
                              if (value.contains(' ')) {
                                return 'La contraseña no debe contener espacios';
                              }
                              if (!value.contains(RegExp(r'[A-Z]'))) {
                                return 'Debe contener al menos una letra mayúscula';
                              }
                              if (!value.contains(RegExp(r'[a-z]'))) {
                                return 'Debe contener al menos una letra minúscula';
                              }
                              if (!value.contains(RegExp(r'[0-9]'))) {
                                return 'Debe contener al menos un número';
                              }
                              if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
                                return 'Debe contener al menos un carácter especial (ej. !, @, #)';
                              }
                              return null;
                            },
                            onSaved: (value) => _password = value!,
                          ),
                          const SizedBox(height: 20),

                          // Role Selector (Only in Register Mode)
                          if (_isRegisterMode) ...[
                            const Text(
                              'Selecciona tu Rol',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildRoleOption(
                              role: 'padre',
                              title: 'Papá / Mamá',
                              icon: Icons.supervisor_account,
                            ),
                            const SizedBox(height: 8),
                            _buildRoleOption(
                              role: 'hijo',
                              title: 'Hijo / Hija',
                              icon: Icons.child_care,
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.electricBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isRegisterMode ? 'Registrarse' : 'Ingresar',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Mode Switcher Link
                          Center(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _isRegisterMode = !_isRegisterMode;
                                  _formKey.currentState?.reset();
                                });
                              },
                              child: Text(
                                _isRegisterMode
                                    ? '¿Ya tienes cuenta? Inicia Sesión'
                                    : '¿No tienes cuenta? Regístrate',
                                style: const TextStyle(
                                  color: AppTheme.electricBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Footer
                  Text(
                    'Sincronizado en tiempo real',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.electricBlue : Colors.black.withValues(alpha: 0.08),
            width: 2,
          ),
          color: isSelected ? AppTheme.electricBlue.withValues(alpha: 0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.electricBlue : AppTheme.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
