class RatingInput {
  double? overall;
  double? food;
  double? service;
  double? value;

  RatingInput({
    this.overall,
    this.food,
    this.service,
    this.value,
  });

  bool get hasAnyRating => 
    overall != null || food != null || service != null || value != null;

  RatingInput copyWith({
    double? overall,
    double? food,
    double? service,
    double? value,
  }) {
    return RatingInput(
      overall: overall ?? this.overall,
      food: food ?? this.food,
      service: service ?? this.service,
      value: value ?? this.value,
    );
  }
}