import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

// --- HELPER CLASS TO MANAGE DYNAMIC CONTROLLERS ---
class RecipeComponentState {
  TextEditingController titleController;
  List<TextEditingController> ingredients;
  List<TextEditingController> methods;

  RecipeComponentState({
    required this.titleController,
    required this.ingredients,
    required this.methods,
  });
}

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  // --- Controllers for basic info ---
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();

  // --- Dynamic Components List ---
  final List<RecipeComponentState> _components = [];

  // --- State for toggles and dropdowns ---
  bool _isVegetarian = false;
  bool _isComplicated = false;
  String _selectedSeason = 'Spring';
  bool _isLoading = false;

  final List<String> _seasons = ['Spring', 'Summer', 'Fall', 'Winter', 'All Seasons'];

  // --- Image State ---
  File? _coverImageFile;
  File? _iconImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _addComponent('Main');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _servingsController.dispose();
    for (var comp in _components) {
      comp.titleController.dispose();
      for (var c in comp.ingredients) {
        c.dispose();
      }
      for (var c in comp.methods) {
        c.dispose();
      }
    }
    super.dispose();
  }

  // --- IMAGE PICKER LOGIC ---
  Future<void> _pickImage(bool isIcon) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isIcon) {
          _iconImageFile = File(pickedFile.path);
        } else {
          _coverImageFile = File(pickedFile.path);
        }
      });
    }
  }

  // --- LOCAL DEVICE STORAGE LOGIC ---
  Future<String?> _saveImageLocally(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await imageFile.copy('${directory.path}/$fileName');
      return savedImage.path;
    } catch (e) {
      debugPrint("Failed to save image locally: $e");
      return null;
    }
  }

  // --- DYNAMIC FORM LOGIC ---
  void _addComponent(String defaultTitle) {
    setState(() {
      _components.add(RecipeComponentState(
        titleController: TextEditingController(text: defaultTitle),
        ingredients: [TextEditingController()],
        methods: [TextEditingController()],
      ));
    });
  }

  void _addIngredientField(int componentIndex) {
    setState(() {
      _components[componentIndex].ingredients.add(TextEditingController());
    });
  }

  void _addMethodField(int componentIndex) {
    setState(() {
      _components[componentIndex].methods.add(TextEditingController());
    });
  }

  // --- SAVE RECIPE LOGIC (was missing + had orphaned code) ---
  // --- THE FIXED FIREBASE SAVE FUNCTION ---
  Future<void> _saveRecipeToInternet() async {
    // Basic validation
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipe title.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Step 1: Save images locally, fallback to hardcoded assets
      String coverUrl = 'assets/images/cover.jpg';
      String iconUrl = 'assets/images/image_34c456.png';

      if (_coverImageFile != null) {
        final localCover = await _saveImageLocally(_coverImageFile!);
        if (localCover != null) coverUrl = localCover;
      }

      if (_iconImageFile != null) {
        final localIcon = await _saveImageLocally(_iconImageFile!);
        if (localIcon != null) iconUrl = localIcon;
      }

      // 🛠️ Step 2: Restructure components into the exact Maps your Recipe Model expects!
      Map<String, List<String>> finalIngredients = {};
      Map<String, List<String>> finalMethods = {};

      for (var comp in _components) {
        String compName = comp.titleController.text.trim();
        if (compName.isEmpty) compName = 'Main'; // Fallback name

        // Extract non-empty text values from text field controllers
        List<String> ingList = comp.ingredients
            .map((c) => c.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();
            
        List<String> metList = comp.methods
            .map((c) => c.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();

        // Save them mapped directly under the section name
        if (ingList.isNotEmpty) finalIngredients[compName] = ingList;
        if (metList.isNotEmpty) finalMethods[compName] = metList;
      }

      // Step 3: Save to Firestore matching the exact historical schema
      final user = FirebaseAuth.instance.currentUser;
      
      final Map<String, dynamic> structuredRecipeData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'time': _timeController.text.trim().isEmpty ? '30 mins' : _timeController.text.trim(),
        'servings': _servingsController.text.trim().isEmpty ? '1 serving' : _servingsController.text.trim(),
        'season': _selectedSeason,
        'isVegetarian': _isVegetarian,
        'isComplicated': _isComplicated,
        'isFavourite': false, // Starts out unfavorited
        'imageAsset': coverUrl, // Mapped to model property expectation
        'iconImage': iconUrl,   // Mapped to model property expectation
        'ingredients': finalIngredients,
        'method': finalMethods,
        'subRecipes': [], 
        'createdBy': user?.uid ?? 'anonymous',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Push cleanly using a system document reference
      await FirebaseFirestore.instance.collection('recipes').add(structuredRecipeData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe saved successfully!'), backgroundColor: Color(0xFF4CAF50)),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error saving recipe: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save recipe: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UI HELPERS ---
  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Color(0xFF5D4037)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(color: Color(0xFF8B5A2B), fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF8B5A2B), width: 1.5)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF5D4037), width: 2)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5A2B),
        foregroundColor: Colors.white,
        title: const Text('Insert a Recipe',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- IMAGE PICKER SECTION ---
            Row(
              children: [
                // Cover Image
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () => _pickImage(false),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: const Color(0xFF8B5A2B), width: 1.5),
                      ),
                      child: _coverImageFile != null
                          ? Image.file(_coverImageFile!, fit: BoxFit.cover)
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo,
                                    color: Color(0xFF8B5A2B)),
                                SizedBox(height: 4),
                                Text('Cover Photo',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF8B5A2B))),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Icon Image
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () => _pickImage(true),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: const Color(0xFF8B5A2B), width: 1.5),
                      ),
                      child: _iconImageFile != null
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.file(_iconImageFile!,
                                  fit: BoxFit.contain),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.grid_view,
                                    color: Color(0xFF8B5A2B)),
                                SizedBox(height: 4),
                                Text('Pixel Icon',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF8B5A2B))),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- BASIC INFO SECTION ---
            _buildTextField(
                _titleController, 'Recipe Title (e.g. Bread and Bruschetta)'),
            _buildTextField(_descriptionController, 'Description',
                maxLines: 2),
            Row(
              children: [
                Expanded(
                    child: _buildTextField(
                        _timeController, 'Time (e.g. 40 mins)')),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildTextField(
                        _servingsController, 'Servings (e.g. 4)')),
              ],
            ),

            // Season Dropdown
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border:
                      Border.all(color: const Color(0xFF8B5A2B), width: 1.5)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSeason,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Color(0xFF8B5A2B)),
                  items: _seasons
                      .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text('Season: $s',
                              style: const TextStyle(
                                  color: Color(0xFF5D4037)))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSeason = val);
                  },
                ),
              ),
            ),

            // Toggles
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border:
                      Border.all(color: const Color(0xFF8B5A2B), width: 1.5)),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Vegetarian',
                        style: TextStyle(color: Color(0xFF5D4037))),
                    activeTrackColor: const Color(0xFF4CAF50),
                    value: _isVegetarian,
                    onChanged: (val) => setState(() => _isVegetarian = val),
                  ),
                  const Divider(height: 1, color: Color(0xFF8B5A2B)),
                  SwitchListTile(
                    title: const Text('Complicated Recipe',
                        style: TextStyle(color: Color(0xFF5D4037))),
                    activeTrackColor: const Color(0xFFE53935),
                    value: _isComplicated,
                    onChanged: (val) => setState(() => _isComplicated = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(color: Color(0xFF8B5A2B), thickness: 3),
            const SizedBox(height: 16),

            // --- DYNAMIC RECIPE COMPONENTS SECTION ---
            const Text('Recipe Components',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5A2B))),
            const SizedBox(height: 8),

            ...List.generate(_components.length, (index) {
              final comp = _components[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDC484),
                  border:
                      Border.all(color: const Color(0xFF5D4037), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(comp.titleController,
                        'Component Name (e.g. "Bruschetta" or "Main")'),
                    const SizedBox(height: 12),

                    // INGREDIENTS
                    const Text('Ingredients',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5D4037))),
                    ...List.generate(
                        comp.ingredients.length,
                        (i) => _buildTextField(
                            comp.ingredients[i], 'Ingredient ${i + 1}')),
                    TextButton.icon(
                      onPressed: () => _addIngredientField(index),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Ingredient'),
                      style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF8B5A2B)),
                    ),

                    const Divider(color: Color(0xFF5D4037)),

                    // METHODS
                    const Text('Instructions',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5D4037))),
                    ...List.generate(
                        comp.methods.length,
                        (i) => _buildTextField(
                            comp.methods[i], 'Step ${i + 1}',
                            maxLines: 2)),
                    TextButton.icon(
                      onPressed: () => _addMethodField(index),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Step'),
                      style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF8B5A2B)),
                    ),
                  ],
                ),
              );
            }),

            // Add New Component Button
            OutlinedButton.icon(
              onPressed: () => _addComponent(''),
              icon: const Icon(Icons.post_add),
              label: const Text('Add Another Component Section'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8B5A2B),
                side: const BorderSide(color: Color(0xFF8B5A2B), width: 2),
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 40),

            // --- SAVE BUTTON ---
            FilledButton.icon(
              onPressed: _isLoading ? null : _saveRecipeToInternet,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.cloud_upload),
              label: Text(
                _isLoading ? 'Uploading...' : 'Save to Cloud',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Color(0xFF5D4037), width: 3),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}