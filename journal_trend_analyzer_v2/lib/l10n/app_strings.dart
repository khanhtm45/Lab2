import '../services/app_preferences.dart';

/// Lightweight EN / VI strings wired to [AppPreferences.language].
class AppStrings {
  final AppLanguage language;

  const AppStrings(this.language);

  bool get isVietnamese => language == AppLanguage.vietnamese;

  String _t(String en, String vi) => isVietnamese ? vi : en;

  // App shell
  String get appTitle => _t('Journal Trend Analyzer', 'Phân tích Xu hướng Tạp chí');
  String get tabHome => _t('Home', 'Trang chủ');
  String get tabJournal => _t('Journal', 'Tạp chí');
  String get tabTrend => _t('Trend', 'Xu hướng');
  String get tabAnalysis => _t('Analysis', 'Phân tích');
  String get tabProfile => _t('Profile', 'Hồ sơ');

  // Home — new dashboard strings
  String get goodMorning  => _t('Good morning', 'Chào buổi sáng');
  String get goodAfternoon => _t('Good afternoon', 'Chào buổi chiều');
  String get goodEvening  => _t('Good evening', 'Chào buổi tối');
  String get researcherGreeting => _t('Researcher 👋', 'Nhà nghiên cứu 👋');
  String get quickStats => _t('Quick Statistics', 'Thống kê nhanh');
  String get latestPublications => _t('Latest Publications', 'Bài báo mới nhất');
  String get seeAll => _t('See All', 'Xem tất cả');
  String get researchHighlights => _t('Research Highlights', 'Điểm nổi bật');
  String get newestPaper => _t('Newest Paper', 'Bài báo mới nhất');
  String get mostInfluential => _t('Most Influential', 'Ảnh hưởng nhất');
  String get trendingJournal => _t('Trending Journal', 'Tạp chí xu hướng');
  String get trendingTopic => _t('Trending Topic', 'Chủ đề xu hướng');
  String get latestUpdates => _t('Latest Updates', 'Cập nhật mới nhất');
  String get recommendedResearch => _t('Recommended Research', 'Nghiên cứu gợi ý');
  String get trendingKeyword => _t('Trending Keyword', 'Từ khóa xu hướng');
  String get searchPublications => _t('Search Publications', 'Tìm bài báo');

  // Journal screen strings
  String get searchJournals => _t('Search Journals', 'Tìm tạp chí');
  String get searchJournalHint => _t('Search by name, ISSN, publisher…', 'Tìm theo tên, ISSN, nhà xuất bản…');
  String get popularJournals => _t('Popular Journals', 'Tạp chí phổ biến');
  String get recentJournalSearches => _t('Recent', 'Gần đây');
  String get noJournalResultsYet => _t('Search for a journal to begin', 'Tìm tạp chí để bắt đầu');
  String get noJournalResultsSubtitle => _t('Try journal name, topic, or publisher', 'Thử tên tạp chí, chủ đề hoặc nhà xuất bản');
  String get country => _t('Country', 'Quốc gia');
  String get hIndex => _t('H-Index', 'Chỉ số H');
  String get sjr => _t('SJR', 'SJR');
  String get quartile => _t('Quartile', 'Bậc tứ phân vị');
  String get openAccessLabel => _t('Open Access', 'Truy cập mở');
  String get addedToFavorites => _t('Added to favorites', 'Đã thêm vào yêu thích');
  String get removedFromFavorites => _t('Removed from favorites', 'Đã xóa khỏi yêu thích');

  // Volume detail
  String get volumes => _t('Volumes', 'Tập');
  String get recentVolumes => _t('Recent Volumes', 'Tập gần đây');
  String volumeLabel(int n) => _t('Volume $n', 'Tập $n');
  String issueLabel(int n) => _t('$n Issues', '$n Số');
  String get loadingVolumes => _t('Loading volumes…', 'Đang tải tập…');
  String get noVolumesFound => _t('No volumes found', 'Không có tập nào');
  String get papersInVolume => _t('Papers in Volume', 'Bài báo trong tập');

  // Trend screen — new keyword dashboard
  String get trendAnalysis => _t('Trend Analysis', 'Phân tích xu hướng');
  String get enterKeywordHint => _t('Enter a keyword to analyze…', 'Nhập từ khóa để phân tích…');
  String get analyzeButton => _t('Analyze', 'Phân tích');
  String get trendEmptyTitle => _t('Discover Research Trends', 'Khám phá xu hướng nghiên cứu');
  String get trendEmptySubtitle => _t('Enter a keyword above to see publication trends, citations, rankings, and more.', 'Nhập từ khóa để xem xu hướng công bố, trích dẫn, xếp hạng và nhiều hơn.');
  String get dashboardFor => _t('Dashboard for', 'Bảng điều khiển cho');
  String get authorRanking => _t('Author Ranking', 'Xếp hạng tác giả');
  String get journalRanking => _t('Journal Ranking', 'Xếp hạng tạp chí');
  String get countryRanking => _t('Country Ranking', 'Xếp hạng quốc gia');
  String get institutionRanking => _t('Institution Ranking', 'Xếp hạng tổ chức');
  String get topKeywordsChart => _t('Top Keywords', 'Từ khóa hàng đầu');
  String get emergingKeywords => _t('Emerging Keywords', 'Từ khóa mới nổi');
  String get keywordCooccurrence => _t('Keyword Co-occurrence', 'Đồng xuất hiện từ khóa');
  String get citationVelocity => _t('Citation Velocity', 'Tốc độ trích dẫn');
  String get researchFrontier => _t('Research Frontier', 'Biên giới nghiên cứu');
  String get rankingsTab => _t('Rankings', 'Xếp hạng');
  String get chartsTab => _t('Charts', 'Biểu đồ');
  String get topInstitution => _t('Top Institution', 'Tổ chức hàng đầu');
  String get topCountry => _t('Top Country', 'Quốc gia hàng đầu');

  // Home
  String get exploreResearchTrends => _t('Explore Research Trends', 'Khám phá Xu hướng Nghiên cứu');
  String get homeSubtitle => _t(
        'Search publications, journals, authors, and emerging topics.',
        'Tìm bài báo, tạp chí, tác giả và chủ đề mới nổi.',
      );
  String get popularTopics => _t('Popular Topics', 'Chủ đề phổ biến');
  String get recentSearches => _t('Recent Searches', 'Tìm kiếm gần đây');
  String get searchHint => _t('Search a research topic…', 'Tìm chủ đề nghiên cứu…');

  // Search states
  String get searchResults => _t('Search Results', 'Kết quả tìm kiếm');
  String get noPublicationsFound => _t('No publications found', 'Không tìm thấy bài báo');
  String get emptySearchHint => _t(
        'Try using another research topic or adjust your filters.',
        'Thử chủ đề khác hoặc điều chỉnh bộ lọc.',
      );
  String get suggestedTopics => _t('Suggested topics', 'Gợi ý chủ đề');
  String get clearFilters => _t('Clear Filters', 'Xóa bộ lọc');
  String get backToSearch => _t('Back to Search', 'Quay lại tìm kiếm');
  String get retry => _t('Retry', 'Thử lại');
  String get backToHome => _t('Back to Home', 'Về trang chủ');
  String get connectionError => _t('Connection error', 'Lỗi kết nối');
  String get unableToLoadPublications => _t(
        'Unable to load publications',
        'Không thể tải bài báo',
      );
  String get checkConnectionHint => _t(
        'Please check your internet connection or try again in a moment.',
        'Kiểm tra kết nối mạng hoặc thử lại sau.',
      );
  String get couldNotLoadData => _t(
        'Could not load data from OpenAlex.',
        'Không thể tải dữ liệu từ OpenAlex.',
      );

  // Settings
  String get settings => _t('Settings', 'Cài đặt');
  String get appearance => _t('Appearance', 'Giao diện');
  String get languageSection => _t('Language', 'Ngôn ngữ');
  String get lightMode => _t('Light Mode', 'Sáng');
  String get darkMode => _t('Dark Mode', 'Tối');
  String get systemDefault => _t('System Default', 'Theo hệ thống');
  String get english => _t('English', 'Tiếng Anh');
  String get vietnamese => _t('Vietnamese', 'Tiếng Việt');

  // Profile
  String get openAlexConfig => _t('OpenAlex API Configuration', 'Cấu hình OpenAlex API');
  String get recentSearchesMenu => _t('Recent Searches', 'Tìm kiếm gần đây');
  String get about => _t('About', 'Giới thiệu');

  // Explore / Analytics
  String get explore => _t('Explore', 'Khám phá');
  String get biCatalog => _t('BI Catalog (30 items)', 'Danh mục BI (30 biểu đồ)');
  String get openAllCharts => _t('Open All Charts', 'Mở tất cả biểu đồ');
  String get loadingExtendedMetrics => _t(
        'Loading extended metrics…',
        'Đang tải số liệu mở rộng…',
      );
  String get analyticsLoadFailed => _t(
        'Some advanced metrics failed to load.',
        'Một số số liệu nâng cao tải thất bại.',
      );
  String get chartLoadFailed => _t(
        'Could not load chart data from OpenAlex.',
        'Không thể tải dữ liệu biểu đồ từ OpenAlex.',
      );
  String get noDistributionData => _t('No distribution data', 'Không có dữ liệu phân bố');
  String get openAccess => _t('Open Access', 'Truy cập mở');
  String get nonOa => _t('Non-OA', 'Không OA');

  // Trend
  String get trends => _t('Trends', 'Xu hướng');
  String get publicationTrend => _t('Publication Trend', 'Xu hướng công bố');
  String get publicationTrendsTitle =>
      _t('Publication Trends', 'Xu hướng công bố');
  String get publicationActivityDefault =>
      _t('Publication activity', 'Hoạt động công bố');
  String publicationActivityFromTo(int from, int to) => _t(
        'Publication activity from $from to $to',
        'Hoạt động công bố từ $from đến $to',
      );
  String publicationsSortedByCitations(String count) => _t(
        '$count publications · sorted by citations',
        '$count bài báo · xếp theo trích dẫn',
      );
  String get topPapers => _t('Top Papers', 'Bài hàng đầu');
  String get citationTrend => _t('Citation Trend', 'Xu hướng trích dẫn');
  String get loadingTrends => _t('Loading trends...', 'Đang tải xu hướng…');
  String get openHomeFirst => _t('Open Home first', 'Mở Trang chủ trước');
  String get noChartData => _t('No chart data.', 'Không có dữ liệu biểu đồ.');
  String get globalResearchOpenAlex => _t('Global research · OpenAlex', 'Nghiên cứu toàn cầu · OpenAlex');
  String get publicationVolume => _t('Publication Volume', 'Khối lượng công bố');
  String get citations => _t('Citations', 'Trích dẫn');
  String get avgCitations => _t('Avg. Citations', 'TB trích dẫn');
  String get overTime => _t('Over Time', 'Theo thời gian');
  String get publicationTypeDistribution =>
      _t('Publication Type Distribution', 'Phân bố loại công bố');
  String get openAccessRatio => _t('Open Access Ratio', 'Tỷ lệ Open Access');
  String get languageDistribution => _t('Language Distribution', 'Phân bố ngôn ngữ');
  String get researchMomentum => _t('Research Momentum', 'Động lực nghiên cứu');
  String get periodGrowthVolume =>
      _t('period growth · publication volume', 'tăng trưởng kỳ · khối lượng công bố');
  String get annualGrowth => _t('Annual Growth', 'Tăng trưởng hàng năm');
  String get peakYear => _t('Peak Year', 'Năm đỉnh');
  String get yearlyBreakdown => _t('Yearly Breakdown', 'Chi tiết theo năm');
  String countPerYear(String metric) =>
      _t('Count per year · $metric', 'Số lượng theo năm · $metric');
  String get metricPublications => _t('publications', 'bài báo');
  String get metricTotalCitations => _t('total citations', 'tổng trích dẫn');
  String get metricAvgCitations => _t('avg citations', 'TB trích dẫn');
  String get period5Y => _t('5Y', '5N');
  String get period10Y => _t('10Y', '10N');
  String get periodAll => _t('All', 'Tất cả');

  // Explore
  String get exploreSubtitle =>
      _t('Discover research ecosystems · OpenAlex', 'Khám phá hệ sinh thái nghiên cứu · OpenAlex');
  String get advancedBiAnalytics => _t('Advanced BI Analytics', 'Phân tích BI nâng cao');
  String get thirtyVisualizations => _t('30 visualizations', '30 biểu đồ');
  String get biAnalyticsDesc => _t(
        'Publication trend, scatter, treemap, heatmap, network… from OpenAlex API.',
        'Xu hướng, scatter, treemap, heatmap, network… từ OpenAlex API.',
      );
  String get trendingTopics => _t('Trending Topics', 'Chủ đề đang hot');
  String get researchDomains => _t('Research Domains', 'Lĩnh vực nghiên cứu');
  String get domainHierarchy => _t('Domain → Field → Subfield', 'Lĩnh vực → Ngành → Chuyên ngành');
  String get domainBrowseDesc => _t(
        'Browse OpenAlex concept hierarchy and field distribution.',
        'Duyệt phân cấp concept và phân bố ngành từ OpenAlex.',
      );
  String get openResearchDomains => _t('Open Research Domains', 'Mở Lĩnh vực nghiên cứu');
  String get keywordNetwork => _t('Keyword Network', 'Mạng từ khóa');
  String get keywordsAndTopics => _t('Keywords & Topics', 'Từ khóa & Chủ đề');
  String get loadingKeywordNetwork =>
      _t('Loading keyword network...', 'Đang tải mạng từ khóa…');
  String get topicComparison => _t('Topic Comparison', 'So sánh chủ đề');
  String get comparingTopics => _t('Comparing topics...', 'Đang so sánh chủ đề…');
  String get publicationsLabel => _t('Publications', 'Bài báo');
  String get avgCitationsLabel => _t('Avg. Citations', 'TB trích dẫn');
  String get topAuthors => _t('Top Authors', 'Tác giả hàng đầu');
  String get topJournals => _t('Top Journals', 'Tạp chí hàng đầu');
  String get compareTopics => _t('Compare Topics', 'So sánh chủ đề');
  String get compareTopicsSubtitle => _t(
        'Pick two topics to compare publications, citations, leading country and journal.',
        'Chọn hai chủ đề để so sánh bài báo, trích dẫn, quốc gia và tạp chí hàng đầu.',
      );
  String get compareCustomTopics =>
      _t('Custom comparison', 'So sánh tùy chọn');
  String get topicA => _t('Topic A', 'Chủ đề A');
  String get topicB => _t('Topic B', 'Chủ đề B');
  String get compareSameTopicError =>
      _t('Please choose two different topics.', 'Vui lòng chọn hai chủ đề khác nhau.');
  String get peakPublicationYear =>
      _t('Peak publication year', 'Năm xuất bản đỉnh');
  String get leadingJournal => _t('Leading Journal', 'Tạp chí dẫn đầu');
  String get featuredCharts => _t('Featured charts', 'Biểu đồ nổi bật');
  String get openChart => _t('Open chart', 'Mở biểu đồ');

  // Bookmarks
  String get bookmarkedTopics => _t('Saved Topics', 'Chủ đề đã lưu');
  String get noBookmarkedTopics => _t(
        'Bookmark topics from search or popular chips to access them quickly.',
        'Lưu chủ đề từ tìm kiếm hoặc chip phổ biến để truy cập nhanh.',
      );
  String get bookmarkTopic => _t('Save topic', 'Lưu chủ đề');
  String get unbookmarkTopic => _t('Remove saved topic', 'Bỏ lưu chủ đề');

  // Share / export
  String get shareSummary => _t('Share summary', 'Chia sẻ tóm tắt');
  String get summaryCopied =>
      _t('Summary copied to clipboard', 'Đã sao chép tóm tắt vào clipboard');
  String get generatedBy => _t('Generated by', 'Tạo bởi');
  String get shareFooter => _t(
        'Data source: OpenAlex · Journal Trend Analyzer',
        'Nguồn: OpenAlex · Journal Trend Analyzer',
      );

  // Dashboard
  String get researchDashboard => _t('Research Dashboard', 'Bảng điều khiển nghiên cứu');
  String get loadingResearchData => _t('Loading research data...', 'Đang tải dữ liệu nghiên cứu…');
  String get dashboardInsightsSubtitle => _t(
        'Insights based on selected OpenAlex publications',
        'Thống kê từ các bài báo OpenAlex đã chọn',
      );
  String get totalPublications => _t('Total Publications', 'Tổng bài báo');
  String get averageCitations => _t('Average Citations', 'Trích dẫn trung bình');
  String get mostActiveYear => _t('Most Active Year', 'Năm hoạt động nhất');
  String get growthRate => _t('Growth Rate', 'Tốc độ tăng trưởng');
  String get viewFullTrendAnalysis =>
      _t('View Full Trend Analysis', 'Xem phân tích xu hướng đầy đủ');
  String get keyResearchLeaders => _t('Key Research Leaders', 'Tác giả & tạp chí nổi bật');
  String get topJournal => _t('Top Journal', 'Tạp chí hàng đầu');
  String get topAuthor => _t('Top Author', 'Tác giả hàng đầu');
  String get mostInfluentialPaper => _t('Most Influential Paper', 'Bài báo ảnh hưởng nhất');
  String get yearRange => _t('Year Range', 'Khoảng năm');
  String get fromYear => _t('From', 'Từ');
  String get toYear => _t('To', 'Đến');
  String get apply => _t('Apply', 'Áp dụng');
  String yearRangeLabel(int from, int to) => _t('Years $from–$to', 'Năm $from–$to');
  String citationCountLabel(String formatted) =>
      _t('$formatted citations', '$formatted trích dẫn');

  // Common actions
  String get cancel => _t('Cancel', 'Hủy');
  String get clear => _t('Clear', 'Xóa');
  String get clearAll => _t('Clear all', 'Xóa tất cả');
  String get reset => _t('Reset', 'Đặt lại');
  String get none => _t('None', 'Không có');
  String get active => _t('Active', 'Đang hoạt động');
  String get notSet => _t('Not set', 'Chưa cấu hình');
  String get na => _t('N/A', 'N/A');
  String get loaded => _t('Loaded', 'Đã tải');
  String get live => _t('Live', 'Trực tiếp');
  String get unavailable => _t('Unavailable', 'Không khả dụng');
  String get name => _t('Name', 'Tên');
  String get topic => _t('Topic', 'Chủ đề');
  String topicLabel(String t) => _t('Topic: $t', 'Chủ đề: $t');
  String yearLabel(int year) => _t('Year $year', 'Năm $year');
  String yearColon(int year) => _t('Year: $year', 'Năm: $year');
  String publishedInYear(int year) => _t('Published in $year', 'Xuất bản năm $year');
  String peakYearValue(int year) => _t('$year Peak Year', 'Năm đỉnh $year');

  // Splash
  String get splashTagline => _t('Explore • Analyze • Discover', 'Khám phá • Phân tích • Khám phá');
  String get poweredByOpenAlex => _t('Powered by OpenAlex', 'Dữ liệu từ OpenAlex');

  // Search / Journal tab
  String get journal => _t('Journal', 'Tạp chí');
  String get journals => _t('Journals', 'Tạp chí');
  String get searchBrowseSubtitle =>
      _t('Search and browse academic publications.', 'Tìm kiếm và duyệt bài báo học thuật.');
  String get searchResearchTopic => _t('Search a research topic', 'Tìm chủ đề nghiên cứu');
  String get searchFromHomeHint => _t(
        'Use Home or tap the search bar above to explore publications.',
        'Dùng Trang chủ hoặc chạm thanh tìm kiếm phía trên để khám phá bài báo.',
      );
  String get researchTopic => _t('Research Topic', 'Chủ đề nghiên cứu');
  String get trendingResearchAreas => _t('Trending Research Areas', 'Lĩnh vực nghiên cứu đang hot');
  String get searchingPublications =>
      _t('Searching publications…', 'Đang tìm bài báo…');
  String get noPublicationsMatch => _t(
        'No publications match your search and filters.',
        'Không có bài báo phù hợp với tìm kiếm và bộ lọc.',
      );
  String get loadMorePublications =>
      _t('Load more publications', 'Tải thêm bài báo');
  String showingPublications(int shown, int total) =>
      _t('Showing $shown of $total publications', 'Hiển thị $shown / $total bài báo');
  String publicationsFound(String formatted) =>
      _t('$formatted publications found', 'Tìm thấy $formatted bài báo');
  String get loadMore => _t('Load more', 'Tải thêm');
  String get analyzingPublications =>
      _t('Analyzing research publications…', 'Đang phân tích bài báo…');
  String get openAlexRequestFailed =>
      _t('OpenAlex API request failed', 'Yêu cầu OpenAlex API thất bại');
  String errorCode(int code) => _t('Error code: $code', 'Mã lỗi: $code');

  // Search filters
  String get filterPublications => _t('Filter Publications', 'Lọc bài báo');
  String get publicationYear => _t('Publication Year', 'Năm xuất bản');
  String get sortBy => _t('Sort By', 'Sắp xếp theo');
  String get publicationType => _t('Publication Type', 'Loại công bố');
  String get showOpenAccessOnly => _t(
        'Show open access publications only',
        'Chỉ hiển thị bài truy cập mở',
      );
  String get applyFilters => _t('Apply Filters', 'Áp dụng bộ lọc');
  String get sortRelevance => _t('Relevance', 'Liên quan');
  String get sortMostCited => _t('Most Cited', 'Trích dẫn nhiều');
  String get sortNewest => _t('Newest', 'Mới nhất');
  String get sortOldest => _t('Oldest', 'Cũ nhất');
  String get sortAlphabetical => _t('A-Z', 'A-Z');
  String get typeArticle => _t('Article', 'Bài báo');
  String get typeReview => _t('Review', 'Review');
  String get typePreprint => _t('Preprint', 'Preprint');
  String get typeDataset => _t('Dataset', 'Dataset');
  String get typeBookChapter => _t('Book Chapter', 'Chương sách');
  String get typeBook => _t('Book', 'Sách');
  String get typeProceedings => _t('Proceedings Article', 'Bài hội nghị');
  String get unknownType => _t('Unknown', 'Không rõ');

  // Settings extras
  String get searchPreferences => _t('Search Preferences', 'Tùy chọn tìm kiếm');
  String get resultsPerPage => _t('Results Per Page', 'Số kết quả mỗi trang');
  String get defaultSort => _t('Default Sort', 'Sắp xếp mặc định');
  String get defaultTrendPeriod => _t('Default Trend Period', 'Kỳ xu hướng mặc định');
  String get fiveYears => _t('5 Years', '5 năm');
  String get sevenYears => _t('7 Years', '7 năm');
  String get allTime => _t('All Time', 'Toàn thời gian');
  String get dataPreferences => _t('Data Preferences', 'Tùy chọn dữ liệu');
  String get saveRecentSearches => _t('Save Recent Searches', 'Lưu tìm kiếm gần đây');
  String get saveRecentSearchesSubtitle =>
      _t('Store topics locally on this device', 'Lưu chủ đề trên thiết bị này');
  String get clearSearchHistory => _t('Clear Search History', 'Xóa lịch sử tìm kiếm');
  String get clearLocalCache => _t('Clear Local Cache', 'Xóa bộ nhớ đệm');
  String get clearSearchHistoryTitle =>
      _t('Clear search history?', 'Xóa lịch sử tìm kiếm?');
  String get clearSearchHistoryBody => _t(
        'This removes all recent search topics from this device.',
        'Thao tác này xóa tất cả chủ đề tìm kiếm gần đây trên thiết bị.',
      );
  String get searchHistoryCleared =>
      _t('Search history cleared', 'Đã xóa lịch sử tìm kiếm');
  String get clearLocalCacheTitle => _t('Clear local cache?', 'Xóa bộ nhớ đệm?');
  String get clearLocalCacheBody => _t(
        'This reloads analytics data from OpenAlex. Your API key, '
        'settings, and search history will be kept.',
        'Tải lại dữ liệu phân tích từ OpenAlex. API key, cài đặt và '
        'lịch sử tìm kiếm sẽ được giữ.',
      );
  String get localCacheCleared =>
      _t('Local cache cleared', 'Đã xóa bộ nhớ đệm');
  String get preferences => _t('Preferences', 'Tùy chọn');
  String get account => _t('Account', 'Tài khoản');
  String get data => _t('Data', 'Dữ liệu');
  String get information => _t('Information', 'Thông tin');
  String get profile => _t('Profile', 'Hồ sơ');
  String get privacyAndDataSource =>
      _t('Privacy & Data Source', 'Quyền riêng tư & Nguồn dữ liệu');
  String get aboutApplication => _t('About Application', 'Giới thiệu ứng dụng');
  String get aiCodeReviewReport =>
      _t('AI Code Review Report', 'Báo cáo review code AI');
  String get defaultResultsPerPage =>
      _t('Default Results per Page', 'Số kết quả mặc định');
  String get defaultTrendRange =>
      _t('Default Trend Range', 'Khoảng xu hướng mặc định');
  String versionLabel(String version) => _t('Version $version', 'Phiên bản $version');

  // Recent searches
  String get noRecentSearchesYet =>
      _t('No recent searches yet.', 'Chưa có tìm kiếm gần đây.');
  String get recentSearchesCleared =>
      _t('Recent searches cleared', 'Đã xóa tìm kiếm gần đây');
  String searchedMinutesAgo(int n) => _t(
        'searched $n ${n == 1 ? 'minute' : 'minutes'} ago',
        'đã tìm $n phút trước',
      );
  String searchedHoursAgo(int n) => _t(
        'searched $n ${n == 1 ? 'hour' : 'hours'} ago',
        'đã tìm $n giờ trước',
      );
  String get searchedYesterday => _t('searched yesterday', 'đã tìm hôm qua');
  String searchedDaysAgo(int n) => _t('searched $n days ago', 'đã tìm $n ngày trước');
  String searchedOnDate(DateTime date) {
    if (isVietnamese) {
      return 'đã tìm ${date.day}/${date.month}/${date.year}';
    }
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'searched ${months[date.month - 1]} ${date.day}';
  }

  // Detail screen
  String get publicationDetail => _t('Publication Detail', 'Chi tiết bài báo');
  String get couldNotOpenLink =>
      _t('Could not open link', 'Không thể mở liên kết');
  String get publicationDetailsCopied =>
      _t('Publication details copied', 'Đã sao chép chi tiết bài báo');
  String get savedToBookmarks => _t('Saved to bookmarks', 'Đã lưu bookmark');
  String get removedFromBookmarks =>
      _t('Removed from bookmarks', 'Đã xóa bookmark');
  String get authors => _t('Authors', 'Tác giả');
  String get abstract => _t('Abstract', 'Tóm tắt');
  String get researchTopics => _t('Research Topics', 'Chủ đề nghiên cứu');
  String get publicationInformation =>
      _t('Publication Information', 'Thông tin xuất bản');
  String get relatedPapers => _t('Related Papers', 'Bài báo liên quan');
  String get showFewerAuthors => _t('Show fewer authors', 'Ẩn bớt tác giả');
  String viewAllAuthors(int n) =>
      _t('View All Authors ($n)', 'Xem tất cả tác giả ($n)');
  String get showLess => _t('Show less', 'Thu gọn');
  String get readMore => _t('Read More', 'Xem thêm');
  String get journalLabel => _t('Journal', 'Tạp chí');
  String get typeLabel => _t('Type', 'Loại');
  String get languageLabel => _t('Language', 'Ngôn ngữ');
  String get englishLanguage => _t('English', 'Tiếng Anh');
  String get available => _t('Available', 'Có');
  String get notAvailable => _t('Not available', 'Không có');
  String get loadingRelatedPapers =>
      _t('Loading related papers...', 'Đang tải bài liên quan…');
  String get noRelatedPapers =>
      _t('No related papers loaded from OpenAlex.', 'Không có bài liên quan từ OpenAlex.');
  String get openDoi => _t('Open DOI', 'Mở DOI');
  String get viewRelatedPapers =>
      _t('View Related Papers', 'Xem bài liên quan');
  String yearJournal(int year, String journal) =>
      _t('Year: $year · Journal: $journal', 'Năm: $year · Tạp chí: $journal');

  // Author / Journal detail
  String get authorProfile => _t('Author Profile', 'Hồ sơ tác giả');
  String get journalDetail => _t('Journal Detail', 'Chi tiết tạp chí');
  String get loadingPublications =>
      _t('Loading publications...', 'Đang tải bài báo…');
  String get loadingAuthorProfile =>
      _t('Loading author profile...', 'Đang tải hồ sơ tác giả…');
  String get loadingJournalData =>
      _t('Loading journal data...', 'Đang tải dữ liệu tạp chí…');
  String get unableToLoadAuthorProfile => _t(
        'Unable to load author profile.',
        'Không thể tải hồ sơ tác giả.',
      );
  String get activeYears => _t('Active Years', 'Số năm hoạt động');
  String get recentPublications =>
      _t('Recent Publications', 'Bài báo gần đây');
  String get noPapersOnOpenAlex =>
      _t('No papers found on OpenAlex.', 'Không tìm thấy bài trên OpenAlex.');
  String noPapersByAuthorInTopic(String topic) => _t(
        'No papers by this author in topic "$topic".',
        'Không có bài của tác giả này trong chủ đề "$topic".',
      );
  String get publicationActivity =>
      _t('Publication Activity', 'Hoạt động công bố');
  String get topPapersFromJournal =>
      _t('Top Papers from This Journal', 'Bài hàng đầu từ tạp chí này');
  String get researchAreas => _t('Research areas', 'Lĩnh vực nghiên cứu');
  String orcidLabel(String id) => 'ORCID $id';
  String openAlexIdLabel(String id) => _t('OpenAlex ID $id', 'OpenAlex ID $id');
  String get viewAllPublications =>
      _t('View All Publications', 'Xem tất cả bài báo');
  String viewAllJournalPublications(String journal) => _t(
        'View All $journal Publications',
        'Xem tất cả bài từ $journal',
      );
  String get publisher => _t('Publisher', 'Nhà xuất bản');
  String get sourceType => _t('Source type', 'Loại nguồn');
  String get issn => _t('ISSN', 'ISSN');

  // Rankings / lists
  String get topInfluentialPapers =>
      _t('Top Influential Papers', 'Bài báo ảnh hưởng nhất');
  String get loadingInfluentialPapers =>
      _t('Loading influential papers...', 'Đang tải bài ảnh hưởng…');
  String get noInfluentialPapers =>
      _t('No influential papers loaded yet.', 'Chưa có bài ảnh hưởng.');
  String get rankedByCitations =>
      _t('Ranked by citation count', 'Xếp theo số trích dẫn');
  String get moreRankedPapers =>
      _t('More Ranked Papers', 'Thêm bài xếp hạng');
  String get topResearchJournals =>
      _t('Top Research Journals', 'Tạp chí nghiên cứu hàng đầu');
  String get loadingJournalRankings =>
      _t('Loading journal rankings...', 'Đang tải xếp hạng tạp chí…');
  String get noJournalRankings =>
      _t('No journal rankings loaded yet.', 'Chưa có xếp hạng tạp chí.');
  String get journalsMostPublications => _t(
        'Journals with the most publications',
        'Tạp chí có nhiều bài báo nhất',
      );
  String get rankedJournals => _t('Ranked Journals', 'Tạp chí xếp hạng');
  String get loadingAuthorRankings =>
      _t('Loading author rankings...', 'Đang tải xếp hạng tác giả…');
  String get noAuthorRankings =>
      _t('No author rankings loaded yet.', 'Chưa có xếp hạng tác giả.');
  String get mostActiveResearchers =>
      _t('Most Active Researchers', 'Nhà nghiên cứu tích cực nhất');
  String get rankedByPublications =>
      _t('Ranked by number of publications', 'Xếp theo số bài báo');
  String get moreRankedAuthors =>
      _t('More Ranked Authors', 'Thêm tác giả xếp hạng');
  String get sortAuthors => _t('Sort Authors', 'Sắp xếp tác giả');
  String get sortJournals => _t('Sort Journals', 'Sắp xếp tạp chí');
  String get mostPublications => _t('Most Publications', 'Nhiều bài nhất');
  String get mostCitations => _t('Most Citations', 'Nhiều trích dẫn nhất');
  String get viewPublications => _t('View Publications', 'Xem bài báo');
  String get noJournalData => _t('No journal data available', 'Không có dữ liệu tạp chí');

  // Insights / Analysis tab
  String get insights => _t('Insights', 'Thống kê');
  String get trendsAndInsights =>
      _t('Trends & research insights', 'Xu hướng & thống kê nghiên cứu');
  String get loadingInsights =>
      _t('Loading insights...', 'Đang tải thống kê…');
  String get papers => _t('Papers', 'Bài báo');
  String get institutions => _t('Institutions', 'Tổ chức');
  String get countries => _t('Countries', 'Quốc gia');
  String get loadDashboardFirst =>
      _t('Load dashboard data first', 'Tải dữ liệu bảng điều khiển trước');
  String get noPapersFound => _t('No papers found', 'Không có bài báo');
  String get noAuthorsFound => _t('No authors found', 'Không có tác giả');
  String get noJournalsFound => _t('No journals found', 'Không có tạp chí');
  String get noDataAvailable => _t('No data available', 'Không có dữ liệu');
  String get fullRankingView => _t('Full ranking view', 'Xem xếp hạng đầy đủ');
  String get openAlexSource => _t('OpenAlex source / journal', 'Nguồn OpenAlex / tạp chí');

  // Year / domain / keywords
  String get loadingYearData =>
      _t('Loading year data...', 'Đang tải dữ liệu năm…');
  String get hotTopicsOpenAlex =>
      _t('Hot topics (OpenAlex)', 'Chủ đề hot (OpenAlex)');
  String get tapTopicToExplore => _t(
        'Tap a topic to explore papers, authors & journals',
        'Chạm chủ đề để xem bài, tác giả & tạp chí',
      );
  String topCitedPapersInYear(int year) =>
      _t('Top Cited Papers in $year', 'Bài trích dẫn nhiều nhất năm $year');
  String get noPapersForYear =>
      _t('No papers loaded for this year.', 'Không có bài cho năm này.');
  String get loadingDomainData =>
      _t('Loading domain data...', 'Đang tải dữ liệu lĩnh vực…');
  String get publicationsInDomain =>
      _t('Publications in this domain', 'Bài báo trong lĩnh vực này');
  String get domainGrowth => _t('Domain growth', 'Tăng trưởng lĩnh vực');
  String get worksTaggedConcept => _t(
        'Works tagged with this OpenAlex concept',
        'Bài gắn với concept OpenAlex này',
      );
  String get noTrendForDomain =>
      _t('No trend data for this domain.', 'Không có xu hướng cho lĩnh vực này.');
  String get mostCitedInDomain =>
      _t('Most cited in this domain', 'Trích dẫn nhiều nhất trong lĩnh vực');
  String get noPapersForDomain =>
      _t('No papers loaded for this domain.', 'Không có bài cho lĩnh vực này.');
  String get mostPublicationsInDomain => _t(
        'Most publications in this domain',
        'Nhiều bài nhất trong lĩnh vực',
      );
  String get noAuthorDataDomain =>
      _t('No author data for this domain.', 'Không có dữ liệu tác giả.');
  String get whereDomainPublishes => _t(
        'Where this domain publishes most',
        'Nơi lĩnh vực công bố nhiều nhất',
      );
  String get noJournalDataDomain =>
      _t('No journal data for this domain.', 'Không có dữ liệu tạp chí.');
  String shareAmongDomains(int n) => _t(
        'Share among top $n domains shown below',
        'Tỷ lệ trong top $n lĩnh vực bên dưới',
      );
  String get loadingKeywordsTopics =>
      _t('Loading keywords and topics...', 'Đang tải từ khóa & chủ đề…');
  String get mostFrequentThemes => _t(
        'Most frequent research themes',
        'Chủ đề nghiên cứu xuất hiện nhiều nhất',
      );
  String get keywordCloud => _t('Keyword Cloud', 'Đám mây từ khóa');
  String get topTopics => _t('Top Topics', 'Chủ đề hàng đầu');
  String get noTopicRankings =>
      _t('No topic rankings loaded yet.', 'Chưa có xếp hạng chủ đề.');
  String get noKeywordsForTopic =>
      _t('No keywords available for this topic.', 'Không có từ khóa cho chủ đề này.');
  String get domainDistribution =>
      _t('Domain Distribution', 'Phân bố lĩnh vực');
  String get byPublicationsOpenAlex => _t(
        'By Publications · OpenAlex concepts',
        'Theo bài báo · concept OpenAlex',
      );
  String get topDomains => _t('Top Domains', 'Lĩnh vực hàng đầu');
  String get noDomainDataYet =>
      _t('No domain data yet.', 'Chưa có dữ liệu lĩnh vực.');
  String get loadingResearchDomains =>
      _t('Loading research domains…', 'Đang tải lĩnh vực nghiên cứu…');
  String get tapDomainToExplore => _t(
        'Tap a domain to explore papers, authors & journals',
        'Chạm lĩnh vực để xem bài, tác giả & tạp chí',
      );

  // Citation leaders / journals analysis
  String get citationLeaders => _t('Citation Leaders', 'Dẫn đầu trích dẫn');
  String get noPapersFromOpenAlex =>
      _t('No papers from OpenAlex', 'Không có bài từ OpenAlex');
  String get noAuthorsFromOpenAlex =>
      _t('No authors from OpenAlex', 'Không có tác giả từ OpenAlex');
  String get noJournalsFromOpenAlex =>
      _t('No journals from OpenAlex', 'Không có tạp chí từ OpenAlex');
  String get publicationSources =>
      _t('Publication Sources', 'Nguồn công bố');
  String get publishers => _t('Publishers', 'Nhà xuất bản');
  String get topJournalsByPublications =>
      _t('Top Journals by Publications', 'Tạp chí theo số bài báo');
  String get barLengthPublicationCount => _t(
        'Bar length = publication count · OpenAlex',
        'Độ dài cột = số bài · OpenAlex',
      );
  String get viewAllJournals => _t('View All Journals', 'Xem tất cả tạp chí');
  String get topPublishingVenues =>
      _t('Top Publishing Venues', 'Địa điểm xuất bản hàng đầu');
  String get groupedByOpenAlexSource => _t(
        'Grouped by OpenAlex source · publication count',
        'Nhóm theo nguồn OpenAlex · số bài',
      );

  // Growth / year activity
  String get publicationsByYear =>
      _t('Publications by Year', 'Bài báo theo năm');
  String get noTrendData => _t('No trend data available', 'Không có dữ liệu xu hướng');
  String get noCitationData =>
      _t('No citation data available', 'Không có dữ liệu trích dẫn');
  String get peakPublications => _t('Peak Publications', 'Bài báo đỉnh');
  String growthSinceYear(int year) =>
      _t('Growth Since $year', 'Tăng trưởng từ $year');
  String get growth => _t('Growth', 'Tăng trưởng');
  String get trendInsight => _t('Trend Insight', 'Nhận xét xu hướng');
  String viewPublicationsFromYear(int year) =>
      _t('View Publications from $year', 'Xem bài năm $year');
  String get researchActivityInYear => _t(
        'Research Activity in {year}',
        'Hoạt động nghiên cứu năm {year}',
      );
  String researchActivityYear(int year) =>
      _t('Research Activity in $year', 'Hoạt động nghiên cứu năm $year');
  String get loadingYearInsights =>
      _t('Loading year insights...', 'Đang tải thống kê năm…');
  String get topResearchArea => _t('Top Research Area', 'Lĩnh vực hàng đầu');
  String topPublicationInYear(int year) =>
      _t('Top Publication in $year', 'Bài hàng đầu năm $year');
  String get noPublicationDataYear => _t(
        'No publication data available for this year.',
        'Không có dữ liệu bài báo cho năm này.',
      );
  String viewAllPublicationsFromYear(int year) => _t(
        'View All Publications from $year',
        'Xem tất cả bài năm $year',
      );

  // OpenAlex config
  String get apiKey => _t('API Key', 'API Key');
  String get pasteApiKey =>
      _t('Paste your OpenAlex API key', 'Dán API key OpenAlex');
  String get keepApiKeyPrivate =>
      _t('Keep your API key private.', 'Giữ API key bí mật.');
  String get testConnection => _t('Test Connection', 'Kiểm tra kết nối');
  String get saveApiKey => _t('Save API Key', 'Lưu API Key');
  String get enterApiKeyToSave =>
      _t('Enter an API key to save', 'Nhập API key để lưu');
  String get apiKeySaved =>
      _t('OpenAlex API key saved', 'Đã lưu API key OpenAlex');
  String get academicDataFromOpenAlex => _t(
        'Academic data is retrieved dynamically from OpenAlex.',
        'Dữ liệu học thuật được lấy động từ OpenAlex.',
      );
  String get openAlexNoResponse => _t(
        'OpenAlex did not respond. Verify your API key.',
        'OpenAlex không phản hồi. Kiểm tra API key.',
      );
  String get apiKeyUsageInfo => _t(
        'Your API key is used only to retrieve academic publication data from OpenAlex.',
        'API key chỉ dùng để lấy dữ liệu bài báo từ OpenAlex.',
      );
  String get testingConnection =>
      _t('Testing connection…', 'Đang kiểm tra kết nối…');
  String get verifyingOpenAlex =>
      _t('Verifying OpenAlex API access', 'Xác minh truy cập OpenAlex API');
  String get connectionSuccessful =>
      _t('Connection successful', 'Kết nối thành công');
  String get openAlexReady =>
      _t('OpenAlex API is ready to use.', 'OpenAlex API sẵn sàng sử dụng.');
  String get connectionFailed =>
      _t('Connection failed', 'Kết nối thất bại');
  String get unableToReachOpenAlex => _t(
        'Unable to reach OpenAlex. Check your API key.',
        'Không kết nối được OpenAlex. Kiểm tra API key.',
      );
  String get noApiKeyConfigured =>
      _t('No API key configured', 'Chưa cấu hình API key');
  String get addKeyForRateLimits => _t(
        'Add a key to improve rate limits and reliability.',
        'Thêm key để cải thiện giới hạn và độ ổn định.',
      );
  String get connectionNotTested =>
      _t('Connection not tested', 'Chưa kiểm tra kết nối');
  String get tapTestConnection => _t(
        'Tap Test Connection to verify your API key.',
        'Chạm Kiểm tra kết nối để xác minh API key.',
      );

  // About
  String get projectInformation =>
      _t('Project Information', 'Thông tin dự án');
  String get course => _t('Course', 'Môn học');
  String get courseValue =>
      _t('PRM393 – Mobile Programming', 'PRM393 – Lập trình Di động');
  String get project => _t('Project', 'Dự án');
  String get projectValue => _t(
        'Lab 2 – Journal Trend Analysis',
        'Lab 2 – Phân tích Xu hướng Tạp chí',
      );
  String get framework => _t('Framework', 'Framework');
  String get frameworkValue => _t('Flutter & Dart', 'Flutter & Dart');
  String get dataSource => _t('Data Source', 'Nguồn dữ liệu');
  String get platform => _t('Platform', 'Nền tảng');
  String get android => _t('Android', 'Android');
  String get developedForAcademic => _t(
        'Developed for academic learning purposes.',
        'Phát triển cho mục đích học tập.',
      );
  String get aboutHeroParagraph => _t(
        'Explore publication trends, citation impact, and research landscapes '
        'powered by OpenAlex.',
        'Khám phá xu hướng công bố, tác động trích dẫn và bức tranh nghiên cứu '
        'từ OpenAlex.',
      );
  String get aiAssistedCodeReview =>
      _t('AI-Assisted Code Review', 'Review code hỗ trợ AI');
  String get codeQualityReviewed => _t(
        'Code quality reviewed using AI-assisted tools.',
        'Chất lượng code được review bằng công cụ AI.',
      );
  String get labVersionFooter => _t(
        'Version 1.0.0 · PRM393 Lab 2 · Powered by OpenAlex.',
        'Phiên bản 1.0.0 · PRM393 Lab 2 · Dữ liệu OpenAlex.',
      );

  // Profile info screens
  String get yourDataAndOpenAlex =>
      _t('Your data & OpenAlex', 'Dữ liệu của bạn & OpenAlex');
  String get privacyParagraph1 => _t(
        'Search topics and preferences are stored locally on your device. '
        'Publication data is fetched from the public OpenAlex API.',
        'Chủ đề tìm kiếm và tùy chọn được lưu cục bộ trên thiết bị. '
        'Dữ liệu bài báo được lấy từ API công khai OpenAlex.',
      );
  String get privacyParagraph2 => _t(
        'No personal account is required. API keys, if provided, are kept '
        'in secure device storage.',
        'Không cần tài khoản cá nhân. API key (nếu có) được lưu an toàn trên thiết bị.',
      );
  String get privacyParagraph3 => _t(
        'OpenAlex is an open catalog of scholarly papers, authors, institutions, '
        'and more.',
        'OpenAlex là danh mục mở về bài báo, tác giả, tổ chức học thuật, v.v.',
      );
  String get aboutParagraph1 => _t(
        'Journal Trend Analyzer helps researchers explore publication trends, '
        'citation impact, and emerging topics using OpenAlex data.',
        'Journal Trend Analyzer giúp khám phá xu hướng công bố, trích dẫn '
        'và chủ đề mới từ dữ liệu OpenAlex.',
      );
  String get aboutParagraph2 => _t(
        'Built with Flutter for PRM393 Lab 2, featuring interactive charts, '
        'search, and research dashboards.',
        'Xây dựng bằng Flutter cho PRM393 Lab 2, với biểu đồ tương tác, '
        'tìm kiếm và bảng điều khiển nghiên cứu.',
      );
  String get aboutParagraph3 => _t(
        'This app demonstrates mobile analytics UX patterns for academic data.',
        'Ứng dụng minh họa UX phân tích dữ liệu học thuật trên di động.',
      );
  String get developmentReviewNotes =>
      _t('Development & review notes', 'Ghi chú phát triển & review');
  String get aiReviewParagraph1 => _t(
        'Parts of this codebase were developed with AI-assisted tooling and '
        'reviewed for structure, readability, and Flutter best practices.',
        'Một phần mã nguồn được phát triển với công cụ AI và review về cấu trúc, '
        'khả năng đọc và best practice Flutter.',
      );
  String get aiReviewParagraph2 => _t(
        'Charts, OpenAlex integration, and navigation were iterated based on '
        'lab requirements and usability feedback.',
        'Biểu đồ, tích hợp OpenAlex và điều hướng được lặp theo yêu cầu lab '
        'và phản hồi người dùng.',
      );
  String get aiReviewParagraph3 => _t(
        'Future work includes expanding localization and additional analytics views.',
        'Hướng phát triển: mở rộng đa ngôn ngữ và thêm biểu đồ phân tích.',
      );

  // Home extras
  String get quickInsights => _t('Quick Insights', 'Thống kê nhanh');
  String get researchOutput => _t('Research output', 'Sản lượng nghiên cứu');
  String get chartsGrowthInsights => _t(
        'Charts, growth trends & domain insights',
        'Biểu đồ, xu hướng tăng trưởng & lĩnh vực',
      );

  // Advanced analytics
  String get advancedAnalytics =>
      _t('Advanced Analytics', 'Phân tích nâng cao');
  String get thirtyBiVisualizations => _t(
        '30 BI Visualizations · OpenAlex',
        '30 biểu đồ BI · OpenAlex',
      );
  String get viewCharts => _t('View Charts', 'Xem biểu đồ');
  String get biAnalyticsCatalog =>
      _t('BI Analytics Catalog', 'Danh mục BI Analytics');
  String get thirtyResearchVisualizations => _t(
        '30 Research Analytics Visualizations',
        '30 biểu đồ phân tích nghiên cứu',
      );
  String get catalogHeroSubtitle => _t(
        'Fact Table × Dimension Table → Display Type · OpenAlex mobile client',
        'Bảng Fact × Dimension → Loại hiển thị · Client OpenAlex',
      );
  String catalogComplete(int n) =>
      _t('$n / 30 Complete', '$n / 30 hoàn thành');
  String get openAlexLive => _t('OpenAlex Live', 'OpenAlex trực tiếp');
  String get topJournalsChart => _t('Top journals', 'Tạp chí hàng đầu');
  String get openAccessMix => _t('Open access mix', 'Tỷ lệ OA');
  String get countryOutput => _t('Country output', 'Sản lượng quốc gia');
  String get totalCitations => _t('Total Citations', 'Tổng trích dẫn');
  String get productivityWorks =>
      _t('Productivity (works)', 'Năng suất (bài)');
  String get impactCitations => _t('Impact (citations)', 'Tác động (trích dẫn)');
  String get collaborationIndex =>
      _t('Collaboration index', 'Chỉ số hợp tác');
  String get collaborationLinks =>
      _t('Collaboration links', 'Liên kết hợp tác');

  // Chart empty states & labels
  String get noData => _t('No data', 'Không có dữ liệu');
  String get notEnoughTimeSeries => _t(
        'Not enough time-series data.',
        'Không đủ dữ liệu chuỗi thời gian.',
      );
  String get noScatterData => _t('No scatter data', 'Không có dữ liệu scatter');
  String get noBubbleData => _t('No bubble data', 'Không có dữ liệu bubble');
  String get insufficientMatrixData =>
      _t('Insufficient matrix data', 'Không đủ dữ liệu ma trận');
  String get searchTopicForKeywords => _t(
        'Search a topic to see related keywords.',
        'Tìm chủ đề để xem từ khóa liên quan.',
      );
  String get notEnoughNetworkData => _t(
        'Not enough network data from OpenAlex sample',
        'Không đủ dữ liệu mạng từ mẫu OpenAlex',
      );
  String get noCountryData => _t('No country data', 'Không có dữ liệu quốc gia');
  String get citationIntensityByCountry => _t(
        'Citation intensity by country',
        'Cường độ trích dẫn theo quốc gia',
      );
  String get researchOutputByCountry => _t(
        'Research output by country',
        'Sản lượng nghiên cứu theo quốc gia',
      );
  String get notEnoughJournalMigration => _t(
        'Not enough journal migration data',
        'Không đủ dữ liệu chuyển tạp chí',
      );
  String get yearJournalFlows => _t(
        'Year → Journal flows (OpenAlex sample, last 5 years)',
        'Luồng Năm → Tạp chí (mẫu OpenAlex, 5 năm gần nhất)',
      );
  String get needMoreNetworkNodes =>
      _t('Need more nodes for network', 'Cần thêm nút cho mạng');
  String get citationImpactMap =>
      _t('Citation impact map', 'Bản đồ tác động trích dẫn');
  String get researchOutputMap =>
      _t('Research output map', 'Bản đồ sản lượng nghiên cứu');
  String get sizeIndex => _t('Size index', 'Chỉ số kích thước');
  String get growthYoy => _t('Growth YoY', 'Tăng trưởng YoY');
  String get volume => _t('Volume', 'Khối lượng');
  String get momentum => _t('Momentum', 'Đà tăng');
  String get works => _t('Works', 'Bài báo');
  String worksCitations(String works, String citations) =>
      _t('Works $works · Citations $citations', 'Bài $works · Trích dẫn $citations');
  String growthYoyValue(String percent) =>
      _t('Growth $percent YoY', 'Tăng trưởng $percent YoY');
  String get count => _t('count', 'số lượng');
  String get statusLive => _t('Live', 'Trực tiếp');
  String get statusPartial => _t('Partial', 'Một phần');
  String get statusPlanned => _t('Planned', 'Kế hoạch');

  // Momentum badges
  String get momentumHigh => _t('HIGH', 'CAO');
  String get momentumMedium => _t('MEDIUM', 'TB');
  String get momentumLow => _t('LOW', 'THẤP');
  String get momentumDeclining => _t('DECLINING', 'GIẢM');
  String trendInsightFallback(String topic, int peakYear) => _t(
        '$topic research shows strong and sustained growth, with '
        'publication activity peaking in $peakYear.',
        'Nghiên cứu $topic tăng trưởng mạnh và bền vững, '
        'đỉnh công bố vào năm $peakYear.',
      );
  String get globalResearch => _t('Global research', 'Nghiên cứu toàn cầu');
  String get globalResearchOverview =>
      _t('Global Research Overview', 'Tổng quan nghiên cứu toàn cầu');
  String get researchPublications =>
      _t('Research publications', 'Bài báo nghiên cứu');

  // Dynamic research insights (ResearchInsights)
  String get insufficientInsightData =>
      _t('Insufficient data', 'Không đủ dữ liệu');
  String get notEnoughOpenAlexInsights => _t(
        'Not enough OpenAlex data to generate insights.',
        'Không đủ dữ liệu OpenAlex để tạo nhận xét.',
      );
  String insightHeadlineStrongGrowth(
    String label,
    String growth,
    int from,
    int to,
  ) =>
      _t(
        '$label grew $growth from $from to $to, signaling strong research momentum.',
        '$label tăng $growth từ $from đến $to, thể hiện động lực nghiên cứu mạnh.',
      );
  String insightHeadlineSteadyGrowth(
    String label,
    String growth,
    int from,
    int to,
  ) =>
      _t(
        '$label shows steady growth ($growth) between $from and $to.',
        '$label tăng trưởng ổn định ($growth) giữa $from và $to.',
      );
  String insightHeadlineCooled(String label, String growth, int from, int to) =>
      _t(
        '$label cooled $growth from $from to $to.',
        '$label giảm $growth từ $from đến $to.',
      );
  String get momentumStrongInsight =>
      _t('Growth remains strong.', 'Tăng trưởng vẫn mạnh.');
  String get momentumModerateInsight => _t(
        'Growth is moderate but sustained.',
        'Tăng trưởng vừa phải nhưng bền vững.',
      );
  String get momentumSlowedInsight =>
      _t('Growth has slowed recently.', 'Tăng trưởng đã chậm lại gần đây.');
  String get momentumContractingInsight =>
      _t('Activity is contracting.', 'Hoạt động đang thu hẹp.');
  String insightSummary(
    String growth,
    int from,
    int to,
    int peak,
    String momentumText,
  ) =>
      _t(
        'Publications changed $growth between $from and $to. '
        'Research activity peaked in $peak. $momentumText',
        'Bài báo thay đổi $growth giữa $from và $to. '
        'Hoạt động nghiên cứu đỉnh năm $peak. $momentumText',
      );
  String get citationDivergenceVolumeUp => _t(
        'Paper volume is rising faster than citations — possible quantity inflation in this field.',
        'Số bài tăng nhanh hơn trích dẫn — có thể do lượng hóa trong lĩnh vực này.',
      );
  String get citationDivergenceQuality => _t(
        'Fewer papers but rising citations — a high-quality, high-impact research signal.',
        'Ít bài hơn nhưng trích dẫn tăng — dấu hiệu nghiên cứu chất lượng cao.',
      );
  String get citationDivergenceBothUp => _t(
        'Both publication volume and citation impact are growing together.',
        'Cả khối lượng công bố và tác động trích dẫn đều tăng.',
      );
  String get influentialPapersLoading => _t(
        'Influential papers will appear once OpenAlex data loads.',
        'Bài ảnh hưởng sẽ hiện khi dữ liệu OpenAlex tải xong.',
      );
  String influentialPapersLandmark(String citations) => _t(
        'Landmark papers with $citations+ citations shape this research landscape.',
        'Bài then chốt với $citations+ trích dẫn định hình lĩnh vực nghiên cứu này.',
      );
  String influentialPapersJournal(String journal) => _t(
        'Citation leaders in $journal drive impact in this field.',
        'Bài dẫn trích dẫn tại $journal thúc đẩy tác động trong lĩnh vực này.',
      );
  String get researchLeadersLoading => _t(
        'Leading researchers appear after OpenAlex aggregates load.',
        'Tác giả hàng đầu sẽ hiện sau khi OpenAlex tổng hợp xong.',
      );
  String researchLeaderLeads(String name, String count) => _t(
        '$name leads with $count publications in this scope.',
        '$name dẫn đầu với $count bài báo trong phạm vi này.',
      );
  String get journalPowerLoading => _t(
        'Top publishing venues will appear from OpenAlex rankings.',
        'Địa điểm xuất bản hàng đầu sẽ hiện từ xếp hạng OpenAlex.',
      );
  String journalPowerDominant(String name) => _t(
        '$name is the dominant publishing venue in this landscape.',
        '$name là địa điểm xuất bản chủ đạo trong bức tranh này.',
      );
  String journalPowerTopTwo(String first, String second) => _t(
        '$first and $second publish the highest volume of influential research.',
        '$first và $second công bố nhiều nghiên cứu ảnh hưởng nhất.',
      );

  // Chart display types
  String get chartLine => _t('Line Chart', 'Biểu đồ đường');
  String get chartHorizontalBar => _t('Horizontal Bar', 'Cột ngang');
  String get chartArea => _t('Area Chart', 'Biểu đồ vùng');
  String get chartTreemap => _t('Treemap', 'Treemap');
  String get chartScatter => _t('Scatter Plot', 'Scatter');
  String get chartBubble => _t('Bubble Chart', 'Bubble');
  String get chartDonut => _t('Donut Chart', 'Donut');
  String get chartNetwork => _t('Network Graph', 'Đồ thị mạng');
  String get chartMap => _t('Map', 'Bản đồ');
  String get chartHeatmap => _t('Heatmap', 'Heatmap');
  String get chartSankey => _t('Sankey Diagram', 'Sankey');
  String get chartDashboard =>
      _t('Interactive Dashboard', 'Dashboard tương tác');

  // Analytics catalog localization
  String catalogName(int no) => switch (no) {
        1 => _t('Publication Trend', 'Xu hướng công bố'),
        2 => _t('Citation Trend', 'Xu hướng trích dẫn'),
        3 => _t('Top Keywords', 'Từ khóa hàng đầu'),
        4 => _t('Emerging Keywords', 'Từ khóa mới nổi'),
        5 => _t('Topic Evolution', 'Tiến hóa chủ đề'),
        6 => _t('Research Landscape', 'Bức tranh nghiên cứu'),
        7 => _t('Author Impact', 'Tác động tác giả'),
        8 => _t('Top Cited Authors', 'Tác giả trích dẫn cao'),
        9 => _t('Author Productivity vs Impact', 'Năng suất vs Tác động tác giả'),
        10 => _t('Institution Ranking', 'Xếp hạng tổ chức'),
        11 => _t('Institution Impact', 'Tác động tổ chức'),
        12 => _t('Country Research Output', 'Sản lượng nghiên cứu quốc gia'),
        13 => _t('Country Citation Impact', 'Trích dẫn theo quốc gia'),
        14 => _t('Journal Ranking', 'Xếp hạng tạp chí'),
        15 => _t('Journal Impact Analysis', 'Phân tích tác động tạp chí'),
        16 => _t('Quartile Distribution', 'Phân bố Quartile'),
        17 => _t('Citation Network', 'Mạng trích dẫn'),
        18 => _t('Author Collaboration', 'Hợp tác tác giả'),
        19 => _t('Institution Collaboration', 'Hợp tác tổ chức'),
        20 => _t('Country Collaboration', 'Hợp tác quốc gia'),
        21 => _t('Keyword Co-occurrence', 'Đồng xuất hiện từ khóa'),
        22 => _t('Topic Co-occurrence', 'Đồng xuất hiện chủ đề'),
        23 => _t('Journal-Topic Matrix', 'Ma trận Tạp chí-Chủ đề'),
        24 => _t('Author-Topic Matrix', 'Ma trận Tác giả-Chủ đề'),
        25 => _t('Institution-Topic Matrix', 'Ma trận Tổ chức-Chủ đề'),
        26 => _t('Country-Topic Matrix', 'Ma trận Quốc gia-Chủ đề'),
        27 => _t('Research Frontier Detection', 'Phát hiện biên giới nghiên cứu'),
        28 => _t('Citation Velocity', 'Tốc độ trích dẫn'),
        29 => _t('Journal Migration', 'Chuyển dịch tạp chí'),
        30 => _t('Research Ecosystem Overview', 'Tổng quan hệ sinh thái'),
        _ => '',
      };

  String catalogDescription(int no) => switch (no) {
        1 => _t('Publications per year', 'Số lượng bài báo theo năm'),
        2 => _t('Total citations per year', 'Tổng citation theo năm'),
        3 => _t('Most frequent keywords', 'Keyword xuất hiện nhiều nhất'),
        4 => _t('Fastest growing keywords', 'Keyword tăng trưởng nhanh nhất'),
        5 => _t('How topics change over time', 'Sự thay đổi của Topic theo thời gian'),
        6 => _t('Research distribution by domain', 'Phân bố nghiên cứu theo các lĩnh vực'),
        7 => _t('Authors with most publications', 'Tác giả có nhiều công bố nhất'),
        8 => _t('Authors with highest citations', 'Tác giả có citation cao nhất'),
        9 => _t('Compare productivity and citations', 'So sánh Productivity và Citation'),
        10 => _t('Institutions ranked by papers', 'Xếp hạng Institution theo số bài'),
        11 => _t('Institution collaboration strength', 'Quan hệ hợp tác giữa tổ chức'),
        12 => _t('Papers by country', 'Số lượng bài báo theo quốc gia'),
        13 => _t('Citations by country', 'Citation theo quốc gia'),
        14 => _t('Journals with most papers', 'Journal có nhiều bài báo nhất'),
        15 => _t('Citation vs publication volume', 'Citation vs SJR vs H-index (proxy)'),
        16 => _t('Q1–Q4 distribution', 'Phân bố Q1–Q4'),
        17 => _t('Citation links between papers', 'Quan hệ trích dẫn giữa các bài báo'),
        18 => _t('Co-author relationships', 'Quan hệ đồng tác giả'),
        19 => _t('Institution collaboration network', 'Mạng hợp tác giữa tổ chức'),
        20 => _t('Country collaboration patterns', 'Quan hệ hợp tác giữa quốc gia'),
        21 => _t('Keywords appearing together', 'Keyword thường xuất hiện cùng nhau'),
        22 => _t('Relationships between topics', 'Quan hệ giữa các topic nghiên cứu'),
        23 => _t('Which journals dominate topics', 'Journal mạnh ở Topic nào'),
        24 => _t('Author expertise by topic', 'Chuyên môn nghiên cứu của tác giả'),
        25 => _t('Institution research strengths', 'Thế mạnh nghiên cứu của tổ chức'),
        26 => _t('Topics by country', 'Chủ đề nghiên cứu theo quốc gia'),
        27 => _t('Detect emerging research topics', 'Phát hiện chủ đề mới nổi'),
        28 => _t('Citation growth speed by topic', 'Tốc độ tăng citation của chủ đề'),
        29 => _t('Publication shifts between journals', 'Xu hướng chuyển dịch công bố giữa các Journal'),
        30 => _t('Full research ecosystem overview', 'Tổng quan toàn bộ hệ sinh thái nghiên cứu'),
        _ => '',
      };

  String catalogFactTable(String key) => switch (key) {
        'Paper' => _t('Paper', 'Bài báo'),
        'PaperKeyword' => _t('PaperKeyword', 'PaperKeyword'),
        'PaperAuthor' => _t('PaperAuthor', 'PaperAuthor'),
        'AuthorInstitution' => _t('AuthorInstitution', 'AuthorInstitution'),
        'Citation' => _t('Citation', 'Trích dẫn'),
        _ => key,
      };

  String catalogDimensionTable(String key) {
    if (key.contains(',')) {
      return key.split(',').map((e) => catalogDimensionTable(e.trim())).join(', ');
    }
    return switch (key) {
      'Time' => _t('Time', 'Thời gian'),
      'Keyword' => _t('Keyword', 'Từ khóa'),
      'Topic' => _t('Topic', 'Chủ đề'),
      'Domain, Field, Topic' => _t('Domain, Field, Topic', 'Lĩnh vực, Ngành, Chủ đề'),
      'Domain' => _t('Domain', 'Lĩnh vực'),
      'Field' => _t('Field', 'Ngành'),
      'Author' => _t('Author', 'Tác giả'),
      'Institution' => _t('Institution', 'Tổ chức'),
      'Country' => _t('Country', 'Quốc gia'),
      'Journal' => _t('Journal', 'Tạp chí'),
      'Keyword, Time' => _t('Keyword, Time', 'Từ khóa, Thời gian'),
      'Topic, Time' => _t('Topic, Time', 'Chủ đề, Thời gian'),
      'Journal, Topic' => _t('Journal, Topic', 'Tạp chí, Chủ đề'),
      'Author, Topic' => _t('Author, Topic', 'Tác giả, Chủ đề'),
      'Institution, Topic' => _t('Institution, Topic', 'Tổ chức, Chủ đề'),
      'Country, Topic' => _t('Country, Topic', 'Quốc gia, Chủ đề'),
      'Time, Keyword' => _t('Time, Keyword', 'Thời gian, Từ khóa'),
      'Time, Journal, Author, Keyword, Country' => _t(
            'Time, Journal, Author, Keyword, Country',
            'Thời gian, Tạp chí, Tác giả, Từ khóa, Quốc gia',
          ),
      _ => key,
    };
  }
}

/// Resolves pie touch index; returns null when touch is outside sections.
int? resolvePieTouchIndex(int? rawIndex, int? currentIndex) {
  if (rawIndex == null || rawIndex < 0) return null;
  return currentIndex == rawIndex ? null : rawIndex;
}
