unit IHM;

interface
uses 
    UserData, TreeData, CycleData, FileManager, crt, SysUtils, Utilities;

type
    TStartChoice = (IMPORT, REGISTER, QUIT_START, NONE_START);
    TMainMenuChoice = (VIEW_PROFILE, VIEW_FOREST, LOGOUT, START, QUIT_MAINMENU, NONE_MAINMENU);
    TBrowseAction = (ACTION_NONE, NEXT, PREVIOUS, SELECT);
    TSessionAction = (SESSION_ACTION_NONE, TOGGLE_PAUSE, QUIT_SESSION, CHANGE_TREE);

procedure displayStartMenu(var choice: TStartChoice);
procedure displayMainMenu(var choice: TMainMenuChoice; user: TUser);
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
    verticalOffset := 18;
    
    {limit the input area to a specific window size to avoid text overflow}
    Window(horizontalOffset, verticalOffset, horizontalOffset + 40, verticalOffset + 20);
    writeln('Bienvenue ! Veuillez choisir une option :');
    writeln;
    writeln('[1]   Importer un compte existant');
    writeln;
    writeln('[2]   Creer un nouveau compte');
    writeln;
    writeln('[3]   Quitter');

    {reset the window to the default size}
    Window(1, 1, BORDER_WIDTH + 10, BORDER_HEIGHT + 10);

    choice := NONE_START;
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

procedure displayMainMenu(var choice: TMainMenuChoice; user: TUser);
var 
    horizontalOffset, verticalOffset: LongInt;
    welcomeMessage: String;
    key: Char;
begin 
    horizontalOffset := 40;
    verticalOffset := 18;

    welcomeMessage := 'Salut, ' + getName(user) + ' ! Pret a commencer une session de travail ?';
    gotoXY((BORDER_WIDTH - Length(welcomeMessage)) div 2, verticalOffset - 2);
    writeln(welcomeMessage);
    writeln;

    {limit the input area to a specific window size}
    Window(horizontalOffset, verticalOffset, horizontalOffset + 40, verticalOffset + 20);
    writeln('Veuillez choisir une option :');
    writeln;
    writeln('[1]   Demarrer une session de travail');
    writeln;
    writeln('[2]   Voir mon profil');
    writeln;
    writeln('[3]   Voir ma foret');
    writeln;
    writeln('[4]   Se deconnecter');
    writeln;
    writeln('[5]   Quitter');

    {reset the window to the default size}
    Window(1, 1, BORDER_WIDTH + 10, BORDER_HEIGHT + 10);

    choice := NONE_MAINMENU;
    repeat
        key := ReadKey;

        if (key = '1') then
            choice := START
        else if (key = '2') then
            choice := VIEW_PROFILE
        else if (key = '3') then
            choice := VIEW_FOREST
        else if (key = '4') then
            choice := LOGOUT
        else if (key = '5') then
            choice := QUIT_MAINMENU;
    until choice in [VIEW_PROFILE, VIEW_FOREST, LOGOUT, START, QUIT_MAINMENU];
end;

procedure displayLogin(var username: String);
var
    horizontalOffset, verticalOffset: LongInt;
begin 
    horizontalOffset := 30;
    verticalOffset := 18;

    {limit the input area to a specific window size to avoid text overflow}
    Window(horizontalOffset, verticalOffset, horizontalOffset + 50, verticalOffset + 20);

    {enter username. if doesn't exist or empty, ask again}
    repeat
        GoToXY(1, 1);
        clreol;
        write('Veuillez entrer votre nom d''utilisateur : ');
        readln(username);

        if not userExists(username) and (username <> '') then
        begin
            GoToXY(1, 2);
            clreol;
            writeln('Utilisateur inexistant. Veuillez reessayer.');
        end;
    until userExists(username) or (username = '');

    {reset the window to the default size}
    Window(1, 1, BORDER_WIDTH + 10, BORDER_HEIGHT + 10);
end;

procedure displayRegister(var fullname, username, description: String);
var
    horizontalOffset, verticalOffset: LongInt;
begin 
    horizontalOffset := 15;
    verticalOffset := 18;

    {limit the input area to a specific window size to avoid text overflow}
    Window(horizontalOffset, verticalOffset, horizontalOffset + 90, verticalOffset + 20);

    {display instructions}
    writeln('Attention ! ');
    writeln('- Les characteres speciaux ne sont pas autorises dans le nom complet.');
    writeln('- Les espaces et les caracteres speciaux ne sont pas autorises dans le nom d''utilisateur.');
    writeln('- Le nom d''utilisateur doit etre unique et entre 1 et 20 caracteres.');
    {enter full name, if invalid, ask again}
    writeln;
    repeat 
        GoToXY(1, 6);
        clreol;
        write('Veuillez entrer votre nom complet : ');
        readln(fullname);
        
        {remove previous error messages and clear the line for username input}
        writeln;
        GoToXY(1, 7);
        clreol;

        {display error message if full name is invalid}
        if not isValidFullname(fullname) then
        begin
            writeln('Nom complet invalide. Veuillez reessayer.');
        end;
    until isValidFullname(fullname);

    {enter username. if already exists or empty or invalid, ask again}
    repeat 
        writeln;
        GoToXY(1, 8);
        clreol;
        write('Veuillez entrer votre nom d''utilisateur : ');
        readln(username);
        
        {remove previous error messages and clear the line for description input}
        writeln;
        GoToXY(1, 9);
        clreol; 

        {display error messages if username is invalid, empty, or already exists}
        if (userExists(username)) then
        begin
            writeln('Nom d''utilisateur deja existant. Veuillez reessayer.');
        end
        else if not isValidUsername(username) then
        begin
            writeln('Nom d''utilisateur invalide. Veuillez reessayer.');
        end;
    until (username <> '') and (not userExists(username)) and isValidUsername(username);

    writeln;
    write('Veuillez entrer une description de votre profil : ');
    readln(description);

    {reset the window to the default size}
    Window(1, 1, BORDER_WIDTH + 10, BORDER_HEIGHT + 10);
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

