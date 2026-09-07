# NusaMart Retail Sales & Profitability Analytics

> End-to-end retail sales and profitability analysis using Microsoft Excel and SQL to identify performance trends, profitability pressure, and key business opportunities.

---

## 📌 Project Overview

NusaMart is a fictional Indonesian omnichannel retail company operating through **Online** and **Physical Store** channels.

This project analyzes NusaMart's sales performance and profitability during **January 2024 – December 2025** to understand why revenue and profit remained relatively flat and to identify the main areas of profitability pressure.

The analysis is designed from a **Data Analyst perspective**, covering data profiling, data cleaning, data validation, exploratory analysis, business analysis, dashboard reporting, and business recommendations.

---

## 🎯 Business Problem

NusaMart's revenue and profit remained relatively stable from 2024 to 2025, with both metrics showing a slight decline.

The main business question is:

> **Why did NusaMart's revenue and profit remain relatively flat from 2024 to 2025, and what factors explain the stability or pressure in profitability?**

The analysis focuses on identifying profitability patterns across:

- Product categories
- Customer segments
- Sales channels
- Regions
- Discount levels
- Category × Customer Segment combinations

---

## 🎯 Project Objectives

This project aims to:

1. Assess NusaMart's overall sales and profitability performance.
2. Compare revenue and profit performance between 2024 and 2025.
3. Identify product categories with profitability pressure.
4. Evaluate profitability across customer segments and sales channels.
5. Analyze regional performance.
6. Examine the relationship between discount levels and profitability.
7. Identify specific business areas requiring deeper investigation.
8. Translate analytical findings into actionable business recommendations.

---

## 📊 Key Performance Indicators

| KPI | Result |
|---|---:|
| Total Revenue | Rp262.71B |
| Total Profit | Rp24.78B |
| Profit Margin | 9.43% |
| Completed Orders | 37,521 |
| Quantity Sold | 140,321 |
| Active Customers | 4,699 |
| Average Order Value | Rp7.00M |

> **KPI Rule:** Core revenue and profitability metrics are calculated using **Completed orders only**.

---

## 📈 2024 vs 2025 Performance

| Metric | 2024 | 2025 | Growth |
|---|---:|---:|---:|
| Revenue | Rp131.71B | Rp131.00B | -0.54% |
| Profit | Rp12.44B | Rp12.33B | -0.86% |
| Profit Margin | ~9.44% | ~9.42% | — |

The results indicate that **profit declined slightly faster than revenue**, suggesting pressure on overall profitability despite relatively stable sales.

---

## 🔄 Analysis Workflow

The project follows an end-to-end analytical workflow:

```text
Raw Data
    ↓
Data Profiling
    ↓
Data Cleaning
    ↓
Data Validation
    ↓
Business Analysis
    ↓
Dashboard & Business Insights
    ↓
Business Recommendations
```

---

## 🧹 Data Cleaning & Validation

Several data quality issues were identified and handled during the cleaning process.

### Customers

**Issues identified:**

- Duplicate customer records
- Missing city values
- Incorrect customer segment label (`Consumerr`)

**Cleaning actions:**

- Removed duplicate `customer_id`
- Retained the record with the latest registration date
- Standardized `Consumerr` → `Consumer`
- Replaced missing city values with `Unknown`

### Products

**Validation included:**

- Duplicate `product_id`
- Missing product attributes
- Numeric price format
- Price logic validation

### Stores

**Validation included:**

- Duplicate `store_id`
- Missing store attributes
- Channel distribution
- Region distribution
- Store type distribution

### Orders

**Issues identified:**

- Missing payment methods

**Cleaning actions:**

- Converted `order_date` from text to `DATE`
- Replaced missing payment methods with `Unknown`
- Validated customer and store foreign keys

### Order Details

**Issues identified:**

- Duplicate `order_detail_id`
- Raw numeric fields stored as text

**Cleaning actions:**

- Removed duplicate order detail records
- Converted numeric fields into appropriate numeric data types
- Preserved discount precision
- Validated quantity and discount ranges
- Validated order and product foreign keys
- Validated revenue, cost, and profit calculations

---

## 🗂️ Dataset Structure

The project uses five related datasets:

```text
customers
     │
     │ 1 : N
     ▼
orders ───────────── stores
  │
  │ 1 : N
  ▼
order_details
  │
  │ N : 1
  ▼
products
```

### Customers

| Column | Description |
|---|---|
| `customer_id` | Unique customer identifier |
| `customer_name` | Customer name |
| `gender` | Customer gender |
| `age` | Customer age |
| `customer_segment` | Consumer, Small Business, or Corporate |
| `city` | Customer city |
| `region` | Customer region |
| `registration_date` | Customer registration date |

### Products

| Column | Description |
|---|---|
| `product_id` | Unique product identifier |
| `product_name` | Product name |
| `category` | Product category |
| `subcategory` | Product subcategory |
| `brand` | Product brand |
| `unit_cost` | Product unit cost |
| `list_price` | Product list price |

### Stores

| Column | Description |
|---|---|
| `store_id` | Unique store identifier |
| `store_name` | Store name |
| `channel` | Online or Physical Store |
| `city` | Store city |
| `region` | Store region |
| `store_type` | Store type |

### Orders

| Column | Description |
|---|---|
| `order_id` | Unique order identifier |
| `order_date` | Order date |
| `customer_id` | Customer reference |
| `store_id` | Store reference |
| `payment_method` | Payment method |
| `order_status` | Order status |

### Order Details

| Column | Description |
|---|---|
| `order_detail_id` | Unique order detail identifier |
| `order_id` | Order reference |
| `product_id` | Product reference |
| `quantity` | Quantity sold |
| `unit_price` | Transaction unit price |
| `discount_pct` | Discount percentage |
| `sales_amount` | Recorded sales amount |
| `unit_cost` | Unit cost |
| `cost_amount` | Recorded cost amount |
| `profit_amount` | Recorded profit amount |

---

## 📐 Business Calculations

Revenue is calculated as:

```text
Revenue = Quantity × Unit Price × (1 − Discount %)
```

Cost:

```text
Cost = Quantity × Unit Cost
```

Profit:

```text
Profit = Revenue − Cost
```

Profit Margin:

```text
Profit Margin = Profit / Revenue
```

Average Order Value:

```text
AOV = Revenue / Completed Orders
```

---

# 📈 Key Business Findings

## 1. Revenue and Profit Declined Slightly in 2025

Compared with 2024:

- Revenue decreased by **0.54%**
- Profit decreased by **0.86%**

Profit declined slightly faster than revenue, indicating pressure on overall profitability.

---

## 2. Electronics Has the Highest Revenue but the Lowest Margin

Electronics generated approximately:

- **Rp150.44B revenue**
- **Rp2.31B profit**
- **1.54% profit margin**

This makes Electronics the largest revenue contributor but also the category with the weakest profitability.

> **Business implication:** High sales volume does not necessarily translate into strong profitability.

---

## 3. Corporate Customers Have the Lowest Profit Margin

Customer segment profitability shows:

| Customer Segment | Revenue | Profit Margin |
|---|---:|---:|
| Consumer | Rp114.67B | 13.28% |
| Small Business | Rp72.85B | 8.79% |
| Corporate | Rp75.19B | 4.18% |

Corporate customers generate meaningful revenue but operate at the lowest margin among the three segments.

---

## 4. Online Channel Has Lower Profitability

| Channel | Revenue | Profit Margin |
|---|---:|---:|
| Online | Rp143.92B | 8.84% |
| Physical Store | Rp118.78B | 10.14% |

Online contributes more revenue, but its profit margin is lower than the Physical Store channel.

> **Business implication:** Revenue scale and profitability are not necessarily aligned across channels.

---

## 5. Higher Discount Levels Are Associated with Lower Profitability

The discount analysis shows progressively weaker profitability at higher discount levels.

Most notably:

> **Discount levels of 20% or more generated negative profit in the analyzed transactions.**

This indicates that higher discount bands should be reviewed carefully when evaluating promotional strategies.

> **Analytical note:** This finding represents an observed association, not causation. The observational transaction data does not by itself prove that higher discounts caused negative profit.

---

# 🔎 Deep Dive

The analysis further investigates the combination:

> **Electronics × Corporate**

This combination brings together:

- The product category with the lowest overall margin
- The customer segment with the lowest overall margin

The deeper analysis indicates that profitability risk is particularly concentrated in:

- **Jakarta**
- **Higher discount bands**

This makes **Electronics × Corporate** a priority area for commercial review.

---

# 💡 Business Recommendations

## 1. Review Electronics Pricing and Cost Structure

Investigate:

- Product mix
- Supplier costs
- Pricing strategy
- Product-level margins
- Promotional activity

The objective is to identify why the category generates high revenue but relatively low profit.

---

## 2. Review Corporate Discount Strategy

Evaluate whether discounts provided to Corporate customers generate sufficient commercial value relative to the profitability they produce.

---

## 3. Introduce Profitability Guardrails for High Discounts

Consider introducing profitability thresholds or approval rules for discounts of **20% or more**, particularly for products or customer segments with already-low margins.

---

## 4. Prioritize Electronics × Corporate Monitoring

Closely monitor Electronics × Corporate transactions, particularly:

- Jakarta
- Higher discount bands

This segment should be prioritized for further commercial investigation.

---

# 🛠️ Tools & Technologies

| Tool | Usage |
|---|---|
| **Microsoft Excel** | Data cleaning, Pivot Tables, analysis, and dashboard |
| **MySQL** | Database management and analytical queries |
| **HeidiSQL** | SQL development and database management |
| **SQL** | Data profiling, cleaning, validation, aggregation, and business analysis |

---

# 🗃️ SQL Analysis

The SQL workflow covers:

```text
Database Setup
      ↓
Create Clean Tables
      ↓
Create Raw / Staging Tables
      ↓
Data Profiling
      ↓
Data Cleaning
      ↓
Data Validation
      ↓
Business Analysis
```

Business analysis includes:

- Overall KPI
- Yearly Performance
- Growth Analysis
- Monthly Trend
- Category Analysis
- Customer Segment Analysis
- Channel Analysis
- Region Analysis
- Discount Analysis
- Category × Customer Segment Deep Dive
- Electronics × Corporate Deep Dive
- Executive Summary

The complete SQL workflow is available in:

`sql/Query_NusaMart_Analysis.sql`

---

# 📊 Excel Dashboard

The Excel dashboard summarizes the key performance indicators and business findings through:

- KPI cards
- Monthly revenue trend
- Profit margin trend
- Profit by category
- Profit by customer segment
- Profit by channel
- Profitability by discount level
- Key business findings
- Priority business issue

> Dashboard preview will be added to the repository.

---

# 📁 Repository Structure

```text
NusaMart-Retail-Analytics/
│
├── README.md
│
├── sql/
│   └── Query_NusaMart_Analysis.sql
│
├── excel/
│   └── NusaMart_Retail_Analysis.xlsx
│
├── data/
│   ├── customers.csv
│   ├── products.csv
│   ├── stores.csv
│   ├── orders.csv
│   └── order_details.csv
│
└── images/
    └── dashboard_preview.png
```

> The Excel, Python, and dashboard files will be added as the project progresses.

---

# ⚠️ Analytical Notes

- Core revenue and profitability KPIs use **Completed orders only**.
- Cancelled and returned orders are excluded from core KPI calculations.
- Profitability is calculated using transaction-level quantity, unit price, discount, and unit cost.
- Higher discount levels are interpreted as being **associated with** lower profitability, not as proof of causation.
- Business recommendations are based on observed patterns in the available transaction data.

---

# 🎓 Project Purpose

This project was developed as a portfolio case study to demonstrate practical Data Analyst skills in:

- Data cleaning
- Data validation
- SQL
- Microsoft Excel
- Data modeling
- KPI development
- Exploratory analysis
- Profitability analysis
- Business segmentation
- Business insight generation
- Data-driven recommendations
- Stakeholder-oriented reporting

---
