import 'package:flutter/material.dart';

import '../models/publication.dart';
import '../utils/count_format.dart';

class TopPaperListTile extends StatelessWidget {
  final int rank;
  final Publication paper;
  final VoidCallback onTap;

  const TopPaperListTile({
    super.key,
    required this.rank,
    required this.paper,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Text('$rank')),
        title: Text(
          paper.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('Year: ${paper.year} · Journal: ${paper.journal}'),
        trailing: Text(
          '${formatOpenAlexCount(paper.citations)}\ncites',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: onTap,
      ),
    );
  }
}
