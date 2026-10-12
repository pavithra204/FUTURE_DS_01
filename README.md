# Business Sales Performance Analytics — SQL + Power BI Project

End-to-end data analytics project on a synthetic retail dataset (900 orders,
133 customers, 40 products, 2 years of data). Built to demonstrate SQL
querying and Power BI dashboarding skills for a Data Analyst role.

## What this project covers

- **Database design**: a 4-table relational schema (`customers`, `products`,
  `orders`, `order_items`) with primary/foreign keys — see `sql/01_schema.sql`.
- **SQL analysis**: 20 business questions answered in SQL, from basic
  filtering to joins, subqueries, CTEs, window functions, and views — see
  `sql/02_queries.sql`.
- **Power BI dashboard**: a 3-page interactive dashboard (Executive Summary,
  Product Performance, Customer & Regional Analysis) with 9 DAX measures —
  build steps in `powerbi/POWERBI_BUILD_GUIDE.md`.

## Tech stack

`SQL` · `Power BI` · `DAX` · `Python (data generation)`

## Project structure

```
retail-sales-analytics/
├── data/
│   ├── customers.csv
│   ├── products.csv
│   ├── orders.csv
│   └── order_items.csv
├── sql/
│   ├── 01_schema.sql          -- table definitions + indexes
│   └── 02_queries.sql         -- 20 business questions in SQL
├── powerbi/
│   └── POWERBI_BUILD_GUIDE.md -- step-by-step dashboard build guide
└── README.md
```

## Key business questions answered

- What's total revenue and profit by region and category?
- Which products/sub-categories drive the most revenue?
- Who are the top 10 customers by lifetime value?
- What's the month-over-month revenue trend, and year-over-year growth?
- Which products have the best profit margin vs. volume trade-off?

## Sample insight

Revenue is heavily seasonal — order volume rises ~60% in the Oct-Dec festive
period compared to the June-August monsoon months, and the South and North
regions together account for over half of total revenue. This kind of trend
directly informs inventory and regional marketing spend decisions.

## Skills demonstrated

`Joins across multiple tables` · `GROUP BY / HAVING` · `Subqueries` ·
`CTEs` · `Window functions (RANK, ROW_NUMBER, running totals)` · `Views` ·
`DAX measures` · `Data modeling (star schema)` · `Dashboard design`
