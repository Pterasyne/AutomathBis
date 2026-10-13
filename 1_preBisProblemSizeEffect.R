library(lme4) 
library(tidyverse) #or simply library(dplyr)
#dataFull <- read.csv("production_final.csv")
dataOne <- read.csv("preBis_arithmetic_final.csv")
#dataTwo <- read.csv("post_arithmetic_final.csv")

ISR <- 4 #could change depending on individual subitizing range (ISR)

# ctrl + maj + c to uncomment btw
# dataFull <- dataFull %>%
#   mutate(problem_size = num1+num2)
# 
# dataFullWithoutOneNorTie <- dataFull %>%
#   filter((problem_size<10) & (num1 != 1 & num2 != 1) & (num1 != num2) & !is.na(reaction_time))
# 
# 
# dataTwo <- dataTwo %>%
#   mutate(problem_size = num1+num2)
# 
# dataTwoWithoutOneNorTie <- dataTwo %>%
#   filter((num1 != 1 & num2 != 1) & (num1 != num2) & !is.na(RT_true))
# 
# 
# 
# 
# slopesFull <- dataFullWithoutOneNorTie %>%
#   group_by(participant_code) %>%
#   summarize(full = lm(reaction_time ~ problem_size)$coefficients[2])
# 
# semanticSlopesFull <- dataFullWithoutOneNorTie %>%
#   filter(num1 > ISR| num2 > ISR) %>%
#   group_by(participant_code) %>%
#   summarize(semanticFull = lm(reaction_time ~ problem_size)$coefficients[2])
# 
# proceduralSlopesFull <- dataFullWithoutOneNorTie %>%
#   filter(num1 <= ISR & num2 <= ISR) %>%
#   group_by(participant_code) %>%
#   summarize(proceduralFull = lm(reaction_time ~ problem_size)$coefficients[2])
# 
# 
# 
# slopesTwo <- dataTwoWithoutOneNorTie %>%
#   group_by(participant_code) %>%
#   summarize(two = lm(RT_true ~ problem_size)$coefficients[2])
# 
# semanticSlopesTwo <- dataTwoWithoutOneNorTie %>%
#   filter(num1 > ISR| num2 > ISR) %>%
#   group_by(participant_code) %>%
#   summarize(semanticTwo = lm(RT_true ~ problem_size)$coefficients[2])
# 
# proceduralSlopesTwo <- dataTwoWithoutOneNorTie %>%
#   filter(num1 <= ISR & num2 <= ISR) %>%
#   group_by(participant_code) %>%
#   summarize(proceduralTwo = lm(RT_true ~ problem_size)$coefficients[2])



dataOne <- dataOne %>%
  mutate(problem_size = num1+num2)

dataOneWithoutOneNorTie <- dataOne %>%
  filter((num1 != 1 & num2 != 1) & (num1 != num2) & !is.na(RT_true)) 






slopesOne <- dataOneWithoutOneNorTie %>%
  group_by(participant_code) %>%
  summarize(one = lm(RT_true ~ problem_size)$coefficients[2])

semanticSlopesOne <- dataOneWithoutOneNorTie %>%
  filter(num1 > ISR| num2 > ISR) %>%
  group_by(participant_code) %>%
  summarize(semanticOne = lm(RT_true ~ problem_size)$coefficients[2])

proceduralSlopesOne <- dataOneWithoutOneNorTie %>%
  filter(num1 <= ISR & num2 <= ISR) %>%
  group_by(participant_code) %>%
  summarize(proceduralOne = lm(RT_true ~ problem_size)$coefficients[2])

finalOneSlopes <- full_join(
     full_join(semanticSlopesOne, proceduralSlopesOne, by = "participant_code"),
     slopesOne, by = "participant_code")


# finalSlopes <- full_join(
#   full_join(
#     full_join(semanticSlopesOne, semanticSlopesTwo, by = "participant_code"),
#     semanticSlopesFull, by = "participant_code"
#   ),
#   full_join(
#     full_join(proceduralSlopesOne, proceduralSlopesTwo, by = "participant_code"),
#     proceduralSlopesFull, by = "participant_code"
#   ), by = "participant_code")
# 
# 
# finalSlopes <- full_join(
#   full_join(
#     full_join(slopesOne, slopesTwo, by = "participant_code"),
#     slopesFull, by = "participant_code"), 
#   finalSlopes, by = "participant_code")





write.csv(finalOneSlopes, "preBisProblemSizeEffect.csv")

