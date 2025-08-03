import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/complaint_service.dart';
import '../../models/complaint_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/extensions.dart'; 
import '../../utils/app_theme.dart';

class CreateComplaintScreen extends StatefulWidget {
  const CreateComplaintScreen({Key? key}) : super(key: key);

  @override
  State<CreateComplaintScreen> createState() => _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends State<CreateComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _complaintService = ComplaintService();
  final ImagePicker _picker = ImagePicker();

  ComplaintCategory _selectedCategory = ComplaintCategory.infrastruktur;
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
    
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1020,
        maxHeight: 1020,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memilih gambar');
    }
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await _complaintService.submitComplaint(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      evidencePath: _selectedImage?.path,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      _showSuccessSnackBar('Pengaduan berhasil dikirim');
      Navigator.of(context).pop();
    } else if (mounted) {
      _showErrorSnackBar('Gagal mengirim pengaduan');
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Pengaduan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Judul Pengaduan',
                hint: 'Masukkan judul pengaduan',
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  if (value.length < 10) {
                    return 'Judul minimal 10 karakter';
                  }
                  return null;
                },
              ),
              
              const Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ComplaintCategory>(
                    value: _selectedCategory,
                    isExpanded: true,
                    onChanged: (ComplaintCategory? newValue) {
                      if (newValue != null) {
                        setState(() => _selectedCategory = newValue);
                      }
                    },
                    items: ComplaintCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Text(
                              category.icon, // Ini akan berfungsi setelah extensions.dart di-import
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(category.displayName), // Ini juga
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                label: 'Deskripsi',
                hint: 'Jelaskan detail pengaduan Anda',
                controller: _descriptionController,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  if (value.length < 20) {
                    return 'Deskripsi minimal 20 karakter';
                  }
                  return null;
                },
              ),
              
              const Text(
                'Bukti Foto (Opsional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              
              if (_selectedImage != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.edit),
                        label: const Text('Ganti Foto'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _selectedImage = null),
                        icon: const Icon(Icons.delete),
                        label: const Text('Hapus Foto'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Pilih Foto'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitComplaint,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Kirim Pengaduan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}