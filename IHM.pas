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
procedure displayRegister(var firstname, username, description: String);
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
procedure renderStatsArea();

const 
    BORDER_CHAR = '*';
    BORDER_WIDTH = 121;
    BORDER_HEIGHT = 35; { dimension w/o border is 118x33, w/ border is 120x35 }
    BORDER_TREE_VERTICAL = 80; { dimension of tree w/ border is 80x35, w/o border is 78x33 }
    BORDER_CLOCK_HORIZONTAL = 13; { dimension of clock area w/ border is 40x20, w/o border is 38x18 }
    BORDER_STATS_HORIZONTAL = 20;

implementation

{ restricts the output to a rectangular area of the console (corners are inclusive) }
procedure enterArea(x1, y1, x2, y2: LongInt);
begin
    Window(x1, y1, x2, y2);
    GoToXY(1, 1);
end;

{ resets the output to the whole console }
procedure leaveArea();
begin
    Window(1, 1, BORDER_WIDTH + 10, BORDER_HEIGHT + 10);
end;

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

    {display the separation line between the clock and the stats areas}
    GotoXY(BORDER_TREE_VERTICAL + 1, BORDER_CLOCK_HORIZONTAL);
    for width := BORDER_TREE_VERTICAL + 1 to BORDER_WIDTH - 1 do
    begin
        write(BORDER_CHAR);
    end;

    {display the separation line between the stats and instructions areas}
    GotoXY(BORDER_TREE_VERTICAL + 1, BORDER_STATS_HORIZONTAL);
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
    enterArea(horizontalOffset, verticalOffset, horizontalOffset + 40, verticalOffset + 20);
    writeln('Bienvenue ! Veuillez choisir une option :');
    writeln;
    writeln('[1]   Importer un compte existant');
    writeln;
    writeln('[2]   Creer un nouveau compte');
    writeln;
    writeln('[3]   Quitter');

    {reset the window to the default size}
    leaveArea();

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
    {center the welcome message horizontally}
    gotoXY((BORDER_WIDTH - Length(welcomeMessage)) div 2, verticalOffset - 2);
    writeln(welcomeMessage);
    writeln;

    {limit the input area to a specific window size}
    enterArea(horizontalOffset, verticalOffset, horizontalOffset + 40, verticalOffset + 20);
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
    leaveArea();

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
    enterArea(horizontalOffset, verticalOffset, horizontalOffset + 50, verticalOffset + 20);

    {enter username. if doesn't exist or empty, ask again}
    repeat
        GoToXY(1, 1);
        clreol;
        write('Veuillez entrer votre nom d''utilisateur : ');
        readln(username);
        username := lowercase(username);

        if not userExists(username) and (username <> '') then
        begin
            GoToXY(1, 2);
            clreol;
            writeln('Utilisateur inexistant. Veuillez reessayer.');
        end;
    until userExists(username) or (username = '');

    {reset the window to the default size}
    leaveArea();
end;

procedure displayRegister(var firstname, username, description: String);
var
    horizontalOffset, verticalOffset: LongInt;
begin 
    horizontalOffset := 15;
    verticalOffset := 18;

    {limit the input area to a specific window size to avoid text overflow}
    enterArea(horizontalOffset, verticalOffset, horizontalOffset + 90, verticalOffset + 20);

    {display instructions}
    writeln('Attention ! ');
    writeln('- Les caracteres speciaux, sauf le tiret et l''apostrophe, ne sont pas autorises dans le prenom.');
    writeln('- Les espaces et les caracteres speciaux ne sont pas autorises dans le nom d''utilisateur.');
    writeln('- Le nom d''utilisateur doit etre unique et entre 1 et 30 caracteres.');
    {enter full name, if invalid, ask again}
    writeln;
    repeat 
        GoToXY(1, 6);
        clreol;
        write('Veuillez entrer votre prenom : ');
        readln(firstname);
        
        {remove previous error messages and clear the line for username input}
        writeln;
        GoToXY(1, 7);
        clreol;

        {display error message if full name is invalid}
        if not isValidName(firstname) then
        begin
            writeln('Prenom invalide. Veuillez reessayer.');
        end;
    until isValidName(firstname);

    {enter username. if already exists or empty or invalid, ask again}
    repeat 
        writeln;
        GoToXY(1, 8);
        clreol;
        write('Veuillez entrer votre nom d''utilisateur : ');
        readln(username);
        username := lowercase(username);
        
        GoToXY(1, 8);
        clreol;
        write('Veuillez entrer votre nom d''utilisateur : ', username);

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

    leaveArea();
end;

procedure displayProfile(user: TUser);
var
    horizontalOffset, verticalOffset: LongInt;
    joinDate: TDate;
    forest: TForest;
begin 
    {variables}
    horizontalOffset := 30;
    verticalOffset := 18;
    joinDate := getJoinDate(user);
    forest := getForest(user);

    {limit the display area}
    enterArea(horizontalOffset, verticalOffset, horizontalOffset + 60, verticalOffset + 20);

    writeln('Nom d''utilisateur : ', getUsername(user));
    writeln('Prenom : ', getName(user));
    writeln('Date de creation du compte : ', Format('%.2d/%.2d/%4d', [getDay(joinDate), getMonth(joinDate), getYear(joinDate)]));
    writeln('Description : ', getUserDescription(user));
    writeln('Nombre de cycles completes : ', getNbCyclesDone(user));
    writeln('Nombre de sessions completees : ', getNbSessionsDone(user));
    writeln('Temps total de concentration : ', Format('%.2d:%.2d:%.2d', [getTotalFocusTime(user) div 3600, getTotalFocusTime(user) div 60 mod 60, getTotalFocusTime(user) mod 60]));
    writeln('Nombre d''especes differentes ayant pousse : ', getNbSpecies(forest));
    {writeln('Nombre total d''arbres ayant poussé : ', getNbTreesGrown(user));} 
    {the function returns for only one species so this needs to be worked on}

    leaveArea();
end; 

procedure displayForestOverview(forest: TForest; var idx: LongInt);
begin 

end;

procedure displayTreeFull(tree: TTree);
begin 

end;

procedure displayCycleModeMenu(var mode: TMode);
var 
    key: Char;
    isReturn: Boolean;
begin
    isReturn := False;
    mode := NONE_MODE;

    repeat
        clrscr;
        writeln('Veuillez choisir un mode de cycle :');
        writeln('[1]   Mode Pomodoro ');
        writeln('[2]   Mode Personnalise');
        writeln('[3]   Retour');

        key := ReadKey;
        if (key = '1') then
            mode := POMODORO
        else if (key = '2') then
            mode := CUSTOM
        else if (key = '3') then
            isReturn := True;
    until (mode in [POMODORO, CUSTOM]) or isReturn;
end;

procedure displayCustomConfiguration(var focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak: LongInt);
begin 
    clrscr;
    writeln('Veuillez entrer les parametres de configuration du mode personnalise :');
    writeln('Attention : La duree maximale de chaque parametre est de 90 minutes.');
    writeln('Duree de concentration (en minutes) : ');
    read(focusDuration);
    writeln('Duree de pause courte (en minutes) : ');
    read(shortBreakDuration);
    writeln('Duree de pause longue (en minutes) : ');
    read(longBreakDuration);
    writeln('Nombre de sessions avant une pause longue : ');
    read(nbSessionsBeforeLongBreak);

    clrscr;
    writeln('Ci-dessous la configuration que vous avez choisie :');
    writeln('Duree de concentration : ', focusDuration, ' minutes');
    writeln('Duree de pause courte : ', shortBreakDuration, ' minutes');
    writeln('Duree de pause longue : ', longBreakDuration, ' minutes');
    writeln('Nombre de sessions avant une pause longue : ', nbSessionsBeforeLongBreak);

    writeln('Appuyez sur une touche pour continuer...');
    readkey;
end;

procedure displayPomodoroConfiguration();
begin 
    clrscr;
    writeln('Configuration du mode Pomodoro :');
    writeln('Duree de concentration : 25 minutes');
    writeln('Duree de pause courte : 5 minutes');
    writeln('Duree de pause longue : 15 minutes');
    writeln('Nombre de sessions avant une pause longue : 4');

    writeln('Appuyez sur une touche pour continuer...');
    readkey;
end;

procedure renderTreePreview(tree: TTree; currentIdx, totalCnt: LongInt);
begin 

end;

procedure pollBrowseInput(var action: TBrowseAction);
begin 

end;

procedure renderTreeArea(tree: TTree; treePhase: LongInt);
var 
    vertical, horizontal: LongInt;
    phase: TPhase;
begin 
    phase := getPhase(tree, treePhase);

    for vertical := 2 to MAX_VERTICAL - 1 do
    begin
        for horizontal := 2 to MAX_HORIZONTAL - 1 do
        begin
            GoToXY(horizontal, vertical);
            TextColor(Byte(TColor(getColor(phase, horizontal, vertical))));
            write(getElement(phase, horizontal, vertical));
        end;
        writeln;
    end;

    TextColor(White);
    GoToXY(1, 1);
end;

procedure renderDigit(offsetX, digit: LongInt);
begin
    { draws one clock symbol (digit 0..9, or -1 for the colon) at a horizontal offset inside the clock area }
    enterArea(BORDER_TREE_VERTICAL + offsetX, 4, BORDER_WIDTH - 1, BORDER_CLOCK_HORIZONTAL);
    displayClockNumber(digit);
    leaveArea();
end;

procedure renderClockArea(time: LongInt);
var
    m1, m2, s1, s2: LongInt;
begin
    { calculate each component of the clock }
    m1 := (time div 60) div 10;
    m2 := (time div 60) mod 10;
    s1 := (time - (time div 60) * 60) div 10;
    s2 := (time - (time div 60) * 60) mod 10;

    renderDigit(4, m1);
    renderDigit(12, m2);
    renderDigit(19, -1); {colon}
    renderDigit(24, s1);
    renderDigit(32, s2);
end;

procedure renderInstructionsArea(sessionPhase: TPhaseSession);
begin 
    enterArea(BORDER_TREE_VERTICAL + 3, BORDER_STATS_HORIZONTAL + 2, BORDER_WIDTH - 1, BORDER_HEIGHT - 1);
    ClrScr;

    if sessionPhase = FOCUS then
    begin 
        writeln('[1] Pause/Resume');
        writeln;
        writeln('[2] Quitter la session');
    end
    else
    begin 
        writeln('[1] Pause/Resume');
        writeln;
        writeln('[2] Quitter la session');
        writeln;
        writeln('[3] Passer a la prochaine session');
        writeln;
        writeln('[4] Changer d''arbre');
    end;

    leaveArea();
end;

procedure renderStatsArea();
begin
    enterArea(BORDER_TREE_VERTICAL + 3, BORDER_CLOCK_HORIZONTAL + 2, BORDER_WIDTH - 1, BORDER_STATS_HORIZONTAL - 1);
    ClrScr;

    writeln('Phase actuelle: ');
    writeln;
    writeln('Session: ');

    leaveArea();
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

