

## Step 1: Conceptualization and Purpose

The idea behind the app was simple yet profound – create a motivational platform that could inspire and encourage.

## Step 2: Setting Up the Project

Before diving in, ensure you have the following installed:

Flutter SDK

A code editor (Visual Studio Code, IntelliJ IDEA, or Android Studio)

A basic understanding of Dart programming language

Start by creating a new Flutter project using the following commands:


```
flutter create daily_motivator
cd daily_motivator
```

Open the project in your preferred code editor.

## Step 3: Designing the Motivation API Class to fetch Quotes:

Create a file called *motivation_api.dart* under *daily_motivator/lib* and past the following code:


```
import 'dart:convert';
import 'package:http/http.dart' as http;

class MotivationApi {
  final String quoteApiUrl;
  final String unsplashAccessKey;

  MotivationApi({required this.quoteApiUrl, required this.unsplashAccessKey});

  Future<Map<String, dynamic>> fetchMotivationalData() async {
    try {
      final response = await http.get(
        Uri.parse(quoteApiUrl),
        headers: {'X-Api-Key': 'YOUR API KEY'}, // Replace with your actual API key
      );

      if (response.statusCode == 200) {
        final motivationalData = response.body;
        return parseMotivationalData(motivationalData);
      } else {
        throw Exception('Failed to load motivational data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching motivational data: $e');
      return {};
    }
  }

  Map<String, dynamic> parseMotivationalData(String motivationalData) {
    final data = json.decode(motivationalData);
    return {'quote': data[0]['quote'], 'author': data[0]['author']};
  }

  Future<String> fetchRandomImageUrl({String query = 'inspirational'}) async {
    try {
      final response = await http.get(
        Uri.parse('<https://api.unsplash.com/photos/random?query=$query&count=1>'),
        headers: {
          'Authorization': 'Client-ID $unsplashAccessKey',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data[0]['urls']['regular'] ?? '';
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching random image: $e');
      return ''; 
    }
  }
}
```

## Step 4: Getting API keys:

To fetch motivational quotes and images, we need API keys for the quotes API and Unsplash API for image.

Visit the following websites to sign up for free API keys:

API Ninjas - Motivational Quotes

Unsplash Developers

Replace the YOUR API KEY string in the above file with the actual API key from API Ninjas

## Step 5: Building the User Interface

Update the *main.dart* file under *daily_motivator/lib* to create the user interface and fetch motivational data

```
import 'package:flutter/material.dart';
import 'motivation_api.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MotivationPage(),
    );
  }
}

class MotivationPage extends StatefulWidget {
  @override
  _MotivationPageState createState() => _MotivationPageState();
}

class _MotivationPageState extends State<MotivationPage> {
  late MotivationApi motivationApi;
  String quote = '';
  String author = '';
  String backgroundImageUrl = '';
  bool isLoading = true;
  int refreshCount = 0;
  DateTime? nextRefreshTime;

  @override
  void initState() {
    super.initState();
    motivationApi = MotivationApi(
      quoteApiUrl: '<https://api.api-ninjas.com/v1/quotes?category=happiness>',
      unsplashAccessKey: 'YOUR UNSPLASH ACCESS KEY',
    );
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Check if refresh limit is reached
      if (isRefreshAllowed()) {
        final motivationalData = await motivationApi.fetchMotivationalData();
        final imageUrl = await motivationApi.fetchRandomImageUrl(query: 'inspirational');

        setState(() {
          quote = motivationalData['quote'] ?? '';
          author = motivationalData['author'] ?? 'Unknown';
          backgroundImageUrl = imageUrl;
          isLoading = false;
          refreshCount++;
          updateNextRefreshTime();
        });
      } else {
        // Show a message or handle as per your requirement
        print("That's enough motivation for today my love. now get back to work :P");
      }
    } catch (e) {
      // Handle the error
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching data. Please try again.'),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isRefreshAllowed() {
    // Limit to 3 refreshes
    return refreshCount < 3;
  }

  void updateNextRefreshTime() {
    // Set next refresh time to 5 AM IST
    nextRefreshTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 5, 0, 0).add(Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Inspos - For My Wifey ❤️'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (backgroundImageUrl.isNotEmpty)
            Image.network(
              backgroundImageUrl,
              fit: BoxFit.cover,
            ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (quote.isNotEmpty)
                    Column(
                      children: [
                        Text(
                          quote,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          '- $author',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchData,
        child: Icon(Icons.refresh),
      ),
    );
  }
}

```

## Step 6: Run and Test the App

Ensure your Flutter emulator or connected device is running, then execute:

```
flutter run
```

## Step 7: Build the APK file to be installed on the Android phone:

Run the following command in terminal:
```
flutter build apk --debug
```

This will create an APK file under *daily_motivator/build/app/outputs/apk/debug*

the API to the Android device and allow installation of apk from unknown source under settings on the phone

That’s it. The app should fetch motivational quotes along with the author and nice background images automatically for daily inspiration.

## Further Improvements:

You can customize the app icon with a custom png.

You can update the print statement for the rate limit message with a pop-up to display on the app.

## Conclusion: Crafting Love into Code

I hope you've enjoyed this journey as much as I did. As I embark on this new chapter of life as a husband, it's heartening to channel my creativity into crafting apps that bring joy and motivation to my wife's daily routine.

The process of building this app has been a delightful fusion of technology and love.

Remember that coding isn't just about creating software; it's about crafting experiences, memories, and, in this case, motivation wrapped in a digital embrace. Here's to the joy of coding, the love we infuse into our creations, and the boundless possibilities of the future.

Happy coding, and may your apps bring as much joy to your loved ones as this motivation app has brought to mine!
