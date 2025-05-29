import 'package:flutter/material.dart';
import 'package:flutter_application_jin/utils/validators/validators.dart';

class ChangePassword extends StatelessWidget {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom AppBar
      appBar: AppBar(
        title: Text(
          'Change password',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headings
            Text(
              'Use real name for easy verification. This name will appear on several pages.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            // Form for text fields
            Form(
              child: Column(
                children: [
                  // First Name Field
                  TextFormField(
                    validator: (value) =>
                        Validators.validateText('email', value),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Last Name Field
                  TextFormField(
                    validator: (value) =>
                        Validators.validateText('Password', value),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    validator: (value) =>
                        Validators.validateText('confirmPassword', value),
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_open),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
