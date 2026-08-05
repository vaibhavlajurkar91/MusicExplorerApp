import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/album.dart';

/// Fixed-width album tile used in the horizontal album strips.
class AlbumCard extends StatelessWidget {
  final Album album;
  final VoidCallback onTap;

  static const double width = 140;

  const AlbumCard({super.key, required this.album, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: album.artworkUrl100.replaceAll('100x100', '300x300'),
                width: width,
                height: width,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: width,
                  height: width,
                  color: Colors.grey[300],
                  child: const Icon(Icons.album),
                ),
                errorWidget: (context, url, error) => Container(
                  width: width,
                  height: width,
                  color: Colors.grey[300],
                  child: const Icon(Icons.album),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              album.collectionName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (album.releaseDate != null) ...[
              const SizedBox(height: 2),
              Text(
                '${album.releaseDate!.year}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
