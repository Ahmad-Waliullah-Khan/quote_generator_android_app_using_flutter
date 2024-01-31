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
      quoteApiUrl: 'https://api.api-ninjas.com/v1/quotes?category=happiness',
      unsplashAccessKey: 'htYRAlDu29QL5o_XVyDe_T9v_nSowTE2V1CxkqE9G0Q',
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
