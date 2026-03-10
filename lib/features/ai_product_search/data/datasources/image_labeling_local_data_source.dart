import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

abstract class ImageLabelingLocalDataSource {
  Future<List<String>> getLabelsFromImage(String imagePath);
}

class ImageLabelingLocalDataSourceImpl implements ImageLabelingLocalDataSource {
  final ImageLabeler imageLabeler;

  ImageLabelingLocalDataSourceImpl({required this.imageLabeler});

  @override
  Future<List<String>> getLabelsFromImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

    return labels.map((label) => label.label).toList();
  }
}
