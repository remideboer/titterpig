# TTRPG Character Manager

A Flutter application for managing tabletop RPG characters, with support for character creation, spell management, and D&D spell integration.

## Core Features

### Character Management
- Create and edit characters
- Manage character stats (VIT, ATH, WIL)
- Track HP, Life, and Power
- Custom species selection
- Defense category management
- Session logging
- Character notes

### Spell Management
- Add/remove spells to characters
- Track spell costs and power usage
- D&D spell integration
- Spell effect tracking
- Spell type categorization
- Spell editing and versioning

## Business Rules

### Character Creation
- Total stat points: 3 points to distribute
- Minimum stat value: -3
- Maximum stat value: 3
- HP calculation: Base 6 + (2 × VIT)
- Life calculation: Base 3 + VIT
- Power calculation: WIL × 3
- Defense calculation: ATH + Base defense from category + 2 if shield is active

### Spell Management
- Spell cost must be less than or equal to character's power
- D&D spell conversion:
  - Cantrips (level 0) cost 1
  - 1st level spells cost 2
  - 2nd level spells cost 3
  - And so on...
- Damage dice conversion: Convert all damage dice to d6 system (e.g., 2d8 becomes 2d6)
- Spell versioning: Each spell has a unique versionId and lastUpdated timestamp
- Spell updates: Only newer versions of spells replace existing ones

### Defense Categories
- Light: +1 defense
- Medium: +2 defense
- Heavy: +3 defense
- None: +0 defense
- Shield bonus: +2 defense (stacks with category)
- Base defense: Equal to ATH stat

## Gherkin Scenarios

### Character Creation
```gherkin
Feature: Character Creation
  Scenario: Creating a new character
    Given I am on the character creation screen
    When I enter a character name
    And I select a species
    And I allocate stat points
    And I select a defense category
    Then I can save the character
    And the character is created with the specified attributes

  Scenario: Editing an existing character
    Given I am viewing a character
    When I click the edit button
    Then I can modify the character's attributes
    And the changes are saved when I click update
    And the character's spells are preserved
```

### Spell Management
```gherkin
Feature: Spell Management
  Scenario: Adding a spell to a character
    Given I am viewing a character
    When I open the spell selection screen
    And I select a spell
    Then the spell is added to the character's spell list
    And the spell's cost is deducted from available power

  Scenario: Using a spell
    Given a character has spells
    When I use a spell
    Then the spell's cost is deducted from available power
    And the spell effect is applied

  Scenario: Managing D&D spells
    Given I am in the spell admin screen
    When I sync D&D spells
    Then the spells are loaded from the D&D API
    And converted to the game's spell system
    And spell costs are properly converted

  Scenario: Editing a spell
    Given I am viewing a spell
    When I edit the spell details
    Then the changes are saved with a new version
    And the updated spell is available to all characters
```

### Defense Management
```gherkin
Feature: Defense Management
  Scenario: Changing defense category
    Given I am viewing a character
    When I select a defense category
    Then the character's defense value is updated
    And the shield icon reflects the new category
    And the defense bonus is applied correctly
```

## Test Scenarios

### Character Tests
1. Character Creation
   - Verify character can be created with valid attributes
   - Verify stat point allocation is enforced (6 points total)
   - Verify species selection works
   - Verify defense category selection works
   - Verify HP calculation (6 + 2×VIT)
   - Verify Life calculation (3 + VIT)
   - Verify Power calculation (WIL × 3)

2. Character Editing
   - Verify existing character can be edited
   - Verify changes are persisted
   - Verify stat point constraints are maintained
   - Verify species changes are saved
   - Verify spells are preserved during editing

3. Character Stats
   - Verify HP calculation based on VIT
   - Verify Life calculation based on VIT
   - Verify Power calculation based on WIL
   - Verify defense calculation based on ATH and category
   - Verify shield bonus is applied correctly

### Spell Tests
1. Spell Management
   - Verify spells can be added to characters
   - Verify spell costs are correctly tracked
   - Verify power usage is enforced
   - Verify spell effects are displayed
   - Verify spell versioning works correctly

2. D&D Spell Integration
   - Verify D&D spells can be loaded
   - Verify spell conversion works correctly
   - Verify spell costs are properly converted
   - Verify spell effects are preserved
   - Verify spell versioning is maintained

3. Spell Selection
   - Verify spell filtering works
   - Verify spell cost constraints are enforced
   - Verify spell selection is persisted
   - Verify spell removal works
   - Verify spell updates are properly versioned

### Defense Tests
1. Defense Categories
   - Verify defense category selection works
   - Verify defense value calculation is correct
   - Verify shield bonus is applied correctly
   - Verify defense changes are persisted
   - Verify category bonuses are applied correctly

### UI Tests
1. Character Sheet
   - Verify all stats are displayed correctly
   - Verify spell list is displayed
   - Verify defense selection UI works
   - Verify power usage UI works
   - Verify edit button functionality

2. Spell Selection
   - Verify spell list is displayed
   - Verify spell filtering works
   - Verify spell selection UI works
   - Verify spell cost constraints are visible
   - Verify spell version information is displayed

This README reflects the current state of the application, including recent changes to spell management and character editing functionality. All business rules are documented and test scenarios are updated to cover the implemented features.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
