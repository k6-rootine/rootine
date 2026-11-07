program main;

uses 
    FileManager, CycleData, TimerManager, TreeData, UserData, WindowsManager, IHM, crt, Utilities;

procedure handleImport(var user: TUser);
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
    end;
end;

procedure handleRegisteration(var user: TUser);
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

function selectTree(): TTree;
var
    availableSpecies: TStringArray;
    i, nbSpecies: LongInt;
begin 
    {   1. Display available trees (by name)
        2. Get user input for tree selection
        3. Confirm selection
        4. Get tree data from file and return it
    }
    availableSpecies := getAvailableSpecies();
    nbSpecies := getNbAvailableSpecies(availableSpecies);

    clrscr;
    writeln('Selectionnez un arbre parmi les suivants:');

    for i := 0 to nbSpecies - 1 do
    begin
        writeln(i + 1, '. ', availableSpecies[i]);
    end;

    repeat 
        write('Entrez le numero de l''arbre que vous souhaitez selectionner: ');
        readln(i);
    until (i >= 1) and (i <= nbSpecies);

    selectTree := loadTree(availableSpecies[i - 1]);
end;

function selectMode(): TCycle;
var 
    mode: TMode;
    cycle: TCycle;
    focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak: LongInt;
begin 
    displayCycleModeMenu(mode);
    focusDuration := 25 * 60;
    shortBreakDuration := 5 * 60;
    longBreakDuration := 15 * 60;
    nbSessionsBeforeLongBreak := 4;
    
    if mode = CUSTOM then
    begin 
        displayCustomConfiguration(focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak);
        cycle := initialiseCycle(CUSTOM, focusDuration * 60, shortBreakDuration * 60, longBreakDuration * 60, nbSessionsBeforeLongBreak);
    end
    else if mode = POMODORO then
        displayPomodoroConfiguration();
    
    selectMode := cycle;
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

procedure mainSessionLoop(var tree: TTree; var cycle: TCycle; var user: TUser; timer: TTimer);
begin 

end;

procedure handleSessionEnd(var user: TUser; cycle: TCycle);
begin 

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
            tree := selectTree();
            cycle := selectMode();
            startNewCycle(cycle, timer);
            mainSessionLoop(tree, cycle, user, timer);
            handleSessionEnd(user, cycle);
        end;
    until isLogout or isQuit;
end;

var 
    user: TUser;
    isQuit: Boolean;
    choice: TStartChoice;
begin  
    isQuit := False;

    repeat 
        clrscr;
        RootineLogo(30, 5);
        displayOuterBorder();
        displayStartMenu(choice);

        if choice = IMPORT then
        begin 
            handleImport(user);
        end
        else if choice = REGISTER then
        begin 
            user := initialiseUser();
            handleRegisteration(user);
        end
        else if choice = QUIT_START then
        begin
            isQuit := True;
        end;

        if not isQuit then
            runSession(user, isQuit);
    until isQuit;

    clrscr;
    writeln('Le programme se termine. Merci d''avoir utilise Rootine !');
end.