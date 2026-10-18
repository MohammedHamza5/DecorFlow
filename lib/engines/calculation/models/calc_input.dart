import 'package:stream_pay/core/constants/unit_types.dart';

/// Input model for the calculation engine.
///
/// Contains all possible inputs across different calculation modes.
/// Each calculator picks the fields it needs.
class CalcInput {
  /// The calculation mode to use.
  final CalcMode mode;

  /// Installation orientation (vertical/horizontal) — for rods.
  final InstallationOrientation orientation;

  /// Wall length in meters.
  final double wallLength;

  /// Wall height in meters.
  final double wallHeight;

  /// Number of walls to calculate.
  final int wallCount;

  /// Effective coverage width of one piece in meters (e.g., 0.16m for a rod).
  final double effectiveCoverageWidth;

  /// Length of one piece (rod/panel) in meters.
  final double pieceLength;

  /// Width of one piece (panel) in meters.
  final double pieceWidth;

  /// Effective coverage area of one panel in m² (for panels).
  final double effectiveCoverageArea;

  /// Number of panels per box/carton.
  final int piecesPerBox;

  /// Waste percentage (0.0 to 1.0).
  final double wastePercent;

  /// List of openings to deduct.
  final List<OpeningInput> openings;

  /// Whether openings should be deducted from calculations.
  final bool deductOpenings;

  /// Whether to use smart wall layout calculation & 1D cutting stock optimization.
  final bool useSmartLayout;

  /// Concrete beam height on top of the wall in meters.
  final double smartBeamHeight;

  /// Whether the concrete beam is covered with wood alternative.
  final bool smartCoverBeam;

  /// Whether there is a TV screen in the middle.
  final bool smartHasTv;

  /// TV width in meters.
  final double smartTvWidth;

  /// TV height in meters.
  final double smartTvHeight;

  /// TV horizontal position from left of wall in meters.
  final double smartTvPosX;

  /// TV vertical position from floor in meters.
  final double smartTvPosY;

  /// Whether to cover the wall area below the TV screen.
  final bool smartCoverBelowTv;

  /// Whether to cover the wall area above the TV screen.
  final bool smartCoverAboveTv;

  /// Perimeter for linear meter calculation.
  final double perimeter;

  /// Number of corners (for linear meter waste).
  final int cornerCount;

  /// Total area (for direct area input).
  final double? directArea;

  /// Quantity for pieces calculation.
  final int quantity;

  /// Frame width for frames calculation.
  final double frameWidth;

  /// Frame height for frames calculation.
  final double frameHeight;

  /// Number of frames for frames calculation.
  final int frameCount;

  /// Category name for auto-detection of calc mode.
  final String? category;

  /// Roll width in meters (for wallpaper rolls).
  final double rollWidth;

  /// Roll length in meters (for wallpaper rolls).
  final double rollLength;

  /// Rapport/repeat pattern height in meters (for wallpaper rolls).
  final double rapportRepeat;

  /// Coverage per unit in m² (for putty/paint containers).
  final double coveragePerUnit;

  const CalcInput({
    required this.mode,
    this.orientation = InstallationOrientation.vertical,
    this.wallLength = 0,
    this.wallHeight = 0,
    this.wallCount = 1,
    this.effectiveCoverageWidth = 0,
    this.pieceLength = 0,
    this.pieceWidth = 0,
    this.effectiveCoverageArea = 0,
    this.piecesPerBox = 1,
    this.wastePercent = 0.10,
    this.openings = const [],
    this.deductOpenings = true,
    this.useSmartLayout = false,
    this.smartBeamHeight = 0,
    this.smartCoverBeam = true,
    this.smartHasTv = false,
    this.smartTvWidth = 0,
    this.smartTvHeight = 0,
    this.smartTvPosX = 0,
    this.smartTvPosY = 0,
    this.smartCoverBelowTv = true,
    this.smartCoverAboveTv = true,
    this.perimeter = 0,
    this.cornerCount = 0,
    this.directArea,
    this.quantity = 1,
    this.frameWidth = 0,
    this.frameHeight = 0,
    this.frameCount = 1,
    this.category,
    this.rollWidth = 0,
    this.rollLength = 0,
    this.rapportRepeat = 0,
    this.coveragePerUnit = 0,
  });

  /// Create a copy with some fields changed.
  CalcInput copyWith({
    CalcMode? mode,
    InstallationOrientation? orientation,
    double? wallLength,
    double? wallHeight,
    int? wallCount,
    double? effectiveCoverageWidth,
    double? pieceLength,
    double? pieceWidth,
    double? effectiveCoverageArea,
    int? piecesPerBox,
    double? wastePercent,
    List<OpeningInput>? openings,
    bool? deductOpenings,
    bool? useSmartLayout,
    double? smartBeamHeight,
    bool? smartCoverBeam,
    bool? smartHasTv,
    double? smartTvWidth,
    double? smartTvHeight,
    double? smartTvPosX,
    double? smartTvPosY,
    bool? smartCoverBelowTv,
    bool? smartCoverAboveTv,
    double? perimeter,
    int? cornerCount,
    double? directArea,
    int? quantity,
    double? frameWidth,
    double? frameHeight,
    int? frameCount,
    String? category,
    double? rollWidth,
    double? rollLength,
    double? rapportRepeat,
    double? coveragePerUnit,
  }) {
    return CalcInput(
      mode: mode ?? this.mode,
      orientation: orientation ?? this.orientation,
      wallLength: wallLength ?? this.wallLength,
      wallHeight: wallHeight ?? this.wallHeight,
      wallCount: wallCount ?? this.wallCount,
      effectiveCoverageWidth:
          effectiveCoverageWidth ?? this.effectiveCoverageWidth,
      pieceLength: pieceLength ?? this.pieceLength,
      pieceWidth: pieceWidth ?? this.pieceWidth,
      effectiveCoverageArea:
          effectiveCoverageArea ?? this.effectiveCoverageArea,
      piecesPerBox: piecesPerBox ?? this.piecesPerBox,
      wastePercent: wastePercent ?? this.wastePercent,
      openings: openings ?? this.openings,
      deductOpenings: deductOpenings ?? this.deductOpenings,
      useSmartLayout: useSmartLayout ?? this.useSmartLayout,
      smartBeamHeight: smartBeamHeight ?? this.smartBeamHeight,
      smartCoverBeam: smartCoverBeam ?? this.smartCoverBeam,
      smartHasTv: smartHasTv ?? this.smartHasTv,
      smartTvWidth: smartTvWidth ?? this.smartTvWidth,
      smartTvHeight: smartTvHeight ?? this.smartTvHeight,
      smartTvPosX: smartTvPosX ?? this.smartTvPosX,
      smartTvPosY: smartTvPosY ?? this.smartTvPosY,
      smartCoverBelowTv: smartCoverBelowTv ?? this.smartCoverBelowTv,
      smartCoverAboveTv: smartCoverAboveTv ?? this.smartCoverAboveTv,
      perimeter: perimeter ?? this.perimeter,
      cornerCount: cornerCount ?? this.cornerCount,
      directArea: directArea ?? this.directArea,
      quantity: quantity ?? this.quantity,
      frameWidth: frameWidth ?? this.frameWidth,
      frameHeight: frameHeight ?? this.frameHeight,
      frameCount: frameCount ?? this.frameCount,
      category: category ?? this.category,
      rollWidth: rollWidth ?? this.rollWidth,
      rollLength: rollLength ?? this.rollLength,
      rapportRepeat: rapportRepeat ?? this.rapportRepeat,
      coveragePerUnit: coveragePerUnit ?? this.coveragePerUnit,
    );
  }

  /// Convert to JSON for saving calculation records.
  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'orientation': orientation.name,
    'wallLength': wallLength,
    'wallHeight': wallHeight,
    'wallCount': wallCount,
    'effectiveCoverageWidth': effectiveCoverageWidth,
    'pieceLength': pieceLength,
    'pieceWidth': pieceWidth,
    'effectiveCoverageArea': effectiveCoverageArea,
    'piecesPerBox': piecesPerBox,
    'wastePercent': wastePercent,
    'openings': openings.map((o) => o.toJson()).toList(),
    'deductOpenings': deductOpenings,
    'useSmartLayout': useSmartLayout,
    'smartBeamHeight': smartBeamHeight,
    'smartCoverBeam': smartCoverBeam,
    'smartHasTv': smartHasTv,
    'smartTvWidth': smartTvWidth,
    'smartTvHeight': smartTvHeight,
    'smartTvPosX': smartTvPosX,
    'smartTvPosY': smartTvPosY,
    'smartCoverBelowTv': smartCoverBelowTv,
    'smartCoverAboveTv': smartCoverAboveTv,
    'perimeter': perimeter,
    'cornerCount': cornerCount,
    'directArea': directArea,
    'quantity': quantity,
    'frameWidth': frameWidth,
    'frameHeight': frameHeight,
    'frameCount': frameCount,
    'category': category,
    'rollWidth': rollWidth,
    'rollLength': rollLength,
    'rapportRepeat': rapportRepeat,
    'coveragePerUnit': coveragePerUnit,
  };
}

/// Represents an opening (door, window, column) in a wall.
class OpeningInput {
  final OpeningType type;
  final double width;
  final double height;
  final bool deduct;

  const OpeningInput({
    required this.type,
    required this.width,
    required this.height,
    this.deduct = true,
  });

  /// Area of this opening.
  double get area => width * height;

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'width': width,
    'height': height,
    'deduct': deduct,
  };
}
