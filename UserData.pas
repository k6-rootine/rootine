{This unit stocks user information such as join date, identifiants and statistics}
unit UserData;

interface 

    const 
        MAX_SPECIES = 100   

    type TDate = Record
        day, month, year : Integer;
    end;
    
    type TForest = Record
            speciesName : Array[1..MAX_SPECIES] of string;
            nbTreesGrown : Array[1..MAX_SPECIES] of Integer;
            nbSpecies : integer;
        end;

    type TUser = Record;
        firstName, lastName, username, description : string;
        joinDate : TDate;
        nbSessionsDone, nbCyclesDone, totalFocusTime : integer;
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


    

implementation

end.