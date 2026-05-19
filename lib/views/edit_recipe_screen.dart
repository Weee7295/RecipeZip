import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/recipe_model.dart';

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

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;
  final String recipeDocId; // Firestore document ID needed to update the right doc

  const EditRecipeScreen({
    super.key,
    required this.recipe,
    required this.recipeDocId,
  });

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  // --- Controllers pre-filled from existing recipe ---
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _timeController;
  late final TextEditingController _servingsController;

  // --- Dynamic Components List ---
  final List<RecipeComponentState> _components = [];

  // --- State for toggles and dropdowns ---
  late bool _isVegetarian;
  late bool _isComplicated;
  late String _selectedSeason;
  bool _isLoading = false;

  final List<String> _seasons = ['Spring', 'Summer', 'Fall', 'Winter', 'All Seasons'];

  // --- Image State ---
  // If the user picks a new image, this will be non-null.
  // Otherwise we keep the existing URL string from the recipe.
  File? _newCoverImageFile;
  File? _newIconImageFile;
  late String _existingCoverUrl;
  late String _existingIconUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Pre-fill basic info from the recipe
    _titleController = TextEditingController(text: widget.recipe.title);
    _descriptionController = TextEditingController(text: widget.recipe.description);
    _timeController = TextEditingController(text: widget.recipe.time);
    _servingsController = TextEditingController(text: widget.recipe.servings);

    // Pre-fill toggles
    _isVegetarian = widget.recipe.isVegetarian;
    _isComplicated = widget.recipe.isComplicated;

    // Pre-fill season — fall back to 'All Seasons' if stored value isn't in the list
    _selectedSeason = _seasons.contains(widget.recipe.season)
        ? widget.recipe.season
        : 'All Seasons';

    // Keep track of existing image paths/URLs
    _existingCoverUrl = widget.recipe.imageAsset;
    _existingIconUrl = widget.recipe.iconImage;

    // Pre-fill dynamic components from the recipe's ingredients + method maps
    // Assumes ingredients and method share the same component keys
    final componentKeys = widget.recipe.ingredients.keys.toList();

    if (componentKeys.isEmpty) {
      // Fallback: at least one empty component
      _addComponent('Main');
    } else {
      for (final key in componentKeys) {
        final ingredientList = widget.recipe.ingredients[key] ?? [];
        final methodList = widget.recipe.method[key] ?? [];

        _components.add(RecipeComponentState(
          titleController: TextEditingController(text: key),
          ingredients: ingredientList.isNotEmpty
              ? ingredientList.map((e) => TextEditingController(text: e)).toList()
              : [TextEditingController()],
          methods: methodList.isNotEmpty
              ? methodList.map((e) => TextEditingController(text: e)).toList()
              : [TextEditingController()],
        ));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _servingsController.dispose();
    for (var comp in _components) {
      comp.titleController.dispose();
      for (var c in comp.ingredients) c.dispose();
      for (var c in comp.methods) c.dispose();
    }
    super.dispose();
  }

  // --- IMAGE PICKER LOGIC ---
  Future<void> _pickImage(bool isIcon) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isIcon) {
          _newIconImageFile = File(pickedFile.path);
        } else {
          _newCoverImageFile = File(pickedFile.path);
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

  void _removeComponent(int index) {
    setState(() {
      final comp = _components.removeAt(index);
      comp.titleController.dispose();
      for (var c in comp.ingredients) c.dispose();
      for (var c in comp.methods) c.dispose();
    });
  }

  // --- UPDATE RECIPE LOGIC ---
  Future<void> _updateRecipe() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipe title.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Step 1: Resolve image URLs
      // Only save a new local copy if the user picked a new image
      String coverUrl = _existingCoverUrl;
      String iconUrl = _existingIconUrl;

      if (_newCoverImageFile != null) {
        final localCover = await _saveImageLocally(_newCoverImageFile!);
        if (localCover != null) coverUrl = localCover;
      }

      if (_newIconImageFile != null) {
        final localIcon = await _saveImageLocally(_newIconImageFile!);
        if (localIcon != null) iconUrl = localIcon;
      }

      // Step 2: Build components list
      final List<Map<String, dynamic>> componentsData = _components.map((comp) {
        return {
          'title': comp.titleController.text.trim(),
          'ingredients': comp.ingredients
              .map((c) => c.text.trim())
              .where((s) => s.isNotEmpty)
              .toList(),
          'methods': comp.methods
              .map((c) => c.text.trim())
              .where((s) => s.isNotEmpty)
              .toList(),
        };
      }).toList();

      // Step 3: Update the existing Firestore document
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipeDocId)
          .update({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'time': _timeController.text.trim(),
        'servings': _servingsController.text.trim(),
        'season': _selectedSeason,
        'isVegetarian': _isVegetarian,
        'isComplicated': _isComplicated,
        'coverUrl': coverUrl,
        'iconUrl': iconUrl,
        'components': componentsData,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe updated successfully!')),
        );
        // Pop twice: once for edit screen, once to go back to the list
        // (since the detail screen data is now stale)
        Navigator.of(context)
          ..pop() // close edit screen
          ..pop(); // close detail screen so list refreshes
      }
    } catch (e) {
      debugPrint('Error updating recipe: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update recipe: $e')),
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
          labelStyle: const TextStyle(color: Color(0xFF8B5A2B), fontSize: 14),
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

  // Builds the image picker block.
  // Shows the newly picked file if available, otherwise falls back to the
  // existing asset/path stored in the recipe.
  Widget _buildImageBlock({
    required bool isIcon,
    required File? newFile,
    required String existingUrl,
    required IconData placeholderIcon,
    required String placeholderLabel,
    required int flex,
  }) {
    Widget imageContent;

    if (newFile != null) {
      // User just picked a new image this session
      imageContent = isIcon
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(newFile, fit: BoxFit.contain),
            )
          : Image.file(newFile, fit: BoxFit.cover);
    } else if (existingUrl.isNotEmpty) {
      // Show the previously saved image
      final isAsset = existingUrl.startsWith('assets/');
      imageContent = isAsset
          ? (isIcon
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(existingUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          Icon(placeholderIcon, color: const Color(0xFF8B5A2B))),
                )
              : Image.asset(existingUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Icon(placeholderIcon, color: const Color(0xFF8B5A2B))))
          : (isIcon
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(File(existingUrl),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          Icon(placeholderIcon, color: const Color(0xFF8B5A2B))),
                )
              : Image.file(File(existingUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Icon(placeholderIcon, color: const Color(0xFF8B5A2B))));
    } else {
      // No image at all
      imageContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(placeholderIcon, color: const Color(0xFF8B5A2B)),
          const SizedBox(height: 4),
          Text(placeholderLabel,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8B5A2B))),
        ],
      );
    }

    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => _pickImage(isIcon),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF8B5A2B), width: 1.5),
          ),
          child: imageContent,
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
        title: const Text('Edit Recipe',
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
                _buildImageBlock(
                  isIcon: false,
                  newFile: _newCoverImageFile,
                  existingUrl: _existingCoverUrl,
                  placeholderIcon: Icons.add_a_photo,
                  placeholderLabel: 'Cover Photo',
                  flex: 2,
                ),
                const SizedBox(width: 12),
                _buildImageBlock(
                  isIcon: true,
                  newFile: _newIconImageFile,
                  existingUrl: _existingIconUrl,
                  placeholderIcon: Icons.grid_view,
                  placeholderLabel: 'Pixel Icon',
                  flex: 1,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- BASIC INFO SECTION ---
            _buildTextField(
                _titleController, 'Recipe Title (e.g. Bread and Bruschetta)'),
            _buildTextField(_descriptionController, 'Description', maxLines: 2),
            Row(
              children: [
                Expanded(
                    child: _buildTextField(_timeController, 'Time (e.g. 40 mins)')),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildTextField(_servingsController, 'Servings (e.g. 4)')),
              ],
            ),

            // Season Dropdown
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF8B5A2B), width: 1.5)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSeason,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF8B5A2B)),
                  items: _seasons
                      .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text('Season: $s',
                              style: const TextStyle(color: Color(0xFF5D4037)))))
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
                  border: Border.all(color: const Color(0xFF8B5A2B), width: 1.5)),
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
                  border: Border.all(color: const Color(0xFF5D4037), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Component title row + remove button
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(comp.titleController,
                              'Component Name (e.g. "Bruschetta" or "Main")'),
                        ),
                        // Only show remove if there's more than one component
                        if (_components.length > 1) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _removeComponent(index),
                            child: Container(
                              width: 32,
                              height: 32,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: const Color(0xFF5D4037), width: 1.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.delete_outline,
                                  size: 16, color: Color(0xFFE53935)),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 4),

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
                        (i) => _buildTextField(comp.methods[i], 'Step ${i + 1}',
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

            // --- SAVE CHANGES BUTTON ---
            FilledButton.icon(
              onPressed: _isLoading ? null : _updateRecipe,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(
                _isLoading ? 'Saving...' : 'Save Changes',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8B5A2B),
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