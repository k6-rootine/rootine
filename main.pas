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
begin 

end;

function selectMode(): TCycle;
begin 

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