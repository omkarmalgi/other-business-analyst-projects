
# Amazon Brazil Market Analysis

**Created by:** Omkar Malgi  
**Project:** Business Analyst Portfolio Project  
**Tools:** PostgreSQL, Excel

## Project Overview

This project analyses Brazilian e-commerce transaction data to understand customer purchasing behaviour, payment preferences, product pricing, revenue performance, seasonal sales patterns and customer segmentation.

The findings are interpreted from a business analysis perspective to identify strategic opportunities relevant to Amazon India's market context.

## Project Objectives

- Analyse payment preferences and transaction values.
- Understand product pricing and category-level revenue.
- Identify seasonal sales trends.
- Analyse customer purchasing frequency.
- Segment customers based on order history.
- Identify high-value customers.
- Evaluate product data quality.
- Analyse monthly and cumulative sales growth.

## Dataset & Source

The analysis uses the **Brazilian E-Commerce Public Dataset by Olist**, published on Kaggle.

The dataset contains approximately 100,000 orders from Brazilian marketplaces between 2016 and 2018.

**Original dataset:**  
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

**Dataset licence:** CC BY-NC-SA 4.0.

Important: This is Olist Brazilian marketplace data, not Amazon's internal company data. Amazon India is the strategic business context used in the report.

The original CSV files are not included in this repository. They can be obtained from the original dataset source above.

## Tables Used

The PostgreSQL schema contains six tables:

- Customer Data
- Orders
- Order Items
- Payments
- Products
- Sellers

## SQL Techniques Demonstrated

- Aggregate functions: SUM, AVG, COUNT, MIN, MAX and STDDEV
- INNER JOIN
- GROUP BY and HAVING
- CASE statements
- Subqueries
- Temporary tables
- Common Table Expressions (CTEs)
- Recursive CTEs
- Window functions
- RANK and LAG
- Date and time functions
- Filtering and sorting

## Key Business Findings

| Business Area | Finding |
|---|---|
| Payment preferences | Credit cards account for 73.9% of payment transactions |
| Seasonal sales | Spring generated approximately BRL 4.22 million |
| Customer behaviour | 3,140 customers placed multiple orders |
| Customer segmentation | 98,144 customers fall into the Occasional segment |
| Product data quality | 614 records have missing or incomplete category information |
| Category revenue | Beauty & Health generated approximately BRL 1.26 million |

## Business Recommendations

1. Strengthen the credit-card checkout experience.
2. Align promotional and inventory planning with seasonal demand.
3. Improve product category data quality.
4. Develop customer retention and loyalty initiatives.
5. Identify high-value customers for targeted rewards.
6. Focus on high-performing product categories.
7. Monitor monthly payment-method sales trends.

## Project Deliverables

**1. Complete Strategic Analysis Report**

[View Amazon Brazil Market Analysis Report](Amazon_Brazil_Market_Analysis_Report_By_Omkar_Malgi.pdf)

**2. PostgreSQL SQL Script**

[View SQL Analysis Script](Amazon_brazil.sql)

## Skills Demonstrated

- PostgreSQL
- SQL Query Writing
- Relational Data Analysis
- Data Aggregation
- Joins and Subqueries
- CTEs and Window Functions
- Customer Segmentation
- Revenue and Payment Analysis
- Business Insights and Recommendations

## Project Disclaimer

This is an independent portfolio case study based on the publicly available Olist Brazilian E-Commerce dataset. The report uses Amazon India as a strategic case-study context. The findings are analytical observations from the Olist dataset and must not be interpreted as actual Amazon business performance.
