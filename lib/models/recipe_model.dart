class Recipe {
  final int id;
  final String title;
  final String servings;
  final String time;
  final String description;
  final String imageAsset;
  final String iconImage; 
  final bool isVegetarian;
  final bool isComplicated;
  final String season;
  bool isFavourite; 

  final Map<String, List<String>> ingredients;
  final Map<String, List<String>> method;

  Recipe({
    required this.id,
    required this.title,
    required this.servings,
    required this.time,
    required this.description,
    required this.imageAsset,
    required this.iconImage,
    required this.isVegetarian,
    required this.isComplicated,
    required this.season,
    this.isFavourite = false,
    required this.ingredients,
    required this.method,
  });
}

// Sample recipes
final List<Recipe> allRecipes = [
  Recipe(
    id: 1,
    title: 'Complete Breakfast',
    servings: '4 servings',
    time: '45 minutes',
    description: "You'll feel ready to take on the world! This highly nutritious meal is a farmer's best friend.",
    imageAsset: 'assets/images/completeBreakfast.jpg', // Replace with your real photo
    iconImage: 'assets/images/completeBreakfastIcon.png', // Replace with your Stardew icon asset
    isVegetarian: true,
    isComplicated: true,
    season: 'Spring',
    isFavourite: false,
    ingredients: {
      'Fried Egg': ['2 tbsp EXTRA_VIRGIN OLIVE OIL', '1 tbs UNSALTED BUTTER', '8 LARGE EGGS', 'KOSHER SALT', 'FRESHLY GROUND BLACK PEPPER'],
      'Hash Browns': ['1 RUSSET POTATOES', '2 tbsp CORNSTARCH', '1 tsp GRANULATED GARLIC', '1/2 tsp ONION POWDER', 'FRESHLY GROUND BLACK PEPPER', 'NEUTRAL HIGH_HEAT COOKING OIL', 'KOSHER SALT'],
      'Yogurt Pancakes': ['8 oz FRESH RHUBARD', '50g GRANULATED SUGAR', '3 tbsp WATER', 'KOSHER SALT', '115g fresh SALMONBERRIES', '210g ALL-PURPOSE FLOUR', '1 tbsp BAKING SODA', '1.5 tbsp BAKING POWDER', '2 LARGE EGGS, at room temp', '2 tbsp HONEY', '300g PLAIN FULL_FAT GOAT"S MILK COW\'s MILK YOGURT', '2 tbsp UNSALTED BUTTER',],
    },
    method: {
      'Fried Egg': ['Heat oil in a pan.', 'Crack the egg and fry until the whites are set.'],
      'Hash Browns': ['Preheat the oven to 200°F(95°C).', 'Fit a rimmed baking sheet with a wire rack.', 'Grate the potato.', 'Fry in a hot oiled pan until crispy and golden brown.'],
      'Yogurt Pancakes': ['Mix flour, egg, and yogurt.', 'Pour batter onto a hot griddle and flip when bubbly.'],
    },
  ),
  Recipe(
    id: 2,
    title: 'Pink Cake',
    servings: '4 servings',
    time: '60 minutes',
    description: "There's little heart candies on top. I'm sure you'll fall in love with it.",
    imageAsset: 'assets/images/pinkcake.jpg', // Real photo
    iconImage: 'assets/images/image_29c1a5.png', // Stardew icon
    isVegetarian: true,
    isComplicated: false, // Simple dish
    season: 'Summer',
    isFavourite: true,
    ingredients: {
      'Main': [
        '1 Melon',
        '1 cup Wheat Flour',
        '1 cup Sugar',
        '1 Egg'
      ],
    },
    method: {
      'Main': [
        'Preheat oven to 180°C.',
        'Blend melon into a puree.',
        'Mix dry ingredients together.',
        'Add eggs and melon puree, stir well.',
        'Pour into pan and bake for 30 mins.',
      ],
    },
  ),
];