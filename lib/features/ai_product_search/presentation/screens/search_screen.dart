import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(aiSearchProvider);
    final notifier = ref.read(aiSearchProvider.notifier);
    final imagePath = ref.watch(aiSearchProvider.notifier).currentImagePath;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Product Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (imagePath != null)
                  Stack(
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(File(imagePath)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: notifier.clearImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Describe or take a photo...',
                    prefixIcon: const Icon(
                      Icons.auto_awesome,
                      color: Colors.purple,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.camera,
                        );
                        if (image != null) {
                          notifier.onImageCaptured(image.path);
                        }
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  onChanged: (val) {
                    if (imagePath != null) notifier.clearImage();
                    notifier.onSearchChanged(val);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: searchState.when(
              data: (suggestions) {
                if (suggestions.isEmpty) {
                  return const Center(
                    child: Text(
                      'Start typing or take a photo for AI predictions.',
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = suggestions[index];
                    return ListTile(
                      leading: const Icon(Icons.search),
                      title: Text(suggestion),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Searching for: $suggestion')),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Failed to load predictions: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
