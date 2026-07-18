import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../firebase/analytics_service.dart';
import '../firebase/crashlytics_service.dart';
import 'keyword_analysis_screen.dart';

/// Keywords/Trend screen - Phân tích 1 keyword nghiên cứu cụ thể
class KeywordsScreen extends StatefulWidget {
  const KeywordsScreen({super.key});

  @override
  State<KeywordsScreen> createState() => _KeywordsScreenState();
}

class _KeywordsScreenState extends State<KeywordsScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  
  List<String> _searchHistory = [];
  bool _isSearching = false;

  // Hot keywords cho IT/CS research
  static const List<String> _hotITKeywords = [
    'Machine Learning',
    'Artificial Intelligence', 
    'Deep Learning',
    'Neural Networks',
    'Computer Vision',
    'Natural Language Processing',
    'Cybersecurity',
    'Blockchain',
    'Internet of Things',
    'Cloud Computing',
    'Edge Computing',
    'Quantum Computing',
    'Data Mining',
    'Big Data Analytics',
    'Software Engineering',
    'Human Computer Interaction',
    'Robotics',
    'Augmented Reality',
    'Virtual Reality',
    'Distributed Systems',
  ];

  @override
  void initState() {
    super.initState();
    CrashlyticsService.recordScreenView('KeywordsScreen');
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadSearchHistory() {
    // Load search history from provider or local storage
    final provider = context.read<PublicationProvider>();
    setState(() {
      _searchHistory = provider.recentSearches
          .map((search) => search.topic)
          .take(5)
          .toList();
    });
  }

  Future<void> _searchKeyword(String keyword) async {
    if (keyword.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      // Log analytics event
      await AnalyticsService.logViewKeyword(keyword);

      // Add to search history
      if (!_searchHistory.contains(keyword)) {
        setState(() {
          _searchHistory.insert(0, keyword);
          if (_searchHistory.length > 5) {
            _searchHistory = _searchHistory.take(5).toList();
          }
        });
      }

      // Navigate to keyword analysis screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KeywordAnalysisScreen(keyword: keyword),
          ),
        );
      }
    } catch (e) {
      CrashlyticsService.recordError(
        e,
        StackTrace.current,
        reason: 'Keyword search failed',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: ${e.toString()}'),
            backgroundColor: context.palette.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header 
            Text(
              'Analysis Keywords',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Explore trends and detailed analysis of IT research keywords.',
              style: TextStyle(
                fontSize: 14,
                color: palette.textSecondary,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: palette.border),
                boxShadow: [
                  BoxShadow(
                    color: palette.textPrimary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Enter a keyword to analyze (e.g., Machine Learning)',
                  prefixIcon: Icon(Icons.search, color: palette.textSecondary),
                  suffixIcon: _isSearching
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(palette.primary),
                            ),
                          ),
                        )
                      : _controller.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _controller.clear();
                                setState(() {});
                              },
                              icon: Icon(Icons.clear, color: palette.textSecondary),
                            )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  hintStyle: TextStyle(color: palette.textSecondary),
                ),
                onSubmitted: _searchKeyword,
                onChanged: (value) => setState(() {}),
              ),
            ),
            
            const SizedBox(height: 28),
            
            // Hot IT Keywords
            Text(
              'Keywords IT/CS Hot',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _hotITKeywords.take(12).map((keyword) {
                return _buildKeywordChip(keyword, palette, isHot: true);
              }).toList(),
            ),
            
            if (_searchHistory.isNotEmpty) ...[
              const SizedBox(height: 28),
              Row(
                children: [
                  Text(
                    'Recent searches',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: palette.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchHistory.clear();
                      });
                    },
                    child: Text(
                      'Delete all',
                      style: TextStyle(
                        fontSize: 12,
                        color: palette.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              ..._searchHistory.map((keyword) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildRecentSearchCard(keyword, palette),
                );
              }),
            ],
            
            const SizedBox(height: 28),
            
            // Quick Analysis Cards
            Text(
              'Quick analysis',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                _buildQuickAnalysisCard(
                  context,
                  'AI/ML Trends',
                  'Artificial Intelligence',
                  Icons.psychology,
                  palette.primary,
                ),
                const SizedBox(width: 12),
                _buildQuickAnalysisCard(
                  context,
                  'Security Trends',
                  'Cybersecurity',
                  Icons.security,
                  palette.secondary,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                _buildQuickAnalysisCard(
                  context,
                  'Blockchain Tech',
                  'Blockchain',
                  Icons.link,
                  palette.accent,
                ),
                const SizedBox(width: 12),
                _buildQuickAnalysisCard(
                  context,
                  'Cloud Computing',
                  'Cloud Computing',
                  Icons.cloud,
                  palette.warning,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeywordChip(String keyword, AppPalette palette, {bool isHot = false}) {
    return GestureDetector(
      onTap: () => _searchKeyword(keyword),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isHot 
              ? palette.primary.withValues(alpha: 0.1)
              : palette.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHot 
                ? palette.primary.withValues(alpha: 0.3) 
                : palette.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isHot) ...[
              Icon(
                Icons.local_fire_department,
                size: 14,
                color: palette.primary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              keyword,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isHot ? palette.primary : palette.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearchCard(String keyword, AppPalette palette) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.history,
            size: 16,
            color: palette.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              keyword,
              style: TextStyle(
                fontSize: 14,
                color: palette.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _searchKeyword(keyword),
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: palette.textSecondary,
            ),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAnalysisCard(
    BuildContext context, 
    String title, 
    String keyword,
    IconData icon, 
    Color color,
  ) {
    final palette = context.palette;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _searchKeyword(keyword),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Phân tích $keyword',
                style: TextStyle(
                  fontSize: 11,
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}