import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/publication.dart';
import '../providers/publication_provider.dart';
import '../widgets/top_paper_list_tile.dart';
import 'detail_screen.dart';

/// 4.4 Top Influential Papers
class TopPapersScreen extends StatelessWidget {
  const TopPapersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPapers = context.watch<PublicationProvider>().topPapersOpenAlex;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Influential Papers (OpenAlex)'),
      ),
      body: topPapers.isEmpty ? _buildEmptyState() : _buildPaperList(context, topPapers),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('No publications from OpenAlex yet.'),
    );
  }

  Widget _buildPaperList(BuildContext context, List<Publication> topPapers) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: topPapers.length,
      itemBuilder: (context, index) {
        final paper = topPapers[index];
        return TopPaperListTile(
          rank: index + 1,
          paper: paper,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => DetailScreen(publication: paper),
              ),
            );
          },
        );
      },
    );
  }
}
