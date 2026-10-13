import pandas as pd
import os.path
import sys
os.chdir(sys.path[0])
numberOfProblems = 144

df = pd.read_csv("preBis_arithmetic_clean_experiment.csv")
listOfParticipants = set(df["participant_code"].tolist())
print(listOfParticipants)

df.drop("response_key", axis = 1, inplace = True) 
df.drop("response_type", axis = 1, inplace = True) 
df.drop("displayed_sum", axis = 1, inplace = True)

#Filtering on trials
df.drop(df[df["correct"] != True].index, inplace = True) #also remove undef

#Filtering on participants
stdDf = df.groupby("participant_code", as_index = False)["reaction_time"].std()
meanDf = df.groupby("participant_code", as_index = False)["reaction_time"].mean()

for i in listOfParticipants:
    mean = meanDf.loc[meanDf['participant_code'] == i, 'reaction_time'].iloc[0]
    std = stdDf.loc[stdDf['participant_code'] == i, 'reaction_time'].iloc[0]
    df.drop(df[(df["participant_code"] == i) & ((df["reaction_time"] > mean + 3*std) 
               | (df["reaction_time"] < mean - 3*std))].index, inplace = True) #remove extreme problems within a participant
    if len(df[df['participant_code'] == i]) <= (1/2)*numberOfProblems: #more conservative here in Bis as equal number of right and wrong answers
        df.drop(df[df["participant_code"] == i].index, inplace = True) #remove potential guessers

#Opportunistic Stopping part
false_plus1 = df.drop(df[df["trial_kind"] != "false_plus1"].index)
false_plus1.drop(["trial_kind"], axis = 1, inplace = True)
true = df.drop(df[df["trial_kind"] != "true"].index)
true.drop(["trial_kind"], axis = 1, inplace = True)
false_minus1 = df.drop(df[df["trial_kind"] != "false_minus1"].index)
false_minus1.drop(["trial_kind"], axis = 1, inplace = True)

false_plus1.rename(columns={"reaction_time" : "RT_false_plus1"}, inplace = True)
true.rename(columns={"reaction_time" : "RT_true"}, inplace = True)
true = true.groupby(["participant_code", 
                      "num1",  "num2", "correct"], as_index=False)[["participant_code", 
                      "num1",  "num2", "correct","RT_true"]].agg("mean") #IMPORTANT
false_minus1.rename(columns={"reaction_time" : "RT_false_minus1"}, inplace = True)

df = true.merge(false_plus1, how="outer").merge(false_minus1, how="outer") #df = true.merge(false_plus1.merge(false_minus1)) #Without outer, you don't have empty cells

df["opportunistic_stopping"] = 0
df.loc[df["RT_false_plus1"] > df["RT_false_minus1"], "opportunistic_stopping"] = 1
df.loc[df["RT_false_plus1"].isnull() | df["RT_false_minus1"].isnull(), "opportunistic_stopping"] = None

#Adding pre-tests automatization information for R-analyses
if os.path.exists("preBis_addition_strat_automatized.csv"): 
    autoDf = pd.read_csv("preBis_addition_strat_automatized.csv")
    autoDf.drop("child_answer", axis = 1 , inplace = True)
    df = pd.merge(df,autoDf, how = "outer")

#Adding post-tests automatization information for R-analyses
if os.path.exists("postBis_addition_strat_automatized.csv"): 
    autoDf = pd.read_csv("postBis_addition_strat_automatized.csv")
    autoDf.drop("child_answer", axis = 1 , inplace = True)
    df = pd.merge(df,autoDf, how = "outer")

#TO CHANGE BUT I DON'T HAVE THESE DATA YET
#df["stillAutomatized"] = ((df["preAutomatized"] == 1) & (df["postAutomatized"] == 1)).astype(int)
#df["stillNonAutomatized"] = ((df["preAutomatized"] == 0) & (df["postAutomatized"] == 0)).astype(int)
#df["becameAutomatized"] = ((df["preAutomatized"] == 0) & (df["postAutomatized"] == 1)).astype(int)

df["problem"] = df["num1"].astype(str) + " + " + df["num2"].astype(str) #adding a column to have an identifiying key for problem

df.to_csv("preBis_arithmetic_final.csv", index = False)

