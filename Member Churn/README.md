# Churn and Push Risk Prediction

This project builds predictive models to identify members at risk of **churning** or being **pushed** (i.e., proactively disengaged) from an organization. The models aim to help retention and engagement teams intervene early and strategically, using data-driven insights. **It is based on simulated membership data from an organization that offers products to healthcare researchers.**

## Objectives

- Predict whether a member is likely to **churn** (disengage).
- Predict whether a member will be **pushed** due to inactivity or other criteria.
- Enable data-driven **member retention** and **targeted re-engagement** strategies.
- Generate actionable **feature importance** insights for operational teams.

## Models

- **XGBoost Classifier** for both `CHURNED` and `PUSHED` outcomes
- Bayesian Optimization and testing with **Optuna**
- Hyperparameter tuning with **GridSearchCV**


## Features

- Demographic data (e.g., age, gender, income level)
- Membership data (e.g., member type, join date, status)
- Engagement history (e.g., days since last activity, event attendance)
- Donation behavior
- Communication opt-outs

## Evaluation Metrics

- **Precision / Recall / F1-Score**
- **ROC AUC**
- **SHAP values** for interpretability and feature importance

## Tech Stack

- Snowflake / SQL for initial EDA and data extraction
- Python (Pandas, Scikit-learn, XGBoost, Imbalanced-learn, SHAP)
- Google Colab / Jupyter Notebooks
- Visualizations with Matplotlib and Seaborn

## Key Findings

- Engagement metrics like `DAYS_SINCE_LAST_ACTIVITY` and `MEMBERSHIP_STATUS` are strong predictors of both churn and push likelihood.
- Donation history and opt-out flags significantly influence churn risk.
- SMOTE + XGBoost yielded the best balance of recall and precision for rare churn cases.

## Next Steps

- Deploy models into a real-time scoring API (e.g., via FastAPI or Azure ML endpoint).
- Integrate predictions into CRM tools for automated alerts.
- Run A/B tests on retention strategies informed by model outputs.
