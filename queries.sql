select * from player_statistics;

Select 
p.firstName, p.lastName, s.points, t.teamScore,t.win
from player_statistics s
join players p
on s.personId = p.personId
join team_statistics t
on s.gameId = t.gameId
and s.playerteamId = t.teamId
order by s.points desc,t.teamScore desc
limit 10;

/*top 10 avg_points per player with avg_win*/
select p.firstName, p.lastName,t.teamName, round(AVG(s.points), 1) as avg_points,
round(avg(t.win),3) as avg_win
from player_statistics s
join players p
on s.personId = p.personId
join team_statistics t
on s.gameId = t.gameId
and s.playerteamId = t.teamId
group by p.personId,t.teamName
order by avg_points desc limit 10;


/*top 10 avg_points per player with avg_win > 0.5 
and games_played >20*/

select p.firstName, p.lastName, round(avg(s.points),1) as avg_points,
round(avg(t.win),3) as avg_win, count(distinct s.gameId) as games_played
from player_statistics s
join players p
on s.personId = p.personId
join team_statistics t
on s.gameId = t.gameId
and s.playerteamId = t.teamId
group by p.personId,t.gameType
having avg_win > 0.5 and count(distinct s.gameId) > 20
order by avg_points desc limit 10
;

select p.firstName, p.lastName, round(avg(s.points),1) as avg_points,
round(avg(t.win),3) as avg_win,t.gameType as game_type, count(distinct s.gameId) as games_played
from player_statistics s
join players p
on s.personId = p.personId
join team_statistics t
on s.gameId = t.gameId
and s.playerteamId = t.teamId
where t.gameType like ('%Playoffs%')
group by p.personId,t.gameType
order by avg_points desc limit 10
;

Select 
case 
when s.numMinutes <20 then '<20 min' 
when s.numMinutes >= 20 and s.numMinutes <=30 then '20-30 min' 
else '30+ min' 
end as minutes_played, 
round(avg(s.points), 1) as avg_points, 
round(avg(s.numMinutes), 1) as avg_minutes,
count( distinct s.personId) as players_count
from player_statistics s
join team_statistics t
on s.gameId = t.gameId
and s.playerteamId = t.teamId
where t.gameType like ('%Playoffs%')
group by minutes_played
order by avg_points desc;

/*one game Player Efficiency Rating (PER) by points, rebounds, assists, steals, blocks*/
select 
firstName, LastName, gameId,
(points+reboundsTotal+assists+steals+blocks-(fieldGoalsAttempted 
-fieldGoalsMade)-(freeThrowsAttempted-freeThrowsMade)-turnovers) as PER 
from player_statistics
order by PER desc limit 20;

/*Player Efficiency Rating (PER) by points, rebounds, assists, steals, blocks*/
select 
firstName, LastName, Count(distinct gameId) as games_played,
round(avg(numMinutes), 2) as avg_minutes,
round(
avg(points+reboundsTotal+assists+steals+blocks
-(fieldGoalsAttempted-fieldGoalsMade)
-(freeThrowsAttempted-freeThrowsMade)
-turnovers),2) as PER
from player_statistics
group by personId
having avg(numMinutes) > 20 and count(distinct gameId) > 5
order by PER desc limit 20;

select *,avg(numMinutes) as avg_minutes from player_statistics
group by personId
having avg(numMinutes) > 10;

select 
firstName, 
LastName, 
Count(distinct gameId) as games_played,
round(
    avg(
        points+reboundsTotal+assists+steals+blocks
        -(fieldGoalsAttempted-fieldGoalsMade)
        -(freeThrowsAttempted-freeThrowsMade)
        -turnovers
        )
    ,2
)
 as PER
from player_statistics
where gameType like ('%Playoffs%')
group by personId
having count(distinct gameId) > 10
order by PER desc limit 20;

/*per minutes*/


SELECT
    firstName,
    lastName,
    COUNT(DISTINCT gameId) AS games_played,
    ROUND(     
AVG(
        (
            points +
            reboundsTotal +
            assists +
            steals +
            blocks
            - (fieldGoalsAttempted - fieldGoalsMade)
            - (freeThrowsAttempted - freeThrowsMade)
            - turnovers
        ) / NULLIF(numMinutes,0)
    ),
    3
) AS efficiency_per_minute
FROM player_statistics
WHERE gameType LIKE '%Playoffs%'
GROUP BY personId
HAVING COUNT(DISTINCT gameId) > 10 and avg(numMinutes) > 15
ORDER BY efficiency_per_minute DESC
LIMIT 20;



with ppp as (
    SELECT
        gameId,
        playerteamId,

        (
            points +
            reboundsTotal +
            assists +
            steals +
            blocks
            -
            (fieldGoalsAttempted - fieldGoalsMade)
            -
            (freeThrowsAttempted - freeThrowsMade)
            -
            turnovers
        ) AS efficiency

    FROM player_statistics

    WHERE gameType LIKE '%Playoffs%'
)

SELECT 
case 
when efficiency < 10 then '<10' 
when efficiency <=20 then '10-20'
when efficiency <=30 then '20-30' 
else '30+' 
end as efficiency_games,
round(avg(t.win),3) as avg_win,
round(avg(efficiency),2) as avg_efficiency
from ppp
join team_statistics t
on ppp.gameId = t.gameId
and ppp.playerteamId = t.teamId
group by efficiency_games
order by avg_win asc
;


SELECT
    win,
    ROUND(AVG(fieldGoalsPercentage),3) as fg_pct,
    ROUND(AVG(threePointersPercentage),3) as three_pct,
    ROUND(AVG(turnovers),1) as turnovers,
    ROUND(AVG(assists),1) as assists,
    ROUND(AVG(reboundsTotal),1) as rebounds
FROM team_statistics
GROUP BY win;

select 
teamName,
count(distinct gameId) as games_played,
round(avg(win),3) as avg_win,
round(avg(fieldGoalsPercentage),3) as avg_fg_pct,
round(avg(threePointersPercentage),3) as avg_three_pct,
round(avg(turnovers),1) as avg_turnovers,
round(avg(assists),1) as avg_assists,
round(avg(reboundsTotal),1) as avg_rebounds
from team_statistics
WHERE gameType LIKE '%Playoffs%'
group by teamName
order by avg_win desc
limit 10;



WITH top_teams AS (

    SELECT
        teamName,
        COUNT(DISTINCT gameId) as games_played,
        ROUND(AVG(win),3) as avg_win,
        ROUND(AVG(fieldGoalsPercentage),3) as avg_fg_pct,
        ROUND(AVG(threePointersPercentage),3) as avg_three_pct,
        ROUND(AVG(turnovers),1) as avg_turnovers,
        ROUND(AVG(assists),1) as avg_assists,
        ROUND(AVG(reboundsTotal),1) as avg_rebounds

    FROM team_statistics

    WHERE gameType LIKE '%Playoffs%'

    GROUP BY teamName

    ORDER BY avg_win DESC

    LIMIT 10
)

SELECT *
FROM top_teams

UNION ALL

SELECT
    'TOP 10 AVG',
    ROUND(AVG(games_played),1),
    ROUND(AVG(avg_win),3),
    ROUND(AVG(avg_fg_pct),3),
    ROUND(AVG(avg_three_pct),3),
    ROUND(AVG(avg_turnovers),1),
    ROUND(AVG(avg_assists),1),
    ROUND(AVG(avg_rebounds),1)
FROM top_teams;


WITH team_metrics AS (

    SELECT
        teamName,
        ROUND(AVG(win),3) as avg_win,
        ROUND(AVG(fieldGoalsPercentage),3) as avg_fg_pct,
        ROUND(AVG(threePointersPercentage),3) as avg_three_pct,
        ROUND(AVG(turnovers),1) as avg_turnovers,
        ROUND(AVG(assists),1) as avg_assists,
        ROUND(AVG(reboundsTotal),1) as avg_rebounds

    FROM team_statistics

    WHERE gameType LIKE '%Playoffs%'

    GROUP BY teamName
)

SELECT

    ROW_NUMBER() OVER(ORDER BY avg_win DESC) as row_id,

    teamName,

    avg_win,
    RANK() OVER(ORDER BY avg_win DESC) as win_rank,

    avg_fg_pct,
    RANK() OVER(ORDER BY avg_fg_pct DESC) as fg_rank,

    avg_three_pct,
    RANK() OVER(ORDER BY avg_three_pct DESC) as three_rank,

    avg_turnovers,
    RANK() OVER(ORDER BY avg_turnovers ASC) as turnover_rank,

    avg_assists,
    RANK() OVER(ORDER BY avg_assists DESC) as assist_rank,

    avg_rebounds,
    RANK() OVER(ORDER BY avg_rebounds DESC) as rebound_rank

FROM team_metrics;


