import pandas as pd
import os.path
import sys
os.chdir(sys.path[0])
NumberOfParticipants = 42

#Init
temp_tra = pd.DataFrame(columns =["participant_code", "trial_kind", "num1", "num2", "displayed_sum", "response_type", "response_key", "correct", "reaction_time"])
temp_exp = pd.DataFrame(columns =["participant_code", "trial_kind", "num1", "num2", "displayed_sum", "response_type", "response_key", "correct", "reaction_time"])

for i in range(1, NumberOfParticipants + 1):
    if os.path.exists(f"arithmetic_{i:02}.csv") :
        df = pd.read_csv(f"arithmetic_{i:02}.csv") #format of your participant code (leading 0 if single digit here)
        df.drop(["success", "rt", "trial_type", "trial_index", "plugin_version", "time_elapsed", "response", "value", "expected", "stimulus", "correct_sum", "response_matching"], axis = 1, inplace = True)

    #For the training file
        df_tra = df[df["phase"]=="training"]
        df_tra = df_tra.drop("phase", axis = 1)
        temp_tra = pd.concat([temp_tra.astype(df_tra.dtypes), df_tra], ignore_index = True)

    #For the experiment file
        df_exp = df[df["phase"]=="main"]
        df_exp = df_exp.drop("phase", axis = 1)
        temp_exp = pd.concat([temp_exp.astype(df_exp.dtypes), df_exp], ignore_index = True)

    if os.path.isfile("demographics_arithmetic.csv"): #per participant
        temp_d = pd.read_csv("demographics_arithmetic.csv")
        temp_tra = pd.merge_ordered(temp_d, temp_tra, on = "participant_code")
        temp_exp = pd.merge_ordered(temp_d, temp_exp, on = "participant_code")
    
temp_tra.to_csv("preBis_arithmetic_clean_training.csv", index = False)
temp_exp.to_csv("preBis_arithmetic_clean_experiment.csv", index = False)