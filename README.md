# Pokémon Lookup App

A simple Flutter application for searching Pokémon using the public [PokéAPI](https://pokeapi.co/).

## Features

- Search for a Pokémon by name (for example, `pikachu`, `treecko`, or `charizard`).
- Retrieves information from the PokéAPI using an HTTP GET request.
- Displays the Pokémon's name, ID, height, weight, abilities, types, and sprite.
- Shows a loading indicator while the request is running.
- Displays an error message for Pokémon that do not exist, network problems, timeouts, unsuccessful server responses, or invalid response data.
- Disables the Search button while a request is in progress to prevent repeated submissions.

## Requirements

- Flutter SDK
- Dart SDK
- Internet connection

## Run the application

1. Open this project folder in Visual Studio Code.
2. Open the terminal in the project folder.
3. Run:

   ```bash
   flutter pub get
   flutter run
   ```

For a browser run, use:

```bash
flutter run -d chrome
```

## How the application works

1. The user enters a Pokémon name in the text field.
2. The app sends an HTTP GET request to:

   `https://pokeapi.co/api/v2/pokemon/{name}`

3. The app checks the HTTP status code before processing the response.
4. When the status code is `200`, `dart:convert` decodes the JSON response and the `Pokemon` model reads the required fields.
5. The interface displays the retrieved Pokémon details and image.

## Error handling

- **Pokémon not found (404):** The app tells the user that the requested Pokémon does not exist.
- **Other unsuccessful HTTP response:** The app displays the returned status code and asks the user to try again.
- **No internet / connection failure:** The app informs the user that it cannot connect and suggests checking the connection.
- **Timeout:** The app tells the user that the request took too long.
- **Invalid or unexpected JSON data:** The app displays a message instead of trying to show incomplete or invalid information.

## Proposed offline strategy

For offline use, previously retrieved Pokémon information could be saved locally on the device after a successful request. If a later request fails because the device has no internet connection, the app could show the saved information and clearly indicate that it is cached and may be outdated. When the connection becomes available again, the user could refresh the Pokémon information from the API.

Local database storage and synchronization are not implemented in this activity; this is only the proposed offline approach.

## API

Data is provided by the [PokéAPI](https://pokeapi.co/).
