import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_dropdown.dart';
import '../colors.dart';
import '../../network/recipe_model.dart';
import 'package:flutter/services.dart';
import '../recipe_card.dart';
import 'recipe_details.dart';
import '../../network/recipe_service.dart';
import 'package:chopper/chopper.dart';
import '../../network/model_response.dart';

class RecipeList extends StatefulWidget {
  const RecipeList({Key? key}) : super(key: key);

  @override
  _RecipeListState createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  static const String prefSearchKey = 'previousSearches';
  late TextEditingController searchTextController;
  final ScrollController _scrollController = ScrollController();
  List<APIHits> currentSearchList = [];
  int currentCount = 0;
  int currentStartPosition = 0;
  int currentEndPosition = 20;
  int pageCount = 20;
  bool hasMore = false;
  bool loading = false;
  bool inErrorState = false;
  List<String> previousSearches = <String>[];

  @override
  void initState() {
    super.initState();
    getPreviousSearches();

    searchTextController = TextEditingController(text: '');
    _scrollController
      ..addListener(() {
        final triggerFetchMoreSize =
            0.7 * _scrollController.position.maxScrollExtent;

        if (_scrollController.position.pixels > triggerFetchMoreSize) {
          if (hasMore &&
              currentEndPosition < currentCount &&
              !loading &&
              !inErrorState) {
            setState(() {
              loading = true;
              currentStartPosition = currentEndPosition;
              currentEndPosition =
                  min(currentStartPosition + pageCount, currentCount);
            });
          }
        }
      });
  }

  void savePreviousSearches() async {
    // Uses the await keyword to wait for an instance of SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    // Saves the list of previous searches using the prefSearchKey key.
    prefs.setStringList(prefSearchKey, previousSearches);
  }

  void getPreviousSearches() async {
    // Use the await keyword to wait for an instance of SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    // Check if a preference for your saved list already exists.
    if (prefs.containsKey(prefSearchKey)) {
      // Get the list of previous searches.
      final searches = prefs.getStringList(prefSearchKey);
      // If the list is not null,
      // set the previous searches,
      // otherwise initialize an empty list.
      if (searches != null) {
        previousSearches = searches;
      } else {
        previousSearches = <String>[];
      }
    }
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildSearchCard(),
            _buildRecipeLoader(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 4,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search),
              // Add onPressed to handle the tap event.
              onPressed: () {
                // Use the current search text to start a search.
                startSearch(searchTextController.text);
                // Hide the keyboard by using the FocusScope class.
                final currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
            ),
            const SizedBox(
              width: 6.0,
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    // Add a TextField to enter your search queries.
                    child: TextField(
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: 'Search'),
                      autofocus: false,
                      // Set the keyboard action to TextInputAction.done.
                      // This closes the keyboard when the user presses
                      // the Done button.
                      textInputAction: TextInputAction.done,
                      // Save the search when the user finishes entering text.
                      onSubmitted: (value) {
                        if (!previousSearches.contains(value)) {
                          previousSearches.add(value);
                          savePreviousSearches();
                        }
                      },
                      controller: searchTextController,
                    ),
                  ),
                  // Create a PopupMenuButton to show previous searches.
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: lightGrey,
                    ),
                    // When the user selects an item from previous searches,
                    // start a new search.
                    onSelected: (String value) {
                      searchTextController.text = value;
                      startSearch(searchTextController.text);
                    },
                    itemBuilder: (BuildContext context) {
                      // Build a list of custom drop-down menus (see widgets/custom_dropdown.dart)
                      // to display previous searches.
                      return previousSearches
                          .map<CustomDropdownMenuItem<String>>(
                        (String value) {
                          return CustomDropdownMenuItem<String>(
                            text: value,
                            value: value,
                            callback: () {
                              setState(
                                () {
                                  // If the X icon is pressed, remove the search
                                  // from the previous searches and close
                                  // the pop-up menu.
                                  previousSearches.remove(value);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                      ).toList();
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void startSearch(String value) {
    // Tell the system to redraw the widgets by calling setState().
    setState(() {
      // Clear the current search list and reset the count,
      // start and end positions.
      currentSearchList.clear();
      currentCount = 0;
      currentEndPosition = pageCount;
      currentStartPosition = 0;
      hasMore = true;
      value = value.trim();
      // Check to make sure the search text hasn???t
      // already been added to the previous search list.
      if (!previousSearches.contains(value)) {
        // Add the search item to the previous search list.
        previousSearches.add(value);
        // Save the new list of previous searches.
        savePreviousSearches();
      }
    });
  }

  Widget _buildRecipeLoader(BuildContext context) {
    // You check there are at least three characters in the search term.
    // You can change this value, but you probably won???t get
    // good results with only one or two characters.
    if (searchTextController.text.length < 3) {
      return Container();
    }
    // FutureBuilder determines the current state of the Future
    // that APIRecipeQuery returns.
    // It then builds a widget that displays asynchronous
    // data while it???s loading.
    return FutureBuilder<Response<Result<APIRecipeQuery>>>(
      // You assign the Future that getRecipeData returns to future.
      future: RecipeService.create().queryRecipes(
          searchTextController.text.trim(),
          currentStartPosition,
          currentEndPosition),
      // builder is required; it returns a widget.
      builder: (context, snapshot) {
        // You check the connectionState. If the state is done,
        // you can update the UI with the results or an error.
        if (snapshot.connectionState == ConnectionState.done) {
          // If there???s an error, return a simple Text element
          // that displays the error message.
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString(),
                  textAlign: TextAlign.center, textScaleFactor: 1.3),
            );
          }
          // If there???s no error, process the query results
          // and add query.hits to currentSearchList.
          loading = false;

          // snapshot.data is now a Response and not a string anymore.
          // The body field is either the Success or Error that you
          // defined above. Extract the value of body into result.
          final result = snapshot.data?.body;
          // If result is an error, return the current list of recipes.
          if (result is Error) {
            // Hit an error
            inErrorState = true;
            return _buildRecipeList(context, currentSearchList);
          }
          // Since result passed the error check,
          // cast it as Success and extract its value into query.
          final query = (result as Success).value;

          inErrorState = false;
          if (query != null) {
            currentCount = query.count;
            hasMore = query.more;
            currentSearchList.addAll(query.hits);
            // If you aren???t at the end of the data,
            // set currentEndPosition to the current location.
            if (query.to < currentEndPosition) {
              currentEndPosition = query.to;
            }
          }
          // Return _buildRecipeList() using currentSearchList.
          return _buildRecipeList(context, currentSearchList);
        }
        // You check that snapshot.connectionState isn???t done.
        else {
          // If the current count is 0, show a progress indicator.
          if (currentCount == 0) {
            // Show a loading indicator while waiting for the recipes
            return const Center(child: CircularProgressIndicator());
          } else {
            // Otherwise, just show the current list.
            return _buildRecipeList(context, currentSearchList);
          }
        }
      },
    );
  }

  // This method returns a widget and takes recipeListContext
  // and a list of recipe hits.
  Widget _buildRecipeList(BuildContext recipeListContext, List<APIHits> hits) {
    // You use MediaQuery to get the device???s screen size.
    // You then set a fixed item height and create two
    // columns of cards whose width is half the device???s width.
    final size = MediaQuery.of(context).size;
    const itemHeight = 310;
    final itemWidth = size.width / 2;
    // You return a widget that???s flexible in width and height.
    return Flexible(
      // GridView is similar to ListView, but it allows for some
      // interesting combinations of rows and columns.
      // In this case, you use GridView.builder()
      // because you know the number of items and you???ll
      // use an itemBuilder.
      child: GridView.builder(
        // You use _scrollController, created in initState(),
        // to detect when scrolling gets to about 70% from the bottom.
        controller: _scrollController,
        // The SliverGridDelegateWithFixedCrossAxisCount delegate
        // has two columns and sets the aspect ratio.
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: (itemWidth / itemHeight),
        ),
        // The length of your grid items depends on the number
        // of items in the hits list.
        itemCount: hits.length,
        // itemBuilder now uses _buildRecipeCard() to return a
        // card for each recipe.
        // _buildRecipeCard() retrieves the recipe from the hits
        // list by using hits[index].recipe.
        itemBuilder: (BuildContext context, int index) {
          return _buildRecipeCard(recipeListContext, hits, index);
        },
      ),
    );
  }

  Widget _buildRecipeCard(
      BuildContext topLevelContext, List<APIHits> hits, int index) {
    // Finds the recipe at the given index.
    final recipe = hits[index].recipe;
    return GestureDetector(
      onTap: () {
        Navigator.push(topLevelContext, MaterialPageRoute(
          builder: (context) {
            return const RecipeDetails();
          },
        ));
      },
      child: recipeCard(recipe),
    );
  }
}
