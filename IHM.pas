unit IHM;

interface
uses 
    UserData, TreeData, CycleData;

type
    TStartChoice = (IMPORT, REGISTER, QUIT_START);
    TMainMenuChoice = (VIEW_PROFILE, VIEW_FOREST, LOGOUT, START, QUIT_MAINMENU);
    TBrowseAction = (ACTION_NONE, NEXT, PREVIOUS, SELECT);
    TSessionAction = (SESSION_ACTION_NONE, TOGGLE_PAUSE, QUIT_SESSION, CHANGE_TREE);

procedure displayStartMenu(var choice: TStartChoice);
procedure displayMainMenu(var choice: TMainMenuChoice);
procedure displayLogin(var username: String);
procedure displayRegister(var fullname, username, description: String);
procedure displayProfile(user: TUser);
procedure displayForestOverview(forest: TForest; var idx: LongInt);
procedure displayTreeFull(tree: TTree);
procedure displayCycleModeMenu(var mode: TMode);
procedure displayCustomConfiguration(var focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak: LongInt);
procedure displayPomodoroConfiguration();
procedure renderTreePreview(tree: TTree; currentIdx, totalCnt: LongInt);
procedure pollBrowseInput(var action: TBrowseAction);
procedure renderTreeArea(tree: TTree; treePhase: LongInt);
procedure renderClockArea(time: LongInt);
procedure renderInstructionsArea(sessionPhase: TPhaseSession);
procedure pollSessionInput(var action: TSessionAction);
procedure displayCycleEnd(cycle: TCycle; success: Boolean);
procedure displayMessage(msg: String);
procedure displayError(msg: String);
procedure askConfirmation(msg: String; var answer: Boolean);
procedure waitForKey();

implementation

procedure displayStartMenu(var choice: TStartChoice);
begin 

end;

procedure displayMainMenu(var choice: TMainMenuChoice);
begin 

end;

procedure displayLogin(var username: String);
begin 

end;

procedure displayRegister(var fullname, username, description: String);
begin 

end;

procedure displayProfile(user: TUser);
begin 

end; 

procedure displayForestOverview(forest: TForest; var idx: LongInt);
begin 

end;

procedure displayTreeFull(tree: TTree);
begin 

end;

procedure displayCycleModeMenu(var mode: TMode);
begin 

end;

procedure displayCustomConfiguration(var focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak: LongInt);
begin 

end;

procedure displayPomodoroConfiguration();
begin 

end;

procedure renderTreePreview(tree: TTree; currentIdx, totalCnt: LongInt);
begin 

end;

procedure pollBrowseInput(var action: TBrowseAction);
begin 

end;

procedure renderTreeArea(tree: TTree; treePhase: LongInt);
begin 

end;

procedure renderClockArea(time: LongInt);
begin 

end;

procedure renderInstructionsArea(sessionPhase: TPhaseSession);
begin 

end;

procedure pollSessionInput(var action: TSessionAction);
begin 

end;

procedure displayCycleEnd(cycle: TCycle; success: Boolean);
begin 

end;

procedure displayMessage(msg: String);
begin 

end;

procedure displayError(msg: String);
begin 

end;

procedure askConfirmation(msg: String; var answer: Boolean);
begin 

end; 

procedure waitForKey();
begin 

end;

end.

