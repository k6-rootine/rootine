program main;

uses 
    FileManager, CycleData, TimerManager, TreeData, UserData, WindowsManager, IHM, crt, Utilities, SysUtils;

const
    { pomodoro settings. durations in minutes }
    POMODORO_FOCUS = 25;
    POMODORO_SHORT_BREAK = 5;
    POMODORO_LONG_BREAK = 15;
    POMODORO_NB_SESSIONS = 4;

procedure handleImport(var user: TUser);
var
    username: String;
begin
    user := initialiseUser();
    renderScreenHeader('');
    displayLogin(username);

    { an empty username means that the login was cancelled }
    if username <> '' then
        user := loadUser(username);
end;

procedure handleRegistration(var user: TUser);
var
    fullname, username, description: String;
begin
    renderScreenHeader('');
    displayRegister(fullname, username, description);

    { an empty username means that the registration was cancelled: nothing is saved }
    if username <> '' then
    begin
        setName(user, fullname);
        setUsername(user, username);
        setUserDescription(user, description);
        saveUser(user);
    end;
end;

procedure handleViewForest(user: TUser);
begin 

end;

procedure handleLogout(user: TUser);
begin 
    saveUser(user);
    displayLogout();
end;

procedure handleViewProfile(user: TUser);
begin
    renderScreenHeader('');
    displayProfile(user);
    readkey;
end;

procedure selectTree(var tree: TTree; deadline: Int64; var action: TTreeChoice);
var
    availableSpecies: TStringArray;
    idx: LongInt;
    timedOut: Boolean;
begin
    availableSpecies := getAvailableSpecies();
    action := NONE_TREECHOICE;
    timedOut := False;

    repeat
        displayTreeList(availableSpecies, idx, deadline, timedOut); { idx = 0 means return or time is up }

        if (idx > 0) and not timedOut then
        begin
            tree := loadTree(availableSpecies[idx - 1]);

            repeat
                displayTreeChoice(availableSpecies[idx - 1], action, deadline, timedOut);
                if (action = PREVIEW_TREE) and not timedOut then
                    displayTreeFull(tree, deadline, timedOut);
            until (action <> PREVIEW_TREE) or timedOut;

            { going back or running out of time means that nothing was confirmed }
            if (action <> CONFIRM_TREE) or timedOut then
                action := NONE_TREECHOICE;
        end;
    until (action = CONFIRM_TREE) or (idx = 0) or timedOut;
end;

procedure selectMode(var cycle: TCycle);
var
    mode: TMode;
    confirmed: Boolean;
    focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak: LongInt;
begin
    { the mode menu is shown again if the user cancels a configuration }
    repeat
        displayCycleModeMenu(mode);
        confirmed := False;

        if mode = POMODORO then
        begin
            displayPomodoroConfiguration(POMODORO_FOCUS, POMODORO_SHORT_BREAK, POMODORO_LONG_BREAK, POMODORO_NB_SESSIONS, confirmed);
            if confirmed then
                cycle := initialiseCycle(POMODORO, POMODORO_FOCUS * 60, POMODORO_SHORT_BREAK * 60, POMODORO_LONG_BREAK * 60, POMODORO_NB_SESSIONS);
        end
        else if mode = CUSTOM then
        begin
            displayCustomConfiguration(focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak, confirmed);

            { durations are entered in minutes and stored in seconds }
            if confirmed then
                cycle := initialiseCycle(CUSTOM, focusDuration * 60, shortBreakDuration * 60, longBreakDuration * 60, nbSessionsBeforeLongBreak);
        end;
    until confirmed or (mode = NONE_MODE);

    { the user went back. NONE_MODE means that no mode was confirmed }
    if not confirmed then
        cycle := initialiseCycle(NONE_MODE, 0, 0, 0, 0);
end;

procedure startNewCycle(var cycle: TCycle; var timer: TTimer);
begin
    startCycle(cycle);
    timer := initialiseTimer(getCurrentPhaseDuration(cycle));
end;

procedure handleSessionAction(var sessionAction: TSessionAction; var cycle: TCycle; var timer: TTimer; var nextTree: TTree);
var
    newTree: TTree;
    treeAction: TTreeChoice;
begin
    { applies an action of the user during the session. 
    when the action is finished, the sessionAction resets to none }

    if sessionAction = TOGGLE_PAUSE then
    begin
        if isPaused(timer) then
            resumeTimer(timer)
        else
            pauseTimer(timer);
        sessionAction := NONE_SESSIONACTION;
    end
    else if sessionAction = QUIT_SESSION then
    begin
        { if in focus, the user needs to confirm. if not, the session ends without any inteference }
        if getCurrentPhase(cycle) <> FOCUS then
            finishCycle(cycle)
        else
            sessionAction := NONE_SESSIONACTION;
    end
    else if sessionAction = CHANGE_TREE then
    begin
        { the break keeps running while the user chooses, so it is resumed if it was paused }
        if isPaused(timer) then
            resumeTimer(timer);

        { temporary variable newTree }
        selectTree(newTree, deadlineIn(getRemainingTime(timer)), treeAction);
        
        { nextTree is used when the next focus session starts }
        if treeAction = CONFIRM_TREE then
            nextTree := newTree;
        sessionAction := NONE_SESSIONACTION;
    end;
end;

procedure handlePhaseEnd(var cycle: TCycle; var timer: TTimer; var user: TUser; var tree: TTree; nextTree: TTree);
begin
    { called when the timer of the current phase is finished }
    if getCurrentPhase(cycle) = FOCUS then
    begin
        { credits a completed focus session (with the tree that was grown) }
        addTree(user, getSpeciesName(tree));
        setNbSessionsDone(user, getNbSessionsDone(user) + 1);
        setTotalFocusTime(user, getTotalFocusTime(user) + getDuration(timer));
        saveUser(user);
    end;

    { then moves to the next phase }
    nextPhase(cycle);
    timer := initialiseTimer(getCurrentPhaseDuration(cycle));

    { when the next phase is a focus session, tree becomes the tree chosen for it (nextTree) }
    if getCurrentPhase(cycle) = FOCUS then
        tree := nextTree;
end;

procedure handleSessionEnd(var user: TUser; cycle: TCycle);
begin
    displayCycleEnd(cycle);

    { a cycle counts once at least one focus session was completed }
    if (getState(cycle) = FINISHED) or (getCurrentSession(cycle) > 1) then
        setNbCyclesDone(user, getNbCyclesDone(user) + 1);

    saveUser(user);
end;

function getDisplayedTreePhase(tree: TTree; cycle: TCycle; timer: TTimer): LongInt;
begin
    if getCurrentPhase(cycle) = FOCUS then
        getDisplayedTreePhase := computeGrowthPhase(getNbPhases(tree), getElapsedTime(timer), getDuration(timer))
    else
        getDisplayedTreePhase := getNbPhases(tree);
end;

procedure renderSessionScreen(tree: TTree; cycle: TCycle; timer: TTimer);
begin
    { draws the whole session screen: borders, tree, clock, stats and instructions }
    clrscr;
    renderOuterBorder();
    renderInnerBorder();
    renderTreeArea(tree, getDisplayedTreePhase(tree, cycle, timer));
    renderClockArea(getRemainingTime(timer));
    renderStatsArea(getCurrentPhase(cycle), getCurrentSession(cycle), getSpeciesName(tree), isPaused(timer));
    renderInstructionsArea(getCurrentPhase(cycle));
end;

procedure mainSessionLoop(var tree: TTree; var cycle: TCycle; var user: TUser; var timer: TTimer);
var
    nextTree: TTree;
    action: TSessionAction;
    quitAnswer: TQuitAnswer;
    isEnded, needsRedraw, isConfirmingQuit: Boolean;
    lastTick: Int64;
    elapsedSeconds, displayedPhase: LongInt;
begin
    { initialise variables }
    nextTree := tree; {the tree of the next focus session, can be changed by user during a break }
    isEnded := False;
    needsRedraw := False;
    isConfirmingQuit := False;

    { keys typed before the session must not act as commands }
    while keypressed do
        readkey;

    renderSessionScreen(tree, cycle, timer);
    displayedPhase := getDisplayedTreePhase(tree, cycle, timer);
    lastTick := currentTick();

    repeat
        action := NONE_SESSIONACTION;

        if isConfirmingQuit then
        begin
            { the confirmation does not stop the clock }
            pollQuitConfirmation(quitAnswer);
            if quitAnswer = QUIT_YES then
            begin
                { the unfinished tree dies }
                abandonCycle(cycle);
                isEnded := True;
            end
            else if quitAnswer = QUIT_NO then
            begin
                isConfirmingQuit := False;
                renderInstructionsArea(getCurrentPhase(cycle));
            end;
        end
        else
            pollSessionInput(getCurrentPhase(cycle), action);

        if (action = QUIT_SESSION) and (getCurrentPhase(cycle) = FOCUS) then
        begin
            isConfirmingQuit := True;
            displayQuitConfirmation();
        end
        else if action = SKIP_PHASE then
        begin
            handlePhaseEnd(cycle, timer, user, tree, nextTree);
            needsRedraw := True;
        end
        else if action = TOGGLE_PAUSE then
        begin
            { only the state line changes }
            handleSessionAction(action, cycle, timer, nextTree);
            renderStatsArea(getCurrentPhase(cycle), getCurrentSession(cycle), getSpeciesName(tree), isPaused(timer));
        end
        else if action <> NONE_SESSIONACTION then
        begin
            handleSessionAction(action, cycle, timer, nextTree);
            isEnded := (action = QUIT_SESSION);
            needsRedraw := True;
        end;

        { the timer follows the real time, so a slow redraw or a menu does not make it lose seconds. 
            the whole seconds are removed from lastTick so that nothing drifts }
        elapsedSeconds := LongInt((currentTick() - lastTick) div 1000);

        if (elapsedSeconds > 0) and not isEnded then
        begin
            lastTick := lastTick + Int64(elapsedSeconds) * 1000;
            tick(timer, elapsedSeconds);

            if isFinished(timer) then
            begin
                handlePhaseEnd(cycle, timer, user, tree, nextTree);
                isConfirmingQuit := False; { the redraw below replaces the confirmation }
                needsRedraw := True;
            end
            else
            begin
                { the clock is drawn first, then the tree if its growth phase changed }
                renderClockArea(getRemainingTime(timer));
                if getDisplayedTreePhase(tree, cycle, timer) <> displayedPhase then
                begin
                    displayedPhase := getDisplayedTreePhase(tree, cycle, timer);
                    renderTreeArea(tree, displayedPhase);
                end;
            end;
        end;

        if needsRedraw and not isEnded then
        begin
            renderSessionScreen(tree, cycle, timer);
            displayedPhase := getDisplayedTreePhase(tree, cycle, timer);
            needsRedraw := False;
        end;

        delay(50);
    until isEnded;
end;

procedure runSession(var user: TUser);
var
    tree: TTree;
    cycle: TCycle;
    timer: TTimer;
    treeAction: TTreeChoice;
begin   
    { flow: tree -> mode -> start session }
    selectTree(tree, 0, treeAction);
    if treeAction = CONFIRM_TREE then
    begin
        selectMode(cycle);
        if getMode(cycle) <> NONE_MODE then
        begin
            startNewCycle(cycle, timer);
            mainSessionLoop(tree, cycle, user, timer);
            handleSessionEnd(user, cycle);
        end;
    end;
end;

procedure handleMainMenu(var user: TUser; var isQuit: Boolean);
var
    isLogout: Boolean;
    choice: TMainMenuChoice;
begin 
    isLogout := False;

    repeat 
        renderScreenHeader('');
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
            saveUser(user);
            isQuit := True;
        end
        else if choice = START then
        begin 
            runSession(user);
        end;
    until isLogout or isQuit;
end;

procedure handleStartMenu();
var
    user: TUser;
    isQuit, isLoggedIn: Boolean;
    choice: TStartChoice;
begin
    isQuit := False;

    repeat
        isLoggedIn := False;
        renderScreenHeader('');
        displayStartMenu(choice);

        if choice = IMPORT then
        begin
            handleImport(user);
            isLoggedIn := (getUsername(user) <> '');
        end
        else if choice = REGISTER then
        begin
            user := initialiseUser();
            handleRegistration(user);
            isLoggedIn := (getUsername(user) <> '');
        end
        else if choice = QUIT_START then
        begin
            isQuit := True;
        end;

        if isLoggedIn then
            handleMainMenu(user, isQuit);
    until isQuit;
end;

begin
    lockConsoleWindow(BORDER_WIDTH + 2 * SCREEN_MARGIN_X + 2, BORDER_HEIGHT + 2 * SCREEN_MARGIN_Y);
    initialiseScreen();
    handleStartMenu();
    displayQuit();
    clrscr;
end.