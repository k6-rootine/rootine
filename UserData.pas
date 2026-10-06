{This unit stocks and manuplates user information such as join date, identifiants and statistics}
unit UserData;

interface
    const MAX_SPECIES = 100;

   {saves the date of creation of the account}      
    type TDate = Record
        day, month, year : LongInt;
    end;
    
    {the forest data with its nb species, nb of trees grown and name of the trees}
    type TForest = Record
            speciesName : Array[1..MAX_SPECIES] of string;
            nbTreesGrown : Array[1..MAX_SPECIES] of LongInt;
            nbSpecies : LongInt;
        end;
    
   {keeps the info of the user as well as its forest and stats}
    type TUser = Record
        name, username, description : string;
        joinDate : TDate;
        nbSessionsDone, nbCyclesDone, totalFocusTime : LongInt;
        forest : TForest;
        end;


    {--- Date ---}
    function initialiseDate(day, month, year: LongInt): TDate;
    function getDay(date: TDate): LongInt;
    function getMonth(date: TDate): LongInt;
    function getYear(date: TDate): LongInt;

    {---Forest --}
    function initialiseForest(): TForest;
    function getNbTreesGrown(forest: TForest; n: LongInt): LongInt;
    function getNbSpecies(forest: TForest): LongInt;
    function findSpecies(forest: TForest; tree: string): LongInt;
    function getForestSpeciesName(forest: TForest; n: LongInt): string;

    {--User--}
    function initialiseUser(): TUser;

    function getName(user: TUser): string;
    procedure setName(var user: TUser; name: string);

    procedure setUsername(var user: TUser; username: string);
    function getusername(user: TUser): string;


    procedure setDescription(var user: TUser; description: string);
    function getDescription(user: TUser): string;


    procedure setNbSessionsDone(var user: TUser; nb: LongInt);
    function getNbSessionsDone(user: TUser): LongInt;


    procedure setNbCyclesDone(var user: TUser; nb: LongInt);
    function getNbCyclesDone(user: TUser): LongInt;


    procedure setTotalFocusTime(var user: TUser; nb: LongInt);
    function getTotalFocusTime(user: TUser): LongInt;


    function getForest(user: TUser): TForest;
    function getJoinDate(user: TUser): TDate;

    {adds +1 grown tree to the species "tree" of the user's forest (the species is created if it is new)}
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
    begin
        user.name := '';
        user.username := '';
        user.description := '';
        user.joinDate := initialiseDate(0, 0, 0);
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
 
    function getDescription(user: TUser): string;
    begin
        getDescription := user.description;
    end;
 
    procedure setDescription(var user: TUser; description: string);
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
 
        {if new species, we create it at the end of the list (we check if there is still room)}
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