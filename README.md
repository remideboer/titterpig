# TTRPG Character Manager

A character management application for tabletop role-playing games.

## Business Rules

### Character Creation and Stats

```gherkin
Feature: Character Creation
  As a player
  I want to create and manage my character
  So that I can track my character's stats and abilities

  Scenario: Creating a new character
    Given I am on the character creation screen
    When I enter a character name
    And I select a species
    And I distribute my stat points
    And I select my armor type
    And I add abilities
    Then my character should be created with the specified attributes

  Scenario: Stat point distribution
    Given I have 3 total stat points to distribute
    When I increase a stat
    Then my remaining points should decrease
    And the stat's derived values should update
    When I decrease a stat
    Then my remaining points should increase
    And the stat's derived values should update

  Scenario: Stat point limits
    Given I am distributing stat points
    When I try to increase a stat above 3
    Then I should not be able to do so
    When I try to decrease a stat below -3
    Then I should not be able to do so

  Scenario: Vitality (VIT) requirements
    Given I am setting my VIT stat
    When I try to set VIT below -2
    Then I should not be able to do so
    And I should see an error message about minimum HP requirements
```

### Health and Life System

```gherkin
Feature: Health and Life Management
  As a player
  I want to track my character's health and life points
  So that I can manage my character's survival

  Scenario: HP calculation
    Given I have a VIT stat of X
    When I create or update my character
    Then my HP should be calculated as 6 + (2 * VIT)
    And my HP should never be negative

  Scenario: Life calculation
    Given I have a VIT stat of X
    When I create or update my character
    Then my Life should be calculated as 3 + VIT

  Scenario: Taking damage
    Given I have temporary HP
    When I take damage
    Then my temporary HP should decrease first
    And my actual HP should remain unchanged
    When I have no temporary HP
    And I take damage
    Then my HP should decrease
    When my HP reaches 0
    And I take damage
    Then my Life should decrease
    When my Life reaches 0
    Then I should be notified of character death

  Scenario: Healing
    Given I have less than maximum HP
    When I heal
    Then my HP should increase
    When I have maximum HP
    And I heal
    Then my Life should increase if below maximum
```

### Power and Spell System

```gherkin
Feature: Power and Spell Management
  As a player
  I want to manage my character's power and spells
  So that I can use magical abilities effectively

  Scenario: Power calculation
    Given I have a WIL stat of X
    When I create or update my character
    Then my Power should be calculated as WIL * 3

  Scenario: Spell casting
    Given I have available power
    When I cast a spell
    Then my available power should decrease by the spell's cost
    When I try to cast a spell with insufficient power
    Then I should see a "Not enough power" message
    And the spell should not be cast

  Scenario: Power reset
    Given I have used some of my power
    When I reset my power
    Then my available power should be restored to maximum

  Scenario: Spell selection
    Given I am selecting spells
    When I try to select a spell with cost higher than my maximum power
    Then I should not be able to select it
    And I should see a visual indicator that it's unavailable
    When I select a spell within my power limit
    Then it should be added to my spell list
```

### Defense System

```gherkin
Feature: Defense Management
  As a player
  I want to manage my character's defense
  So that I can protect my character effectively

  Scenario: Defense calculation
    Given I have selected a defense category
    When I have a shield
    Then my defense should be calculated as defense category value + 2
    When I do not have a shield
    Then my defense should be equal to the defense category value

  Scenario: Defense selection
    Given I am selecting my defense
    When I select a defense category
    Then it should be applied to my character
    When I select the same category again
    Then it should be removed
```

### Spell Filtering

```gherkin
Feature: Spell Filtering
  As a player
  I want to filter spells by cost
  So that I can easily find spells within my power range

  Scenario: Cost range filtering
    Given I am viewing available spells
    When I adjust the cost range slider
    Then only spells within the selected cost range should be displayed
    And the range should be displayed above the slider
    And the minimum and maximum values should be shown on the slider

  Scenario: Spell availability
    Given I am viewing available spells
    When I have a maximum power of X
    Then spells with cost higher than X should be visually indicated as unavailable
    And I should not be able to select them
```

### Character Persistence

```gherkin
Feature: Character Data Persistence
  As a player
  I want my character data to be saved
  So that I can access it across sessions

  Scenario: Character saving
    Given I have made changes to my character
    When I navigate away from the character sheet
    Then the changes should be automatically saved
    And the last used timestamp should be updated

  Scenario: Character loading
    Given I have saved character data
    When I open the application
    Then my character data should be loaded correctly
    And all derived stats should be calculated properly
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
