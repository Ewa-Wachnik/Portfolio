#### Case Study - Data analysis of stroke prediction dataset ####

### Source: https://www.kaggle.com/datasets/fedesoriano/stroke-prediction-dataset ###


### setting the project directory and loading packages ###
setwd("C:/Users/ewwci/OneDrive/Desktop/r studies/case_study")

# packages needed 

library(tidyverse)
library(janitor)
library(corrplot)
options(repos = c(CRAN = "https://cloud.r-project.org"))
install.packages("caTools")


### importing data and checking the structure ###

stroke <- read.csv("healthcare-dataset-stroke-data.csv")
str(stroke)
head(stroke)

#### Data transformation - Data cleaning ####

# unifying column names 
stroke <- select_all(stroke, tolower)

# checking new format
head(stroke)

# deleting id column as it is not going to be needed in the data analysis process 
head(stroke[,-1])
stroke <- stroke[,-1]

# checking the structure again

str(stroke)
summary(stroke)
# hypertension, heart_disease, stroke are integer type but can be transformed to factor
# ever_married, work_type, Residence_type, smoking_status are character but can be transformed to factor
# bmi is character but should be changed to number so that we can check for missing data

# converting  bmi from character to numeric
suppressWarnings(stroke$bmi <- as.numeric(as.character(stroke$bmi)))

#checking new structure
str(stroke)

#Are there any missing values?
stroke[!complete.cases(stroke),]
# bmi

summary(stroke$bmi)
median(stroke$bmi)

median(stroke$bmi,na.rm = TRUE)

# use median to fill missing values in bmi 
stroke$bmi[is.na(stroke$bmi)] <- median(stroke$bmi,na.rm = TRUE)

#check again for missing values
stroke[!complete.cases(stroke),] #none 

## Check and transform variables to factors ##


# check if there are no errors
# Gender
summary(factor(stroke$gender))
# since there is only one row containing "other" we treat it as an outlier and remove it 
stroke = stroke[!stroke$gender == 'Other',]
# transform to factor
stroke$gender <- as.factor(stroke$gender)


# Work_type
summary(factor(stroke$work_type))
stroke$work_type <- factor(stroke$work_type, levels = c("children", "Govt_job", "Never_worked", "Private", "Self-employed"))


# Smoking_status
summary(factor(stroke$smoking_status))
stroke$smoking_status <- as.factor(stroke$smoking_status)


# Residence_type
summary(factor(stroke$residence_type))
stroke$residence_type <- as.factor(stroke$residence_type)

# Hypertension
summary(factor(stroke$hypertension))
stroke$hypertension <- factor(stroke$hypertension, levels = c("0", "1"),
                              labels = c("No", "Yes"))

# Heart_disease
summary(factor(stroke$heart_disease))
stroke$heart_disease <- factor(stroke$heart_disease, levels = c("0", "1"),
                               labels = c("No", "Yes"))

# Stroke 
summary(factor(stroke$stroke))
stroke$stroke <- factor(stroke$stroke, levels = c("0", "1"),
                        labels = c("No", "Yes"))

# Ever_married
summary(factor(stroke$ever_married))
stroke$ever_married <- as.factor(stroke$ever_married)

str(stroke)

#### Data Analysis ####

summary(stroke) # statistics 

# Age statistics
summary(stroke$age)

# Age analysis 
# Based on the age column statistics we can observe that there is a wide range of values, Min 0.08/ Max 82 indicating that the 
# population sample was prepared correctly assuring the data wasn't biased. Moreover we can see that both Median and Mean are similar,
# the median (45.00) and mean (43.23) which suggests that the distribution of ages in the data-set is not heavily skewed 
# and the data is symmetrically distributed. This similarity between the median and mean ages is a positive aspect. 
# It implies that the central tendency of the age distribution is robust and not heavily influenced by extremely young or old ages. 
# The one thing that can be concerning is Min value 0.08 and should be investigated, as it may be an error or a special case that needs attention.
# It can however be treated as an outlier during the analysis process.

# Average Glucose level statistics
summary(stroke$avg_glucose_level)

# The he glucose levels in this data-set range from a minimum of 55.12 to a maximum of 271.74. The majority of levels (50%) fall between
# 77.24 and 114.09. The mean glucose level is higher than the median, indicating a potential right skewness influenced by higher glucose values.
# The right skewness suggests that there are some individuals with elevated glucose levels, potentially outliers, that contribute to the higher average.
# Understanding the distribution of glucose levels is crucial, especially in the context of health data where extreme values may have clinical 
# implications. Further exploration and consideration of clinical significance are warranted, particularly for the higher glucose values.

# Bmi statistics 
summary(stroke$bmi)

# The BMI distribution in this data-set ranges from 10.30 to 97.60. The median and mean are relatively close, suggesting a moderately 
# symmetric distribution, but the presence of a higher maximum BMI (97.60) indicates the potential presence of outliers. 
# Extremely low or high BMI values may have clinical significance. Very low BMI values (e.g., 10.30) might be unusual and could indicate
# potential data quality issues or represent individuals with severe underweight conditions. Similarly, very high BMI values (e.g., 97.60)
# may warrant closer examination due to their potential impact on the overall analysis and their relevance in the context of stroke prediction.

# Analyzing if there is gender and stroke correlation
table(stroke$gender, stroke$stroke)
mosaicplot(table(stroke$gender, stroke$stroke))

# The numbers suggest a correlation between gender and stroke, according to the mosaicplot we can see more men had strokes than women 
# but it's important to note that correlation does not imply causation. There appears to be some association between gender and the 
# occurrence of stroke. However, additional statistical analysis and consideration of other factors would be necessary to draw more 
# definitive conclusions about the nature and strength of this association.

# Other factors/stroke correlations 

table(stroke$hypertension, stroke$stroke)
table(stroke$heart_disease, stroke$stroke)
table(stroke$ever_married, stroke$stroke)
table(stroke$work_type, stroke$stroke)
table(stroke$residence_type, stroke$stroke)
table(stroke$smoking_status, stroke$stroke)

#### Data Visualization ####


### mosaic plots to help visualize the correlations between factor type values ###

mosaicplot(table(stroke$hypertension, stroke$stroke))
# According to the plot, people with hypertension had more cases of stroke than those who have no hypertension.

mosaicplot(table(stroke$heart_disease, stroke$stroke))
# Same as with hypertension, there are more cases of stroke in the group with heart diseases present.

mosaicplot(table(stroke$ever_married, stroke$stroke))
# Married people suffered more cases of stroke.

mosaicplot(table(stroke$work_type, stroke$stroke))
# Stroke seems to have occurred mostly in the self-employed, private, government job groups. In comparison
# children and never worked groups show significantly less cases of stroke. This might suggest there is an important
# correlation between actively working and stroke.

mosaicplot(table(stroke$residence_type, stroke$stroke))
# There doesn't seem to be any difference in stroke cases depending on type of residency.

mosaicplot(table(stroke$smoking_status, stroke$stroke))
# According to the plot, people who formerly smoked had more recorded cases of stroke compared to other groups.

### Data Visualization of numerical values ###

## Stroke by age (Boxplot) ##

ggplot(data = stroke, aes(x = stroke, y = age, fill = stroke)) +
  geom_boxplot() +
  labs(title = 'Stroke by age') +
  scale_fill_manual(values = c("skyblue", "salmon"))

# As previously stated in age analysis this boxplot shows that people in the 60/80 years old group, with few 
# exceptions (outliers), are the ones that suffered stroke.

## Stroke by bmi (Scatterplot) ##

ggplot(data = stroke, aes(x = stroke, y = bmi, color = stroke)) +
  geom_point(position = "jitter", alpha = 0.7) +  
  labs(title = 'Scatterplot of stroke by bmi', x = 'stroke', y = 'bmi') +
  scale_color_manual(values = c("royalblue", "maroon"))

# Based on the chart we can assume that bmi alone doesn't seem to have any correlation to suffering stroke.

## Stroke/ avg_glucose_level correlation (Histogram) ##

ggplot(data = stroke, aes(x = avg_glucose_level , fill = stroke)) +
  geom_histogram(position = "identity", alpha = 0.7, bins = 30) +
  labs(title = 'Histogram of Stroke and average glucose level comparison', x = 'avg_glucose_level', y = 'Frequency') +
  scale_fill_manual(values = c("lightgreen", "orange"))

# Just like with bmi, according to the data presented we can see that average glucose level doesn't correlate with stroke.  

## Bmi/Age stroke cases ##

ggplot(data = stroke, aes(x= age, y = bmi, color = stroke))+
  geom_point(shape = stroke$stroke)+
  labs(title = 'Bmi/Age stroke correlation')

# As we can see, stroke patients are more likely to appear among people above 50 years old. However as mentioned before 
# bmi doesn't seem to correlate with age when it comes to suffering stroke.

### Data Visualization of multiple factors ###

## Age/Gender/Stroke correlation ##

ggplot(stroke, aes(x = age, fill = gender, color = stroke)) +
  geom_histogram(binwidth = 5, position = "identity", alpha = 0.7) +
  facet_grid(. ~ stroke) +
  labs(title = 'Age Distribution by Gender and Stroke Status', x = 'Age', y = 'Frequency') +
  scale_fill_manual(values = c("lightgreen", "orange")) +
  scale_color_manual(values = c("blue", "red"))

# Based on the chart we can see that men are more prone to suffering stroke rather than women, especially those who are 50+ years old.

## Work Type/Hypertension/Stroke ##

ggplot(stroke, aes(x = work_type, fill = hypertension, color = stroke)) +
  geom_bar(position = "stack", alpha = 0.7) +
  labs(title = 'Work Type Distribution by Hypertension and Stroke', x = 'Work Type', y = 'Count') +
  scale_fill_manual(values = c("lightblue", "darkblue")) +
  scale_color_manual(values = c("red", "black"))

# According to the chart work type combined with hypertension seems to have big impact on probability of having stroke.
# Those working government jobs, self-employed and private and additionally suffering from hypertension have more cases of stroke.


## Age/Smoking/Stroke ##

ggplot(stroke, aes(x = smoking_status, y = age, fill = stroke)) +
  geom_boxplot(position = "dodge", alpha = 0.7) +
  labs(title = 'Age Distribution by Smoking Status and Stroke', x = 'Smoking Status', y = 'Age') +
  scale_fill_manual(values = c("lightgreen", "orange"))

# Based on this chart smoking doesn't seem to be a factor in suffering stroke, however we can notice again that the 
# age seems to be one of the main factors that have to be examined more closely.

## Age/Work Type/Stroke ##

ggplot(stroke, aes(x = work_type, y = age, fill = stroke)) +
  geom_boxplot(position = "dodge", alpha = 0.7) +
  labs(title = 'Age Distribution by Work Type and Stroke', x = 'Work type', y = 'Age') +
  scale_fill_manual(values = c("navy", "indianred"))

# This boxplot shows more clearly the correlation between age and working status when it comes to suffering stroke.


## Work type/Hypertension/Martial Status/Stroke ##

ggplot(stroke, aes(x = work_type, fill = interaction(hypertension, ever_married), color = stroke)) +
  geom_bar(position = "dodge", alpha = 0.7, stat = "count") +
  labs(title = 'Work Type by Hypertension, Martial Status, and Stroke',
       x = 'Work Type', y = 'Count') +
  scale_fill_manual(values = c("lightblue", "darkblue", "lightpink", "darkred"),
                    name = "Hypertension and Marital Status") +
  scale_color_manual(values = c("black", "red"), name = "Stroke") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Based on this chart we can see that as stated before hypertension, work type and martial status are main factors.

#### Logistic Regression ####

### Heatmap - correlation of risk factors ###

# Checking for missing values
if (any(is.na(stroke))) {
  cat("Warning: There are missing values in the data. Please handle them before creating the heatmap.\n")
}

# Checking for infinite values
if (any(sapply(stroke, function(x) any(is.infinite(x))))) {
  cat("Warning: There are infinite values in the data. Please handle them before creating the heatmap.\n")
}

# Convert all columns to numeric
stroke <- as.data.frame(sapply(stroke, as.numeric))

# Calculate correlation
stroke.cor <- round(cor(stroke), 2)

# Create heatmap using corrplot

corrplot(stroke.cor, method = "color", type = "upper", addCoef.col = "black")

## Heatmap conclusion ##

# Upon examination of the heatmap, it is discernible that a substantial proportion of features exhibits a lack 
# of noteworthy correlation with one another, rendering them conducive to regression analysis. Noteworthy 
# correlation is primarily confined to the relationship between age and ever_married, albeit the underlying 
# rationale for this association is straightforward. Among the array of features, age manifests the most 
# elevated correlation coefficients, particularly in relation to the occurrence of stroke.


### Creating a Logistic Regression Model ###

str(stroke)

# splitting data into training and testing sets before training the model

install.packages("caTools")
library(caTools)
set.seed(123)
split <- sample.split(stroke$stroke, SplitRatio = 0.7)
train_data <- subset(stroke, split == TRUE)
test_data <- subset(stroke, split == FALSE)

# Training the logistic regression model

# Checking unique values in the 'stroke' variable in train_data
unique(train_data$stroke)

# Converting variable to 0 and 1
train_data$stroke <- as.factor(ifelse(train_data$stroke == "1", 1, 0))

# Training the logistic regression model
model <- glm(stroke ~ ., data = train_data, family = "binomial")

summary(model)

# The logistic regression model was fitted to predict the occurrence of stroke based on various predictor variables:

# Significant Predictors:

# Age is a highly significant predictor (p < 2e-16), with a negative coefficient of -0.074484, suggesting a decrease in the log-odds of stroke as age increases.
# Hypertension is a significant predictor (p = 0.02509), with a negative coefficient of -0.436022, indicating a decrease in the log-odds of stroke for individuals with hypertension.
# Average glucose level is a significant predictor (p = 0.00479), with a negative coefficient of -0.004018, implying a decrease in the log-odds of stroke for higher average glucose levels.

# Non-Significant Predictors:

# Gender, heart disease, ever_married, work_type, residence_type, BMI, and smoking_status are not found to be significant predictors of stroke based on their p-values.

# Model Fit:

# The model's null deviance is 1391.4, and the residual deviance is 1093.6. A lower residual deviance suggests a better fit of the model to the data.
# The AIC is 1115.6, providing a measure of the model's goodness of fit while penalizing for the number of parameters.

# Additional information:

# The intercept is significantly different from zero, indicating the presence of stroke cases even when other predictors are zero.
# The number of Fisher Scoring iterations during model estimation is 7.

# Overall, the logistic regression model suggests that age, hypertension, and average glucose level are important predictors 
# in determining the likelihood of stroke in the dataset.
# It provides insights into the relationships between these factors and the occurrence of stroke.

## The deviance of the regression model ( Anova ) ## 

anova(model, test="Chisq")

# In summary, age, hypertension, and avg_glucose_level are significant predictors of stroke in this model, while gender,
# heart_disease, ever_married, work_type, residence_type, bmi, and smoking_status do not significantly contribute to explaining
# the variation in the response variable.

# Obtaining predicted probabilities
predicted_probabilities <- predict(model, newdata = test_data, type = "response")

## Confusion Matrix ##
conf_matrix <- table(true_labels = test_data$stroke, predicted_labels = ifelse(predicted_probabilities > 0.5, 1, 0))

# Display Confusion Matrix
conf_matrix

#Based on the provided confusion matrix:
  
# True Positive (TP): 1458
# True Negative (TN): 0
# False Positive (FP): 0
# False Negative (FN): 75

# This means that the model correctly predicted 1458 instances of stroke (True Positives), and it incorrectly predicted 
# 75 instances as non-stroke that were actually strokes (False Negatives). There are no instances predicted as strokes that
# are actually non-strokes (False Positives), and no instances correctly predicted as non-strokes (True Negatives). 
# The model seems to have good sensitivity but may need further tuning for specificity.

## Creating ROC curve ##
install.packages("pROC")
library(pROC)

roc_curve <- roc(test_data$stroke, predicted_probabilities)

# Plotting the ROC curve
plot(roc_curve, col = "blue", main = "ROC Curve", col.main = "darkblue", lwd = 2)

# Add labels and legend
abline(a = 0, b = 1, lty = 2, col = "red")  # Diagonal line for reference
legend("bottomright", legend = paste("AUC =", round(auc(roc_curve), 2)), col = "blue", lwd = 2)

# The ROC analysis for the logistic regression model yielded an Area Under the Curve (AUC) of 0.82.
# This AUC value signifies excellent discriminatory power, indicating the model's strong ability to distinguish between 
# positive and negative cases.
# Overall, with an AUC of 0.82, the logistic regression model demonstrates high accuracy in making predictions for 
# the binary classification task in the dataset.

#### Summary ####

# Conclusion and Recommendations

## Data Transformation and Cleaning:

# The dataset underwent necessary transformations, including unifying column names, removing unnecessary ID columns, and converting data types to facilitate analysis.

# Missing values in the BMI column were handled by replacing them with the median BMI value, ensuring data completeness.

## Data Analysis:

# Statistical summaries and visualizations were conducted on numerical variables such as age, average glucose level, and BMI.

# Age emerged as a crucial factor, with a wide range of values. The distribution was relatively symmetric, with a notable concentration of stroke cases in the 60-80 age group.

# Average glucose level and BMI were also explored, revealing potential outliers and the need for further investigation.

# Mosaic plots and correlation analyses were performed to identify potential correlations between various factors and the occurrence of strokes.

## Logistic Regression:

# A logistic regression model was trained to predict the likelihood of stroke based on several predictor variables.

# Significant predictors included age, hypertension, and average glucose level, while gender, heart disease, marital status, work type, residence type, BMI, and smoking status did not significantly contribute to the model.

# The model demonstrated good fit, with the ROC analysis yielding an Area Under the Curve (AUC) of 0.82, indicating excellent discriminatory power.

## Recommendations:

# Age Awareness:

# - Pay close attention to older individuals, as age emerged as a decisive factor in the risk of stroke. Regular health check-ups and targeted interventions for this demographic could be beneficial.

# Hypertension Management:

# - Given that hypertension was a significant predictor, serious attention to hypertension management is crucial. Regular monitoring and appropriate medical interventions for individuals with hypertension may help mitigate the risk of stroke.

# Occupational Considerations:

# - Individuals in self-employed roles were found to have a reduced risk of stroke. Exploring the lifestyle and occupational factors associated with self-employment could provide insights into mitigating stroke risk.

# Further Investigation:

# - Explore anomalies and outliers in variables such as average glucose level and BMI, as they may have clinical implications and could be further investigated to enhance stroke prediction accuracy.

# Model Refinement:

# - While the logistic regression model demonstrated good overall performance, continued refinement and exploration of additional features or machine learning algorithms could enhance predictive accuracy, especially in addressing the imbalances in the dataset.

# In conclusion, this analysis provides valuable insights into factors influencing stroke occurrence. Implementing the recommendations could contribute to proactive health management and the development of more accurate stroke prediction models.


