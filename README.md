# Financial Data Analysis

## Project Overview

This project focuses on analyzing financial and operational data to evaluate business performance, profitability, branch-level results, expenses, and working capital.

The objective is to transform raw financial data into meaningful business insights using SQL, Python, Excel, and Power BI.

## Business Problem

The business requires a centralized financial analysis to understand its overall performance and identify areas requiring improvement.

Key challenges include:

- Monitoring revenue and operating expenses
- Evaluating branch-level financial performance
- Understanding profitability and cost structure
- Identifying outstanding accounts receivable and payable
- Analyzing working capital and cash flow
- Comparing financial performance across different periods

## Project Objectives

- Analyze overall financial performance
- Evaluate revenue and expense trends
- Compare financial performance across branches
- Identify major operating expense categories
- Monitor profitability and EBITDA
- Analyze accounts receivable and accounts payable
- Provide actionable insights through an interactive Power BI dashboard

## Dataset Overview

The project uses financial and operational datasets containing information about:

- Transactions
- Branches
- Departments
- Budgets
- Customers
- Vendors
- Invoices
- Payments
- Account Mapping
- Calendar

### Dataset Summary

| Metric | Value |
|---|---:|
| Total Transactions | 20,075 |
| Total Branches | 10 |
| Analysis Period | January 2025 – October 2026 |
| Revenue | ₹654.62 Million |
| Operating Expenses | ₹513.67 Million |
| EBITDA | ₹52.96 Million |
| Profit Before Tax | ₹7.85 Million |
| Accounts Receivable | ₹262.96 Million |
| Accounts Payable | ₹246.30 Million |

## Key Business Questions

1. How is the business performing financially?
2. What are the revenue trends over time?
3. Which branches are generating the highest revenue?
4. Which branches have the highest operating expenses?
5. What is the overall profitability of the business?
6. Which expense categories contribute most to operating costs?
7. What is the outstanding accounts receivable?
8. What is the outstanding accounts payable?
9. What are the key working capital challenges?
10. Which areas require management attention?

## Tools & Technologies

- **SQL (MySQL):** Data extraction, joins, aggregations, CTEs, and window functions
- **Python:** Data analysis using Pandas and NumPy
- **Power BI:** Interactive dashboards, KPI cards, and financial visualization
- **Excel:** Data validation, analysis, and supporting calculations

## Dashboard Preview

### 1. Finance Overview

[![Finance overview](PowerBI/Screenshots/Finance%20overview.png)](PowerBI/Screenshots/Finance%20overview.png)

[Open Finance overview screenshot](PowerBI/Screenshots/Finance%20overview.png)

### 2. Branch Performance

[![Branch Performance](PowerBI/Screenshots/Branch%20Performance.png)](PowerBI/Screenshots/Branch%20Performance.png)

[Open Branch Performance screenshot](PowerBI/Screenshots/Branch%20Performance.png)

### 3. Expenses & Profit

[![Expenses & Profit](PowerBI/Screenshots/Expenses%20%26%20Profit.png)](PowerBI/Screenshots/Expenses%20%26%20Profit.png)

[Open Expenses & Profit screenshot](PowerBI/Screenshots/Expenses%20%26%20Profit.png)

### 4. Working Capital

[![working capital](PowerBI/Screenshots/working%20capital.png)](PowerBI/Screenshots/working%20capital.png)

[Open working capital screenshot](PowerBI/Screenshots/working%20capital.png)

## Dashboard Pages

### Finance Overview

Provides a high-level view of financial performance, including:

- Revenue
- Operating Expenses
- EBITDA
- Profit Before Tax
- Revenue and profitability trends

### Branch Performance

Analyzes financial performance across branches, including:

- Branch-wise revenue
- Branch-wise expenses
- Branch profitability
- Performance comparison across locations

### Expenses & Profit

Focuses on cost structure and profitability, including:

- Operating expense analysis
- Expense category comparison
- EBITDA analysis
- Profitability trends

### Working Capital

Provides insights into working capital and financial obligations, including:

- Accounts Receivable
- Accounts Payable
- Outstanding invoices
- Payment analysis
- Working capital position

## Key Financial Insights

- Revenue was approximately ₹654.62 Million during the analysis period.
- Operating expenses were approximately ₹513.67 Million.
- EBITDA was approximately ₹52.96 Million.
- Profit Before Tax was approximately ₹7.85 Million.
- Accounts Receivable stood at approximately ₹262.96 Million.
- Accounts Payable stood at approximately ₹246.30 Million.

These metrics provide an overview of revenue generation, cost management, profitability, and working capital position.

## Project Files

- [Business Case Study](Documentation/Business_Case.pdf)
- [Python Analysis Notebook](Notebooks/Finance.ipynb)
- [Power BI Dashboard](PowerBI/Finance_BI.pbix)
- [SQL Analysis Queries](SQL/Financial_Analysis.sql)

## Repository Structure

```text
financial-data-analysis/
│
├── Dataset/
├── Documentation/
│   └── Business_Case.pdf
├── Notebooks/
│   └── Finance.ipynb
├── PowerBI/
│   ├── Finance_BI.pbix
│   └── Screenshots/
│       ├── Branch Performance.png
│       ├── Expenses & Profit.png
│       ├── Finance overview.png
│       └── working capital.png
├── SQL/
│   └── Financial_Analysis.sql
└── README.md
```

## Conclusion

This project demonstrates how financial data can be transformed into actionable business insights using SQL, Python, and Power BI.

The analysis supports financial performance monitoring, branch comparison, expense control, profitability analysis, and working capital management.

The interactive dashboard provides a consolidated view of financial KPIs and helps management make informed business decisions.

## Author

**Rahul Chhabra**

Data Analytics | SQL | Power BI | Python | Excel

[GitHub Profile](https://github.com/ssdnrahul)
