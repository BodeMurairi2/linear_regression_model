import 'package:flutter/material.dart';

enum FieldGroup { healthSystem, economyDemographics, environmentEducation }

class FieldConfig {
  final String key;
  final String label;
  final String unit;
  final double min;
  final double max;
  final double initial;

  const FieldConfig({
    required this.key,
    required this.label,
    required this.unit,
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
      min: 0,
      max: 1000,
      initial: 45,
    ),
    FieldConfig(
      key: 'govt_health_exp_pct_gdp',
      label: 'Government health spending',
      unit: '% of GDP',
      min: 0,
      max: 10,
      initial: 4.2,
    ),
    FieldConfig(
      key: 'under5_mortality_per_1000',
      label: 'Under-5 mortality',
      unit: 'per 1,000',
      min: 0,
      max: 600,
      initial: 95,
    ),
    FieldConfig(
      key: 'life_expectancy_years',
      label: 'Life expectancy',
      unit: 'years',
      min: 0,
      max: 100,
      initial: 58,
    ),
    FieldConfig(
      key: 'basic_water_access_pct',
      label: 'Basic water access',
      unit: '% of pop.',
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
      min: 0,
      max: 25000,
      initial: 2100,
    ),
    FieldConfig(
      key: 'population_density',
      label: 'Population density',
      unit: '/ km²',
      min: 0,
      max: 800,
      initial: 220,
    ),
    FieldConfig(
      key: 'rural_population_pct',
      label: 'Rural population',
      unit: '%',
      min: 0,
      max: 100,
      initial: 62,
    ),
    FieldConfig(
      key: 'fertility_rate_births_per_woman',
      label: 'Fertility rate',
      unit: 'births/woman',
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
      min: 0,
      max: 100,
      initial: 18,
    ),
    FieldConfig(
      key: 'primary_completion_rate_pct',
      label: 'Primary completion rate',
      unit: '%',
      min: 0,
      max: 170,
      initial: 68,
    ),
  ],
};
