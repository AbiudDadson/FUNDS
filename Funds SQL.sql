SELECT*
FROM .ETFprices

SELECT*
FROM .ETFs	

SELECT*
FROM .[MutualFundPrices _A_E]

SELECT*
FROM .MutualFunds



SELECT fund_category,exchange_name,count(exchange_name)
FROM .ETFs
	WHERE fund_category IS NOT NULL
		GROUP BY fund_category ,exchange_name

--ALL MUTUAL FUNDS PRICES--
DROP TABLE IF EXISTS MFP
CREATE TABLE MFP
	(
	Fund_symbol VARCHAR(50),
	Price_date DATE,
	Nav_per_share FLOAT
	)
INSERT INTO MFP	
	SELECT *
		FROM .[MutualFundPrices _A_E]
 UNION
	SELECT *
		FROM .[MutualFundPrices _F_K]
 UNION
	SELECT *
		FROM .[MutualFundPrices _L_P]
 UNION
	SELECT *
		FROM .[MutualFundPrices _ Q_Z]

-- MUTUAL FUND PRICES FROM 2011-2021--

SELECT Fund_symbol, Nav_per_share, YEAR(Price_date) AS Year
FROM MFP
	WHERE YEAR(Price_date) >= 2011
		ORDER BY YEAR(Price_date)


--AMOUNT OF FUNDS FOR YEAR--

CREATE VIEW MFP_VIEW AS 
SELECT COUNT(Fund_symbol)AS Count_Of_Funds, YEAR(Price_date) AS Year
FROM MFP
	WHERE YEAR(Price_date) >= 2011
		GROUP BY YEAR(Price_date)
		
CREATE PROC
SELECT .MutualFunds.fund_symbol,region,fund_category,management_name,investment_type,investment_strategy,
		CAST(management_start_date AS date) AS management_start_date,initial_investment,total_net_assets,
		asset_cash,asset_stocks
FROM MutualFunds
	JOIN
.MFP
	ON .MFP.Fund_symbol = .MutualFunds.fund_symbol
	WHERE Price_date = management_start_date 
			AND YEAR(management_start_date) >= 2011		
	ORDER BY management_start_date



-- Fund NAVTotal_Share_Per_Investment by Year--

SELECT .MutualFunds.fund_symbol,SUM(Nav_per_share/initial_investment)AS NAVTotal_Share_Per_Investment,YEAR(management_start_date) AS YEAR
FROM MutualFunds
	JOIN
.MFP
	ON .MFP.Fund_symbol = .MutualFunds.fund_symbol
	WHERE Price_date = management_start_date 
			AND YEAR(management_start_date) >= 2011	
	GROUP BY .MutualFunds.fund_symbol,YEAR(management_start_date)
	HAVING SUM(Nav_per_share/initial_investment) IS NOT NULL




--NAVTotal_Share_Per_Investment by Year--
SELECT SUM(Nav_per_share/initial_investment)AS NAVTotal_Share_Per_Investment,YEAR(management_start_date) AS YEAR
FROM MutualFunds
	JOIN
.MFP
	ON .MFP.Fund_symbol = .MutualFunds.fund_symbol
	WHERE Price_date = management_start_date 
			AND YEAR(management_start_date) >= 2011	
	GROUP BY YEAR(management_start_date)
	HAVING SUM(Nav_per_share/initial_investment) IS NOT NULL
		AND SUM(Nav_per_share/initial_investment) >= 1
	

-- TOTAL ASSETS COMPARED WITH CASH AND STOCK ASSETS BY YEAR--
CREATE VIEW NET_ASSET AS 
	SELECT	SUM(total_net_assets)AS Net_Asset,
			SUM(Nav_per_share*asset_cash)AS NAVTotal_Share_Per_Cash_Asset,
			SUM(Nav_per_share*asset_stocks)AS NAVTotal_Share_Per_Stock_Asset,
			YEAR(management_start_date) AS YEAR
FROM MutualFunds
	JOIN
.MFP
	ON .MFP.Fund_symbol = .MutualFunds.fund_symbol
	WHERE Price_date = management_start_date 
			AND YEAR(management_start_date) >= 2011	
	GROUP BY YEAR(management_start_date)
	

-- THE MOUNTH THHAT HAD THE BIGGEST FUNDS BY INVESTMENT TYPE--
UPDATE .MutualFunds 
SET investment_type = 'Straight' 
	where investment_type IS NULL

CREATE VIEW INVESTMENT_WITH_BIGGEST_FUNDS AS
SELECT COUNT(.MutualFunds.fund_symbol)AS Amount_of_funds,investment_type,MONTH(management_start_date)AS Months
FROM MutualFunds
	JOIN
.MFP
	ON .MFP.Fund_symbol = .MutualFunds.fund_symbol
	WHERE Price_date = management_start_date 
			AND YEAR(management_start_date) >= 2011		
	GROUP BY investment_type,MONTH(management_start_date)


--TOTAL FUNDS--
CREATE VIEW TOTAL_FUNDS AS
SELECT COUNT(.MutualFunds.fund_symbol) AS TOTAL FUNDS
FROM .MutualFunds
	JOIN
.MFP
	ON .MFP.Fund_symbol = .MutualFunds.fund_symbol
	WHERE Price_date = management_start_date 
			AND YEAR(management_start_date) >= 2011	
			



CREATE VIEW QUATER_INVESTMENT AS
--QUATER INVESTMENT SHARE--
SELECT COUNT(management_name) AS INVESTOR ,
		investment_type,
		((SUM(total_net_assets-(Nav_per_share/(initial_investment/subsequent_investment))))-SUM(initial_investment*Nav_per_share))/200 AS QUATER_investment_Share
FROM .MutualFunds
	JOIN
.MFP
	ON .MFP.Fund_symbol = .MutualFunds.fund_symbol
	WHERE Price_date = management_start_date 
			AND YEAR(management_start_date) >= 2011	
			GROUP BY investment_type



SELECT*
FROM ETFprices
 LEFT JOIN
.MFP
ON .ETFprices.price_date = .MFP.Price_date
RIGHT JOIN
.MutualFunds
ON .MFP.fund_symbol =  .MutualFunds.fund_symbol
	WHERE .ETFprices.price_date = .MFP.Price_date  AND
			.MFP.Price_date = .MutualFunds.inception_date AND 
			MONTH(ETFprices.price_date) BETWEEN 6 AND 12
			ORDER BY .ETFprices.fund_symbol,.MFP.fund_symbol,.MutualFunds.fund_symbol






	