import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/complaint_service.dart';
import '../../models/complaint_model.dart';
import '../auth/login_screen.dart';
import '../complaint/create_complaint_screen.dart';
import '../complaint/complaint_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _complaintService = ComplaintService();

  Future<void> _handleLogout() async {
    await _authService.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Keluar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 24),
              const Text(
                'Statistik Pengaduan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Menunggu',
                      _complaintService.getComplaintCountByStatus(ComplaintStatus.menunggu),
                      Colors.orange,
                      Icons.pending,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Diproses',
                      _complaintService.getComplaintCountByStatus(ComplaintStatus.diproses),
                      Colors.blue,
                      Icons.sync,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Selesai',
                      _complaintService.getComplaintCountByStatus(ComplaintStatus.selesai),
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Menu Utama',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      'Buat Pengaduan',
                      'Sampaikan keluhan Anda',
                      Icons.add_box,
                      Colors.blue,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CreateComplaintScreen(),
                          ),
                        ).then((_) => setState(() {}));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      'Lihat Pengaduan',
                      'Cek status pengaduan',
                      Icons.list_alt,
                      Colors.green,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ComplaintListScreen(),
                          ),
                        ).then((_) => setState(() {}));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return FutureBuilder<UserModel?>(
      future: _authService.getCurrentUser(),
      builder: (context, snapshot) {
        final userName = snapshot.data?.name ?? 'User';
        final userInitial = userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'U';

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    userInitial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Selamat datang,', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(
                        userName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, Future<int> futureCount, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<int>(
          future: futureCount,
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return Column(
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(height: 8),
                Text(
                  count.toString(),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
                ),
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}