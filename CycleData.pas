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
implementation 
function initialiseCycle(mode: TMode; focusDuration, shortBreakDuration, longBreakDuration, nbSessionsBeforeLongBreak: LongInt): TCycle;
begin 

end;

end.