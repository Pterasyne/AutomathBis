import pandas as pd
import os
import sys
os.chdir(sys.path[0]) #https://stackoverflow.com/questions/1432924/python-change-the-scripts-working-directory-to-the-scripts-own-directory

codeInput = input("What is the number/code of the participant (2 digits): ")
codeOutput = input("By what number would ou want to change it into (2 digits)?"
'\n(n.b., if wrong mapping, you have to change parity): ')
changingStratFileToo = input("Do you want to change the corresponding 'Strat' file ? y/n: ")
df = pd.read_csv(f"arithmetic_{codeInput}.csv")

if changingStratFileToo == "n":
    if (os.path.exists(f"arithmetic_{codeOutput}.csv")):
        print("The output file already exists, please find a new code")
        sys.exit()

if changingStratFileToo == "y":
    if (os.path.exists(f"Strat_{codeOutput}.xlsx")) or (os.path.exists(f"arithmetic_{codeOutput}.csv")):
        print("At least one of the output files already exists, please find a new code")
        sys.exit()
    os.rename(f"Strat_{codeInput}.xlsx", f"Strat_{codeOutput}.xlsx")

df = pd.read_csv(f"arithmetic_{codeInput}.csv")
df["participant_code"] = codeOutput
os.rename(f"arithmetic_{codeInput}.csv", f"PREVIOUSarithmetic_{codeInput}.csv")
df.replace({"response_matching" : {True : False, False : True}}, inplace = True)
df.replace({"correct" : {True : False, False : True}}, inplace = True)

df.to_csv(f"arithmetic_{codeOutput}.csv", index=False)
