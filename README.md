# Ray Wenderlich Flutter Apprentice 2nd Edition

## Chapter 9 - Shared Preferences
- There are multiple ways to save data in an app: to files, in shared preferences and to a SQLite database.
- Shared preferences are best used to store simple, key-value pairs of primitive types like strings, numbers and Booleans.
- An example of when to use shared preferences is to save the tab a user is viewing, so the next time the user starts the app, they’re brought to the same tab.
- The async/await keyword pair let you run asynchronous code off the main UI thread and then wait for the response. An example is getting an instance of SharedPreferences.
- The shared_preferences plugin should not be used to hold sensitive data. Instead, consider using the flutter_secure_storage plugin.

## Chapter 10 - Serialization With JSON
- JSON is an open-standard format used on the web and in mobile clients, especially with REST APIs.
- In mobile apps, JSON code is usually parsed into the model objects that your app will work with.
- You can write JSON parsing code yourself, but it’s usually easier to let a JSON package generate the parsing code for you.
- json_annotation and json_serializable are packages that will let you generate the parsing code.

## Chapter 11 - Networking in Flutter
- The HTTP package is a simple-to-use set of methods for retrieving data from the internet.
- The built-in json.decode transforms JSON strings into a map of objects that you can use in your code.
- FutureBuilder is a widget that retrieves information from a Future.
- GridView is useful for displaying columns of data.
