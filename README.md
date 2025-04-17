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
    And the species name should be automatically capitalized
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
    Then my power points should decrease by the spell's cost
    When I have insufficient power points
    Then I should not be able to cast the spell

  Scenario: Spell selection
    Given I am on the character creation screen
    When I open the spell selection overlay
    Then I should see a list of available spells
    And I can select multiple spells
    And the overlay should remain open after selecting a spell
    When I close the overlay
    Then my selected spells should be saved with the character

  Scenario: Spell administration
    Given I am on the spells admin screen
    When I create a new spell
    Then I should be taken to a dedicated spell creation screen
    And I can enter the spell's name, cost, and effect
    When I edit an existing spell
    Then I should be taken to a dedicated spell edit screen
    And I can modify the spell's properties
    When I delete a spell
    Then I should be prompted for confirmation
    And the spell should be removed from the available spells list
```

### Character Persistence

```gherkin
Feature: Character Persistence
  As a player
  I want my character selection to be remembered
  So that I can quickly return to my last used character

  Scenario: Remembering last selected character
    Given I have multiple characters
    When I select a character
    Then that character should be remembered as the last selected
    When I restart the application
    Then the last selected character should be automatically loaded
    And I should be taken to that character's sheet
```

### Character List Sorting

```gherkin
Feature: Character List Sorting
  As a player
  I want to sort my character list
  So that I can easily find and organize my characters

  Scenario: Selecting sort criteria
    Given I am viewing the character list
    When I click the sort button
    Then I should see available sort options
    When I select a sort option
    Then it should be added to the active sort criteria
    And the character list should be sorted accordingly

  Scenario: Reordering sort criteria
    Given I have multiple sort criteria selected
    When I drag a sort criterion to a new position
    Then the sort precedence should update
    And the character list should be reordered based on the new precedence

  Scenario: Toggling sort direction
    Given I have a sort criterion selected
    When I click the direction toggle
    Then the sort direction should change
    And the character list should be reordered accordingly

  Scenario: Removing sort criteria
    Given I have a sort criterion selected
    When I click the sort criterion
    Then it should be removed from the active sort criteria
    And the character list should be reordered without that criterion

  Scenario: Multiple sort criteria
    Given I have multiple sort criteria selected
    When characters have the same value for the first criterion
    Then they should be sorted by the second criterion
    And so on for each subsequent criterion
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
