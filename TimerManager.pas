unit TimerManager;

interface 
    type 
        TTimer = record 
            elapsedTime, duration: LongInt;
            isPaused: Boolean;
        end;

    function initialiseTimer(duration: LongInt): TTimer;
    function getElapsedTime(timer: TTimer): LongInt;
    function getDuration(timer: TTimer): LongInt;
    function getRemainingTime(timer: TTimer): LongInt;
    function isPaused(timer: TTimer): Boolean;
    function isFinished(timer: TTimer): Boolean;
    procedure tick(var timer: TTimer; step: LongInt);
    procedure pauseTimer(var timer: TTimer);
    procedure resumeTimer(var timer: TTimer);
    { procedure resetTimer(var TTimer, duration: LongInt); 
        Note from Minh: don't write this procedure yet. i think this procedure is redundant and 
        it is actually initialiseTimer :))
    }
implementation 
    function initialiseTimer(duration: LongInt): TTimer;
    begin 

    end; 

    function getElapsedTime(timer: TTimer): LongInt;
    begin 

    end; 

    function getDuration(timer: TTimer): LongInt;
    begin 

    end;

    function getRemainingTime(timer: TTimer): LongInt;
    begin 

    end; 

    function isPaused(timer: TTimer): Boolean;
    begin 

    end; 

    function isFinished(timer: TTimer): Boolean;
    begin 

    end;

    procedure tick(var timer: TTimer; step: LongInt);
    begin 

    end;

    procedure pauseTimer(var timer: TTimer);
    begin 

    end;

    procedure resumeTimer(var timer: TTimer);
    begin 

    end;

end.