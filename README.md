# TTRPG Character Manager

A Flutter application for managing tabletop RPG characters, with support for character creation, spell management, and D&D spell integration.

## Core Features

### Character Management
- Create and edit characters
- Manage character stats (VIT, ATH, WIL)
- Track HP, Life, and Power
- HP to Life conversion system:
  * Excess healing accumulates as temporary HP
  * When temporary HP reaches max HP, converts to 1 Life
  * Visual indicator shows current temporary HP
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

Story ID: JS-49
When I am on the main character screen
I want to be able to change my avatar by clicking on it
So that I can update my character's appearance without going to the edit screen

Acceptance Criteria:
1. Avatar is clickable in the main character screen
2. Clicking the avatar opens the avatar selector dialog
3. New avatar selection is immediately visible in the main screen
4. Changes are persisted and visible in the character list
5. Avatar changes are synchronized across all views
6. Dead characters cannot change their avatar

Related Business Rules: None

## Business Rules

### Character Creation
- Total stat points: 3 points to distribute
- Minimum stat value: -3
- HP calculation: Base 6 + (2 × VIT)
- Life calculation: Base 3 + VIT
- Power calculation: WIL × 3
- Defense calculation: Base defense from category + 2 if shield is active
- HP to Life conversion:
  * When HP is full, excess healing accumulates as temporary HP
  * Temporary HP is displayed as an overlay on the heart icon
  * When temporary HP reaches max HP, converts to 1 Life
  * Conversion only occurs if Life is not at maximum

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

Rule ID: BR-08
Description: Base Character Stats
Each character has three base stats (VIT, ATH, WIL) that determine their derived stats:
- VIT (Vitality): Affects HP and Life
- ATH (Athletics): Affects Defense
- WIL (Willpower): Affects Power and maximum spells

Rules:
- Each stat starts at -3 and can be increased using stat points
- Total of 3 stat points to distribute during character creation
- Stat constraints follow this priority order:
  1. VIT must result in HP >= 2 (HP = 6 + (2 × VIT))
  2. VIT must result in Life >= 1 (Life = 3 + VIT)
  3. All other stats have a minimum of -3
- Power is calculated as (WIL × 3), clamped to minimum 0
- HP to Life conversion:
  * Excess healing accumulates as temporary HP
  * Temporary HP is displayed as an overlay on the heart icon
  * When temporary HP reaches max HP, converts to 1 Life
  * Conversion only occurs if Life is not at maximum

Examples:
- VIT constraint by HP: VIT cannot be less than -2 (6 + (2 × -2) = 2 HP)
- VIT constraint by Life: VIT cannot be less than -2 (3 + -2 = 1 Life)
- ATH and WIL can go down to -3 (minimum stat value)
- Valid stat distribution: VIT -2, ATH -3, WIL -1 (total points: 3)
- Invalid VIT value: VIT -3 (results in HP = 0 and Life = 0)
- Power calculation: WIL -1 gives Power 0 (-3 clamped to 0)
- HP to Life conversion: Healing at max HP (8) accumulates temporary HP
  * After 8 heals at max HP, converts to 1 Life
  * Temporary HP (4/8) shown as overlay on heart icon

Dependencies: None

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

Rule ID: BR-14
Description: Character spells use custom components instead of DnD spell system
Validation: Verify that spells only use the custom component system
Examples:
- Spell components are defined by the game system
- No references to DnD spells or spell levels
- Components will be fetched from a dedicated API (future implementation)
Dependencies: BR-12 (Character Spell Limit)

Rule ID: BR-15
Description: Random character generation for initial character creation
Validation: 
- Verify random generation follows the sequence: species -> name -> stats
- Verify stats follow existing rules (total points: 3, min: -3, max: 3)
- Verify HP calculation rules are respected in random generation
- Verify generated names are appropriate for the selected species
Examples:
- Random species selection from available species list
- Name generation based on selected species
- Random but valid stat distribution (VIT, ATH, WIL)
Dependencies: BR-08 (Base Character Stats), BR-13 (HP Minimum Rule)

Story ID: JS-48
When I am creating a new character
I want to quickly generate a random but valid character base
So that I can start playing faster and potentially discover interesting character combinations

Acceptance Criteria:
1. Random generation button is available on character creation screen
2. Species is randomly selected first
3. Name is randomly generated based on selected species
4. Stats are randomly assigned following existing rules:
   - Total of 3 points to distribute
   - Each stat between -3 and 3
   - VIT must result in HP >= 2
5. User can modify any generated values afterwards
6. Generated character follows all existing character creation rules

Related Business Rules: BR-08, BR-13, BR-15

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

### Check System
The check system allows players to perform skill checks using their character's stats. Here's how it works:

1. **Stat Selection**: Tap on any main stat (VIT, ATH, or WIL) to initiate a check
2. **Difficulty Selection**: Choose from three difficulty levels:
   - Easy (Target Number: 1) - Uses VIT stat
   - Normal (Target Number: 3) - Uses ATH stat
   - Hard (Target Number: 5) - Uses WIL stat
3. **Roll Mechanics**:
   - Base dice: 3 dice
   - Additional dice: Equal to the selected stat value
   - Total dice: 3 + stat value (minimum 1 die)
   - Success: Total roll meets or exceeds the target number
   - Failure: Total roll is less than the target number
4. **Visual Feedback**:
   - Animated dice roll shows the actual rolling process
   - Dice values are displayed during the animation
   - Final result shows total roll and target number
   - Success/failure is color-coded (green/red)
   - Check display automatically closes after viewing results
   - Focus returns to main character screen

Example:
- A character with VIT 2 performing an Easy check:
  - Rolls 5 dice (3 base + 2 from VIT)
  - Needs a total of 1 or higher to succeed
  - Animated dice show the rolling process
  - Result dialog displays total and success/failure
  - After closing result, returns to character screen

- A character with ATH -1 performing a Normal check:
  - Rolls 2 dice (3 base + -1 from ATH, minimum 1)
  - Needs a total of 3 or higher to succeed
  - Animated dice show the rolling process
  - Result dialog displays total and success/failure
  - After closing result, returns to character screen

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

## Development

### Building and Testing

The project includes automated test runs before builds. You can build the project in several ways:

#### Using Android Studio
1. Open the Run/Debug Configurations dropdown (next to the run button)
2. Select one of the following configurations:
   - `Flutter Debug APK with Tests`: Runs tests and builds debug APK
   - `Flutter Debug Windows with Tests`: Runs tests and builds debug Windows app
   - `All Flutter Tests`: Runs all tests in the test directory with coverage
   - `Flutter Tests Only`: Runs widget_test.dart with coverage

You can also create custom run configurations:
1. Click "Edit Configurations..."
2. For running specific test files:
   - Click "+" and select "Flutter Test"
   - Set the "Test File" to your test file
   - Add "--coverage" to "Additional Args" if you want coverage reports
3. For running all tests:
   - Click "+" and select "Shell Script"
   - Set the "Script text" field to:
     ```bash
     flutter test --coverage test/
     ```
4. For test-driven builds:
   - Click "+" and select "Shell Script"
   - Set the "Script text" field to:
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

### Testing

Before running tests for the first time or after changing any mocked classes:

1. Generate mock classes:
   ```bash
   flutter pub run build_runner build
   ```
   Or use the "Generate Mocks" run configuration in Android Studio.

2. Run tests using one of these methods:
   - VS Code: Use the "Flutter: Run Tests Only" task
   - Android Studio: Use "All Flutter Tests" configuration
   - Command line: `flutter test --coverage`

The test suite includes:
- Widget tests with mocked HTTP client for API calls
- Model tests for character stats and validation
- Service tests for business logic

Note: Tests automatically mock external dependencies like:
- HTTP client for D&D API calls
- SharedPreferences for settings
- File system access

Rule ID: BR-16
Description: Spell selection list maintains a consistent, prioritized sort order
Validation: Verify that spells are sorted in the following priority order:
1. Selected spells appear at the top of the list
2. Within each group (selected/unselected), spells are sorted by cost (ascending)
3. Spells with equal cost are sorted alphabetically by name
Examples:
- Selected spells "Fireball (3)" and "Shield (1)" appear before unselected "Blast (1)"
- Within selected spells, "Shield (1)" appears before "Fireball (3)"
- Two cost-1 spells are sorted alphabetically: "Blast" before "Shield"
Dependencies: BR-12 (Character Spell Limit)

Rule ID: BR-17
Description: Manage Spells Option Availability
When a character's maximum power (WIL × 3) is less than the minimum spell cost in the game (1), 
the "Manage Spells" option in the character sheet screen should be disabled.

Validation:
- Character's maximum power must be >= 1 for the Manage Spells option to be enabled
- Maximum power is calculated as WIL × 3
- The button should be disabled and show a tooltip explaining why when maximum power < 1
- The button should be enabled when maximum power >= 1

Examples:
- Character with WIL -1 has max power -3: Manage Spells disabled
- Character with WIL 0 has max power 0: Manage Spells disabled
- Character with WIL 1 has max power 3: Manage Spells enabled
- Character with WIL 2 has max power 6: Manage Spells enabled

Dependencies:
- BR-12 (Spell Selection Sort Order)
- BR-13 (Character HP Minimum)

Rule ID: BR-18
Description: Character Power Calculation and Minimum Value
A character's power is calculated as WIL × 3, but can never be less than 0. This affects:
- Initial character creation
- Stat updates
- Derived stat calculations
- Spell management availability

Validation:
- Power is calculated as WIL × 3
- Power value is clamped to minimum 0
- Characters with negative WIL still have 0 power
- Spell management is disabled when power < 1
- Available power can't go below 0

Examples:
- WIL -1 gives power 0: (-1 × 3 = -3, clamped to 0)
- WIL 0 gives power 0: (0 × 3 = 0)
- WIL 1 gives power 3: (1 × 3 = 3)
- WIL 2 gives power 6: (2 × 3 = 6)

Dependencies:
- BR-17 (Manage Spells Option Availability)
- BR-08 (Base Character Stats)

Rule ID: BR-19
Description: Spell Count Display
The current number of selected spells and maximum selectable spells must be consistently displayed in a (x/n) format, where:
- x = number of currently selected spells
- n = maximum number of selectable spells (based on WIL)
This count must be shown in:
- Spell selection menu header
- Character sheet screen in the abilities section header

Validation:
- Format must be exactly "(x/n)" with no spaces
- Count must update immediately when spells are added/removed
- Count must update when WIL changes affect maximum spells
- Count must be visible without scrolling in both locations
- Maximum spells (n) must follow the Fibonacci sequence based on WIL

Examples:
- New character, no spells: "(0/2)" for WIL 1
- 2 spells selected, WIL 2: "(2/3)"
- 3 spells selected, WIL 3: "(3/5)"
- After removing a spell: "(2/5)"
- After reducing WIL: "(2/3)"

Dependencies:
- BR-12 (Spell Selection Sort Order)
- BR-17 (Manage Spells Option Availability)
- BR-18 (Character Power Calculation)

Rule ID: BR-20
Description: Spell Type Filtering
The spell selection and management screens must provide dynamic type-based filtering:
- Available filter types are derived from the loaded spell list
- Multiple filter types can be selected simultaneously
- Filter selection is visualized using interactive chips
- Selected filters are prominently displayed
- Filters can be toggled on/off
- Empty filter selection shows all spells

Validation:
- Verify filter chips are generated from actual spell types
- Verify multiple filters can be active simultaneously
- Verify toggling a filter updates the spell list immediately
- Verify removing all filters shows all spells
- Verify filter state persists during screen session

Examples:
- Single filter: Selecting "Fire" shows only fire spells
- Multiple filters: Selecting "Fire" and "Ice" shows both types
- Dynamic types: New spell type "Lightning" appears in filters when spells of that type are loaded
- Removing filters: Deselecting "Fire" while "Ice" is selected shows only ice spells
- Clear filters: Deselecting all filters shows complete spell list

Dependencies:
- BR-12 (Character Spell Limit)
- BR-16 (Spell Selection Sort Order)

Rule ID: BR-21
Description: Optional Character Data Cloud Synchronization
Characters and related data must be primarily stored locally, with optional Google Drive synchronization:
- Local storage remains the primary data source
- Google Drive sync must be opt-in through settings
- Users must be able to:
  * Enable/disable sync at any time
  * Switch back to local-only mode
  * See sync status and last sync time
  * Force manual sync
  * Remove cloud data while keeping local data
- When sync is disabled, all operations must work in local-only mode
- When re-enabling sync, system must handle:
  * Initial data merge
  * Conflict resolution using timestamps
  * Clear indication of sync progress

Validation:
- Verify app works completely offline without sync enabled
- Verify enabling sync properly merges local and cloud data
- Verify disabling sync continues with local data only
- Verify sync status is clearly indicated in UI
- Verify manual sync works as expected
- Verify data integrity when switching between modes

Examples:
- User enables sync, local data is uploaded to Drive
- User disables sync, continues working locally
- User re-enables sync, changes are merged
- User removes cloud data, local data remains intact
- Manual sync forces immediate update

Dependencies:
- BR-08 (Base Character Stats)
- BR-12 (Character Spell Limit)
