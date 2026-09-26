/// Period options for the Overview "This Month" dropdown.
enum OverviewPeriod {
  week('week', 'This Week', 'vs last week'),
  month('month', 'This Month', 'vs last month'),
  year('year', 'This Year', 'vs last year');

  const OverviewPeriod(this.apiValue, this.label, this.comparisonLabel);

  final String apiValue;
  final String label;
  final String comparisonLabel;
}

/// Year / Month / Week toggle on the Company Growth chart.
enum GrowthRange {
  year('year', 'Year'),
  month('month', 'Month'),
  week('week', 'Week');

  const GrowthRange(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

class Stat {
  const Stat({required this.value, required this.changePercent});

  factory Stat.fromJson(Map<String, dynamic> json) => Stat(
        value: (json['value'] as num).toInt(),
        changePercent: (json['changePercent'] as num).toInt(),
      );

  final int value;
  final int changePercent;
}

class Overview {
  const Overview({
    required this.walletBalance,
    required this.totalShipments,
    required this.totalExports,
    required this.totalImports,
  });

  factory Overview.fromJson(Map<String, dynamic> json) => Overview(
        walletBalance: (json['walletBalance'] as num).toDouble(),
        totalShipments:
            Stat.fromJson(json['totalShipments'] as Map<String, dynamic>),
        totalExports:
            Stat.fromJson(json['totalExports'] as Map<String, dynamic>),
        totalImports:
            Stat.fromJson(json['totalImports'] as Map<String, dynamic>),
      );

  final double walletBalance;
  final Stat totalShipments;
  final Stat totalExports;
  final Stat totalImports;

  Overview copyWith({double? walletBalance}) => Overview(
        walletBalance: walletBalance ?? this.walletBalance,
        totalShipments: totalShipments,
        totalExports: totalExports,
        totalImports: totalImports,
      );
}

class GrowthPoint {
  const GrowthPoint({required this.label, required this.value});

  factory GrowthPoint.fromJson(Map<String, dynamic> json) => GrowthPoint(
        label: json['label'] as String,
        value: (json['value'] as num).toDouble(),
      );

  final String label;
  final double value;
}

class BannerSlide {
  const BannerSlide({
    required this.id,
    required this.title,
    required this.imageKey,
    this.subtitle,
  });

  factory BannerSlide.fromJson(Map<String, dynamic> json) => BannerSlide(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String?,
        imageKey: json['imageKey'] as String,
      );

  final String id;
  final String title;
  final String? subtitle;
  final String imageKey;
}
