import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  Future<void> _openCheckout(String paymentLink) async {
    final url = Uri.parse(paymentLink);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('Plans')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Choose your plan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Unlock more generations and full continuity tools.', style: TextStyle(color: DripTheme.silver)),
          const SizedBox(height: 24),

          _PlanCard(
            name: 'First Take',
            price: '\$19.99 / month',
            tokens: '300 tokens',
            features: const ['~10\u201315 short clips', 'Basic continuity', 'Standard models'],
            onPressed: () => _openCheckout('https://buy.stripe.com/3cI3cw4nodEefi5feR5AQ01'),
          ),
          const SizedBox(height: 16),

          _PlanCard(
            name: 'Director Mode',
            price: '\$49.99 / month',
            tokens: '1,000 tokens',
            features: const ['~30\u201350 clips', 'Full continuity engine', 'Better models'],
            highlighted: true,
            onPressed: () => _openCheckout('https://buy.stripe.com/4gMfZi8DEfMmb1P4Ad5AQ02'),
          ),
          const SizedBox(height: 16),

          _PlanCard(
            name: 'Full Production',
            price: '\$99.99 / month',
            tokens: '5,000+ tokens',
            features: const ['Heavy usage', 'Priority generation', 'All tools unlocked'],
            onPressed: () => _openCheckout('https://buy.stripe.com/4gMfZi6vw57Id9XeaN5AQ03'),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String price;
  final String tokens;
  final List<String> features;
  final VoidCallback onPressed;
  final bool highlighted;

  const _PlanCard({
    required this.name,
    required this.price,
    required this.tokens,
    required this.features,
    required this.onPressed,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: highlighted ? DripTheme.gunmetalLight : DripTheme.gunmetal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: highlighted ? DripTheme.teal : Colors.transparent, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(fontSize: 18, color: DripTheme.teal)),
          Text(tokens, style: DripTheme.meta),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('\u2022 $f', style: DripTheme.body),
          )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              child: const Text('Get Started'),
            ),
          ),
        ],
      ),
    );
  }
}
