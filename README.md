 # Rootine - Main

## List of things that can be considered after the presentation
- Create a separate unit, WindowsManager, to fix the size of the terminal windows and block users from resizing it.
- The break timer still counts when the user changes tree in break phase. If the break ends and the user hasn't chosen another tree species, the program automatically returns to the main screen with the current tree. (Proposed by the teacher)
- Tree growth not being constant but rather exponential (meaning slower growth at the beginning and faster growth towards the end) (Proposed by the teacher)

## Changes with respect to original planning
- Implemented a new unit, Utitlies, which contains helper functions, such as the logo, numbers (for the clocks), strings verification, etc
- Added the option "NONE" for options in enumerated types.
- Changed get/set description function names to avoid duplication.
- Introduced private helpers (enterArea, leaveArea,...)
- Remove unnecessary functions/procedures that we thought was useful (askConfirmation, displayMessage, displayError, etc)
- Removal of TStringArray in FileManager since SysUtils already has that
- Introduced booleans in some functions/procedures to report whether the user confirmed or cancelled 
- Some IHMs call functions/procedures that are not initially planned (displayLogin, displayRegister, etc)