import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> userData = {};
  final _passwordController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  String _selectedPlan = 'Básico';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró un usuario autenticado')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      print('Obteniendo datos del usuario con email: ${user.email}');
      final response = await Supabase.instance.client
          .from('User')
          .select()
          .eq('Email', user.email)
          .maybeSingle();

      if (response == null) {
        print('No se encontraron datos para el usuario: ${user.email}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontraron datos del usuario')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('Datos obtenidos: $response');

      setState(() {
        userData = response;
        _passwordController.text = userData['Password'] ?? '';
        _contactNameController.text = userData['Contact_name'] ?? '';
        _contactNumberController.text = userData['Contact_number'] ?? '';
        _selectedPlan = userData['Plan'] ?? 'Básico';
        _isLoading = false;
      });
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener datos del usuario: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserData(String field, dynamic value) async {
    try {
      await Supabase.instance.client
          .from('User')
          .update({field: value})
          .eq('Email', userData['Email']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Información actualizada correctamente')),
      );
      _fetchUserData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Perfil de Usuario'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData.isEmpty
              ? const Center(child: Text('No hay datos disponibles'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Perfil de Usuario',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      _buildUserInfo('Nombre de Usuario', userData['Username']),
                      _buildUserInfo('Correo Electrónico', userData['Email']),
                      _buildEditableField('Contraseña', _passwordController, 'Password'),
                      const SizedBox(height: 20),
                      const Text(
                        'Contacto de Emergencia',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      _buildEditableField('Nombre', _contactNameController, 'Contact_name'),
                      _buildEditableField('Número', _contactNumberController, 'Contact_number'),
                      const SizedBox(height: 20),
                      const Text(
                        'Plan',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          const Text('Básico'),
                          Radio<String>(
                            value: 'Básico',
                            groupValue: _selectedPlan,
                            onChanged: (value) {
                              setState(() {
                                _selectedPlan = value!;
                                _updateUserData('Plan', _selectedPlan);
                              });
                            },
                          ),
                          const Text('Plus'),
                          Radio<String>(
                            value: 'Plus',
                            groupValue: _selectedPlan,
                            onChanged: (value) {
                              setState(() {
                                _selectedPlan = value!;
                                _updateUserData('Plan', _selectedPlan);
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Cerrar Sesión', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildUserInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, String field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _updateUserData(field, controller.text.trim()),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}