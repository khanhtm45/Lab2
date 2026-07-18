import 'package:flutter/material.dart';

import '../l10n/strings_extension.dart';
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
    final s = context.strings;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Text('$rank')),
        title: Text(
          paper.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(s.yearJournal(paper.year, paper.journal)),
        trailing: Text(
          '${formatOpenAlexCount(paper.citations)}\n${s.citations.toLowerCase()}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: onTap,
      ),
    );
  }
}
