USE finsight;

SELECT'account_mapping' AS table_name, COUNT(*) AS total_records
FROM account_mapping
UNION ALL
SELECT 'branches', COUNT(*) FROM branches
UNION ALL
SELECT 'budgets', COUNT(*) FROM budgets
UNION ALL
SELECT 'calendar', COUNT(*) FROM calendar
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'departments', COUNT(*) FROM departments
UNION ALL
SELECT 'invoices', COUNT(*) FROM invoices
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL
SELECT 'vendors', COUNT(*) FROM vendors;

-- Transactions validation

SELECT
    COUNT(*) AS total_transactions,
	SUM(b.branch_id IS NULL) AS invalid_branch,
	SUM(d.department_id IS NULL) AS invalid_department,
	SUM(a.account_code IS NULL) AS invalid_account
    FROM transactions t
	LEFT JOIN branches b
    ON t.branch_id = b.branch_id
	LEFT JOIN departments d
    ON t.department_id = d.department_id
	LEFT JOIN account_mapping a
    ON t.account_code = a.account_code;
    
    -- Budgets validation
    
    
SELECT
    COUNT(*) AS total_budgets,
	SUM(b.branch_id IS NULL) AS invalid_branch,
	SUM(d.department_id IS NULL) AS invalid_department,
	SUM(a.account_code IS NULL) AS invalid_account
	FROM budgets bu
	LEFT JOIN branches b
    ON bu.branch_id = b.branch_id
	LEFT JOIN departments d
    ON bu.department_id = d.department_id
	LEFT JOIN account_mapping a
    ON bu.account_code = a.account_code;
    
-- Invoice Validation

SELECT
    invoice_type,
    COUNT(*) AS total_invoices,
    SUM(party_id IS NULL) AS missing_party_id,
    SUM(branch_id IS NULL) AS missing_branch_id,
    SUM(transaction_id IS NULL) AS missing_transaction_id
FROM invoices
GROUP BY invoice_type;


WITH monthly_data AS (
SELECT
DATE_FORMAT(STR_TO_DATE(transaction_date, '%d-%m-%Y'), '%Y-%m') AS month,
ROUND(SUM(CASE WHEN account_code = 'Revenue' THEN amount_inr ELSE 0 END),2) AS revenue,
ROUND(SUM(CASE WHEN account_code = 'COGS' THEN amount_inr ELSE 0 END),2) AS cogs,
ROUND(SUM(CASE WHEN account_type = 'Operating Expense' THEN amount_inr ELSE 0 END),2) AS operating_expenses,
ROUND(SUM(CASE WHEN account_code = 'Depreciation' THEN amount_inr ELSE 0 END),2) AS depreciation,
ROUND(SUM(CASE WHEN account_code = 'Interest' THEN amount_inr ELSE 0 END),2) AS interest
FROM transactions
WHERE status = 'Posted'
GROUP BY month
)
SELECT month, revenue, cogs, ROUND(revenue - cogs,2) AS gross_profit,
ROUND(revenue - cogs - operating_expenses,2) AS EBITDA,
ROUND(revenue - cogs - operating_expenses - depreciation,2) AS EBIT,
ROUND(revenue - cogs - operating_expenses - depreciation - interest,2) AS PBT
FROM monthly_data
ORDER BY month;



WITH monthly_data AS (
SELECT
DATE_FORMAT(STR_TO_DATE(t.transaction_date, '%d-%m-%Y'), '%Y-%m') AS month,
SUM(CASE WHEN a.pnl_group = 'Revenue' THEN t.amount_inr ELSE 0 END) AS revenue,
SUM(CASE WHEN a.pnl_group = 'Cost of Goods Sold' THEN t.amount_inr ELSE 0 END) AS cogs,
SUM(CASE WHEN a.pnl_group = 'Operating Expenses' THEN t.amount_inr ELSE 0 END) AS operating_expenses,
SUM(CASE WHEN a.pnl_group = 'Depreciation' THEN t.amount_inr ELSE 0 END) AS depreciation,
SUM(CASE WHEN a.pnl_group = 'Finance Costs' THEN t.amount_inr ELSE 0 END) AS finance_costs
FROM transactions t
JOIN account_mapping a
ON t.account_code = a.account_code
WHERE t.status = 'Posted'
GROUP BY month
)
SELECT month, ROUND(revenue, 2) AS revenue, ROUND(cogs, 2) AS cogs,
ROUND(revenue - cogs, 2) AS gross_profit,
ROUND((revenue - cogs) / NULLIF(revenue, 0) * 100,2) AS gross_margin_pct,
ROUND(revenue - cogs - operating_expenses,2) AS EBITDA,
ROUND((revenue - cogs - operating_expenses)/ NULLIF(revenue, 0) * 100,2) AS EBITDA_margin_pct,
ROUND(revenue - cogs - operating_expenses - depreciation,2) AS EBIT,
ROUND(revenue - cogs - operating_expenses- depreciation - finance_costs,2) AS PBT
FROM monthly_data
ORDER BY month;


 /* Branch Revenue Ranking
Business Scenario: The Finance Head wants to compare branch revenue performance 
for October 2026 and identify the highest-revenue branches*/


WITH ninjas AS(
SELECT t.branch_id,
ROUND(SUM(CASE WHEN a.pnl_group='Revenue' THEN t.amount_inr ELSE 0 END),2) AS revenue
FROM transactions t
JOIN account_mapping a 
ON t.account_code = a.account_code
WHERE DATE_FORMAT(STR_TO_DATE(t.transaction_date,'%d-%m-%Y'),'%Y-%m') = '2026-10'
AND status = 'Posted'
GROUP BY branch_id)
SELECT branch_id, revenue, 
DENSE_RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM ninjas;

-- Budget vs Actual Revenue by Branch
/* Business scenario: The Finance Head wants to compare actual Revenue 
with the planned Revenue budget for October 2026, branch-wise.*/

WITH actual_revenue AS (
SELECT branch_id,
ROUND(SUM(CASE WHEN account_code='Revenue' THEN amount_inr ELSE 0 END),2 )AS actual_revenue
FROM transactions
WHERE DATE_FORMAT(STR_TO_DATE(transaction_date,'%d-%m-%Y'),'%Y-%m') = '2026-10'
AND status = 'Posted'
GROUP BY branch_id),
budget_revenue AS(
SELECT branch_id,
ROUND(SUM(CASE WHEN account_code = 'Revenue' THEN budget_amount_inr ELSE 0 END),2) AS budget_revenue
FROM budgets 
WHERE budget_month = '2026-10'
GROUP BY branch_id)
SELECT ar.branch_id,
ar.actual_revenue,
br.budget_revenue,
ROUND(ar.actual_revenue-br.budget_revenue) AS variance,
ROUND((ar.actual_revenue-br.budget_revenue)/br.budget_revenue*100,2) AS variance_pct
FROM actual_revenue ar
JOIN budget_revenue br
    ON ar.branch_id = br.branch_id
ORDER BY actual_revenue DESC;


/* Monthly Expense Budget Variance
Business scenario:

The Finance Manager wants to identify which branches exceeded their October 2026 operating expense budget.*/


WITH actual_expense AS (
SELECT branch_id,
ROUND(SUM(CASE WHEN account_type = 'Operating Expense' THEN amount_inr ELSE 0 END),2 )AS actual_expense
FROM transactions
WHERE DATE_FORMAT(STR_TO_DATE(transaction_date,'%d-%m-%Y'),'%Y-%m') = '2026-10'
AND status = 'Posted'
GROUP BY branch_id),
budgeted_expense AS(
SELECT b.branch_id,
ROUND(SUM(CASE WHEN a.account_type = 'Operating Expense' THEN b.budget_amount_inr ELSE 0 END),2) AS budgeted_expense
FROM budgets b
JOIN account_mapping a
ON b.account_code = a.account_code
WHERE budget_month = '2026-10'
GROUP BY b.branch_id)
SELECT ae.branch_id,
ae.actual_expense,
be.budgeted_expense,
ROUND(ae.actual_expense-be.budgeted_expense,2) AS variance,
ROUND((ae.actual_expense-be.budgeted_expense)/be.budgeted_expense*100,2) AS variance_pct
FROM actual_expense ae
JOIN budgeted_expense be
    ON ae.branch_id = be.branch_id
ORDER BY actual_expense DESC;


-- total outstanding Accounts Payable by vendor as of October 31, 2026.


WITH invoice_amount AS(
SELECT party_id, invoice_id, SUM(invoice_amount_inr) AS total_invoice_amount
FROM invoices
WHERE invoice_type = 'AP'
GROUP BY party_id, invoice_id),

payment_amount AS(
SELECT invoice_id, SUM(payment_amount_inr) AS total_payment
FROM payments
GROUP BY invoice_id)
SELECT i.party_id AS vendor_id, 
ROUND(SUM(i.total_invoice_amount), 2) AS total_invoiced,
ROUND(SUM(IFNULL(p.total_payment, 0)), 2) AS total_paid,
ROUND(SUM(i.total_invoice_amount - IFNULL(p.total_payment, 0)),2) AS outstanding_amount
FROM invoice_amount i
LEFT JOIN payment_amount p
ON i.invoice_id = p.invoice_id
GROUP BY i.party_id
HAVING outstanding_amount>0
ORDER BY outstanding_amount DESC;



-- Calculate the total outstanding Accounts Receivable by customer as of October 31, 2026.


WITH invoice AS(
SELECT party_id, invoice_id, SUM(invoice_amount_inr) AS invoiced_amount
FROM invoices
WHERE invoice_type = 'AR'
GROUP BY party_id, invoice_id),
pending_payments AS(
SELECT invoice_id, SUM(payment_amount_inr) AS payment_received
FROM payments
GROUP BY invoice_id)

SELECT i.party_id AS customer_id,
ROUND(SUM(i.invoiced_amount),2) AS total_invoiced,
ROUND(SUM(IFNULL(p.payment_received,0)),2) AS total_payment_received,
ROUND(SUM(i.invoiced_amount - IFNULL(p.payment_received,0)),2) AS outstanding_amount
FROM invoice i
LEFT JOIN pending_payments p 
ON i.invoice_id = p.invoice_id
GROUP BY i.party_id
HAVING outstanding_amount > 0
ORDER BY outstanding_amount DESC;

-- Find the total amount paid to each vendor during October 2026.

SELECT i.party_id AS vendor_id,
ROUND(SUM(p.payment_amount_inr),2) AS amount_paid
FROM payments p
JOIN invoices i
ON p.invoice_id = i.invoice_id
WHERE DATE_FORMAT(payment_date,'%Y-%m') = '2026-10'
AND i.invoice_type = 'AP'
GROUP BY i.party_id
ORDER BY amount_paid DESC;

-- Calculate the total operating expenses for each branch for October 2026.

SELECT branch_id,
ROUND(SUM(CASE WHEN account_type = 'Operating Expense' THEN amount_inr ELSE 0 END),2) 
AS total_operating_expense
FROM transactions
WHERE DATE_FORMAT(STR_TO_DATE(transaction_date,'%d-%m-%Y'),'%Y-%m') = '2026-10'
GROUP BY branch_id
ORDER BY total_operating_expense DESC;

-- Monthly Operating Expense Trend

SELECT 
DATE_FORMAT(STR_TO_DATE(transaction_date,'%d-%m-%Y'),'%Y-%m') AS month,
ROUND(SUM(CASE WHEN account_type = 'Operating Expense' THEN amount_inr ELSE 0 END),2) 
AS total_operating_expense
FROM transactions
GROUP BY month 
ORDER BY month;

-- Year-over-Year Operating Expense Comparison

SELECT
DATE_FORMAT(STR_TO_DATE(transaction_date,'%d-%m-%Y'),'%Y') AS Year,
ROUND(SUM(CASE WHEN account_type = 'Operating Expense' THEN amount_inr ELSE 0 END),2) 
AS total_operating_expense
FROM transactions
GROUP BY Year
ORDER BY Year;

-- Monthly Cash Movement

WITH ninjas AS(
SELECT 
DATE_FORMAT(payment_date, '%Y-%m') AS month,
ROUND(SUM(CASE WHEN cash_direction = 'Incoming' THEN payment_amount_inr ELSE 0 END),2) AS total_incoming,
ROUND(SUM(CASE WHEN cash_direction = 'Outgoing' THEN payment_amount_inr ELSE 0 END),2) AS total_outgoing
FROM payments
GROUP BY month)
SELECT month, total_incoming,
total_outgoing,
ROUND((total_incoming - total_outgoing),2) AS net_cash_movement
FROM ninjas
ORDER BY month;


-- Invoice Payment Reconciliation
-- The Finance Head wants to identify invoices that have been overpaid.


WITH invoice_amount AS(
SELECT invoice_id, invoice_type, 
SUM(invoice_amount_inr) AS invoice_amount
FROM invoices
GROUP BY invoice_id, invoice_type),

payment_amount AS(
SELECT invoice_id, SUM(payment_amount_inr) AS total_paid
FROM payments
GROUP BY invoice_id)

SELECT i.invoice_id,i.invoice_type, i.invoice_amount, p.total_paid,
ROUND((p.total_paid - i.invoice_amount),2) AS overpayment_amount
FROM invoice_amount i 
JOIN payment_amount p 
ON i.invoice_id = p.invoice_id 
WHERE p.total_paid > i.invoice_amount
HAVING ROUND((p.total_paid - i.invoice_amount),2)>0;



/* The Finance Head wants to identify how much the company owes each vendor and how overdue those outstanding balances are.

Using the invoices and payments tables, calculate the outstanding amount for each AP invoice 
as of 31-Oct-2026 and classify it into these ageing buckets:*/

WITH invoice_data AS (
SELECT invoice_id,
party_id AS vendor_id,
invoice_type, SUM(invoice_amount_inr) AS invoice_amount,
MAX(due_date) AS due_date
FROM invoices
WHERE invoice_type = 'AP'
AND invoice_date <= '2026-10-31'
GROUP BY invoice_id, party_id, invoice_type
),

payment_data AS (
SELECT invoice_id,
SUM(payment_amount_inr) AS total_paid
FROM payments
WHERE payment_date <= '2026-10-31'
GROUP BY invoice_id
),

outstanding_data AS (
SELECT i.invoice_id, i.vendor_id, i.invoice_amount,
IFNULL(p.total_paid, 0) AS total_paid,
(i.invoice_amount - IFNULL(p.total_paid, 0)) AS outstanding_amount,
i.due_date
FROM invoice_data i
LEFT JOIN payment_data p
ON i.invoice_id = p.invoice_id
)

SELECT invoice_id, vendor_id,
ROUND(invoice_amount, 2) AS invoice_amount,
ROUND(total_paid, 2) AS total_paid,
ROUND(outstanding_amount, 2) AS outstanding_amount,
CASE
WHEN outstanding_amount = 0 THEN 'Paid'
WHEN due_date >= '2026-10-31' THEN 'Not Due'
WHEN DATEDIFF('2026-10-31', due_date) BETWEEN 1 AND 30 THEN '1-30 days'
WHEN DATEDIFF('2026-10-31', due_date) BETWEEN 31 AND 60 THEN '31-60 days'
WHEN DATEDIFF('2026-10-31', due_date) BETWEEN 61 AND 90 THEN '61-90 days'
WHEN DATEDIFF('2026-10-31', due_date) > 90 THEN '90+ days'
END AS ageing_bucket
FROM outstanding_data
ORDER BY vendor_id, due_date;

-- AR Ageing Analysis

WITH invoice_data AS (
    SELECT
        invoice_id,
        party_id AS customer_id,
        SUM(invoice_amount_inr) AS invoice_amount,
        MAX(due_date) AS due_date
    FROM invoices
    WHERE invoice_type = 'AR'
      AND invoice_date <= '2026-10-31'
    GROUP BY invoice_id, party_id
),

payment_data AS (
    SELECT
        invoice_id,
        SUM(payment_amount_inr) AS total_payment
    FROM payments
    WHERE payment_date <= '2026-10-31'
    GROUP BY invoice_id
),

outstanding AS (
    SELECT
        i.invoice_id,
        i.customer_id,
        i.invoice_amount,
        IFNULL(p.total_payment, 0) AS total_payment,
        i.invoice_amount - IFNULL(p.total_payment, 0)
            AS outstanding_amount,
        i.due_date
    FROM invoice_data i
    LEFT JOIN payment_data p
        ON i.invoice_id = p.invoice_id
)

SELECT
    invoice_id,
    customer_id,
    ROUND(invoice_amount, 2) AS invoice_amount,
    ROUND(total_payment, 2) AS total_payment,
    ROUND(outstanding_amount, 2) AS outstanding_amount,
    CASE
        WHEN due_date >= '2026-10-31' THEN 'Not Due'
        WHEN DATEDIFF('2026-10-31', due_date)
            BETWEEN 1 AND 30 THEN '1-30 days'
        WHEN DATEDIFF('2026-10-31', due_date)
            BETWEEN 31 AND 60 THEN '31-60 days'
        WHEN DATEDIFF('2026-10-31', due_date)
            BETWEEN 61 AND 90 THEN '61-90 days'
        WHEN DATEDIFF('2026-10-31', due_date) > 90
            THEN '90+ days'
    END AS ageing_bucket
FROM outstanding
WHERE outstanding_amount > 0
ORDER BY customer_id, due_date;

-- Revenue Forecast for November 2026

WITH monthly_revenue AS (
SELECT
DATE_FORMAT(STR_TO_DATE(transaction_date, '%d-%m-%Y'),'%Y-%m'
) AS month,
SUM(amount_inr) AS revenue
FROM transactions
WHERE status = 'Posted'
AND account_code = 'Revenue'
AND STR_TO_DATE(transaction_date, '%d-%m-%Y') >= '2026-08-01'
AND STR_TO_DATE(transaction_date, '%d-%m-%Y') < '2026-11-01'
GROUP BY month
)
SELECT
'2026-11' AS forecast_month,
ROUND(AVG(revenue), 2) AS forecasted_revenue
FROM monthly_revenue;
 
 
 
