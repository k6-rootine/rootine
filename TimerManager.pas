{ 
Cette unité gère tout ce qui est relatif aux minuteurs : la création, la mise en pause, la reprise et l'avancement.
}
unit TimerManager;

interface 
    { Un minuteur contenant le temps écoulé, la durée totale et un booléen indiquant si le minuteur est en pause. }
    type 
        TTimer = record 
            elapsedTime, duration: LongInt;
            isPaused: Boolean;
        end;

    function initialiseTimer(duration: LongInt): TTimer;
    {   
        @abstract(Créé un minuteur avec une durée donnée)
        Prend en entrée la durée @code(duration) puis initialise un minuteur dans @code(TTimer).
        @param(duration La durée du minuteur.)
        @returns(Un minuteur dans @code(TTimer) initialisé.)
    }

    function getElapsedTime(timer: TTimer): LongInt;
    {   
        @abstract(Retourne le temps écoulé du minuteur)
        Prend en entrée un minuteur @code(timer) et retourne le temps écoulé depuis son initialisation.
        @param(timer Le minuteur duquel on veut récupérer le temps écoulé.)
        @returns(Le temps écoulé du minuteur.)
    }
    function getDuration(timer: TTimer): LongInt;
    {   
        @abstract(Retourne la durée totale du minuteur)
        Prend en entrée un minuteur @code(timer) et retourne sa durée totale.
        @param(timer Le minuteur duquel on veut récupérer la durée totale.)
        @returns(La durée totale du minuteur.)
    }
    function getRemainingTime(timer: TTimer): LongInt;
    {   
        @abstract(Retourne le temps restant du minuteur)
        Prend en entrée un minuteur @code(timer) et retourne le temps restant avant la fin du minuteur.
        @param(timer Le minuteur duquel on veut récupérer le temps restant.)
        @returns(Le temps restant du minuteur.)
    }
    function isPaused(timer: TTimer): Boolean;
    {   
        @abstract(Vérifie si le minuteur est en pause)
        Prend en entrée un minuteur @code(timer) et retourne un booléen indiquant si le minuteur est en pause.
        @param(timer Le minuteur à vérifier.)
        @returns(Un booléen indiquant si le minuteur est en pause.)
    }
    function isFinished(timer: TTimer): Boolean;
    {   
        @abstract(Vérifie si le minuteur est terminé)
        Prend en entrée un minuteur @code(timer) et retourne un booléen indiquant si le minuteur est terminé.
        @param(timer Le minuteur à vérifier.)
        @returns(Un booléen indiquant si le minuteur est terminé.)
    }
    procedure tick(var timer: TTimer; step: LongInt);
    {   
        @abstract(Avance le minuteur d'un certain temps)
        Prend en entrée un minuteur @code(timer) et un temps @code(step) puis avance le minuteur de ce temps. Sans effet si le minuteur est en pause ou terminé.
        @param(timer Le minuteur à avancer.)
        @param(step Le temps d'avancement du minuteur.)
    }
    procedure pauseTimer(var timer: TTimer);
    {   
        @abstract(Met le minuteur en pause)
        Prend en entrée un minuteur @code(timer) et le met en pause. Sans effet si le minuteur est déjà en pause ou terminé.
        @param(timer Le minuteur à mettre en pause.)
    }
    procedure resumeTimer(var timer: TTimer);
    {   
        @abstract(Reprend le minuteur)
        Prend en entrée un minuteur @code(timer) et le reprend. Sans effet si le minuteur n'est pas en pause.
        @param(timer Le minuteur à reprendre.)
    }
    procedure resetTimer(var timer: TTimer; duration: LongInt);
    { procedure resetTimer(var TTimer, duration: LongInt); 
        Note from Minh: don't write this procedure yet. i think this procedure is redundant and 
        it is actually initialiseTimer :))
    }
implementation 
    function initialiseTimer(duration: LongInt): TTimer;
    var 
        timer: TTimer;
    begin 

        timer.elapsedTime := 0;
        timer.duration := duration;
        timer.isPaused := False;
        initialiseTimer := timer;

    end; 

    function getElapsedTime(timer: TTimer): LongInt;
    begin 

        getElapsedTime := timer.elapsedTime;
    end; 

    function getDuration(timer: TTimer): LongInt;
    begin 
        getDuration := timer.duration;
    end;

    function getRemainingTime(timer: TTimer): LongInt;
    begin 
        getRemainingTime := timer.duration - timer.elapsedTime;
    end; 

    function isPaused(timer: TTimer): Boolean;
    begin 
        isPaused := timer.isPaused;
    end; 

    function isFinished(timer: TTimer): Boolean;
    begin 
        isFinished := timer.elapsedTime >= timer.duration;
    end;

    procedure tick(var timer: TTimer; step: LongInt);
    begin 
        timer.elapsedTime := timer.elapsedTime + step;
    end;

    procedure pauseTimer(var timer: TTimer);
    begin 
        timer.isPaused := True;

    end;

    procedure resumeTimer(var timer: TTimer);
    begin 
        timer.isPaused := False;
    end;

end.