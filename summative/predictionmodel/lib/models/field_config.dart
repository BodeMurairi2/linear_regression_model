import 'package:flutter/material.dart';

enum FieldGroup { healthSystem, economyDemographics, environmentEducation }

class FieldConfig {
  final String key;
  final String label;
  final String unit;
  final String description;
  final double min;
  final double max;
  final double initial;

  const FieldConfig({
    required this.key,
    required this.label,
    required this.unit,
    required this.description,
    required this.min,
    required this.max,
    required this.initial,
  });

  String get rangeLabel {
    String fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
    return '${fmt(min)}–${fmt(max)}';
  }
}

const Map<FieldGroup, String> fieldGroupTitles = {
  FieldGroup.healthSystem: 'Health system & outcomes',
  FieldGroup.economyDemographics: 'Economy & demographics',
  FieldGroup.environmentEducation: 'Environment & education',
};

const Map<FieldGroup, IconData> fieldGroupIcons = {
  FieldGroup.healthSystem: Icons.medical_services_outlined,
  FieldGroup.economyDemographics: Icons.insights_outlined,
  FieldGroup.environmentEducation: Icons.park_outlined,
};

// Keys and bounds mirror summative/api/schemas/prediction_schemas.py exactly.
const Map<FieldGroup, List<FieldConfig>> fieldGroups = {
  FieldGroup.healthSystem: [
    FieldConfig(
      key: 'health_expenditure_per_capita_usd',
      label: 'Health expenditure per capita',
      unit: 'USD',
      description: 'Average amount spent on health per person, in USD.',
      min: 0,
      max: 1000,
      initial: 45,
    ),
    FieldConfig(
      key: 'govt_health_exp_pct_gdp',
      label: 'Government health spending',
      unit: '% of GDP',
      description: 'Government health expenditure as a share of GDP.',
      min: 0,
      max: 10,
      initial: 4.2,
    ),
    FieldConfig(
      key: 'under5_mortality_per_1000',
      label: 'Under-5 mortality',
      unit: 'per 1,000',
      description:
          'Child deaths before age 5 per 1,000 live births — a proxy for how strained the health system is.',
      min: 0,
      max: 600,
      initial: 95,
    ),
    FieldConfig(
      key: 'life_expectancy_years',
      label: 'Life expectancy',
      unit: 'years',
      description: 'Average number of years a newborn is expected to live.',
      min: 0,
      max: 100,
      initial: 58,
    ),
    FieldConfig(
      key: 'basic_water_access_pct',
      label: 'Basic water access',
      unit: '% of pop.',
      description: 'Share of the population with access to a basic drinking water source.',
      min: 0,
      max: 100,
      initial: 52,
    ),
  ],
  FieldGroup.economyDemographics: [
    FieldConfig(
      key: 'gdp_per_capita_usd',
      label: 'GDP per capita',
      unit: 'USD',
      description: 'Average economic output per person, in current USD.',
      min: 0,
      max: 25000,
      initial: 2100,
    ),
    FieldConfig(
      key: 'population_density',
      label: 'Population density',
      unit: '/ km²',
      description: 'People per square kilometer of land area.',
      min: 0,
      max: 800,
      initial: 220,
    ),
    FieldConfig(
      key: 'rural_population_pct',
      label: 'Rural population',
      unit: '%',
      description: 'Share of the population living in rural areas.',
      min: 0,
      max: 100,
      initial: 62,
    ),
    FieldConfig(
      key: 'fertility_rate_births_per_woman',
      label: 'Fertility rate',
      unit: 'births/woman',
      description: 'Average number of births per woman.',
      min: 1,
      max: 9.9,
      initial: 5.1,
    ),
  ],
  FieldGroup.environmentEducation: [
    FieldConfig(
      key: 'forest_area_pct',
      label: 'Forest area',
      unit: '%',
      description: 'Share of land covered by forest — more habitat for mosquito breeding.',
      min: 0,
      max: 100,
      initial: 18,
    ),
    FieldConfig(
      key: 'primary_completion_rate_pct',
      label: 'Primary completion rate',
      unit: '%',
      description:
          'Share of children completing primary school (can exceed 100% due to over-age enrollment).',
      min: 0,
      max: 170,
      initial: 68,
    ),
  ],
};

/// Flat lookup by field key, so widgets that only have the API's
/// `feature` string (e.g. the SHAP contribution list) can find the
/// matching label/description without re-scanning [fieldGroups].
final Map<String, FieldConfig> fieldConfigByKey = {
  for (final fields in fieldGroups.values)
    for (final field in fields) field.key: field,
};
