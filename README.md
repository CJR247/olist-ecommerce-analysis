# 📊 Olist E-commerce Analysis

An end-to-end Business Intelligence project that demonstrates the complete analytics workflow—from raw CSV data ingestion to interactive Power BI dashboards using **Python, PostgreSQL, SQL, and Power BI**.

---

## 🚀 Project Overview

This project analyzes the Brazilian Olist E-commerce dataset to provide insights into sales performance, customer behavior, seller performance, payment trends, and customer reviews.

The project follows a complete data analytics pipeline:

- Data Cleaning & Transformation using Python
- Data Modeling & SQL Transformations in PostgreSQL
- Dimensional Modeling (Star Schema)
- Interactive Dashboard Development in Power BI
- Business KPI Reporting using DAX

---

## 🛠️ Tech Stack

- **Python** (Pandas)
- **PostgreSQL**
- **SQL**
- **Power BI**
- **DAX**

---

## 📂 Project Workflow

### 1. Data Preparation (Python)

- Loaded raw CSV datasets
- Performed data exploration
- Fixed data types
- Handled missing values
- Created installment buckets
- Cleaned and prepared datasets
- Loaded transformed data into PostgreSQL

---

### 2. Data Modeling (PostgreSQL)

Created analytical views to support reporting.

**Dimensions**

- Customer
- Product
- Seller
- Date
- Time

**Facts**

- Sales
- Payments
- Reviews

Performed SQL transformations including:

- Data aggregation
- Ranking
- Grain fixing
- Business calculations
- Reporting views for Power BI

---

### 3. Power BI

Imported SQL views from PostgreSQL and created a Star Schema consisting of:

- 5 Dimension tables
- 3 Fact tables

Additional transformations included:

- Derived columns
- Relationships
- Data modeling
- DAX calculations

---

## 📈 Executive Dashboard

Key business KPIs:

- Total Revenue
- Total Orders
- Revenue MTD vs Previous Month MTD
- On-Time Delivery %
- Revenue Trend
- Sales by Product Category
- Payment Method Distribution
- Sales by Region (Map)
- Average Seller Rating

---

## 👥 Customer Dashboard

Customer analytics including:

- Customer Segmentation
  - Single
  - Repeat
  - Loyal
  - VIP
- Revenue by Customer Type
- New Customers by Month & Year
- Orders by Day of Week
- Orders by Time of Day
- Top 10 Customers by Revenue

---

## ⭐ Review Dashboard

Customer review insights:

- Total Reviews
- Average Rating
- Average Reply Time
- Positive / Neutral / Negative Review Trends
- Rating Distribution
- Review Type Analysis
- Top Rated Sellers

---

## 🏗️ Data Model

<img width="654" height="335" alt="image" src="https://github.com/user-attachments/assets/c1970ad4-9214-4e01-b67f-f47a873b91b3" />


---

## 📊 Dashboard Preview

### Executive Dashboard

<img width="573" height="321" alt="image" src="https://github.com/user-attachments/assets/b7c02c6a-0303-417f-bf2a-a8466206bd62" />


### Customer Dashboard

<img width="574" height="323" alt="image" src="https://github.com/user-attachments/assets/01e159ac-9d6a-459a-83fb-d16b2cbb90f4" />


### Review Dashboard

<img width="572" height="319" alt="image" src="https://github.com/user-attachments/assets/96019f2e-e744-421e-96bf-0f8e0af68202" />


---

## 📁 Repository Structure

```text
olist-ecommerce
│
├── files/
│   └── Raw CSV datasets
│
├── Scripts/
│   └── SQL scripts for dimensions, facts and analysis
│
├── data_cleaning.ipynb
├── olist_dimensional_modeling.pbix
├── requirements.txt
└── README.md
```

---

## 📌 Key Skills Demonstrated

- Data Cleaning
- Data Transformation
- PostgreSQL
- SQL
- Data Warehousing
- Dimensional Modeling
- Star Schema
- ETL
- DAX
- Power BI
- Business Intelligence
- Data Visualization

---

## 📬 Contact

If you have any feedback or would like to connect, feel free to reach out through LinkedIn.
