import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LocalRecipeCard extends StatefulWidget {
  final String name;
  final String imageUrl;

  const LocalRecipeCard({
    Key? key,
    required this.name,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<LocalRecipeCard> createState() => _LocalRecipeCardState();
}

class _LocalRecipeCardState extends State<LocalRecipeCard> {
  bool isLoading = false;
  bool _showSuccessScreen = false;

  Future<void> _sendLocalRecipes(String drinkName) async {
    setState(() {
      isLoading = true;
    });

    const String apiUrl = 'http://192.168.0.65:3001/simulateScanner';
    final Uri uri = Uri.parse('$apiUrl?recipe=$drinkName');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          _showSuccessScreen = true;
        });
        // Hide success screen after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          setState(() {
            _showSuccessScreen = false;
          });
        });
      } else {
        _showSnackBar("Failed to start processing: ${response.statusCode}");
      }
    } catch (e) {
      _showSnackBar("Error occurred: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.02),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image with rounded corners
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2B2B2B),
              // border: Border.all(color: const Color(0xFFE9E9E9), width: 0.20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66BCBCBC),
                  offset: Offset(0, 5),
                  blurRadius: 15,
                ),
              ],
              borderRadius: BorderRadius.circular(32),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32.0),
              child: Image.asset(
              widget.imageUrl,
              height: screenHeight * 0.16,
              width: screenWidth * 0.4,
              fit: BoxFit.cover,
            ),

            ),
            
          ),
          SizedBox(height: screenHeight * 0.01),
          // Recipe name
          Text(
            widget.name,
            style: Theme.of(context).primaryTextTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.01),
          // Make button
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    _sendLocalRecipes(widget.name);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.14,
                vertical: 6,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0E0E0E),
                    ),
                  )
                : Text(
                    'Make',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          color: const Color(0xFF0E0E0E),
                          fontWeight: FontWeight.w400,
                        ),
                  ),
          ),
          if (_showSuccessScreen)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Recipe started successfully!',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }
}
