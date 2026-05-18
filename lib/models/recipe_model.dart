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
  final List<Recipe> subRecipes;

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
    this.subRecipes = const [],
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
    imageAsset: 'assets/images/completeBreakfast.jpg', 
    iconImage: 'assets/images/completeBreakfastIcon.png', 
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
    title: 'Farmer\'s Lunch',
    servings: '1 serving',
    time: '60 minutes',
    description: "There's little heart candies on top. I'm sure you'll fall in love with it.",
    imageAsset: 'assets/images/farmerLunch.jpg', // Real photo
    iconImage: 'assets/images/farmerLunchIcon.png', // Stardew icon
    isVegetarian: true,
    isComplicated: false, // Simple dish
    season: 'Spring',
    isFavourite: true,
    ingredients: {
      'Main': [
        '3 LARGE EGGS',
        '2 tbsp WHOLE MILK',
        '1 tbsp UNSALTED BUTTER',
        'KOSHER SALT',
        'FRESHLY GROUND BLACK PEPPER',
        '1/2 cups grated GRUYERE CHEESE',
        '2 tbsp coarsely chopped FRESH SPRING HERBS (chervil, tarragon, chives, parsley)',
        'ROASTED PARSNIPS WITH BABY ARUGULA',
      ],
    },
    method: {
      'Main': [
        'Separate the egg whites and egg yolks.',
        'Whip the egg whites until they form medium-stiff peaks. (2mins)',
        'Drizzle the milk over the egg yolks.',
        'Use mixer to whip the yolkq until the mixture is slightly airy and pale yellow. (2mins)',
        'Gently fold the yolks into the whites until just combined.',
        'Heat a medium cast-iron skillet over medium-low heat.',
        'Add the butter to the warm skillet and swirl to coat the bottom.',
        'Carefully pour the egg mixture into the skillet and cook until the bottom are set. (6-8mins)',
        'Cover the skillet with a lid and cook until the top is mostly set. (4-6mins)',
        'Season the eggs with salt and pepper, and sprinkle with the cheese.',
        'Cover the skillet again and cook until the cheese is melted. (2mins)',
        'Sprinkle the eggs with the herbs',
        'Use a rubber spatula to loosen the side of the omelet, then fold the omelet over.',
        'Switch to a wide metal spatula to carefully transfer the omelet to a plate.',
        'Serve immediately, along with a few large spoonfuls of the parsnips.',
      ],
    },
    subRecipes: [
      Recipe(
        id: 101, 
        title: 'ROASTED PARSNIPS with BABY ARUGULA',
        servings: '4 serving',
        time: '60 minutes',
        description: "There's little heart candies on top. I'm sure you'll fall in love with it.",
        imageAsset: 'assets/images/parsnips.png', 
        iconImage: 'assets/images/image_29c1a5.png', 
        isVegetarian: true,
        isComplicated: false, 
        season: 'Spring',
        isFavourite: true,
        ingredients: {
          'Main': [
            '450g fresh parsnips, peeled and cut into 1/2-inch pieces',
            '2 tbsp extra-virgin olive oil',
            '1 tbsp maple syrup',
            'KOSHER SALT',
          ],
        },
        method: {
          'Main': [
            'Preheat the oven to 375°F (190°C).',
            'Toss the parsnips with the olive oil, maple syrup, and salt.',
            'Spread the parsnips on a baking sheet and roast for 25-30 minutes, until tender and lightly browned.',
            'Let cool for a few minutes before serving with baby arugula.',
          ],
        },
      ),
    ],
  ),
  Recipe(
    id: 3,
    title: 'Vegetable Stock',
    servings: '2 quarts',
    time: '15 minutes',
    description: "There's little heart candies on top. I'm sure you'll fall in love with it.",
    imageAsset: 'assets/images/parsnips.png', 
    iconImage: 'assets/images/image_29c1a5.png', 
    isVegetarian: true,
    isComplicated: false, 
    season: 'Spring',
    isFavourite: false,
    ingredients: {
      'Main': [
        '450g fresh parsnips, peeled and cut into 1/2-inch pieces',
        '2 tbsp extra-virgin olive oil',
        '1 tbsp maple syrup',
        'KOSHER SALT',
      ],
    },
    method: {
      'Main': [
        'Preheat the oven to 375°F (190°C).',
        'Toss the parsnips with the olive oil, maple syrup, and salt.',
        'Spread the parsnips on a baking sheet and roast for 25-30 minutes, until tender and lightly browned.',
        'Let cool for a few minutes before serving with baby arugula.',
      ],
    },
  ),

];