unit IHM;

interface
uses 
    UserData, TreeData, CycleData, FileManager, crt, SysUtils, Utilities;

type
    TStartChoice = (IMPORT, REGISTER, QUIT_START, NONE_START);
    TMainMenuChoice = (VIEW_PROFILE, VIEW_FOREST, LOGOUT, START, QUIT_MAINMENU, NONE_MAINMENU);
    TTreeChoice = (CONFIRM_TREE, PREVIEW_TREE, CANCEL_TREE, NONE_TREECHOICE);
    TSessionAction = (TOGGLE_PAUSE, QUIT_SESSION, CHANGE_TREE, SKIP_PHASE, NONE_SA);

procedure displayStartMenu(var choice: TStartChoice);
procedure displayMainMenu(var choice: TMainMenuChoice; user: TUser);
procedure displayLogin(var username: String);
procedure displayRegister(var firstname, username, description: String);
procedure displayProfile(user: TUser);
procedure displayForestOverview(forest: TForest; var idx: LongInt);
procedure displayTreeFull(tree: TTree);
procedure displayCycleModeMenu(var mode: TMode);
procedure displayCustomConfiguration(var focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak: LongInt; var confirmed: Boolean);
procedure displayPomodoroConfiguration(focus, shortBreak, longBreak, nbSessions: LongInt; var confirmed: Boolean);
procedure displayTreeList(species: TStringArray; var choice: LongInt);
procedure displayTreeChoice(speciesName: String; var action: TTreeChoice);
procedure renderTreeArea(tree: TTree; treePhase: LongInt);
procedure renderClockArea(time: LongInt);
procedure renderInstructionsArea(sessionPhase: TPhaseSession);
procedure pollSessionInput(sessionPhase: TPhaseSession; var action: TSessionAction);
procedure displayCycleEnd(cycle: TCycle; success: Boolean);
procedure displayOuterBorder();
procedure displayInnerBorder();
procedure drawScreenHeader(heading: String);
procedure initialiseScreen();
procedure renderStatsArea(phase: TPhaseSession; session: LongInt; speciesName: String; isPaused: Boolean);

const
    BORDER_CHAR = '*';
    BORDER_WIDTH = 121;
    BORDER_HEIGHT = 35; { dimension w/o border is 118x33, w/ border is 120x35 }
    BORDER_TREE_VERTICAL = 80; { dimension of tree w/ border is 80x35, w/o border is 78x33 }
    BORDER_CLOCK_HORIZONTAL = 13; { dimension of clock area w/ border is 40x20, w/o border is 38x18 }
    BORDER_STATS_HORIZONTAL = 20;

    LOGO_X = 30; { position of the RootineLogo }
    LOGO_Y = 5;
    HEADING_ROW = 16; { row of the centred heading under the logo }
    CONTENT_ROW = 18; { first row of the content area under the heading }
    MENU_X = 40; { left column of the menus and choices }
    LIST_X = 30; { left column of the lists, login and profile }
    FORM_X = 15; { left column of the register form }
    DEFAULT_COLOR = crt.White; { colour of all the text; any other colour is local and must restore this one }

implementation

procedure enterArea(x1, y1, x2, y2: LongInt);
begin
    { restricts the output to a rectangular area of the console (corners/borders are included) }
    Window(x1, y1, x2, y2);
    GoToXY(1, 1);
end;

procedure leaveArea();
begin
    { resets the output to the whole console }
    Window(1, 1, BORDER_WIDTH + 10, BORDER_HEIGHT + 10);
end;

function phaseLabel(phase: TPhaseSession): String;
begin
    { returns the French label of a session phase }
    if phase = FOCUS then
        phaseLabel := 'Concentration'
    else if phase = SHORT_BREAK then
        phaseLabel := 'Pause courte'
    else if phase = LONG_BREAK then
        phaseLabel := 'Pause longue'
    else
        phaseLabel := '';
end;

function readInteger(prompt: String; minValue, maxValue: LongInt): LongInt;
var
    input: String;
    value, code, row: LongInt;
    isValid: Boolean;
begin
    row := WhereY;
    repeat
        GoToXY(1, row);
        clreol;
        write(prompt);
        readln(input);
        val(input, value, code);
        isValid := (code = 0) and (value >= minValue) and (value <= maxValue);

        GoToXY(1, row + 1);
        clreol;
        if not isValid then
            write('Valeur invalide : entrez un entier entre ', minValue, ' et ', maxValue, '.');
    until isValid;
    readInteger := value;
end;

{ writes text in the current window, going to the next line before a word that would not fit; width is the number of columns of the window }
procedure writeWrapped(text: String; width: LongInt);
var
    w: String;
    lineLength, spacePos: LongInt;
begin
    lineLength := 0;
    text := text + ' ';

    while length(text) > 0 do
    begin
        spacePos := pos(' ', text);
        w := copy(text, 1, spacePos - 1);
        delete(text, 1, spacePos);

        if w <> '' then
        begin
            {a word longer than a whole line is cut}
            while length(w) >= width do
            begin
                if lineLength > 0 then
                begin
                    writeln;
                    lineLength := 0;
                end;
                writeln(copy(w, 1, width - 1));
                delete(w, 1, width - 1);
            end;

            {lines stay one character shorter than the window so that a full line does not wrap by itself}
            if (lineLength > 0) and (lineLength + 1 + length(w) > width - 1) then
            begin
                writeln;
                lineLength := 0;
            end;

            if lineLength > 0 then
            begin
                write(' ');
                lineLength := lineLength + 1;
            end;
            write(w);
            lineLength := lineLength + length(w);
        end;
    end;
    writeln;
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

procedure drawVerticalSeparator();
var
    vertical : LongInt;
begin
    { draws the vertical line between the tree (left) and the right-hand panel }
    for vertical := 2 to BORDER_HEIGHT - 1 do
    begin
        GoToXY(BORDER_TREE_VERTICAL, vertical);
        write(BORDER_CHAR);
    end;
end;

procedure drawHorizontalSeparator(y: LongInt);
var
    horizontal : LongInt;
begin
    { draws a horizontal line across the right-hand panel at the specified y-coordinate }
    for horizontal := BORDER_TREE_VERTICAL + 1 to BORDER_WIDTH - 1 do
    begin
        GoToXY(horizontal, y);
        write(BORDER_CHAR);
    end;
end;

procedure displayInnerBorder();
begin
    {display the separation line between the tree and the clock/stats/instructions areas}
    drawVerticalSeparator();

    {display the separation line between the clock and the stats areas}
    drawHorizontalSeparator(BORDER_CLOCK_HORIZONTAL);
    
    {display the separation line between the stats and instructions areas}
    drawHorizontalSeparator(BORDER_STATS_HORIZONTAL);
end;

procedure drawScreenHeader(heading: String);
begin
    { clears the screen and draws the logo, the outer border and a centred heading (the heading may be empty) }
    clrscr;
    RootineLogo(LOGO_X, LOGO_Y);
    displayOuterBorder();
    GoToXY((BORDER_WIDTH - length(heading)) div 2, HEADING_ROW);
    write(heading);
end;

{ sets the default colour of the program and clears the screen; to be called once at startup }
procedure initialiseScreen();
begin
    TextColor(DEFAULT_COLOR);
    clrscr;
end;

procedure displayStartMenu(var choice: TStartChoice);
var 
    key: Char;
begin 
    {limit the input area to a specific window size to avoid text overflow}
    enterArea(MENU_X, CONTENT_ROW, MENU_X + 40, CONTENT_ROW + 20);
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
        key := readkey;

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
    welcomeMessage: String;
    key: Char;
begin 
    if getName(user) = '' then
        welcomeMessage := 'Salut, ' + getUsername(user) + ' ! Pret a commencer une session de travail ?'
    else
        welcomeMessage := 'Salut, ' + getName(user) + ' ! Pret a commencer une session de travail ?';
    
    {center the welcome message horizontally}
    GoToXY((BORDER_WIDTH - length(welcomeMessage)) div 2, HEADING_ROW);
    writeln(welcomeMessage);
    writeln;

    {limit the input area to a specific window size}
    enterArea(MENU_X, CONTENT_ROW, MENU_X + 40, CONTENT_ROW + 20);
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
        key := readkey;

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
begin 
    {limit the input area to a specific window size to avoid text overflow}
    enterArea(LIST_X, CONTENT_ROW, LIST_X + 50, CONTENT_ROW + 20);

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
begin 
    {limit the input area to a specific window size to avoid text overflow}
    enterArea(FORM_X, CONTENT_ROW, FORM_X + 90, CONTENT_ROW + 20);

    {display instructions}
    writeln('Attention ! ');
    writeln('- Les caracteres speciaux, sauf le tiret et l''apostrophe, ne sont pas autorises dans le prenom.');
    writeln('- Les espaces et les caracteres speciaux ne sont pas autorises dans le nom d''utilisateur.');
    writeln('- Le nom d''utilisateur doit etre unique et entre 1 et 30 caracteres.');
    {enter full name, if invalid, ask again}
    writeln;
    repeat 
        GoToXY(1, 7);
        clreol;
        write('Veuillez entrer votre prenom : ');
        readln(firstname);
        
        {remove previous error messages and clear the line for username input}
        writeln;
        GoToXY(1, 8);
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
        GoToXY(1, 9);
        clreol;
        write('Veuillez entrer votre nom d''utilisateur : ');
        readln(username);
        username := lowercase(username);
        
        GoToXY(1, 10);
        clreol;
        write('Veuillez entrer votre nom d''utilisateur : ', username);

        {remove previous error messages and clear the line for description input}
        writeln;
        GoToXY(1, 11);
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
    i, totalTrees: LongInt;
    joinDate: TDate;
    forest: TForest;
begin
    {variables}
    joinDate := getJoinDate(user);
    forest := getForest(user);

    { calculate the total number of trees grown}
    totalTrees := 0;
    for i := 1 to getNbSpecies(forest) do
        totalTrees := totalTrees + getNbTreesGrown(forest, i);

    {limit the display area}
    enterArea(LIST_X, CONTENT_ROW, LIST_X + 60, CONTENT_ROW + 20);

    {display all information}
    writeln('Nom d''utilisateur : ', getUsername(user));
    writeln('Prenom : ', getName(user));
    writeln('Date de creation du compte : ', format('%.2d/%.2d/%4d', [getDay(joinDate), getMonth(joinDate), getYear(joinDate)]));
    writeWrapped('Description : ' + getUserDescription(user), 61);
    writeln('Nombre de cycles completes : ', getNbCyclesDone(user));
    writeln('Nombre de sessions completees : ', getNbSessionsDone(user));
    writeln('Temps total de concentration : ', format('%.2d:%.2d:%.2d', [getTotalFocusTime(user) div 3600, getTotalFocusTime(user) div 60 mod 60, getTotalFocusTime(user) mod 60]));
    writeln('Nombre d''especes differentes ayant pousse : ', getNbSpecies(forest));
    writeln('Nombre total d''arbres ayant pousse : ', totalTrees);

    leaveArea();
end; 

procedure displayForestOverview(forest: TForest; var idx: LongInt);
const
    ROWS_PER_COLUMN = 7;
    COLUMN_WIDTH = 30;
var
    i, nbSpecies: LongInt;
    heading: String;
begin
    nbSpecies := getNbSpecies(forest);

    if nbSpecies = 0 then
        heading := 'Votre foret est vide pour le moment.'
    else
        heading := 'Votre foret : choisissez une espece a afficher :';
    drawScreenHeader(heading);

    if nbSpecies = 0 then
    begin
        enterArea(LIST_X, CONTENT_ROW, BORDER_WIDTH - 2, BORDER_HEIGHT - 2);
        writeln('Terminez une session de concentration pour faire pousser votre premier arbre.');
        writeln;
        write('Appuyez sur une touche pour revenir...');
        leaveArea();
        readkey;
        idx := 0;
    end
    else
    begin
        {species are listed in columns of ROWS_PER_COLUMN entries, with their tree count}
        enterArea(LIST_X, CONTENT_ROW, BORDER_WIDTH - 2, BORDER_HEIGHT - 2);
        for i := 1 to nbSpecies do
        begin
            GoToXY(1 + ((i - 1) div ROWS_PER_COLUMN) * COLUMN_WIDTH, 1 + ((i - 1) mod ROWS_PER_COLUMN));
            write('[', i, ']   ', getForestSpeciesName(forest, i), ' (x', getNbTreesGrown(forest, i), ')');
        end;
        GoToXY(1, ROWS_PER_COLUMN + 2);
        write('[0]   Retour');

        GoToXY(1, ROWS_PER_COLUMN + 4);
        idx := readInteger('Votre choix : ', 0, nbSpecies);
        leaveArea();
    end;
end;

procedure displayTreeFull(tree: TTree);
begin
    clrscr;
    displayOuterBorder();
    drawVerticalSeparator();
    
    {the tree is shown in its final growth phase}
    renderTreeArea(tree, getNbPhases(tree));

    enterArea(BORDER_TREE_VERTICAL + 3, 3, BORDER_WIDTH - 4, BORDER_HEIGHT - 1);
    writeln(uppercase(getSpeciesName(tree)));
    writeln('Apercu de l''etat final');
    writeln;
    writeWrapped(getTreeDescription(tree), BORDER_WIDTH - 1 - (BORDER_TREE_VERTICAL + 3) + 1);
    writeln;
    writeln;
    writeln('Appuyez sur une touche pour revenir');

    leaveArea();
    readkey;
end;

procedure displayCycleModeMenu(var mode: TMode);
var
    key: Char;
    isReturn: Boolean;
    heading: String;
begin
    isReturn := False;
    mode := NONE_MODE;
    heading := 'Veuillez choisir un mode de cycle :';

    drawScreenHeader(heading);

    enterArea(MENU_X, CONTENT_ROW, MENU_X + 40, CONTENT_ROW + 20);
    writeln('[1]   Mode Pomodoro');
    writeln;
    writeln('[2]   Mode Personnalise');
    writeln;
    write('[3]   Retour');
    leaveArea();

    repeat
        key := readkey;

        if (key = '1') then
            mode := POMODORO
        else if (key = '2') then
            mode := CUSTOM
        else if (key = '3') then
            isReturn := True;
    until (mode in [POMODORO, CUSTOM]) or isReturn;
end;

procedure printConfiguration(focus, shortBreak, longBreak, nbSessions: LongInt);
begin
    writeln('Duree de concentration : ', focus, ' minutes');
    writeln;
    writeln('Duree de pause courte : ', shortBreak, ' minutes');
    writeln;
    writeln('Duree de pause longue : ', longBreak, ' minutes');
    writeln;
    writeln('Sessions avant une pause longue : ', nbSessions);
end;

procedure displayCustomConfiguration(var focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak: LongInt; var confirmed: Boolean);
const
    MAX_MINUTES = 90;
    MAX_NB_SESSIONS = 99;
var
    key: Char;
    heading: String;
begin
    repeat
        {form: one field every two rows, the row below each field is used by readInteger for its error message}
        heading := 'Mode personnalise : entrez vos parametres';
        drawScreenHeader(heading);

        enterArea(LIST_X, CONTENT_ROW, BORDER_WIDTH - 2, BORDER_HEIGHT - 2);
        GoToXY(1, 1);
        focusDuration := readInteger('Duree de concentration (1-' + inttostr(MAX_MINUTES) + ' minutes) : ', 1, MAX_MINUTES);
        GoToXY(1, 3);
        shortBreakDuration := readInteger('Duree de pause courte (1-' + inttostr(MAX_MINUTES) + ' minutes) : ', 1, MAX_MINUTES);
        GoToXY(1, 5);
        longBreakDuration := readInteger('Duree de pause longue (1-' + inttostr(MAX_MINUTES) + ' minutes) : ', 1, MAX_MINUTES);
        GoToXY(1, 7);
        nbSessionsBeforeLongBreak := readInteger('Sessions avant une pause longue (1-' + inttostr(MAX_NB_SESSIONS) + ') : ', 1, MAX_NB_SESSIONS);
        leaveArea();

        {summary and choice}
        heading := 'Votre configuration :';
        drawScreenHeader(heading);

        enterArea(LIST_X, CONTENT_ROW, BORDER_WIDTH - 2, BORDER_HEIGHT - 2);
        printConfiguration(focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak);
        writeln;
        writeln('[1]   Confirmer et demarrer');
        writeln;
        writeln('[2]   Modifier les parametres');
        writeln;
        write('[3]   Annuler');
        leaveArea();

        repeat
            key := readkey;
        until (key = '1') or (key = '2') or (key = '3');
    until key <> '2';

    confirmed := (key = '1');
end;

procedure displayPomodoroConfiguration(focus, shortBreak, longBreak, nbSessions: LongInt; var confirmed: Boolean);
var
    key: Char;
    heading: String;
begin
    heading := 'Mode Pomodoro';
    drawScreenHeader(heading);

    enterArea(LIST_X, CONTENT_ROW, BORDER_WIDTH - 2, BORDER_HEIGHT - 2);
    printConfiguration(focus, shortBreak, longBreak, nbSessions);
    writeln;
    writeln('[1]   Confirmer et demarrer');
    writeln;
    write('[2]   Annuler');
    leaveArea();

    repeat
        key := readkey;
    until (key = '1') or (key = '2');

    confirmed := (key = '1');
end;

procedure displayTreeList(species: TStringArray; var choice: LongInt);
const
    ROWS_PER_COLUMN = 7;
    COLUMN_WIDTH = 30;
var
    i, nbSpecies: LongInt;
    heading: String;
begin
    nbSpecies := getNbAvailableSpecies(species);
    heading := 'Selectionnez un arbre a faire pousser :';

    drawScreenHeader(heading);

    {species are listed in columns of ROWS_PER_COLUMN entries}
    enterArea(LIST_X, CONTENT_ROW, BORDER_WIDTH - 2, BORDER_HEIGHT - 2);
    for i := 0 to nbSpecies - 1 do
    begin
        GoToXY(1 + (i div ROWS_PER_COLUMN) * COLUMN_WIDTH, 1 + (i mod ROWS_PER_COLUMN));
        if (i < 9) then
            write('[', i + 1, ']   ', species[i])
        else
            write('[', i + 1, ']  ', species[i]);
    end;
    GoToXY(1, ROWS_PER_COLUMN + 2);
    write('[0]   Retour');

    GoToXY(1, ROWS_PER_COLUMN + 4);
    choice := readInteger('Votre choix : ', 0, nbSpecies);
    leaveArea();
end;

procedure displayTreeChoice(speciesName: String; var action: TTreeChoice);
var
    key: Char;
    heading: String;
begin
    heading := 'Vous avez choisi : ' + speciesName;

    drawScreenHeader(heading);

    enterArea(MENU_X, CONTENT_ROW, MENU_X + 40, BORDER_HEIGHT - 2);
    writeln('[1]   Confirmer ce choix');
    writeln;
    writeln('[2]   Voir un apercu de l''arbre');
    writeln;
    writeln('[3]   Choisir un autre arbre');
    leaveArea();

    action := NONE_TREECHOICE;
    repeat
        key := readkey;

        if (key = '1') then
            action := CONFIRM_TREE
        else if (key = '2') then
            action := PREVIEW_TREE
        else if (key = '3') then
            action := CANCEL_TREE;
    until action <> NONE_TREECHOICE;
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

    TextColor(DEFAULT_COLOR);
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
    clrscr;

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

procedure renderStatsArea(phase: TPhaseSession; session: LongInt; speciesName: String; isPaused: Boolean);
begin
    enterArea(BORDER_TREE_VERTICAL + 3, BORDER_CLOCK_HORIZONTAL + 2, BORDER_WIDTH - 1, BORDER_STATS_HORIZONTAL - 1);
    clrscr;

    writeln('Phase : ', phaseLabel(phase));
    writeln('Session : ', session);
    writeln('Arbre : ', speciesName);
    {write, not writeln: a newline on the last row would scroll the area}
    if isPaused then
        write('Etat : En pause')
    else
        write('Etat : En cours');

    leaveArea();
end;

procedure pollSessionInput(sessionPhase: TPhaseSession; var action: TSessionAction);
var
    key: Char;
begin
    action := NONE_SA;

    if keypressed then
    begin
        key := readkey;

        if key = #0 then
            readkey {special keys send a second code that must be skipped}
        else if key = '1' then
            action := TOGGLE_PAUSE
        else if key = '2' then
            action := QUIT_SESSION
        else if (sessionPhase <> FOCUS) and (key = '3') then
            action := SKIP_PHASE
        else if (sessionPhase <> FOCUS) and (key = '4') then
            action := CHANGE_TREE;
    end;
end;

procedure displayCycleEnd(cycle: TCycle; success: Boolean);
var
    heading, modeName: String;
    nbSessionsDone: LongInt;
begin
    {a cycle can only succeed from a break (the current session is complete) and only be abandoned during a focus phase (the current session is unfinished)}
    if success then
    begin
        heading := 'Cycle termine, bravo !';
        nbSessionsDone := getCurrentSession(cycle);
    end
    else
    begin
        heading := 'Cycle abandonne : l''arbre en cours n''a pas survecu.';
        nbSessionsDone := getCurrentSession(cycle) - 1;
    end;

    if getMode(cycle) = POMODORO then
        modeName := 'Pomodoro'
    else
        modeName := 'Personnalise';

    drawScreenHeader(heading);

    enterArea(MENU_X, CONTENT_ROW, MENU_X + 40, BORDER_HEIGHT - 2);
    writeln('Mode : ', modeName);
    writeln;
    writeln('Sessions de concentration terminees : ', nbSessionsDone);
    writeln;
    write('Appuyez sur une touche pour continuer...');
    leaveArea();
    readkey;
end;

end.

