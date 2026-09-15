# Power BI Build Guide — Retail Sales Analytics Dashboard

Follow this exactly in Power BI Desktop. Total build time: ~60-90 minutes.
Reference numbers below (Total Revenue ≈ ₹5.78 Cr, Total Profit ≈ ₹1.8 Cr,
900 orders, 133 customers) are from the actual dataset — use them to sanity
check your dashboard once built.

## Step 1 — Import the data

1. Open Power BI Desktop → **Get Data → Text/CSV**.
2. Import all 4 files from the `data/` folder, one at a time:
   `customers.csv`, `products.csv`, `orders.csv`, `order_items.csv`.
3. Click **Transform Data** before loading each one, and check:
   - `order_date`, `ship_date`, `signup_date` are typed as **Date** (not text).
   - `unit_price`, `unit_cost`, `discount` are typed as **Decimal Number**.
   - `quantity` is a **Whole Number**.
4. Click **Close & Apply**.

## Step 2 — Build the relationships (star schema)

Go to the **Model** view. `order_items` and `orders` are your fact tables;
`customers` and `products` are dimension tables. Create these relationships
by dragging the field from one table onto the other:

| From table    | Field         | To table       | Field         |
|---------------|---------------|----------------|---------------|
| orders        | customer_id   | customers      | customer_id   |
| order_items   | order_id      | orders         | order_id      |
| order_items   | product_id    | products       | product_id    |

All relationships should show **1-to-many** automatically (1 on the
dimension side, many on `order_items`/`orders`). If any shows as
many-to-many, double-click it and fix the cardinality manually.

## Step 3 — Create the DAX measures

Right-click `order_items` in the Fields pane → **New Measure**. Add each of
these one at a time (paste the formula, keep the name exactly as given —
you'll use these names as visual fields later):

```DAX
Total Revenue =
SUMX(order_items, order_items[quantity] * order_items[unit_price] * (1 - order_items[discount]))
```

```DAX
Total Cost =
SUMX(order_items, order_items[quantity] * order_items[unit_cost])
```

```DAX
Total Profit = [Total Revenue] - [Total Cost]
```

```DAX
Profit Margin % = DIVIDE([Total Profit], [Total Revenue], 0)
```

```DAX
Total Orders = DISTINCTCOUNT(orders[order_id])
```

```DAX
Total Customers = DISTINCTCOUNT(customers[customer_id])
```

```DAX
Average Order Value = DIVIDE([Total Revenue], [Total Orders], 0)
```

```DAX
Total Units Sold = SUM(order_items[quantity])
```

```DAX
Revenue YoY % =
VAR CurrentYearRevenue = [Total Revenue]
VAR PriorYearRevenue =
    CALCULATE([Total Revenue], SAMEPERIODLASTYEAR(orders[order_date]))
RETURN
    DIVIDE(CurrentYearRevenue - PriorYearRevenue, PriorYearRevenue, 0)
```

> Note: `Revenue YoY %` needs a proper **Date table** marked as a date table
> for `SAMEPERIODLASTYEAR` to work. Quick way: Modeling tab → New Table →
> paste `DateTable = CALENDAR(MIN(orders[order_date]), MAX(orders[order_date]))`,
> mark it as a Date Table (Modeling → Mark as Date Table), and relate
> `DateTable[Date]` to `orders[order_date]`.

## Step 4 — Build the dashboard pages

### Page 1 — Executive Summary
- **4 KPI Cards** across the top: `Total Revenue`, `Total Profit`,
  `Total Orders`, `Average Order Value`.
- **Line chart**: X-axis = `order_date` (by month), Y-axis = `Total Revenue`.
  Title: "Monthly Revenue Trend".
- **Donut chart**: `category` (legend) vs `Total Revenue` (values).
  Title: "Revenue by Category".
- **Bar chart**: `region` (axis) vs `Total Revenue` (values), sorted descending.
  Title: "Revenue by Region".
- **Slicers** at the top: `region`, `segment`, and a date range slicer on
  `order_date`, so the whole page filters interactively.

### Page 2 — Product Performance
- **Table**: `product_name`, `category`, `Total Units Sold`, `Total Revenue`,
  `Total Profit`, `Profit Margin %` — sorted by Total Revenue descending.
- **Bar chart**: Top 10 products by `Total Revenue` (use the Filters pane →
  Top N filter, N = 10).
- **Scatter chart**: X = `Total Units Sold`, Y = `Profit Margin %`, size =
  `Total Revenue`, details = `product_name`. This instantly shows which
  products are high-volume but low-margin (worth flagging as an insight).

### Page 3 — Customer & Regional Analysis
- **Map visual**: `state` (location) vs `Total Revenue` (size). Power BI
  auto-geocodes Indian state names.
- **Stacked bar chart**: `region` (axis), `segment` (legend), `Total Revenue`
  (values).
- **Table**: Top 10 customers by `Total Revenue` (use Top N filter again).
- **Card**: `Total Customers`.

## Step 5 — Polish

- Apply a consistent theme: **View → Themes** → pick one clean theme
  (avoid Power BI's default bright rainbow colors — stick to 2-3 colors
  max per page).
- Add a text box title on each page (e.g., "Retail Sales Analytics —
  Executive Summary").
- Add your name and the data period ("Jan 2023 – Dec 2024") as a small
  footer text box.

## Step 6 — Publish / Export for your GitHub portfolio

Power BI files (`.pbix`) can't be *viewed* directly on GitHub, so also do
this before uploading:

1. **File → Export → Export to PDF** — gives recruiters something they can
   open instantly without Power BI installed.
2. Take 2-3 screenshots of each page (Win+Shift+S) and save them as
   `screenshot_page1.png`, `screenshot_page2.png`, `screenshot_page3.png`.
3. Upload the `.pbix` file **and** the PDF **and** the screenshots to the
   repo — the README embeds the screenshots so it looks good without
   anyone needing to open anything.
