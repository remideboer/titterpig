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
- Defense calculation: Base defense from category + 2 if shield is active

### Spell Management
- Spell cost must be less than or equal to character's power
- Maximum number of spells follows Fibonacci sequence based on WIL:
  - WIL 1: 2 spells
  - WIL 2: 3 spells
  - WIL 3: 5 spells
  - And so on...
- Spell limit is dynamically enforced:
  - When WIL decreases, excess spells are automatically removed
  - Cannot add spells beyond the limit
  - Visual indicator shows current/maximum spells
- D&D spell conversion:
  - Cantrips (level 0) cost 0
  - 1st level spells cost 1
  - 2nd level spells cost 2
  - And so on...
- Damage dice conversion: 
  - Convert all damage dice to d6 system by dividing maximum value by 6 and rounding up (e.g., 1d8 => 8/6=1.33 => 2d6, 5d4 => 20/6=3.33 => 4d6)
  - Final d6 values: 1-2 = no damage, 3-5 = 1 damage, 6 = 2 damage
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
  Scenario: Adding spells within WIL limit
    Given I am viewing a character with WIL 2
    Then I can see the spell limit is 3
    When I open the spell selection screen
    And I select 3 spells
    Then all spells are added successfully
    And the spell count shows (3/3)
    And I cannot add more spells

  Scenario: Reducing WIL affects spell limit
    Given I have a character with WIL 3 and 5 spells
    When I reduce WIL to 2
    Then the spell limit is reduced to 3
    And excess spells are automatically removed
    And the spell count shows (3/3)

  Scenario: Viewing spell limits
    Given I am on the character creation screen
    When I set WIL to different values
    Then I see the following spell limits:
      | WIL | Maximum Spells |
      | 1   | 2             |
      | 2   | 3             |
      | 3   | 5             |
      | 4   | 8             |
    And the current/maximum spell count is always visible

  Scenario: Adding a spell to a character
    Given I am viewing a character
    When I open the spell selection screen
    And I select a spell within my WIL-based limit
    Then the spell is added to the character's spell list
    And the spell's cost is deducted from available power

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
   - Verify spell limits based on WIL:
     * Correct Fibonacci sequence (2, 3, 5, 8, ...)
     * Visual indicator shows current/maximum spells
     * Cannot exceed limit when adding spells
     * Excess spells removed when WIL decreases
     * Limit updates when WIL changes

2. D&D Spell Integration
   - Verify D&D spells can be loaded
   - Verify spell conversion works correctly
   - Verify spell costs are properly converted
   - Verify spell effects are preserved
   - Verify spell versioning is maintained
   - Verify spell limits are respected during D&D spell import

3. Spell Selection
   - Verify spell filtering works
   - Verify spell cost constraints are enforced
   - Verify spell selection is persisted
   - Verify spell removal works
   - Verify spell updates are properly versioned
   - Verify WIL-based spell limits are enforced
   - Verify UI shows current/maximum spell count
   - Verify appropriate feedback when limit is reached

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
