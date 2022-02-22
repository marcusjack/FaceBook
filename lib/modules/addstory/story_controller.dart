import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app/layout/layout_controller.dart';
import 'package:social_app/model/storymodel.dart';
import 'package:social_app/shared/constants.dart';

class StoryController extends GetxController {
  SocialLayoutController socialLayoutController =
      Get.find<SocialLayoutController>();
  void onInit() async {
    super.onInit();
    pickStoryImage();
  }

  // NOTE Pick Story image
  File? _storyimage;
  File? get storyimage => _storyimage;
  var picker = ImagePicker();

  Future<void> pickStoryImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _storyimage = File(pickedFile.path);
      //NOTE :upload Story image to firebase storage
      //uploadStoryImage();
      update();
    } else {
      print('no image selected');
    }
  }

// NOTE on click close to remove image from Story
  void removeStoryImage() {
    _storyimage = null;
    // _imagePostUrl = null;
    update();
  }

  // NOTE ------------------- Add Story ------------------------

  Future<void> AddStoryToFireStore(String uId) async {
    StoryModel storyModel = StoryModel(
        storyId: '',
        storyUserId: uId,
        storyName: socialLayoutController.socialUserModel!.name,
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQJiDUsiX6YaPIQ1cWEEehfjPYQjHyjJkMU3Q&usqp=CAU',
        caption: "instagram",
        storyDate: DateTime.now().toString());

    await FirebaseFirestore.instance
        .collection('stories')
        .add(storyModel.toJson())
        .then((value) async {
      print("story inserted in stories collection");
      storyModel.storyId = value.id;
      await FirebaseFirestore.instance
          .collection('stories')
          .doc(value.id)
          .update({'storyId': value.id}).then((value) {
        print("story updated in stories collection");
      });
    });
  }

// NOTE :  upload post image
  bool? _isloadingurlStory = false;
  bool? get isloadingurlStory => _isloadingurlStory;

  String? _imageStoryUrl = null;
  String? get imageStoryUrl => _imageStoryUrl;

  Future<void> uploadStoryImage() async {
    _isloadingurlStory = true;
    update();
    FirebaseStorage.instance
        .ref('')
        .child('Stories/$uId/${Uri.file(_storyimage!.path).pathSegments.last}')
        .putFile(_storyimage!)
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        _imageStoryUrl = value;
        _isloadingurlStory = false;
        update();
      }).catchError((error) {
        {
          print(error.toString());
        }
      });
    }).catchError((error) {
      print(error.toString());
    });
  }
}
