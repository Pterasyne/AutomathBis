# AutomathBis
## Tasks
This repository is the second wave of *The Automath Project*. As for the first part, note that the zipped jsPsych library has been redistributed to simplify task execution, but please install it directly from the source [github.com/jspsych](https://github.com/jspsych/jsPsych). The guide is in French but if you want a translation, we will be happy to provide it to you :)

Please note that, among the small differences in this project:
- we added the 36 possible combinations for true conditions (from 108 problems to 144 in the arithmetic task)
- we changed "count on from the largest addend" to "count on from the second addend"

## Analyses
First, we propose a new code for mistake during experiment by swapping stickers for true/false keys : [wrongMapping.py](https://github.com/Pterasyne/AutomathBis/blob/main/wrongMapping.py) (the idea is to correct the wrong parity)
### Strategies
[0_preBisStrat.py](https://github.com/Pterasyne/AutomathBis/blob/main/0_preBisStrat.py) is very similar to our first way to analyse strategies. As a reminder, we changed our column "2" to mean "second" operand rather than largest. Consequently, if you want to compare our first experiment to this second waves, you need to add some lines of codes to switch the meaning.
### Arithmetic (verification task)
[0_preArithmeticCleanTheData.py](https://github.com/Pterasyne/AutomathBis/blob/main/0_preArithmeticCleanTheData.py) followed by [0_preArithmeticFilterTheData.py](https://github.com/Pterasyne/AutomathBis/blob/main/0_preArithmeticFilterTheData.py) are also similar. However, for each equations there is now two times a true printed result. As such, and at least for the moment, we averaged both value for each equation (e.g., "1 + 1") and each participant.
