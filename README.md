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

## Job Stories

Story ID: JS-46
When I am viewing a character's empty background section
I want to be taken directly to the background editor when clicking "Add Background"
So that I can immediately start filling in the background information without extra navigation

Acceptance Criteria:
1. When clicking "Add Background" from the background view, the edit screen opens directly to the background section
2. The background editor is immediately ready for input
3. Navigation between stats and background sections remains available
4. All changes are saved automatically as they are made

Related Business Rules: BR-12

Story ID: JS-47
When I am editing my character's background
I want my changes to be saved automatically and immediately visible in the main view
So that I don't lose any changes and can see my progress in real-time

Acceptance Criteria:
1. Background changes are saved automatically as they are made
2. Changes are immediately visible when navigating back to the main view
3. No explicit save button is needed for background changes
4. Background state is preserved when switching between views
5. Template selection immediately updates the background

Related Business Rules: BR-13, BR-14

Story ID: JS-46
When I am creating or modifying a character's VIT stat
I want to be prevented from setting values that would make HP less than 2
So that my character remains viable in combat

Acceptance Criteria:
1. Calculate HP as 6 + (2 × VIT)
2. Prevent VIT changes that would result in HP < 2
3. Show feedback when attempting invalid VIT changes
4. Allow VIT changes that keep HP >= 2
5. Apply this rule in both character creation and modification

Related Business Rules: BR-13

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

Rule ID: BR-13
Description: Character creation/editing screen maintains context of the current section (Stats/Background) when opened
Validation: Verify that editing a character opens to the same section that was being viewed
Examples:
- Opening editor from background view shows background section
- Opening editor from stats view shows stats section
Dependencies: None

Rule ID: BR-14
Description: Background changes are automatically saved and propagated in real-time
Validation: 
- Verify changes are saved without explicit save action
- Verify changes are immediately visible in main view
- Verify state is preserved when navigating between views
Examples:
- Editing background text immediately updates the view
- Selecting a template immediately shows the template content
- Changes persist when switching between stats and background views
Dependencies: BR-13 (Screen Context Maintenance)

Rule ID: BR-13
Description: Character HP must always be 2 or greater
Validation: HP is calculated as 6 + (2 × VIT), and must be >= 2
Examples:
- VIT -2 gives HP 2: 6 + (2 × -2) = 2 (valid)
- VIT -3 gives HP 0: 6 + (2 × -3) = 0 (invalid)
Dependencies: BR-08 (Base Character Stats)

## Features

### Character Background System

Rule ID: BR-13
Description: Character backgrounds can be custom or based on prewritten templates with customization
Validation: 
- Verify background can be entered as free text
- Verify prewritten backgrounds can be selected from dropdown
- Verify selected prewritten background text appears in editable field
- Verify edited prewritten background saves as custom version
- Verify all required attributes are present
Examples:
- User enters completely custom background text
- User selects "Noble" background, then customizes the description
- User selects "Merchant" background but keeps original text
Dependencies: BR-01 (Character Creation)

Story ID: JS-46
When I am creating or editing my character's background
I want to either write my own background or customize a prewritten one
So that I can quickly create a rich character history while maintaining creative freedom

Acceptance Criteria:
1. Can enter completely custom background text
2. Can select from prewritten backgrounds via dropdown
3. Selected prewritten background auto-fills the text field
4. Can edit prewritten background text
5. Edited prewritten background saves as custom version
6. All background attributes are properly saved:
   - ID
   - Background name
   - Description
   - Place of birth
   - Parents
   - Siblings

#### Feature Details

The character background system allows players to:
- Choose from prewritten background templates (e.g., Noble, Merchant)
- Create completely custom backgrounds
- Customize prewritten backgrounds
- Save edited backgrounds as new custom versions
- Track detailed background information including:
  - Character's place of birth
  - Family information (parents and siblings)
  - Rich background description

#### Available Background Templates

1. Noble
   - Born into wealth and privilege
   - Raised in a noble house
   - Understanding of leadership and responsibility

2. Merchant
   - Raised in a family of traders
   - Experience with negotiation and commerce
   - Broad perspective from merchant caravan travels

#### State Management

The background editing system follows these principles:
1. Immediate Updates
   - All changes are saved automatically
   - No explicit save button needed for background changes
   - Real-time propagation to all views

2. Template Handling
   - Templates can be selected from dropdown
   - Template content is immediately loaded
   - Customizations are preserved

3. Navigation
   - Background state is preserved when switching views
   - Changes are visible immediately in main view
   - Context is maintained between editing sessions

4. Data Flow
   - Background editor manages local state
   - Changes propagate up through callbacks
   - Main view reflects changes in real-time
   - Repository updates happen automatically

#### Implementation Details

The background system uses a combination of:
- Riverpod for state management
- Automatic save callbacks
- Real-time state propagation
- Context-aware navigation

Key components:
1. BackgroundEditor
   - Handles immediate state updates
   - Manages template selection
   - Provides real-time save callbacks

2. CharacterCreationScreen
   - Maintains background state
   - Handles navigation context
   - Propagates changes to parent

3. CharacterSheetScreen
   - Displays current background state
   - Updates view in real-time
   - Preserves editing context

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

### Background System Tests
1. Auto-save Functionality
   - Verify changes are saved automatically
   - Verify no data loss when switching views
   - Verify real-time updates in main view
   - Verify template selection saves immediately

2. State Management
   - Verify background state preservation
   - Verify proper state propagation
   - Verify context maintenance
   - Verify template state handling

3. Navigation
   - Verify state preservation during navigation
   - Verify immediate updates in main view
   - Verify context restoration
   - Verify proper view transitions

This README reflects the current state of the application, including recent changes to spell management and character editing functionality. All business rules are documented and test scenarios are updated to cover the implemented features.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Development

### Building and Testing

The project includes automated test runs before builds. You can build the project in several ways:

#### Using Android Studio
1. Open the Run/Debug Configurations dropdown (next to the run button)
2. Select one of the following configurations:
   - `Flutter Debug APK with Tests`: Runs tests and builds debug APK
   - `Flutter Debug Windows with Tests`: Runs tests and builds debug Windows app
   - `Flutter Tests Only`: Runs all tests with coverage

You can also create custom run configurations:
1. Click "Edit Configurations..."
2. Click the "+" button and select "Shell Script"
3. Set the "Script text" field to:
   ```bash
   flutter test && flutter build <platform> --debug
   ```
   Replace `<platform>` with: apk, appbundle, web, windows, macos, linux, or ios

#### Using VS Code Tasks
1. Open the Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
2. Type "Tasks: Run Task"
3. Select one of the following tasks:
   - `Flutter: Build Debug APK (with tests)`
   - `Flutter: Build Debug Windows (with tests)`
   - `Flutter: Build Debug Web (with tests)`
   - `Flutter: Run Tests Only`

#### Using Scripts Directly
For Windows (PowerShell):
```powershell
.\scripts\build.ps1 <build_type> <platform>
```

For Linux/macOS (Bash):
```bash
./scripts/build.sh <build_type> <platform>
```

Build types:
- `debug`: Development build with debugging enabled
- `profile`: Performance profiling build
- `release`: Production release build

Platforms:
- `apk`: Android APK
- `appbundle`: Android App Bundle
- `web`: Web application
- `windows`: Windows desktop application
- `macos`: macOS desktop application
- `linux`: Linux desktop application
- `ios`: iOS application

Example:
```bash
./scripts/build.sh debug apk
```

The build scripts will:
1. Run static analysis
2. Execute all tests
3. Only proceed with the build if all tests pass
4. Create the build for the specified platform

### Continuous Integration

The project uses GitHub Actions for CI/CD, which:
- Runs tests on all branches
- Builds debug versions for development branches
- Creates release builds for the main branch
- Uploads build artifacts for each successful build
