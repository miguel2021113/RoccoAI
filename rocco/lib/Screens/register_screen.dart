import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart'; // Asegúrate de tener esta importación

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactNumberController = TextEditingController(text: '+52 ');
  String _selectedPlan = 'Básico';
  bool _obscurePassword = true;

  final RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  Future<void> _registerUser() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final contactName = _contactNameController.text.trim();
    final contactNumber = _contactNumberController.text.trim();
    final plan = _selectedPlan;

    // Validaciones locales
    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        contactName.isEmpty ||
        contactNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los campos son obligatorios')),
      );
      return;
    }

    if (username.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre de usuario no debe exceder 20 caracteres')),
      );
      return;
    }

    if (!emailRegExp.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El correo electrónico no tiene un formato válido')),
      );
      return;
    }

    if (password.length > 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña no debe exceder 8 caracteres')),
      );
      return;
    }

    if (contactName.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre del contacto no debe exceder 20 caracteres')),
      );
      return;
    }

    if (!RegExp(r'^\+52\s\d{10}$').hasMatch(contactNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El número debe tener el formato +52 seguido de 10 dígitos')),
      );
      return;
    }

    try {
      // Verificar si el nombre de usuario o el correo ya existen
      final existingUserResponse = await Supabase.instance.client
          .from('User')
          .select()
          .or('Username.eq.$username,Email.eq.$email');

      if (existingUserResponse.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El nombre de usuario o correo ya están registrados')),
        );
        return;
      }

      // Registrar usuario si no existe duplicado
      final response = await Supabase.instance.client
          .from('User')
          .insert({
            'Username': username,
            'Email': email,
            'Password': password,
            'Contact_name': contactName,
            'Contact_number': contactNumber,
            'Plan': plan,
          })
          .select();

      if (response.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar usuario')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario registrado exitosamente')),
        );

        // Navegar al LoginScreen después de registrar exitosamente
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excepción: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        automaticallyImplyLeading: false, // Se elimina la flecha de regreso
        backgroundColor: Colors.orange,
        elevation: 0,
        title: const Text('Registrar Cuenta'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', height: 120),
              const SizedBox(height: 20),
              const Text(
                'Registrar Cuenta',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildTextField('Nombre de Usuario', _usernameController, maxLength: 20),
              _buildTextField('Correo Electrónico', _emailController, keyboardType: TextInputType.emailAddress),
              _buildPasswordField(),
              _buildTextField('Nombre del Contacto de Emergencia', _contactNameController, maxLength: 20),
              _buildPhoneNumberField(),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Básico'),
                  Radio<String>(
                    value: 'Básico',
                    groupValue: _selectedPlan,
                    onChanged: (value) => setState(() => _selectedPlan = value!),
                  ),
                  const Text('Plus'),
                  Radio<String>(
                    value: 'Plus',
                    groupValue: _selectedPlan,
                    onChanged: (value) => setState(() => _selectedPlan = value!),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Crear Cuenta', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        maxLength: 8,
        decoration: InputDecoration(
          labelText: 'Contraseña',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: _contactNumberController,
        keyboardType: TextInputType.phone,
        maxLength: 14,
        decoration: InputDecoration(
          labelText: 'Número del Contacto de Emergencia',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}