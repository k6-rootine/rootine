{
This unit stores and manipulates user information such as join date, identity and statistics and the forest of trees grown through completed sessions.
}
unit UserData;

interface
    uses SysUtils;

    { Maximum number of different tree species a forest can hold. }
    const MAX_SPECIES = 100;

   { A calender date (day/month/year) 
    Used to check the user's join date. }      
    type TDate = Record
        day, month, year : LongInt;
    end;
    
    { The user's forest: for each tree species, how many trees were grown and their name.
    nbTreesGrown[i] and speciesName[i] describe the same species.
    Only indices 1..nbSpecies are meaningful, the rest is '' and 0. }
    type TForest = Record
            speciesName : Array[1..MAX_SPECIES] of string;
            nbTreesGrown : Array[1..MAX_SPECIES] of LongInt;
            nbSpecies : LongInt;
        end;
    
   {the user profile with its forest and stats}
    type TUser = Record
        name, username, description : string;
        joinDate : TDate;
        nbSessionsDone, nbCyclesDone, totalFocusTime : LongInt;
        forest : TForest;
        end;


    {--- DATE ---}

    { Builds a date with its tree parts.
    @returns corresponding TDate. }
    function initialiseDate(day, month, year: LongInt): TDate;
    
    { @returns The day of the month of the date. }
    function getDay(date: TDate): LongInt;

    { @returns The month of the date. }
    function getMonth(date: TDate): LongInt;

    { @returns The year of the date. }
    function getYear(date: TDate): LongInt;


    {----FOREST---}

    { Creates an empty forest: no species, all names '' and all counts 0.
        @returns A new empty forest. }
    function initialiseForest(): TForest;

    { Gets the number of trees grown for one species.
        @param forest  The forest to read.
        @param n       Position of the species (1..nbSpecies).
        @returns The number of trees of species n, or 0 if n is out of range.}
    function getNbTreesGrown(forest: TForest; n: LongInt): LongInt;

    { @returns The number of different species in the forest. }
    function getNbSpecies(forest: TForest): LongInt;
    
    {  Searches for a species by name (case-sensitive, exact match).
        @param forest  The forest to search.
        @param tree    Name of the species to look for.
        @returns The position (1..nbSpecies) of the species, or 0 if it is not in the forest. }
    function findSpecies(forest: TForest; tree: string): LongInt;

    { Gets the name of the species at a given position.
        @param forest  The forest to read.
        @param n       Position of the species (1..nbSpecies).
        @returns The species name, or a single space ' ' if n is out of range. }
    function getForestSpeciesName(forest: TForest; n: LongInt): string;

    {--USER--}

    { Creates a new, blank user.
        Name, username and description are empty, all counters are 0,
        the forest is empty, and joinDate is set to today's system date.
        @returns A new user. }
    function initialiseUser(): TUser;

    { @returns The display name of the user. }
    function getName(user: TUser): string;

    { Sets the display name of the user.
        @param user  The user to modify.
        @param name  The new name. }
    procedure setName(var user: TUser; name: string);

    { Sets the username. No uniqueness or format check is done here.
        @param user      The user to modify.
        @param username  The new username. }
    procedure setUsername(var user: TUser; username: string);

    { @returns The username (login identifier) of the user. }
    function getusername(user: TUser): string;

    { Sets the description.
        @param user         The user to modify.
        @param description  The new description. }
    procedure setUserDescription(var user: TUser; description: string);

    { @returns The description (biography) of the user. }
    function getUserDescription(user: TUser): string;

    { Sets the number of completed sessions.
        @param user  The user to modify.
        @param nb    The new total (should be >= 0, not checked). }
    procedure setNbSessionsDone(var user: TUser; nb: LongInt);

    { @returns The total number of focus sessions the user has completed. }
    function getNbSessionsDone(user: TUser): LongInt;

    { Sets the number of completed cycles.
        @param user  The user to modify.
        @param nb    The new total (should be >= 0, not checked). }
    procedure setNbCyclesDone(var user: TUser; nb: LongInt);

    { @returns The total number of cycles the user has completed. }
    function getNbCyclesDone(user: TUser): LongInt;

    { Sets the total focus time.
        @param user  The user to modify.
        @param nb    The new total, same unit as the cycle durations (should be >= 0, not checked). }
    procedure setTotalFocusTime(var user: TUser; nb: LongInt);

    { @returns The total focus time, in the unit used for cycle durations. }
    function getTotalFocusTime(user: TUser): LongInt;

    { @returns A copy of the user's forest. Modifying the copy does not change the user; use addTree to grow trees. }
    function getForest(user: TUser): TForest;

    { @returns The date the account was created.}
    function getJoinDate(user: TUser): TDate;

    {Adds one grown tree of the given species to the user's forest.
        If the species is new, it is first added at the end of the list.
        If the species is new and the forest already holds MAX_SPECIES species, nothing happens.
        @param user  The user to modify.
        @param tree  Name of the species (case-sensitive). }
    procedure addTree(var user: TUser; tree: string);

implementation

    {--DATE--}

    function initialiseDate(day, month, year: LongInt): TDate;
    var 
        date: TDate;
    begin
        date.day := day;
        date.month := month;
        date.year := year;

        initialiseDate := date;
    end;
 
    function getDay(date: TDate): LongInt;
    begin
        getDay := date.day;
    end;
 
    function getMonth(date: TDate): LongInt;
    begin
        getMonth := date.month;
    end;
 
    function getYear(date: TDate): LongInt;
    begin
        getYear := date.year;
    end;


    {--FOREST-- }

    function initialiseForest(): TForest;
    var
        forest : TForest;
        i : LongInt;
    begin
        forest.nbSpecies := 0;
        for i := 1 to MAX_SPECIES do
        begin
            forest.speciesName[i] := '';
            forest.nbTreesGrown[i] := 0;
        end;
        initialiseForest:= forest;
    end;

    function getNbTreesGrown(forest: TForest; n: LongInt): LongInt;
    begin
        if (n >= 1) and (n <= forest.nbSpecies) then
            getNbTreesGrown := forest.nbTreesGrown[n]
        else
            getNbTreesGrown := 0;
    end;

    function getNbSpecies(forest: TForest): LongInt;
    begin
        getNbSpecies := forest.nbSpecies;
    end;

     {we look from i = 1 to nbSpecies if tree exists. If its found, we return its position. If it doesnt exist, we return 0}
    function findSpecies(forest: TForest; tree: string): LongInt;
    var 
        i : LongInt;
        found : Boolean;
    begin
        i := 1;
        found := False;
        while (i <= forest.nbSpecies) and (not found) do
        begin
            if forest.speciesName[i] = tree then
                found := True
            else 
                i := i + 1;
        end;

        if found then
            findSpecies := i 
        else
            findSpecies := 0;
    end;
    
    function getForestSpeciesName(forest: TForest; n: LongInt): string;
    begin
        if (n >= 1) and (n <= forest.nbSpecies) then
            getForestSpeciesName := forest.speciesName[n]
        else
            getForestSpeciesName := ' ';
    end;

    {--USER--}

    function initialiseUser(): TUser;
    var
        user : TUser;
        dd, mm, yy : Word;
    begin
        DecodeDate(Date, yy, mm, dd);

        user.name := '';
        user.username := '';
        user.description := '';
        user.joinDate := initialiseDate(dd, mm, yy);
        user.nbSessionsDone := 0;
        user.nbCyclesDone := 0;
        user.totalFocusTime := 0;
        user.forest := initialiseForest();
        
        initialiseUser := user;
    end;

    function getName(user: TUser): string;
    begin
        getName := user.name;
    end;
 
    procedure setName(var user: TUser; name: string);
    begin
        user.name := name;
    end;
 
    function getUsername(user: TUser): string;
    begin
        getUsername := user.username;
    end;
 
    procedure setUsername(var user: TUser; username: string);
    begin
        user.username := username;
    end;
 
    function getUserDescription(user: TUser): string;
    begin
        getUserDescription := user.description;
    end;
 
    procedure setUserDescription(var user: TUser; description: string);
    begin
        user.description := description;
    end;
 
    function getNbSessionsDone(user: TUser): LongInt;
    begin
        getNbSessionsDone := user.nbSessionsDone;
    end;
 
    procedure setNbSessionsDone(var user: TUser; nb: LongInt);
    begin
        user.nbSessionsDone := nb;
    end;
 
    function getNbCyclesDone(user: TUser): LongInt;
    begin
        getNbCyclesDone := user.nbCyclesDone;
    end;
 
    procedure setNbCyclesDone(var user: TUser; nb: LongInt);
    begin
        user.nbCyclesDone := nb;
    end;
 
    function getTotalFocusTime(user: TUser): LongInt;
    begin
        getTotalFocusTime := user.totalFocusTime;
    end;
 
    procedure setTotalFocusTime(var user: TUser; nb: LongInt);
    begin
        user.totalFocusTime := nb;
    end;
 
    function getJoinDate(user: TUser): TDate;
    begin
        getJoinDate := user.joinDate;
    end;
 
    function getForest(user: TUser): TForest;
    begin
        getForest := user.forest;
    end;
 
    procedure addTree(var user: TUser; tree: string);
    var
        n : LongInt;
    begin
        n := findSpecies(user.forest, tree);
 
        {if its a new species, its created at the end of the list (its checked if there is still room)}
        if n = 0 then
        begin
            if user.forest.nbSpecies < MAX_SPECIES then
            begin
                user.forest.nbSpecies := user.forest.nbSpecies + 1;
                n := user.forest.nbSpecies;
                user.forest.speciesName[n] := tree;
                user.forest.nbTreesGrown[n] := 0;
            end;
        end;
 
        
        if (n <> 0) then
            user.forest.nbTreesGrown[n] := user.forest.nbTreesGrown[n] + 1;
    end;
    
end.