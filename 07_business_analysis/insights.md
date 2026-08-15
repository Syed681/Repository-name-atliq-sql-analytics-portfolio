# Business Analysis & Insights

This section translates the SQL analysis into business-oriented observations.

The purpose is to demonstrate how SQL outputs can support decision-making rather than only producing data tables.

---

## 1. Regional Sales Performance

**Business Question**

Which regions generate the highest sales volume?

**SQL Approach**

Sales quantities are aggregated from `fact_sales_monthly` and joined with `dim_customer` to obtain regional attributes.

**Business Relevance**

Regional sales analysis can support:

- Demand planning
- Resource allocation
- Regional performance monitoring
- Sales strategy

---

## 2. Customer Performance

**Business Question**

Which customers contribute the most net sales?

**Business Relevance**

High-value customers can be prioritized for:

- Account management
- Service-level monitoring
- Revenue retention
- Strategic planning

Customer concentration should also be monitored because strong dependence on a small number of customers can increase business risk.

---

## 3. Product Performance

**Business Question**

Which products contribute the most net sales?

**Business Relevance**

Product-level performance can support:

- Product prioritization
- Demand planning
- Portfolio management
- Inventory planning

---

## 4. Forecast Accuracy

**Business Question**

How closely does forecast quantity match actual sales quantity?

**Business Relevance**

Forecast accuracy can help evaluate:

- Demand planning quality
- Supply planning effectiveness
- Inventory planning
- Capacity planning

Large gaps between actual and forecast quantities may indicate opportunities to improve forecasting processes.

---

## 5. Market Performance

**Business Question**

Which markets generate the highest gross sales?

**Business Relevance**

Market-level analysis can support decisions involving:

- Regional expansion
- Sales focus
- Distribution planning
- Commercial strategy

---

## 6. Manufacturing Cost

**Business Question**

Which products have higher manufacturing costs?

**Business Relevance**

Manufacturing cost analysis can help identify:

- High-cost products
- Cost optimization opportunities
- Margin pressure
- Products requiring further investigation

---

## 7. Freight Cost

**Business Question**

Which markets have higher freight cost percentages?

**Business Relevance**

Freight analysis can support:

- Logistics cost optimization
- Route and carrier analysis
- Regional supply-chain decisions
- Transportation planning

---

## 8. Customer Concentration

Customer sales share within each region helps identify whether regional revenue is distributed across many customers or concentrated among a few major accounts.

High concentration can indicate both strong strategic accounts and potential customer-dependency risk.

---

## Portfolio Takeaway

This project demonstrates the progression from:

SQL Querying  
→ Data Aggregation  
→ Analytical SQL  
→ Business KPI Calculation  
→ Business Interpretation

The objective is to demonstrate practical SQL analytics capability using a realistic business dataset.
