{
This unit stores the cycle settings and its progression (session, phase, state).
}
unit CycleData;

interface 
    type 
        {The kind of cycle.
            CUSTOM : durations chosen by the user
            POMODORO : the classic Pomodoro cycle. The unit does not set default values itself, the caller must pass them to initialiseCycle. }
        TMode = (CUSTOM, POMODORO);

        {The phase of the session the user's currently in. (With LONG_BREAK every Nth focus session)}
        TPhaseSession = (FOCUS, SHORT_BREAK, LONG_BREAK);

        {The state of the cycle the user's currently in.}
        TState = (NOT_STARTED, IN_PROGRESS, FINISHED);

        {Full description of a cycle.}
        TCycle = Record
            mode: TMode;
            focusDuration, shortBreakDuration, longBreakDuration,
            nbSessionsBeforeLongBreak, currentSession: LongInt;
            currentPhase: TPhaseSession;
            state: TState;
        end;

    {Creates a new cycle, ready to be started.
    The cycle starts in state NOT_STARTED, session 0 and phase FOCUS.
    @returns the initialised cycle.}
    function initialiseCycle(mode: TMode; focusDuration, shortBreakDuration, longBreakDuration,
            nbSessionsBeforeLongBreak: LongInt): TCycle;
    
    { @returns the mode (CUSTOM or POMODORO) of the cycle. }
    function getMode(cycle: Tcycle): TMode;

    { @returns The number of the current focus session (0 if not started). }
    function getCurrentSession(cycle: TCycle): LongInt;

    { @returns The phase currently running (FOCUS, SHORT_BREAK or LONG_BREAK). }
    function getCurrentPhase(cycle: Tcycle): TPhaseSession;

    { @returns The duration of the current phase, taken from the matching setting (focus, short break or long break). }
    function getCurrentPhaseDuration(cycle: Tcycle): LongInt;

    { @returns The overall state of the cycle (NOT_STARTED, IN_PROGRESS or FINISHED). }
    function getState(cycle: Tcycle): TState;

    { Starts the cycle: goes to session 1 and state IN_PROGRESS.
    @param cycle The cycle to start (modified)}
    procedure startCycle(var cycle: TCycle);

    { Moves to the next phase. Does nothing unless the state is IN_PROGRESS.
    From FOCUS: goes to LONG_BREAK if nbSessionsBeforeLongBreak > 0 and currentSession is a multiple of it, otherwise to SHORT_BREAK.
    From a break: goes back to FOCUS and increments currentSession.
    @param cycle The cycle to advance (modified). }
    procedure nextPhase(var cycle: TCycle);

    { Marks the cycle as FINISHED. Does nothing unless the state is IN_PROGRESS.
    @param cycle The cycle to finish (modified). }
    procedure finishCycle(var cycle: TCycle);

    { Gives up the cycle: back to NOT_STARTED, session 0, phase FOCUS.
    Settings (mode and durations) are kept, so the cycle can be restarted.
    @param cycle The cycle to reset (modified). }
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
        getCurrentSession := cycle.currentSession;                  
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
            cycle.State := IN_PROGRESS;
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
                {coming back from any break : new focus session }
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
        {give up : go back to the initial state, settings are kept }
        cycle.currentSession := 0;
        cycle.currentPhase := FOCUS;
        cycle.state := NOT_STARTED;
    end;

    end.