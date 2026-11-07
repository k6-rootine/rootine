program main;

uses 
    FileManager, CycleData, TimerManager, TreeData, UserData, WindowsManager, IHM, crt, Utilities, SysUtils;

function handleImport(var user: TUser): Boolean;
var
    username: String;
begin
    clrscr;
    RootineLogo(30, 5);
    displayOuterBorder();
    displayLogin(username);

    if username <> '' then
    begin
        user := loadUser(username);
        handleImport := True;
    end
    else
        handleImport := False;
end;

procedure handleRegistration(var user: TUser);
var
    fullname, username, description: String;
begin
    clrscr;
    RootineLogo(30, 5);
    displayOuterBorder();
    displayRegister(fullname, username, description);
    setName(user, fullname);
    setUsername(user, username);
    setUserDescription(user, description);
    saveUser(user);
end;

procedure handleViewForest(user: TUser);
begin 

end;

procedure handleLogout(user: TUser);
begin 
    saveUser(user);
    clrscr;
    writeln('Vous avez ete deconnecte avec succes. Appuyez sur une touche pour continuer...');
    readkey;
end;

procedure handleViewProfile(user: TUser);
begin
    clrscr;
    RootineLogo(30, 5);
    displayOuterBorder();
    displayProfile(user);
    readkey;
end;

function selectTree(var tree: TTree): Boolean;
var
    availableSpecies: TStringArray;
    idx: LongInt;
    action: TTreeChoice;
begin
    availableSpecies := getAvailableSpecies();
    selectTree := False;

    repeat
        displayTreeList(availableSpecies, idx); {idx = 0 means return}

        if idx > 0 then
        begin
            tree := loadTree(availableSpecies[idx - 1]);

            repeat
                displayTreeChoice(availableSpecies[idx - 1], action);
                if action = PREVIEW_TREE then
                    displayTreeFull(tree);
            until action <> PREVIEW_TREE;

            if action = CONFIRM_TREE then
                selectTree := True;
        end;
    until selectTree or (idx = 0);
end;


function clamp(value, minValue, maxValue: LongInt): LongInt;
begin
    { restricts a value to the range [minValue, maxValue]. }
    if value < minValue then
        clamp := minValue
    else if value > maxValue then
        clamp := maxValue
    else
        clamp := value;
end;

function selectMode(var cycle: TCycle): Boolean;
var
    mode: TMode;
    focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak: LongInt;
begin
    displayCycleModeMenu(mode);
    selectMode := True;

    if mode = POMODORO then
    begin
        displayPomodoroConfiguration();
        cycle := initialiseCycle(POMODORO, 25 * 60, 5 * 60, 15 * 60, 4);
    end
    else if mode = CUSTOM then
    begin
        displayCustomConfiguration(focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak);
        { durations are entered in minutes (1..90) and stored in seconds }
        focusDuration := clamp(focusDuration, 1, 90) * 60;
        shortBreakDuration := clamp(shortBreakDuration, 1, 90) * 60;
        longBreakDuration := clamp(longBreakDuration, 1, 90) * 60;
        nbSessionsBeforeLongBreak := clamp(nbSessionsBeforeLongBreak, 1, 99);
        cycle := initialiseCycle(CUSTOM, focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak);
    end
    else
        selectMode := False;
end;

procedure startNewCycle(var cycle: TCycle; var timer: TTimer);
begin 

end;

procedure handleSessionAction(sessionAction: TSessionAction; var cycle: TCycle; var timer: TTimer; var tree: TTree);
begin 

end;

procedure handlePhaseEnd(var cycle: TCycle; var timer: TTimer; var user: TUser; tree: TTree);
begin 

end;

procedure handleSessionEnd(var user: TUser; cycle: TCycle);
begin 
    
end;

procedure mainSessionLoop(var tree: TTree; var cycle: TCycle; var user: TUser; timer: TTimer);
begin 
    clrscr;
    displayOuterBorder();
    displayInnerBorder();


end;

procedure runSession(var user: TUser; var isQuit: Boolean);
var 
    isLogout: Boolean;
    choice: TMainMenuChoice;
    tree: TTree;
    cycle: TCycle;
    timer: TTimer;
begin 
    isLogout := False;

    repeat 
        clrscr;
        RootineLogo(30, 5);
        displayOuterBorder();
        displayMainMenu(choice, user);

        if choice = VIEW_PROFILE then
        begin 
            handleViewProfile(user);
        end
        else if choice = VIEW_FOREST then
        begin 
            handleViewForest(user);
        end
        else if choice = LOGOUT then
        begin 
            handleLogout(user);
            isLogout := True;
        end
        else if choice = QUIT_MAINMENU then
        begin 
            handleLogout(user);
            isQuit := True;
        end
        else if choice = START then
        begin 
            if selectTree(tree) then
                if selectMode(cycle) then
                begin
                    startNewCycle(cycle, timer);
                    mainSessionLoop(tree, cycle, user, timer);
                    handleSessionEnd(user, cycle);
                end;
        end;
    until isLogout or isQuit;
end;

var
    user: TUser;
    isQuit, isLoggedIn: Boolean;
    choice: TStartChoice;
begin
    isQuit := False;

    repeat
        isLoggedIn := False;
        clrscr;
        RootineLogo(30, 5);
        displayOuterBorder();
        displayStartMenu(choice);

        if choice = IMPORT then
        begin
            isLoggedIn := handleImport(user);
        end
        else if choice = REGISTER then
        begin
            user := initialiseUser();
            handleRegistration(user);
            isLoggedIn := True;
        end
        else if choice = QUIT_START then
        begin
            isQuit := True;
        end;

        if isLoggedIn then
            runSession(user, isQuit);
    until isQuit;

    clrscr;
    writeln('Le programme se termine. Merci d''avoir utilise Rootine !');
end.