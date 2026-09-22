import 'app_icon.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_spacing.dart';
import 'audit_export_downloader.dart';
import 'banner.dart';
import 'button.dart';
import 'card.dart';
import 'form_field.dart';
import 'form_select.dart';
import 'heading.dart';

enum AppAuditPeriod { sevenDays, thirtyDays, currentCrop }

enum AppAuditFormat { csv, json }

class AppAuditExport {
  const AppAuditExport({
    required this.filename,
    required this.mimeType,
    required this.content,
    required this.rowCount,
  });

  final String filename;
  final String mimeType;
  final String content;
  final int rowCount;
}

class AppAuditExportPanel extends StatefulWidget {
  const AppAuditExportPanel({
    super.key,
    required this.filename,
    required this.rows,
    required this.onExport,
    this.downloadFile = false,
  });

  final String filename;
  final List<Map<String, String>> rows;
  final ValueChanged<AppAuditExport> onExport;
  final bool downloadFile;

  @override
  State<AppAuditExportPanel> createState() => _AppAuditExportPanelState();
}

class _AppAuditExportPanelState extends State<AppAuditExportPanel> {
  AppAuditPeriod _period = AppAuditPeriod.thirtyDays;
  AppAuditFormat _format = AppAuditFormat.csv;
  AppAuditExport? _lastExport;
  bool _downloaded = false;

  String _csvValue(String value) => '"${value.replaceAll('"', '""')}"';

  void _export() {
    final limit = _period == AppAuditPeriod.sevenDays ? 2 : widget.rows.length;
    final filtered = widget.rows.take(limit).toList();
    final extension = _format.name;
    final content = _format == AppAuditFormat.json
        ? const JsonEncoder.withIndent('  ').convert(filtered)
        : [
            if (filtered.isNotEmpty)
              filtered.first.keys.map(_csvValue).join(','),
            ...filtered.map((row) => row.values.map(_csvValue).join(',')),
          ].join('\n');
    final period = switch (_period) {
      AppAuditPeriod.sevenDays => '7-dias',
      AppAuditPeriod.thirtyDays => '30-dias',
      AppAuditPeriod.currentCrop => 'safra-atual',
    };
    final result = AppAuditExport(
      filename: '${widget.filename}-$period.$extension',
      mimeType: _format == AppAuditFormat.json
          ? 'application/json'
          : 'text/csv;charset=utf-8',
      content: content,
      rowCount: filtered.length,
    );

    final downloaded =
        widget.downloadFile &&
        downloadTextFile(
          filename: result.filename,
          mimeType: result.mimeType,
          content: result.content,
        );
    setState(() {
      _lastExport = result;
      _downloaded = downloaded;
    });
    widget.onExport(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppSectionTitle(
                child: Text('Preparar arquivo de auditoria'),
              ),
              const SizedBox(height: AppSpacing.space2),
              const Text(
                'O conteúdo é gerado localmente com dados demonstrativos.',
              ),
              const SizedBox(height: AppSpacing.space4),
              AppFormField(
                label: 'Período',
                required: true,
                child: AppFormSelect(
                  value: _period.name,
                  options: const [
                    AppFormSelectOption(
                      value: 'sevenDays',
                      label: 'Últimos 7 dias',
                    ),
                    AppFormSelectOption(
                      value: 'thirtyDays',
                      label: 'Últimos 30 dias',
                    ),
                    AppFormSelectOption(
                      value: 'currentCrop',
                      label: 'Safra atual',
                    ),
                  ],
                  onChanged: (value) => setState(
                    () => _period = AppAuditPeriod.values.byName(value!),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              AppFormField(
                label: 'Formato',
                required: true,
                child: AppFormSelect(
                  value: _format.name,
                  options: const [
                    AppFormSelectOption(value: 'csv', label: 'CSV'),
                    AppFormSelectOption(value: 'json', label: 'JSON'),
                  ],
                  onChanged: (value) => setState(
                    () => _format = AppAuditFormat.values.byName(value!),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              AppButton(
                fullWidth: true,
                size: AppButtonSize.lg,
                leftIcon: const AppIcon(
                  AppIcons.download,
                  size: AppSpacing.space4,
                ),
                onPressed: _export,
                child: Text(
                  '${widget.downloadFile ? 'Baixar' : 'Preparar'} '
                  '${_format.name.toUpperCase()}',
                ),
              ),
            ],
          ),
        ),
        if (_lastExport != null)
          AppBanner(
            tone: AppBannerTone.success,
            icon: const AppIcon(AppIcons.fileCheck2, size: AppSpacing.space4),
            child: Text(
              '${_lastExport!.filename} '
              '${_downloaded ? 'baixado' : 'preparado'} com '
              '${_lastExport!.rowCount} registros.',
            ),
          ),
      ],
    );
  }
}

WidgetbookComponent buildAuditExportPanelWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'AuditExportPanel',
    useCases: [
      WidgetbookUseCase(
        name: 'CSV e JSON',
        builder: (context) => Center(
          child: SizedBox(
            width: AppSpacing.space20 * 5,
            child: AppAuditExportPanel(
              filename: 'auditoria-estoque',
              rows: const [
                {'data': '2026-08-16', 'ação': 'Batida registrada'},
                {'data': '2026-08-15', 'ação': 'Estoque ajustado'},
                {'data': '2026-08-14', 'ação': 'Entrada confirmada'},
              ],
              onExport: (_) {},
            ),
          ),
        ),
      ),
    ],
  );
}
