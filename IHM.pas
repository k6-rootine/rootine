unit IHM;

interface
uses 
    UserData, TreeData, CycleData, crt;

type
    TStartChoice = (IMPORT, REGISTER, QUIT_START, NONE);
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
procedure displayOuterBorder();
procedure displayInnerBorder();
procedure waitForKey();

const 
    BORDER_CHAR = '*';
    BORDER_WIDTH = 120;
    BORDER_HEIGHT = 35; { dimension w/o border is 118x33, w/ border is 120x35 }
    BORDER_TREE_VERTICAL = 80; { dimension of tree w/ border is 80x35, w/o border is 78x33 }
    BORDER_CLOCK_HORIZONTAL = 20; { dimension of clock area w/ border is 40x20, w/o border is 38x18 }

implementation

procedure displayOuterBorder();
var 
    width, height : LongInt;
begin 
    GoToXY(1, 1);
    for height := 1 to BORDER_HEIGHT do
    begin
        if (height = 1) or (height = BORDER_HEIGHT) then
        begin 
            for width := 1 to BORDER_WIDTH do
                write(BORDER_CHAR);
        end
        else 
        begin 
            GoToXY(1, height);
            write(BORDER_CHAR);
            GoToXY(BORDER_WIDTH, height);
            write(BORDER_CHAR);

            if (height = BORDER_HEIGHT - 1) then
                writeln;
        end;
    end;
end;

procedure displayInnerBorder();
var 
    width, height : LongInt;
begin 
    {display the separation line between the tree and the clock/instructions areas}
    GotoXY(BORDER_TREE_VERTICAL, 1);
    for height := 2 to BORDER_HEIGHT - 1 do 
    begin 
        GotoXY(BORDER_TREE_VERTICAL, height);
        write(BORDER_CHAR);
    end;

    {display the separation line between the clock and the instructions areas}
    GotoXY(BORDER_TREE_VERTICAL + 1, BORDER_CLOCK_HORIZONTAL);
    for width := BORDER_TREE_VERTICAL + 1 to BORDER_WIDTH - 1 do
    begin
        write(BORDER_CHAR);
    end;
end;

procedure displayStartMenu(var choice: TStartChoice);
var 
    horizontalOffset, verticalOffset: LongInt;
    key: Char;
begin 
    horizontalOffset := 40;
    verticalOffset := 20;

    gotoXY(horizontalOffset, verticalOffset); 
    write('Bienvenue ! Veuillez choisir une option :');
    gotoXY(horizontalOffset, verticalOffset + 1);
    write('1. Importer un compte existant');
    gotoXY(horizontalOffset, verticalOffset + 2);
    write('2. Creer un nouveau compte');
    gotoXY(horizontalOffset, verticalOffset + 3);
    write('3. Quitter');

    choice := NONE;
    repeat
        key := ReadKey;

        if (key = '1') then
            choice := IMPORT
        else if (key = '2') then
            choice := REGISTER
        else if (key = '3') then
            choice := QUIT_START;
    until choice in [IMPORT, REGISTER, QUIT_START];
end;

procedure displayMainMenu(var choice: TMainMenuChoice);
begin 

end;

procedure displayLogin(var username: String);
begin 
    GoToXY(30, 20);
    write('Veuillez entrer votre nom d''utilisateur : ');
    readln(username);
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
    readkey;
end;

end.

