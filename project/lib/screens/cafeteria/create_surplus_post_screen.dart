import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/surplus_post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/surplus_provider.dart';
import '../../utils/constants.dart';

class CreateSurplusPostScreen extends StatefulWidget {
  const CreateSurplusPostScreen({super.key});

  @override
  State<CreateSurplusPostScreen> createState() =>
      _CreateSurplusPostScreenState();
}

class _CreateSurplusPostScreenState extends State<CreateSurplusPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _portionsController = TextEditingController();
  final _locationController = TextEditingController();
  
  FoodCategory _selectedCategory = FoodCategory.veg;
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 2));
  bool _forNgo = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _portionsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    );
    if (picked != null) {
      setState(() {
        _startTime = DateTime(
          _startTime.year,
          _startTime.month,
          _startTime.day,
          picked.hour,
          picked.minute,
        );
        if (_endTime.isBefore(_startTime)) {
          _endTime = _startTime.add(const Duration(hours: 2));
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime),
    );
    if (picked != null) {
      setState(() {
        _endTime = DateTime(
          _endTime.year,
          _endTime.month,
          _endTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final surplusProvider = Provider.of<SurplusProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final post = SurplusPostModel(
      id: const Uuid().v4(),
      cafeteriaId: authProvider.currentUser!.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _selectedCategory,
      totalPortions: int.parse(_portionsController.text),
      availablePortions: int.parse(_portionsController.text),
      pickupLocation: _locationController.text.trim(),
      startTime: _startTime,
      endTime: _endTime,
      forNgo: _forNgo,
      status: PostStatus.active,
      createdAt: DateTime.now(),
    );

    try {
      await surplusProvider.createPost(post);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Surplus post created successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Surplus Post'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Food Title *',
                  hintText: 'e.g., Vegetable rice and curry',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter food title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FoodCategory>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: FoodCategory.veg,
                    child: Text('Vegetarian'),
                  ),
                  DropdownMenuItem(
                    value: FoodCategory.nonVeg,
                    child: Text('Non-Vegetarian'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _portionsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Portions *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of portions';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num <= 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Pickup Location *',
                  hintText: 'e.g., Main Cafeteria, Building A',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pickup location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Start Time'),
                      subtitle: Text(
                        '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: _selectStartTime,
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('End Time'),
                      subtitle: Text(
                        '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: _selectEndTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Suitable for NGO bulk pickup'),
                subtitle: const Text('Enable if portions > ${AppConstants.ngoBulkThreshold}'),
                value: _forNgo,
                onChanged: (value) {
                  setState(() {
                    _forNgo = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Create Post',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

