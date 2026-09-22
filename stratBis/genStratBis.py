import pandas as pd
import random
NB_PARTICIPANTS = 42 #arbitrary as I don't know precisely yet
LAST_NB = 0 #we had 26 for the first wave

pairs = []
for a in range(1, 10):
    for b in range(1, 10):
        if a+b < 10:
            pairs.append((a,b))
for i in range(LAST_NB+1, LAST_NB+NB_PARTICIPANTS+1):
    sheet = []
    random.shuffle(pairs)
    for (a,b) in pairs:
        sheet.append([
            "Addition", 
            a,
            "+",
            b,
            a+b,
            "",
            "",
            ] + [""] * 7)
    columns = [
        "Type", "Opérande 1", "signe", "Opérande 2", "Résultat attendu",
        "Réponse enfant", "Match"
    ] + [str(i) for i in range(7)]    
    df=pd.DataFrame(sheet, columns=columns)
    df.to_excel(f"Strat_{i:02d}.xlsx",index=False)