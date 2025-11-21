#  Retail Sales Performance Analytics (SQL Project)

A complete SQL analytics workflow built to integrate retail sales data, generate monthly targets, calculate variance, and rank salesperson performance.

---

##  What This Project Does

✔ Integrates orders, returns, and salesperson region data  
✔ Creates monthly revenue & profit actuals  
✔ Generates synthetic targets (+3% MoM)  
✔ Computes variance % between actual vs target  
✔ Classifies performance (Overachiever / On Target / Underperformer)  
✔ Applies window functions to rank salespeople  
✔ Extracts KPIs: total sales, profit, return rate, monthly trends  

---

##  SQL Features Used

- Joins & data cleaning (TRIM, UPPER, CASE)  
- Aggregations & GROUP BY  
- Date formatting functions  
- Window functions (`RANK() OVER`)  
- Views (`vw_orders_full`, `vw_monthly_actuals`, `vw_target_attainment`)  
- Synthetic target modelling (+3% logic)  

---

##  Project Structure

Retail-SQL-Performance-Analytics/

│

├── sql/

│ └── retail_sales_project.sql

│

├── docs/

│ ├── project_overview.md

│ ├── data_model.md

│ ├── analysis_process.md

│ └── insights_summary.md

│

├── screenshots/

│ └── schema_diagram.png

│

└── README.md


---

##  Key Features

- **Data Integration:** Joins `orders`, `returned`, and `people` tables into a single analytical view (`vw_orders_full`) with a unified `is_returned` flag.  
- **Monthly Aggregation:** Summaries of revenue and profit for each salesperson via `vw_monthly_actuals`.  
- **Target Modelling:** Generates monthly revenue and profit targets using a realistic +3% month-on-month growth logic.  
- **Performance Ranking:** Uses window functions (`RANK() OVER`) to assign monthly rankings based on profit.  
- **Variance Insights:** Calculates actual vs target variance %, classifying salespeople as **Overachiever**, **On Target**, or **Underperformer**.  
- **KPI Extraction:** Computes total sales, total profit, return rate, and category-level insights.

---

##  High-Level Insights

- Average return rate recorded: **25.8%**  
- All salespeople surpassed generated monthly growth targets  
- Ranking logic clearly shows month-by-month top performers  
- SQL pipeline design can scale to many salespeople or regions with minimum changes

---

##  How to Run

1. Create a MySQL database  
2. Import the base tables (`orders`, `returned`, `people`)  
3. Run `sql/retail_sales_project.sql`  
4. Query the views:  
   - `vw_orders_full`  
   - `vw_monthly_actuals`  
   - `sales_target_monthly`  
   - `vw_target_attainment`

---

##  Author

**Adithya Kannan**  
SQL | Data Analytics | Business Intelligence
