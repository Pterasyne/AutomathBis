import pandas as pd
import os
import sys
os.chdir(sys.path[0])
NumberOfParticipants = 42 #MAX number of participants
    
temp = pd.DataFrame(columns =["participant_code", "Type", "Opérande 1", "Opérande 2", "Réponse enfant", "Match",
                               0, 1, 2, 3, 4, 5, 6])
for i in range(1, NumberOfParticipants + 1):
    if os.path.exists(f"Strat_{i:02}.xlsx") :
        df = pd.read_excel(f"Strat_{i:02}.xlsx") #format of your participant code (leading 0 if single digit here)
        df["Match"] = (df["Résultat attendu"] == df["Réponse enfant"]) #pb in the excel files for the match column
        df.drop(["signe", "Résultat attendu"], axis = 1, inplace = True)
        df = df.astype({"Match":bool, 0:bool, 1:bool, 2:bool, 3:bool, 4:bool, 5:bool, 6:bool})

        #Removing qualitative comments on the file
        df.drop(df[df["Type"] != "Addition"].index, inplace = True) #also to remove added general comments
        columnsNames = df.columns.tolist() #Not by column names (e.g., "Unnamed: 17"), as the formatting changes across excel versions
        for j in range(len(temp.columns)-1, len(columnsNames)):
            df[6] = df[6] | (df[columnsNames[j]].astype(str).str.contains('comp') 
                             & ~(df[columnsNames[j]].astype(str).str.contains('pas')) 
                             & ~(df[columnsNames[j]].astype(str).str.contains('tête')))
            df.drop([columnsNames[j]], axis = 1, inplace = True)              
        df["participant_code"] = i 
        temp = pd.concat([temp, df], ignore_index = True)

temp.rename(columns = {"Opérande 1":"num1", "Opérande 2":"num2", #same name as arithmetic + in english
                       "Réponse enfant":"child_answer"}, inplace = True) 

#Dummy coding for automatization
temp["preAutomatized"] = 0
temp.loc[((temp[3]==True) | (temp[4]==True) | (temp[5]==True)) #necessary parentheses as the logical "and" ("&") has the priority
         & temp["Match"] == True, "preAutomatized"] = 1 

#Addition part
addition = temp.copy()
addition.drop(["Type"], axis = 1, inplace = True)
addAutoOnly = addition.drop(["Match", 0, 1, 2, 3, 4, 5, 6], axis = 1)
addAutoOnly.to_csv("preBis_addition_strat_automatized.csv", index = False) #just the dummy code
addition.rename(columns = {"Match":"PRE match", 
                           "0":"PRE count all", 
                           "1":"PRE count on from the first addend", 
                           "2":"PRE count on from the second addend", #change for automathBis
                            "3":"PRE direct retrieval", 
                            "4":"PRE derived facts", 
                            "5":"PRE other unknown",
                            "6":"PRE direct modeling"}, inplace = True) #link with "guide de passation"
addition.to_csv("preBis_addition_strat_complete.csv", index = False) 