import 'package:flutter/material.dart';

class ProfilePictureWidget extends StatelessWidget {
  const ProfilePictureWidget({
    super.key,
    required this.profilePictureURL,
  });

  final String profilePictureURL;

  @override
  Widget build(BuildContext context) {
    if (profilePictureURL.isNotEmpty) {
      return ClipOval(
        child: FadeInImage.assetNetwork(
          fadeInDuration: const Duration(milliseconds: 10),
          placeholder: "assets/placeHolder.png",
          image: profilePictureURL,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
