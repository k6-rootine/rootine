{This unit stocks and manuplates user information such as join date, identifiants and statistics}
unit UserData;

interface 

    const 
        MAX_SPECIES = 100;


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


    function getSpeciesName(forest: TForest; n: Word): string;


    function getNbTreesGrown(forest: TForest; nb: Word): Word;


    function getNbSpecies(forest: TForest): Word;


    function findSpecies(forest: TForest; tree: string): Word;


    function addTree(forest: TForest; n: Word): TForest;
end.