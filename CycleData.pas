{
Cette unité stocke les paramètres du cycle et sa progression (session, phase, état).
}
unit CycleData;

interface 
    type 
        {Le type de cycle.
            CUSTOM : les durées sont choisies par l'utilisateur.
            POMODORO : le cycle Pomodoro classique. L'unité ne définit pas elle-même de valeurs par défaut, l'appelant doit les passer à initialiseCycle. }
        TMode = (CUSTOM, POMODORO, NONE_MODE);

        {La phase de la session dans laquelle se trouve actuellement l'utilisateur. (Avec LONG_BREAK toutes les N sessions de concentration)}
        TPhaseSession = (FOCUS, SHORT_BREAK, LONG_BREAK, NONE_PS);

        {L'état du cycle dans lequel se trouve actuellement l'utilisateur.}
        TState = (NOT_STARTED, IN_PROGRESS, FINISHED, NONE_STATE);

        {Description complète d'un cycle.}
        TCycle = Record
            mode: TMode;
            focusDuration, shortBreakDuration, longBreakDuration,
            nbSessionsBeforeLongBreak, currentSession: LongInt;
            currentPhase: TPhaseSession;
            state: TState;
        end;

    {Crée un nouveau cycle, prêt à être démarré.
    Le cycle commence à l'état NOT_STARTED, à la session 0 et à la phase FOCUS.
    @returns le cycle initialisé.}
    function initialiseCycle(mode: TMode; focusDuration, shortBreakDuration, longBreakDuration,
            nbSessionsBeforeLongBreak: LongInt): TCycle;
    
    { @returns le mode (CUSTOM ou POMODORO) du cycle. }
    function getMode(cycle: Tcycle): TMode;

    { @returns Le numéro de la session de concentration en cours (0 si le cycle n'est pas démarré). }
    function getCurrentSession(cycle: TCycle): LongInt;

    { @returns La phase en cours (FOCUS, SHORT_BREAK ou LONG_BREAK). }
    function getCurrentPhase(cycle: Tcycle): TPhaseSession;

    { @returns La durée de la phase en cours, tirée du paramètre correspondant (concentration, pause courte ou pause longue). }
    function getCurrentPhaseDuration(cycle: Tcycle): LongInt;

    { @returns L'état global du cycle (NOT_STARTED, IN_PROGRESS ou FINISHED). }
    function getState(cycle: Tcycle): TState;

    { Démarre le cycle : passe à la session 1, à la phase FOCUS et à l'état IN_PROGRESS.
    Ne fait rien si l'état n'est pas NOT_STARTED ou si focusDuration n'est pas strictement positif.
    @param cycle Le cycle à démarrer (modifié)}
    procedure startCycle(var cycle: TCycle);

    { Passe à la phase suivante. Ne fait rien si l'état n'est pas IN_PROGRESS.
    Depuis FOCUS : passe à LONG_BREAK si nbSessionsBeforeLongBreak > 0 et que currentSession est un multiple de cette valeur, sinon à SHORT_BREAK.
    Depuis une pause : retourne à FOCUS et incrémente currentSession.
    @param cycle Le cycle à faire avancer (modifié). }
    procedure nextPhase(var cycle: TCycle);

    { Marque le cycle comme FINISHED. Ne fait rien si l'état n'est pas IN_PROGRESS.
    @param cycle Le cycle à terminer (modifié). }
    procedure finishCycle(var cycle: TCycle);

    { Abandonne le cycle : retour à NOT_STARTED, session 0, phase FOCUS.
    Les paramètres (mode et durées) sont conservés, le cycle peut donc être redémarré.
    @param cycle Le cycle à réinitialiser (modifié). }
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

{---ACCESSEURS---}
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

{---MANIPULATIONS---}
    procedure startCycle(var cycle: TCycle);
    begin
        {on ne démarre que depuis NOT_STARTED, et seulement si la durée de concentration est valide}
        if (cycle.state = NOT_STARTED) and (cycle.focusDuration > 0) then
        begin
            cycle.currentSession := 1;
            cycle.currentPhase := FOCUS;
            cycle.state := IN_PROGRESS;
        end;
    end;

    procedure nextPhase(var cycle: TCycle);
    begin
        if cycle.state = IN_PROGRESS then
        begin
            if cycle.currentPhase = FOCUS then
            begin
                {pause longue après chaque Nième session de concentration, pause courte sinon}
                if (cycle.nbSessionsBeforeLongBreak > 0) and
                   (cycle.currentSession mod cycle.nbSessionsBeforeLongBreak = 0) then
                    cycle.currentPhase := LONG_BREAK
                else
                    cycle.currentPhase := SHORT_BREAK;
            end
            else
            begin
                {retour d'une pause quelconque : nouvelle session de concentration }
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
        {abandon : retour à l'état initial, les paramètres sont conservés }
        cycle.currentSession := 0;
        cycle.currentPhase := FOCUS;
        cycle.state := NOT_STARTED;
    end;

    end.