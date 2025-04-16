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

  Scenario: Distributing stat points
    Given I have 10 stat points to distribute
    When I increase a stat
    Then my remaining points should decrease
    And the stat's derived values should update
    When I decrease a stat
    Then my remaining points should increase
    And the stat's derived values should update

  Scenario: Stat point limits
    Given I am distributing stat points
    When I try to increase a stat above 5
    Then I should not be able to do so
    When I try to decrease a stat below 1
    Then I should not be able to do so

  Scenario: Custom species creation
    Given I am selecting a species
    When I choose "Custom Species"
    And I enter a custom species name
    Then a new species should be created with the human-face icon
```

### Health and Life System

```gherkin
Feature: Health Management
  As a player
  I want to track my character's health and life
  So that I can manage damage and healing

  Scenario: Taking damage
    Given my character has HP and LIFE
    When I take damage
    Then my temporary HP should decrease first
    When I have no temporary HP
    Then my regular HP should decrease
    When my HP reaches 0
    Then my LIFE should decrease
    When my LIFE reaches 0
    Then my character should be marked as dead

  Scenario: Healing
    Given my character has taken damage
    When I heal
    Then my HP should increase first
    When my HP is at maximum
    Then my LIFE should NOT increase
```

### Defense System

```gherkin
Feature: Defense Management
  As a player
  I want to manage my character's defense
  So that I can adjust my protection level

  Scenario: Selecting armor type
    Given I am on the character sheet
    When I select a defense category (Light/Medium/Heavy)
    Then my defense value should update based on my ATH stat and armor type
    When I select the same category again
    Then the armor should be removed
```

### Power and Abilities

```gherkin
Feature: Power and Abilities
  As a player
  I want to manage my character's power and abilities
  So that I can use spells effectively

  Scenario: Power management
    Given my character has power points
    When I use a spell
    Then my available power should decrease by the spell's cost
    When I reset my power
    Then my available power should return to maximum

  Scenario: Spell usage
    Given I have learned spells
    When I have enough power
    Then I can use a spell
    When I don't have enough power
    Then I cannot use the spell
    And I should see a message indicating insufficient power

  Scenario: Learning new spells
    Given I am on the character sheet
    When I add a new spell
    Then the spell should be added to my list
    And it should be sorted by cost
    When I try to add a spell I already know
    Then I should not be able to add it again
    When I try to add a spell that costs more than my maximum power
    Then I should not be able to add it
```

### Character State

```gherkin
Feature: Character State
  As a player
  I want my character's state to be preserved
  So that I can continue my game later

  Scenario: Saving character state
    Given I have made changes to my character
    When I navigate away from the character sheet
    Then all changes should be saved automatically
    When I return to the character sheet
    Then my character should be in the same state as when I left
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
