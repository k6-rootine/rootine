program main;

uses 
    FileManager, CycleData, TimerManager, TreeData, UserData, WindowsManager, IHM;

procedure handleImport(var user: TUser);
var 
    username: String;
begin 
    clrscr;
    repeat
        RootineLogo(30, 5);
        displayOuterBorder();
        displayLogin(username);
        
        if not userExists(username) and (username <> '') then
        begin 
            clrscr;
            GoToXY(30, 22);
            write('Utilisateur inexistant. Veuillez reessayer.');
        end;
    until userExists(username) or (username = '');

    if username <> '' then
    begin
        loadUser(username);
    end;
end;

procedure handleRegisteration(var user: TUser);
begin 

end;

procedure handleViewForest(user: TUser);
begin 

end;

procedure handleLogout(user: TUser);
begin 

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

procedure runSession(var user: TUser);
begin 

end;

begin 
    writeln('hello');
end.