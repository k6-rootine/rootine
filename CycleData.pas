unit CycleData;

interface 
    type 
        TMode = (CUSTOM, POMODORO);

        TPhaseSession = (FOCUS, SHORT_BREAK, LONG_BREAK);

        TState = (NOT_STARTED, IN_PROGRESS, FINISHED);

        TCycle = Record
            mode: TMode;
            focusDuration, shortBreakDuration, longBreakDuration,
            nbSessionsBeforeLongBreak, currentSession: LongInt;
            currentPhase: TPhaseSession;
            state: TState;
        end;

    function initialiseCycle(mode: TMode; focusDuration, shortBreakDuration, longBreakDuration,
            nbSessionsBeforeLongBreak: LongInt): TCycle;
    
    function getMode(cycle: Tcycle): TMode;

    function getCurrentSession(cycle: TCycle): LongInt;

    function getCurrentPhase(cycle: Tcycle): TPhaseSession;

    function getCurrentPhaseDuration(cycle: Tcycle): LongInt;

    function getState(cycle: Tcycle): TState;

    procedure startCycle(var cycle: TCycle);

    procedure nextPhase(var cycle: TCycle);

    procedure finishCycle(var cycle: TCycle);

    procedure abandonCycle(var cycle: Tcycle);





implementation 

    function initialiseCycle(mode: TMode; focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak: LongInt): TCycle;
    var cycle: Tcycle;
    begin 
        cycle.mode := mode;
        cycle.focusDuration := focusDuration;
        cycle.shortBreakDuration := shortBreakDuration;
        cycle.longBreakDuration := longBreakDuration;
        cycle.nbSessionsBeforeLongBreak := nbSessionsBeforeLongBreak;
        cycle.currentSession := 0;
        cycle.state := NOT_STARTED;
        cycle.currentPhase := FOCUS;

        initialiseCycle := cycle;
    end;

{---GET FUNCTIONS---}
    function getMode(cycle: Tcycle): TMode;
    begin
        getMode := cycle.mode;
    end;

    function getCurrentSession(cycle: TCycle): LongInt;
    begin
        getCurrentSession := cycle.currentSession;                  {BURAYA BI GOZ AT NASIL DEGISIYOR CURRENT SESSION BILMIYPRUM}
    end;

    function getCurrentPhase(cycle: Tcycle): TPhaseSession;
    begin
        getCurrentPhase := cycle.currentPhase;
    end;

    function getCurrentPhaseDuration(cycle: Tcycle): LongInt;
    begin
        if getCurrentPhase(cycle) = FOCUS then
            getCurrentPhaseDuration := cycle.focusDuration
        else if getCurrentPhase(cycle) = SHORT_BREAK then
            getCurrentPhaseDuration := cycle.shortBreakDuration
        else 
            getCurrentPhaseDuration := cycle.longBreakDuration;
    end;

    function getState(cycle: Tcycle): TState;
    begin
        getState := cycle.state;
    end;

{---MANUPULATIONS---}
    procedure startCycle(var cycle: TCycle);
    
    begin  
        cycle.currentSession := cycle.currentSession + 1;
        if cycle.focusDuration > 0 then
            cycle.currentPhase := IN_PROGRESS;
    end;

    procedure nextPhase(var cycle: TCycle);
    begin
        if cycle.state = IN_PROGRESS then
        begin
            if cycle.currentPhase = FOCUS then
            begin
                {long break after every Nth focus session, short break otherwise}
                if (cycle.nbSessionsBeforeLongBreak > 0) and
                   (cycle.currentSession mod cycle.nbSessionsBeforeLongBreak = 0) then
                    cycle.currentPhase := LONG_BREAK
                else
                    cycle.currentPhase := SHORT_BREAK;
            end
            else
            begin
                {coming back from any break, new focus session }
                cycle.currentPhase := FOCUS;
                cycle.currentSession := cycle.currentSession + 1;
            end;
        end;
    end;

    procedure finishCycle(var cycle: TCycle);
    begin
    if cycle.state = IN_PROGRESS then
            cycle.state := FINISHED;
    end;

    procedure abandonCycle(var cycle: Tcycle);
    begin
        {we give up so we go back to the initial state, settings are kept }
        cycle.currentSession := 0;
        cycle.currentPhase := FOCUS;
        cycle.state := NOT_STARTED;
    end;

    end.