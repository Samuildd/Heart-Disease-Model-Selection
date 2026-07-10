# Heart Disease Risk Prediction

[Link to Project](https://samuildd.github.io/Heart-Disease-Model-Selection/Output/heart_disease_prediction.html)

A logistic regression workflow for predicting the presence of heart disease from clinical measurements that cover model diagnostics, automated model selection, cross-validated performance comparison, and ROC analysis.

## Data

The data consists of attributes gathered for patients. The variables used are:
- num diagnosis of heart disease where 0=absent 1=present (response).
- age: age of patient.
- sex: 0=female 1=male.
- cp: chest pain type where 1=typical angina, 2=atypical angina, 3=non-anginal pain, 4=asymptomatic,
- trestbps: resting blood pressure in mm Hg.
- chol: serum cholesterol in mg/dl,
- fbs: fasting blood sugar 0=under 120 mg/dl, 1=over 120 mg/dl,
- restecg: resting electrocardiographic results, 0=normal, 1=having wave abnormality, 2=showing left ventricular hypertrophy
- thalach: maximum heart rate achieved
- exang: exercise induced angina 0=no 1=yes
- oldpeak: depression induced by exercise relative to rest

The data is a cleaned subset (missing values removed, restricted to the variables listed) of a heart disease dataset originally sourced from [Kaggle](https://www.kaggle.com/imnikhilanand/heart-attack-prediction).

## Overview

Given a set of clinical attributes for 261 patients (age, sex, chest pain type, resting blood pressure, cholesterol, fasting blood sugar, resting ECG results, maximum heart rate, exercise-induced angina, and ST depression), the goal is to build a model that predicts whether heart disease is present, and to evaluate how well that model generalizes to new patients.

The workflow follows a path:

1. **Fit** a full logistic regression model on all available predictors and
   check the diagnostic plots for problems (leverage, influence, residual
   patterns).
2. **Search** the model space with `dredge()` (from the `MuMIn` package) to
   generate a shortlist of strong candidate models ranked by AICc.
3. **Compare** the top three candidates using 10-fold cross-validation
   (50 repeats), scoring each on out-of-sample AUC rather than in-sample fit.
4. **Select** a final model and characterize its predictive performance with
   an ROC curve, including the threshold that maximizes sensitivity +
   specificity.

## Key results

- The three AICc-competitive models had statistically indistinguishable cross-validated AUC (0.891–0.894), so the choice between them came down to parsimony rather than predictive edge. The top-ranked AICc model (`num ~ chol + cp + exang + fbs + oldpeak + sex`) was selected.
- The final model reaches an in-sample AUC of **0.916**.
- Chest pain type, exercise-induced angina, fasting blood sugar, ST depression (`oldpeak`), and sex are the strongest predictors; resting blood pressure, resting ECG, and age contributed little once these were accounted for.
- A predicted-probability threshold of **c ≈ 0.28** maximizes sensitivity + specificity, giving sensitivity ≈ 0.90 and specificity ≈ 0.78 at that point
— a reasonable operating point for a screening context where missing a true case is more costly than a false alarm, though the right threshold ultimately depends on the clinical use case.

## Method notes

- All candidate predictors were entered as their natural type (factors for categorical variables like chest pain type and sex, continuous for age, cholesterol, etc.).
- Model selection used `MuMIn::dredge()` on the full model with `na.action = "na.fail"`, ranking by AICc.
- Predictive comparison used repeated k-fold cross-validation (`crossval()` from the `bootstrap` package: K = 10 folds, B = 50 repeats) rather than relying on AICc alone, since AICc is an in-sample criterion and can favor models that don't generalize as well.
- ROC/AUC computed with the `pROC` package.

