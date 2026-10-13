library(lme4) 
library(tidyverse) #or simply library(dplyr)
#WILL NEED TO CHANGE PREAUTO BY STILLAUTOMATIZED

preData <- read.csv("preBis_arithmetic_final.csv") %>%
  mutate(time = 0, type = if_else(pmax(num1, num2) <= 4, 0, 1)) #pre; small=0 and big=1

#postData <- read.csv("post_arithmetic_final.csv") %>%
#  mutate(time = 1, type = if_else(pmax(num1, num2) <= 4, 0, 1)) #post; small=0 and big=1

combined <- bind_rows(
  preData %>% select(participant_code, problem, num1, num2, 
                     opportunistic_stopping, time, type, preAutomatized), #opportunistic_stopping, time, type, stillAutomatized, stillNonAutomatized),
#  postData %>% select(participant_code, problem, num1, num2, 
#                      opportunistic_stopping, time, type, stillAutomatized, stillNonAutomatized)
)

tieData <- combined %>%
  mutate(is_tie = if_else(num1 == num2, 1, 0))

dataWithoutTie <- tieData %>%
  filter(is_tie != 1)

dataWithoutOneNorTie <- dataWithoutTie %>%
  filter(num1 != 1 & num2 != 1)

data <- dataWithoutOneNorTie %>%
  filter(!is.na(opportunistic_stopping))

model <- glmer(
  opportunistic_stopping ~ time * type + 
    (1 | participant_code) + 
    (1 | problem),
  data = data,
  family = binomial
)

summary(model)

#dataOnAuto <- data %>%
#  filter((stillAutomatized==1|stillNonAutomatized==1))

modelOnAuto <- glmer(
  opportunistic_stopping ~ preAutomatized * time +
  (1 | participant_code) + 
  (1 | problem),
  data = data, #data = dataOnAuto,
  family = binomial
)

summary(modelOnAuto)

ci_main <- confint(model, method = "Wald")
fixed_rows <- grep("\\.sig", rownames(ci_main), invert = TRUE) #removing random effects, else bugs
ci_fixed_main <- ci_main[fixed_rows, ]
exp(cbind(OR = fixef(model), ci_fixed_main))


ci_auto <- confint(modelOnAuto, method = "Wald")
fixed_rows_auto <- grep("\\.sig", rownames(ci_auto), invert = TRUE)
ci_fixed_auto <- ci_auto[fixed_rows_auto, ]
exp(cbind(OR = fixef(modelOnAuto), ci_fixed_auto))