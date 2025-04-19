
# Agent Performance Clustering and Segmentation

## Overview

This project uses K-Means clustering to analyze and segment insurance agents based on their performance metrics. By identifying distinct clusters, we aim to better understand agent behavior, identify top-performing segments, and inform targeted management strategies.

## Project Objectives

- Perform exploratory data analysis (EDA) to understand the distribution of key metrics.
- Clean and preprocess data to handle missing values and anomalies.
- Utilize K-Means clustering to segment agents based on performance and business metrics.
- Analyze cluster characteristics to draw meaningful insights for strategic decisions.

## Data

The dataset includes the following key metrics for insurance agents:

- **LOSS_RATIO**: Current loss ratio.
- **LOSS_RATIO_3YR**: Three-year average loss ratio.
- **RETENTION_RATIO**: Customer retention rate.
- **GROWTH_RATE_3YR**: Three-year average growth rate.
- Additional metrics on revenue, agency size, and customer interactions.

Data preprocessing included:

- Handling missing and anomalous values (e.g., replacing placeholder values with NaN).
- Filtering unrealistic metric values to improve model reliability.

## Methodology

### Data Preprocessing

- Analyzed missing data patterns.
- Replaced placeholder values (e.g., 99995-99998) with NaN.
- Filtered records based on realistic business thresholds (e.g., loss ratios between 0 and 10).

### Exploratory Data Analysis (EDA)

- Generated descriptive statistics, histograms, and boxplots to visualize data distributions.
- Identified outliers and data inconsistencies for correction.

### Feature Engineering and Selection

- Selected key metrics based on business relevance and statistical analysis.
- Ensured that selected features provided meaningful differentiation among agents.

### K-Means Clustering

- Determined optimal cluster number using the Elbow method.
- Trained a K-Means clustering model to segment agents into performance-based groups.

### Model Evaluation

- Evaluated clustering effectiveness using within-cluster sum of squares (WCSS) and silhouette analysis.

## Results

The analysis revealed distinct clusters of agents:

- **High-performing agents**: Demonstrated low loss ratios, high retention, and strong growth.
- **Underperforming agents**: Exhibited higher loss ratios, lower retention, and stagnant or negative growth.
- **Average-performing agents**: Fell within moderate ranges on performance metrics.

## Business Insights

- Clearly defined segments enable targeted interventions, such as performance incentives, training programs, and resource allocation.
- Identification of top performers helps management replicate successful behaviors across the agency network.

## Conclusion and Next Steps

### Conclusion

This project successfully identified meaningful segments of insurance agents, facilitating data-driven management decisions. Clustering proved effective in highlighting variations in agent performance and potential opportunities for strategic improvement.

### Next Steps

- Integrate clustering results into performance dashboards.
- Periodically re-run clustering analysis to capture changes in agent performance dynamics.
- Experiment with alternative clustering methods (e.g., hierarchical clustering, DBSCAN) to compare results.

## Technologies Used

- Python
- Pandas, NumPy
- Scikit-learn
- Matplotlib, Seaborn
- Jupyter Notebook

## Author

- **[Your Name]** – Data Analyst

