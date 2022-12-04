WITH transaction_per_date AS (
SELECT 
  channelGrouping,
  PARSE_DATE("%Y%m%d", date) AS parsed_date, 
  SUM(totals_transactions) AS trx_per_date
FROM 
  `data-to-insights.ecommerce.rev_transactions`
GROUP BY channelGrouping, parsed_date
),transaction_per_country AS (
SELECT
  channelGrouping, 
  geoNetwork_country,
  PARSE_DATE("%Y%m%d", date) AS parsed_date,  
  SUM(totals_transactions) AS trx_per_country
FROM 
  `data-to-insights.ecommerce.rev_transactions`
WHERE geoNetwork_country != "(not set)" AND channelGrouping != "(Other)" 
GROUP BY channelGrouping, geoNetwork_country, parsed_date
)

SELECT 
  trxdate.channelGrouping,
  trxdate.parsed_date,
  trx_per_date,
  ARRAY_AGG(
    STRUCT(geoNetwork_country, trx_per_country)
  ) AS aggregated_country,
FROM transaction_per_date trxdate
INNER JOIN transaction_per_country trxcountry
ON trxdate.channelGrouping = trxcountry.channelGrouping AND trxdate.parsed_date = trxcountry.parsed_date
GROUP BY channelGrouping, parsed_date, trx_per_date
ORDER BY trx_per_date DESC
