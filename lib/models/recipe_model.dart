// lib/models/recipe_model.dart

class Recipe {
  final int id;
  final String title;
  final String servings;
  final String time;
  final String description;
  final String imageAsset;
  final List<String> ingredients;
  final List<String> method;

  const Recipe({
    required this.id,
    required this.title,
    required this.servings,
    required this.time,
    required this.description,
    required this.imageAsset,
    required this.ingredients,
    required this.method,
  });
}

// Sample recipes - you can add more!
final List<Recipe> allRecipes = [
  Recipe(
    id: 1,
    title: 'Strawberry Cupcake',
    servings: '2 servings',
    time: '15 minutes',
    description:
        'Nunc nulla velit, feugiat vitae ex quis, lobortis porta leo. '
        'Donec dictum lectus in ex accumsan sodales. '
        'Pellentesque habitant morbi tristique.',
    imageAsset: 'assets/images/pinkcake.jpg',
    ingredients: [
      '100 ml milk',
      '50 g butter',
      '3 eggs',
      '1 tbs cocoa',
    ],
    method: [
      'Mix the dry ingredients.',
      'Add the milk and eggs.',
      'Bake at 180°C for 15 mins.',
    ],
  ),
  Recipe(
    id: 2,
    title: 'Chocolate Cake',
    servings: '4 servings',
    time: '30 minutes',
    description:
        'A rich and moist chocolate cake perfect for chocolate lovers. '
        'This classic dessert combines dark chocolate with vanilla frosting. '
        'Great for celebrations and special occasions.',
    imageAsset: 'assets/images/pinkcake.jpg', // Use same image or add new ones
    ingredients: [
      '200 g flour',
      '100 g cocoa powder',
      '200 g sugar',
      '3 eggs',
      '100 ml milk',
      '50 g butter',
    ],
    method: [
      'Preheat oven to 180°C.',
      'Mix dry ingredients together.',
      'Add eggs and milk, stir well.',
      'Pour into pan and bake for 30 mins.',
      'Cool and frost with chocolate icing.',
    ],
  ),
  Recipe(
    id: 3,
    title: 'Vanilla Cheesecake',
    servings: '8 servings',
    time: '45 minutes',
    description:
        'A creamy vanilla cheesecake with a graham cracker crust. '
        'Smooth, rich, and absolutely delicious. '
        'Perfect dessert for any gathering.',
    imageAsset: 'assets/images/pinkcake.jpg',
    ingredients: [
      '200 g graham crackers',
      '100 g butter',
      '500 g cream cheese',
      '100 g sugar',
      '2 eggs',
      '1 tsp vanilla extract',
      '100 ml sour cream',
    ],
    method: [
      'Make crust with crushed crackers and butter.',
      'Press into baking pan.',
      'Mix cheese, sugar, eggs, and vanilla.',
      'Pour onto crust.',
      'Bake at 160°C for 45 mins.',
      'Cool completely before serving.',
    ],
  ),
  Recipe(
    id: 4,
    title: 'Lemon Tart',
    servings: '6 servings',
    time: '20 minutes',
    description:
        'A zesty and refreshing lemon tart with crispy pastry. '
        'Tangy lemon filling with a buttery crust. '
        'Light and perfect for summer.',
    imageAsset: 'assets/images/pinkcake.jpg',
    ingredients: [
      '1 sheet puff pastry',
      '4 lemons (zest & juice)',
      '100 g sugar',
      '3 eggs',
      '50 g butter',
      'Pinch of salt',
    ],
    method: [
      'Preheat oven to 200°C.',
      'Line tart pan with pastry.',
      'Mix lemon juice, zest, sugar, and eggs.',
      'Pour into pastry shell.',
      'Bake for 20 mins until golden.',
      'Serve warm or cold.',
    ],
  ),
];