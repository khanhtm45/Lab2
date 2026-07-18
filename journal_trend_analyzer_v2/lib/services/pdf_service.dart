import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';

/// Service for generating PDF reports
class PdfService {
  /// Generate a research analytics report PDF
  static Future<Uint8List> generateResearchReport({
    required String title,
    String? topic,
    Map<String, dynamic>? data,
  }) async {
    final pdf = pw.Document();

    // Add page with report content
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
            ),
            
            pw.SizedBox(height: 20),

            // Metadata
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Report Information',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('Generated: ${DateTime.now().toString().split('.')[0]}'),
                  if (topic != null) pw.Text('Topic: $topic'),
                  pw.Text('Source: OpenAlex API'),
                  pw.Text('App: Journal Trend Analyzer'),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // Executive Summary
            pw.Header(
              level: 1,
              child: pw.Text(
                'Executive Summary',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            
            pw.Paragraph(
              text: 'This report provides a comprehensive analysis of research publications '
                    'and trends based on data from the OpenAlex academic database. '
                    'The analysis includes publication patterns, citation metrics, '
                    'author contributions, and institutional affiliations.',
            ),

            pw.SizedBox(height: 20),

            // Key Metrics Section
            pw.Header(
              level: 1,
              child: pw.Text(
                'Key Metrics',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            if (data != null) ..._buildMetricsSection(data),

            pw.SizedBox(height: 20),

            // Analysis Sections
            pw.Header(
              level: 1,
              child: pw.Text(
                'Research Analysis',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.Header(
              level: 2,
              child: pw.Text('Publication Trends'),
            ),
            pw.Paragraph(
              text: 'Analysis of publication volume over time reveals important trends '
                    'in research output and academic productivity.',
            ),

            pw.Header(
              level: 2,
              child: pw.Text('Citation Impact'),
            ),
            pw.Paragraph(
              text: 'Citation analysis provides insights into research impact and '
                    'influence within the academic community.',
            ),

            pw.Header(
              level: 2,
              child: pw.Text('Author Contributions'),
            ),
            pw.Paragraph(
              text: 'Examination of author productivity and collaboration patterns '
                    'highlights key researchers and research networks.',
            ),

            pw.Header(
              level: 2,
              child: pw.Text('Journal Analysis'),
            ),
            pw.Paragraph(
              text: 'Analysis of publication venues shows the most influential '
                    'journals and their contribution to the research landscape.',
            ),

            pw.SizedBox(height: 20),

            // Methodology
            pw.Header(
              level: 1,
              child: pw.Text(
                'Methodology',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.Paragraph(
              text: 'This analysis is based on data from the OpenAlex database, '
                    'which provides comprehensive coverage of academic publications. '
                    'Data was retrieved through the OpenAlex API and processed '
                    'using the Journal Trend Analyzer application.',
            ),

            pw.SizedBox(height: 30),

            // Footer
            pw.Align(
              alignment: pw.Alignment.center,
              child: pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Generated by Journal Trend Analyzer',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Powered by OpenAlex API',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      'PRM393 - Lab 03',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Build metrics section with data
  static List<pw.Widget> _buildMetricsSection(Map<String, dynamic> data) {
    final List<pw.Widget> widgets = [];

    // Create a table of key metrics
    final metricsData = [
      ['Metric', 'Value'],
      ['Total Publications', '${data['totalPublications'] ?? 'N/A'}'],
      ['Average Citations', '${data['avgCitations'] ?? 'N/A'}'],
      ['Top Author', '${data['topAuthor'] ?? 'N/A'}'],
      ['Most Active Year', '${data['peakYear'] ?? 'N/A'}'],
      ['Research Period', '${data['researchPeriod'] ?? 'N/A'}'],
    ];

    widgets.add(
      pw.TableHelper.fromTextArray(
        context: null,
        data: metricsData,
        headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        headerDecoration: const pw.BoxDecoration(
          color: PdfColors.blue800,
        ),
        cellStyle: const pw.TextStyle(fontSize: 11),
        cellPadding: const pw.EdgeInsets.all(8),
        oddRowDecoration: const pw.BoxDecoration(
          color: PdfColors.grey100,
        ),
      ),
    );

    return widgets;
  }

  /// Generate a simple dashboard summary PDF
  static Future<Uint8List> generateDashboardSummary() async {
    return generateResearchReport(
      title: 'Research Dashboard Summary',
      topic: 'General Research Analysis',
      data: {
        'totalPublications': '2.5M',
        'avgCitations': '15.3',
        'topAuthor': 'Analysis Pending',
        'peakYear': '2023',
        'researchPeriod': '2020-2024',
      },
    );
  }
}