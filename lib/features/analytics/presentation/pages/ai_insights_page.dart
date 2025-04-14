import 'package:flutter/material.dart';

class AiInsightsPage extends StatelessWidget {
  const AiInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /*leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),*/
        title: const Text('AI Insights'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            //TODO Add graph widget
            /*GraphWidget(
              title: 'Account Balance',
              duration: 'Last 30 Days',
              amount: '15,000',
            ),*/
            // Account Balance Section
            const Text(
              "Account Balance",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              "\$15,000",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Last 30 Days +12%",
              style: TextStyle(color: Colors.green, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // How does this work? Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "How does this work?",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  onPressed: () {
                    //TODO Explanation logic
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Search Box
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                hintText: "Search for a scenario",
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // Popular Scenarios Section
            const Text(
              "Popular Scenarios",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Scenario List
            _buildScenarioItem("Hire 2 staff", 3500),
            _buildScenarioItem("Launch new product", 5000),
            _buildScenarioItem("Buy equipment", 1500),

            const SizedBox(height: 20),

            // Chat Input Field
            const TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Type your message here...",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioItem(String title, double cost) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                "Total cost: \$${cost.toStringAsFixed(0)}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          OutlinedButton(
            onPressed: () {
              //TODO Add to forecast logic
            },
            child: const Text("Add to forecast"),
          ),
        ],
      ),
    );
  }
}
