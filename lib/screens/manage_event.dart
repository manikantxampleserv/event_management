import 'package:event_management/models/event_model.dart';
import 'package:event_management/services/event_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EventFormDialog extends StatefulWidget {
  final EventModel? event;

  const EventFormDialog({super.key, this.event});

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final EventService eventService = Get.find<EventService>();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _venueController;
  late final TextEditingController _timeController;
  late final TextEditingController _priceController;
  late final TextEditingController _seatsController;
  late final TextEditingController _organizerController;

  late String _selectedCategory;
  late DateTime _selectedDate;
  late List<String> _selectedTags;

  bool get isEditing => widget.event != null;

  final List<String> _categories = [
    'Technology',
    'Music',
    'Business',
    'Art',
    'Sports',
    'Education',
    'Health',
    'Food',
  ];

  final List<String> _availableTags = [
    'Technology',
    'Conference',
    'Innovation',
    'Music',
    'Festival',
    'Live Performance',
    'Business',
    'Networking',
    'Professional',
    'Art',
    'Exhibition',
    'Culture',
    'Sports',
    'Fitness',
    'Education',
    'Workshop',
    'Health',
    'Wellness',
    'Food',
    'Cooking',
  ];

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      _titleController = TextEditingController(text: widget.event!.title);
      _descriptionController = TextEditingController(
        text: widget.event!.description,
      );
      _venueController = TextEditingController(text: widget.event!.venue);
      _timeController = TextEditingController(text: widget.event!.time);
      _priceController = TextEditingController(
        text: widget.event!.price.toString(),
      );
      _seatsController = TextEditingController(
        text: widget.event!.availableSeats.toString(),
      );
      _organizerController = TextEditingController(
        text: widget.event!.organizer,
      );
      _selectedCategory = widget.event!.category;
      _selectedDate = widget.event!.date;
      _selectedTags = List.from(widget.event!.tags);
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _venueController = TextEditingController();
      _timeController = TextEditingController();
      _priceController = TextEditingController();
      _seatsController = TextEditingController();
      _organizerController = TextEditingController();
      _selectedCategory = 'Technology';
      _selectedDate = DateTime.now().add(const Duration(days: 7));
      _selectedTags = [];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _timeController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    _organizerController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      bool success;

      if (isEditing) {
        final updatedEvent = widget.event!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          date: _selectedDate,
          time: _timeController.text,
          venue: _venueController.text,
          price: double.parse(_priceController.text),
          availableSeats: int.parse(_seatsController.text),
          organizer: _organizerController.text,
          tags: _selectedTags,
          updatedAt: DateTime.now(),
        );
        success = await eventService.updateEvent(updatedEvent);
      } else {
        final event = EventModel(
          title: _titleController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          imageUrl:
              'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=500',
          date: _selectedDate,
          time: _timeController.text,
          venue: _venueController.text,
          price: double.parse(_priceController.text),
          availableSeats: int.parse(_seatsController.text),
          organizer: _organizerController.text,
          tags: _selectedTags,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        success = await eventService.createEvent(event);
      }

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Event updated successfully!'
                  : 'Event created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Failed to update event. Please try again.'
                  : 'Failed to create event. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: 40,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Event' : 'Add Event',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Event Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _venueController,
                  decoration: const InputDecoration(labelText: 'Venue'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter venue';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _timeController,
                        decoration: const InputDecoration(
                          labelText: 'Time (e.g., 09:00 AM)',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter time';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Date'),
                          child: Text(
                            DateFormat('MMM dd, yyyy').format(_selectedDate),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter valid price';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _seatsController,
                        decoration: const InputDecoration(
                          labelText: 'Available Seats',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter seats';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _organizerController,
                  decoration: const InputDecoration(labelText: 'Organizer'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter organizer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tags (Optional):',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: _availableTags.map((tag) {
                    bool isSelected = _selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(
                        tag,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),

                      showCheckmark: false,
                      selectedColor: const Color(0xFF667eea),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(isEditing ? 'Update' : 'Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
