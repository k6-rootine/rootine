{This unit stocks and manuplates user information such as join date, identifiants and statistics}
unit UserData;

interface 

    const 
        MAX_SPECIES = 100   


   {saves the date of creation of the account}      
    type TDate = Record
        day, month, year : Word;
    end;
    
    {the forest data with its nb species, nb of trees grown and name of the trees}
    type TForest = Record
            speciesName : Array[1..MAX_SPECIES] of string;
            nbTreesGrown : Array[1..MAX_SPECIES] of Word;
            nbSpecies : Word;
        end;
    
   {keeps the info of the user as well as its forest and stats}
    type TUser = Record
        firstName, lastName, username, description : string;
        joinDate : TDate;
        nbSessionsDone, nbCyclesDone, totalFocusTime : Word;
        forest : TForest;
        end;

    function initialiseUser() : TUser;


    function setFirstName(user: TUser; firstName: string): TUser;


    function getFirstName(user: TUser): string;


    function setLastName(user: TUser; lastName: string): TUser;


    function getLastName(user: TUser): string;


    function setUsername(user: TUser; username: string): TUser;


    function getusername(user: TUser): string;


    function setDescription(user: TUser; description: string): TUser;


    function getDescription(user: TUser): string;


    function getJoinDate(user: TUser): TDate;


    function setNbSessionsDone(user: TUser; nb: Word): TUser;


    function getNbSessionsDone(user: TUser): Word;


    function setNbCyclesDone(user: TUser; nb: Word): TUser;


    function getNbCyclesDone(user: TUser): Word;


    function setTotalFocusTime(user: TUser; nb: Word): TUser;


    function getTotalFocusTime(user: TUser): Word;


    function getForest(user: TUser): TForest;


    function getSpeciesName(forest: TForest; n: Word): string;


    function getNbTreesGrown(forest: TForest; nb: Word): Word;


    function getNbSpecies(forest: TForest): Word;


    function findSpecies(forest: TForest; tree: string): Word;


    function addTree(forest: TForest; n: Word): TForest;

implementation

    function initialiseUser() : TUser;
    var
        i : Word;
    begin
        initialiseUser.firstName := '';
        initialiseUser.lastName := '';
        initialiseUser.username := '';
        initialiseUser.description := '';
        
        initialiseUser.joinDate.day := 0;
        initialiseUser.joinDate.month := 0;
        initialiseUser.joinDate.year := 0;
        
        initialiseUser.nbSessionsDone := 0;
        initialiseUser.nbCyclesDone := 0;
        initialiseUser.totalFocusTime := 0;
        
        initialiseUser.forest.nbSpecies := 0;
        for i := 1 to MAX_SPECIES do
        begin
            initialiseUser.forest.speciesName[i] := '';
            initialiseUser.forest.nbTreesGrown[i] := 0;
        end;
    end;


    function setFirstName(user: TUser; firstName: string): TUser;
    begin
        user.firstName := firstName;
        setFirstName := user;
    end;

    function getFirstName(user: TUser): string;
    begin
        getFirstName := user.firstName;
    end;

    function setLastName(user: TUser; lastName: string): TUser;
    begin
        user.lastName := lastName;
        setLastName := user;
    end;

    function getLastName(user: TUser): string;
    begin
        getLastName := user.lastName;
    end;

    function setUsername(user: TUser; username: string): TUser;
    begin
        user.username := username;
        setUsername := user;
    end;


    function getusername(user: TUser): string;
    begin
        getusername := user.username;
    end;

    function setDescription(user: TUser; description: string): TUser;
    begin
        user.description := description;
        setDescription := user;
    end;

    function getDescription(user: TUser): string;
    begin
        getDescription := user.description;
    end;

    function getJoinDate(user: TUser): TDate;
    begin
        getJoinDate := user.joinDate;
    end;

    function setNbSessionsDone(user: TUser; nb: Word): TUser;
    begin
        user.nbSessionsDone := nb;
        setNbSessionsDone := user;
    end;

    function getNbSessionsDone(user: TUser): Word;
    begin
        getNbSessionsDone := user.nbSessionsDone;
    end;

    function setNbCyclesDone(user: TUser; nb: Word): TUser;
    begin
        user.nbCyclesDone := nb;
        setNbCyclesDone := user;
    end;

    function getNbCyclesDone(user: TUser): Word;
    begin
        getNbCyclesDone := user.nbCyclesDone;
    end;

    function setTotalFocusTime(user: TUser; nb: Word): TUser;
    begin
        user.totalFocusTime := nb;
        setTotalFocusTime := user;
    end;

    function getTotalFocusTime(user: TUser): Word;
    begin
        getTotalFocusTime := user.totalFocusTime;
    end;

    function getForest(user: TUser): TForest;
    begin
        getForest := user.forest;
    end;

    {shouldnt we add the user as a parameter too? do we know which "forest" we talking about here?}
    function getSpeciesName(forest: TForest; n: Word): string;
    begin
        if (n >= 1) and (n <= forest.nbSpecies) then
            getSpeciesName := forest.speciesName[n]
        else
            getSpeciesName := ' ';
    end;

    {again, shouldnt we add the user as a parameter too? do we know which "forest" we talking about here?}
    function getNbTreesGrown(forest: TForest; nb: Word): Word;
    begin
        if (n >= 1) and (n <= forest.nbSpecies) then
            getNbTreesGrown := forest.nbTreesGrown[n]
        else
            getNbTreesGrown := 0;
    end;

    function getNbSpecies(forest: TForest): Word;
    begin
        getNbSpecies := forest.nbSpecies;
    end;

    {we look from i = 1 to nbSpecies if tree exists. If its found, we return its position. If it doesnt exist, we return 0}
    function findSpecies(forest: TForest; tree: string): Word;
    var 
        i : Word;
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

    {adds +1 tree to the given species number of grown trees}
    function addTree(forest: TForest; n: Word): TForest;
    begin
        if (n >= 1) and (n <= forest.nbSpecies) then
            forest.speciesName[n] := forest.speciesName[n] + 1;
        addTree := forest;
    end;
end.