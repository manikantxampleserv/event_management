import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:event_management/models/event_model.dart';
import 'package:event_management/services/event_service.dart';
import 'package:event_management/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class EventFormDialog extends StatefulWidget {
  final EventModel? event;

  const EventFormDialog({super.key, this.event});

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final EventService eventService = Get.find<EventService>();
  final StorageService storageService = Get.find<StorageService>();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

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

  String thumbnailDocPath = '';
  List<String> eventImagesDocPaths = [];
  File? thumbnailFile;
  List<File> eventImageFiles = [];
  bool _isUploading = false;

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

    if (isEditing && widget.event != null) {
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

      thumbnailDocPath = widget.event!.thumbnail;
      eventImagesDocPaths = widget.event!.eventImages
          .where((img) => img.isNotEmpty)
          .toList();
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

  Future<void> _selectThumbnail() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          thumbnailFile = File(image.path);
        });
      }
    } catch (e) {
      print('Error selecting thumbnail: $e');
      _showErrorSnackBar('Failed to select thumbnail image');
    }
  }

  Future<void> _selectEventImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (images.isNotEmpty) {
        setState(() {
          eventImageFiles.addAll(images.map((image) => File(image.path)));
        });
      }
    } catch (e) {
      print('Error selecting event images: $e');
      _showErrorSnackBar('Failed to select event images');
    }
  }

  void _removeEventImage(int index) {
    setState(() {
      if (index < eventImagesDocPaths.length) {
        eventImagesDocPaths.removeAt(index);
      } else {
        eventImageFiles.removeAt(index - eventImagesDocPaths.length);
      }
    });
  }

  Widget _buildImageFromDocPath(String docPath) {
    if (docPath.isEmpty) {
      return const Icon(Icons.broken_image, color: Colors.grey);
    }

    return FutureBuilder<Widget>(
      future: _getImageFromDocPath(docPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        if (snapshot.hasError) {
          print('Error loading image: ${snapshot.error}');
          return const Icon(Icons.broken_image, color: Colors.red);
        }

        return snapshot.data ??
            const Icon(Icons.broken_image, color: Colors.grey);
      },
    );
  }

  Future<Widget> _getImageFromDocPath(String docPath) async {
    try {
      if (docPath.isEmpty) {
        return const Icon(Icons.broken_image, color: Colors.grey);
      }

      final pathParts = docPath.split('/');
      if (pathParts.length != 2) {
        print('Invalid docPath format: $docPath');
        return const Icon(Icons.broken_image, color: Colors.orange);
      }

      final doc = await storageService.getFileFromFirestore(
        collectionName: pathParts[0],
        documentId: pathParts[1],
      );

      if (doc != null && doc['imageData'] != null) {
        try {
          Uint8List bytes = base64Decode(doc['imageData']);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error displaying image: $error');
              return const Icon(Icons.broken_image, color: Colors.red);
            },
          );
        } catch (e) {
          print('Error decoding base64 image: $e');
          return const Icon(Icons.broken_image, color: Colors.red);
        }
      } else {
        print('Document not found or no imageData: $docPath');
        return const Icon(Icons.broken_image, color: Colors.grey);
      }
    } catch (e) {
      print('Error loading image from docPath: $e');
      return const Icon(Icons.broken_image, color: Colors.red);
    }
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

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      // Check if thumbnail is required for new events
      if (!isEditing && thumbnailFile == null && thumbnailDocPath.isEmpty) {
        _showErrorSnackBar('Please select a thumbnail image');
        return;
      }

      setState(() {
        _isUploading = true;
      });

      try {
        String finalThumbnailDocPath = thumbnailDocPath;

        // Upload new thumbnail if selected
        if (thumbnailFile != null) {
          print('Uploading thumbnail file: ${thumbnailFile!.path}');
          String? uploadedPath = await storageService.uploadFileToFirestore(
            collectionName: 'event_images',
            file: thumbnailFile!,
            additionalMetadata: {'type': 'thumbnail'},
          );

          if (uploadedPath != null) {
            finalThumbnailDocPath = uploadedPath;
            print('Thumbnail uploaded successfully: $finalThumbnailDocPath');
          } else {
            throw Exception('Failed to upload thumbnail');
          }
        }

        // Upload new event images
        List<String> finalEventImagesDocPaths = List.from(eventImagesDocPaths);
        for (int i = 0; i < eventImageFiles.length; i++) {
          File imageFile = eventImageFiles[i];
          print(
            'Uploading event image ${i + 1}/${eventImageFiles.length}: ${imageFile.path}',
          );

          String? docPath = await storageService.uploadFileToFirestore(
            collectionName: 'event_images',
            file: imageFile,
            additionalMetadata: {'type': 'eventImages'},
          );

          if (docPath != null) {
            finalEventImagesDocPaths.add(docPath);
            print('Event image uploaded successfully: $docPath');
          } else {
            print('Failed to upload event image: ${imageFile.path}');
            // Continue with other images even if one fails
          }
        }

        print("thumbnailFile: $thumbnailFile");
        print("eventImageFiles: $eventImageFiles");
        print("finalThumbnailDocPath: $finalThumbnailDocPath");
        print("finalEventImagesDocPaths: $finalEventImagesDocPaths");

        bool success = false;

        if (isEditing && widget.event != null) {
          final updatedEvent = widget.event!.copyWith(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _selectedCategory,
            date: _selectedDate,
            time: _timeController.text.trim(),
            venue: _venueController.text.trim(),
            price: double.parse(_priceController.text),
            availableSeats: int.parse(_seatsController.text),
            organizer: _organizerController.text.trim(),
            tags: _selectedTags,
            thumbnail: finalThumbnailDocPath,
            eventImages: finalEventImagesDocPaths,
            updatedAt: DateTime.now(),
          );
          success = await eventService.updateEvent(updatedEvent);
        } else {
          final event = EventModel(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _selectedCategory,
            imageUrl:
                finalThumbnailDocPath, // Keep both imageUrl and thumbnail in sync
            date: _selectedDate,
            time: _timeController.text.trim(),
            venue: _venueController.text.trim(),
            price: double.parse(_priceController.text),
            availableSeats: int.parse(_seatsController.text),
            organizer: _organizerController.text.trim(),
            tags: _selectedTags,
            thumbnail: finalThumbnailDocPath,
            eventImages: finalEventImagesDocPaths,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          success = await eventService.createEvent(event);
        }

        setState(() {
          _isUploading = false;
        });

        if (success) {
          if (!mounted) return;
          Navigator.of(context).pop();
          _showSuccessSnackBar(
            isEditing
                ? 'Event updated successfully!'
                : 'Event created successfully!',
          );
        } else {
          _showErrorSnackBar(
            isEditing
                ? 'Failed to update event. Please try again.'
                : 'Failed to create event. Please try again.',
          );
        }
      } catch (e, stackTrace) {
        setState(() {
          _isUploading = false;
        });
        print('Error saving event: $e');
        print('Stack trace: $stackTrace');
        _showErrorSnackBar('Error: ${e.toString()}');
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

                // Thumbnail Section
                Row(
                  children: [
                    const Text(
                      'Thumbnail Image:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (!isEditing) // Only show required for new events
                      const Text(
                        ' *',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: thumbnailFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            thumbnailFile!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading thumbnail file: $error');
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.red,
                                ),
                              );
                            },
                          ),
                        )
                      : thumbnailDocPath.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildImageFromDocPath(thumbnailDocPath),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _selectThumbnail,
                                child: const Text('Select Thumbnail'),
                              ),
                            ],
                          ),
                        ),
                ),
                if (thumbnailFile != null || thumbnailDocPath.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton(
                      onPressed: _selectThumbnail,
                      child: const Text('Change Thumbnail'),
                    ),
                  ),
                const SizedBox(height: 20),

                // Event Images Section
                const Text(
                  'Event Images:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                if (eventImagesDocPaths.isNotEmpty ||
                    eventImageFiles.isNotEmpty)
                  Container(
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          eventImagesDocPaths.length + eventImageFiles.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: index < eventImagesDocPaths.length
                                    ? _buildImageFromDocPath(
                                        eventImagesDocPaths[index],
                                      )
                                    : Image.file(
                                        eventImageFiles[index -
                                            eventImagesDocPaths.length],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          print(
                                            'Error loading event image file: $error',
                                          );
                                          return const Icon(
                                            Icons.broken_image,
                                            color: Colors.red,
                                          );
                                        },
                                      ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 12,
                              child: GestureDetector(
                                onTap: () => _removeEventImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                TextButton.icon(
                  onPressed: _selectEventImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Event Images'),
                ),
                const SizedBox(height: 20),

                // Form Fields
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Event Title *'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter event title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description *'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category *'),
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _venueController,
                  decoration: const InputDecoration(labelText: 'Venue *'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
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
                          labelText: 'Time (e.g., 09:00 AM) *',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
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
                          decoration: const InputDecoration(
                            labelText: 'Date *',
                          ),
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
                        decoration: const InputDecoration(labelText: 'Price *'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
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
                          labelText: 'Available Seats *',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
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
                  decoration: const InputDecoration(labelText: 'Organizer *'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
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
                        onPressed: _isUploading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _saveEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          foregroundColor: Colors.white,
                        ),
                        child: _isUploading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(isEditing ? 'Update' : 'Save'),
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
