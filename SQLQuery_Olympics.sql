--Athletes and Events data
SELECT * FROM Athlete_Events

--Country Details
SELECT * FROM NOC_region



--1.How many olympics games have been held?

--Solution 1
SELECT count(DISTINCT games) as total_olympic_games
FROM Athlete_Events;

--Solution 2
WITH CTE as(
SELECT Games,Row_number() OVER(PARTITION BY Games ORDER BY Games) as X
FROM Athlete_Events
GROUP BY Games)
SELECT  Count(X)
FROM CTE

--2.List down all Olympics games held so far.
SELECT DISTINCT Year , Season ,City
FROM Athlete_Events
ORDER BY Year

--3.Mention the total no of nations who participated in each olympics game?

 WITH all_countries as
        (SELECT g.Games,COUNT(T.region) as X
         FROM Athlete_Events g
         JOIN  NOC_region T
         ON T.NOC = g.NOC
         GROUP BY g.games ,T.region
          ) 
 SELECT games,COUNT(games) as total_countries
 FROM all_countries
 GROUP BY games
 ORDER BY games;

--4.Which year saw the highest and lowest no of countries participating in olympics
--Problem Statement: Write a SQL query to return the Olympic Games which had the highest participating countries and the lowest participating countries.

WITH all_countries as 
     (SELECT g.Games,T.region
      FROM Athlete_Events g
      JOIN  NOC_region T
      ON T.NOC = g.NOC
      GROUP BY g.games ,T.region),

 tot_countries as(
 SELECT Games,COUNT(region) as Total_countries
 FROM all_countries
 GROUP BY Games )

 SELECT DISTINCT 
     CONCAT(FIRST_VALUE(Games) OVER (ORDER BY Total_countries asc),
        '-',
      first_value(Total_countries) over(ORDER BY total_countries asc)) as Lowest_Countries,
      concat(first_value(games) over(ORDER BY total_countries desc)
      , ' - '
      , first_value(Total_countries) over(ORDER BY total_countries desc)) as Highest_Countries
  FROM  tot_countries
  ORDER BY 1;

--5.Which nation has participated in all of the olympic games

 
WITH TotaL_games as(

 SELECT  COUNT(DISTINCT Games) as Total_games
 FROM  Athlete_Events),

 Countries as (
          SELECT g.Games,T.region as country
          FROM Athlete_Events g
          JOIN  NOC_region T
          ON T.NOC = g.NOC
          GROUP BY g.games ,T.region
               ),
 ALL_Countries as(
          SELECT country, count(1) as total_participated_games
          FROM countries
          GROUP BY country
                )
  SELECT AC.*
  FROM ALL_Countries AC
  JOIN TotaL_games tg on tg.total_games = AC.total_participated_games
  ORDER BY 1;


--6.Identify the sport which was played in all summer olympics.
WITH cte as(
SELECT COUNT(DISTINCT games) as total_games from Athlete_Events
WHERE season ='Summer'
),
cte1 as(
SELECT distinct games,Sport  FROM Athlete_Events
WHERE Season ='Summer'),

cte2 as(
SELECT sport , count(1) as total_Summer_games FROM cte1
GROUP BY sport)

SELECT * FROM cte
JOIN cte2
ON cte.total_games = cte2.total_Summer_games


--7.Which Sports were just played only once in the olympics.
WITH cte1 as(
SELECT DISTINCT sport,games from Athlete_Events
),
cte2 as
(SELECT sport , count(1) as no_of_Games
  FROM cte1
  GROUP BY sport)

SELECT cte2.*, games
      from cte2
      join cte1 on cte1.sport = cte2.sport
      WHERE cte2.no_of_games = 1
      ORDER BY cte1.sport;


--8. Fetch the total no of sports played in each olympic games.
WITH cte1 as( 
     SELECT  DISTINCT sport  ,games
     FROM Athlete_Events
     GROUP BY Sport,Games

        ),
cte2 as (
      SELECT Games,Count(1) as total_games From cte1
      GROUP BY Games
        )
SELECT cte2.*
FROM cte2
JOIN  cte1 on cte1.Games = cte2.Games
GROUP BY cte2.Games,cte2.total_games
ORDER BY cte2.total_games desc
     

---9.Fetch oldest athletes to win a gold medal

WITH CTE as(SELECT *,
RANK() Over(ORDER BY AGE Desc) as Oldest_age
FROM Athlete_Events
WHERE Medal='Gold')
SELECT * FROM CTE
WHERE Oldest_age=1
ORDER BY ID

--10. Find the Ratio of male and female athletes participated in all olympic games.

SELECT 
CONCAT( '1',':' ,CasT(ROUND((SUM(CASE
 WHEN Sex='M' THEN 1 Else 0 END  )* 1.0) /
(SUM( CASE WHEN sex='F' THEN 1  Else 0 END)* 1.0),2) as DECIMAL(10,2))) as ratio
FRom Athlete_Events



--11.Fetch the top 5 athletes who have won the most gold medals.
SELECT Name,Team,Count(Medal)as total_medal FROM Athlete_Events
WHERE Medal='Gold'
GROUP BY Team,Name
ORDER BY total_medal desc

--12.Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
SELECT TOP 5 Name,Team,Count(Medal)as total_medal FROM Athlete_Events
WHERE Medal In ('Gold','Silver','Bronze') -- 'Gold' AND  Medal= 'Silver' AND  Medal= 'Bronze'
GROUP BY Team,Name
ORDER BY total_medal desc

--13.Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

SELECT * FROM (
SELECT *,RANK() OVER ( ORDER BY No_ofMedals desc) as rnk FROM
(
SELECT DISTINCT nr.region,SUM(CASE WHEN ae.Medal IN ('Gold','Silver','Bronze') THEN 1 ELSE 0 END) as No_ofMedals  
FROM  Athlete_Events ae
JOIN NOC_region nr
ON nr.NOC =ae.NOC
GROUP BY nr.region
)as x ) as y
WHERE y.rnk<=5

--14. List down total gold, silver and bronze medals won by each country.

SELECT DISTINCT nr.region,SUM(CASE WHEN ae.Medal='Gold' THEN 1 ELSE 0 END) as Gold,
 SUM(CASE WHEN ae.Medal ='Silver' THEN 1 ELSE 0 END) as Silver,
SUM(CASE WHEN ae.Medal ='Bronze' THEN 1 ELSE 0 END) as Bronze

FROM  Athlete_Events ae
JOIN NOC_region nr
ON nr.NOC =ae.NOC
GROUP BY nr.region
ORDER BY Gold desc,Silver desc ,Bronze desc


--15.List down total gold, silver and bronze medals won by each country corresponding to each olympic games.

SELECT DISTINCT nr.region,ae.Games,SUM(CASE WHEN ae.Medal='Gold' THEN 1 ELSE 0 END) as Gold,
 SUM(CASE WHEN ae.Medal ='Silver' THEN 1 ELSE 0 END) as Silver,
SUM(CASE WHEN ae.Medal ='Bronze' THEN 1 ELSE 0 END) as Bronze
FROM  Athlete_Events ae
JOIN NOC_region nr
ON nr.NOC =ae.NOC
GROUP BY nr.region,ae.Games
ORDER BY Games asc


--16. Identify which country won the most gold, most silver and most bronze medals
--in each olympic games



--17. Identify which country won the most gold, most silver, most bronze medals 
--and the most medals in each olympic games.


 

---18.	Which countries have never won gold medal but have won silver/bronze medals?
SELECT region,SUM(Gold) as TotalGold,SUM(Silver) as TotalSilver,SUM(Bronze) as totalBronze FROM
(SELECT DISTINCT nr.region,ae.Games,SUM(CASE WHEN ae.Medal='Gold' THEN 1 ELSE 0 END) as Gold,
 SUM(CASE WHEN ae.Medal ='Silver' THEN 1 ELSE 0 END) as Silver,
SUM(CASE WHEN ae.Medal ='Bronze' THEN 1 ELSE 0 END) as Bronze
FROM  Athlete_Events ae
JOIN NOC_region nr
ON nr.NOC =ae.NOC
GROUP BY nr.region,ae.Games)as x
WHERE Gold=0 AND  (silver > 0 or bronze > 0)
GROUP BY region
ORDER BY totalBronze asc  

---19.In which Sport/event, India has won highest medals.
SELECT TOP 1 sport,COUNT(1) as TotalMedal
FROM  Athlete_Events
WHERE Team ='India' AND Medal<>'NA'
GROUP BY Sport
ORDER BY TotalMedal desc

--20.Break down all olympic games WHERE India won medal for Hockey and how many medals in each olympic games
SELECT games,team, sport,COUNT(1) as TotalMedal
FROM  Athlete_Events
WHERE Team ='India' AND Medal<>'NA' AND Sport='Hockey'
GROUP BY Sport,Team,Games
ORDER BY TotalMedal desc