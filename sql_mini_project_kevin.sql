use ipl;
#1 Show the percentage of wins of each bidder in the order of highest to lowest percentage.
select bd.bidder_id,bidder_name,bid_status,no_of_bids,no_of_matches,count(no_of_matches),sum(bid_status ='Won')  as matches_won,
(sum(bid_status ='Won'))/ (count(no_of_matches))*100 as win_percentage,
 total_points from ipl_bidding_details bid 
inner join ipl_bidder_details bd on bid.bidder_id=bd.bidder_id
inner join ipl_bidder_points bp on bd.bidder_id=bp.bidder_id
group by bidder_id
order by win_percentage desc;


#2 Which teams have got the highest and the lowest no. of bids?

select team_name,a.bid_team,count(a.bid_team) from ipl_bidding_details a
inner join ipl_team b on a.bid_team=b.team_id
group by team_id,bid_team
having count(a.bid_team) =(select count(bid_team) from ipl_bidding_details
group by bid_team
order by count(bid_team) desc limit 1)
or
count(bid_team)=(select count(bid_team) from ipl_bidding_details
group by bid_team
order by count(bid_team) limit 1)
order by count(a.bid_team) desc;

#3 In a given stadium, what is the percentage of wins by a team which had won the toss?

select mat_stad.*, match_win.toss_win_count  , (match_win.toss_win_count/mat_stad.match_count)*100  as stadim_team_win_perc from 
(select s.stadium_id,t.team_id, count(*) as match_count from ipl_match m join ipl_team t join ipl_match_schedule s on s.match_id=m.match_id
where (team_id1=t.team_id or team_id2=team_id) group by stadium_id,t.team_id order by team_id, stadium_id)  #no. of matched by each team in each stadium
as mat_stad 
join  
(select a.stadium_id,toss_winner_teamid, count(*) as toss_win_count	#no. of match wins
from ipl_match_schedule a 
inner join ipl_stadium b on a.stadium_id=b.stadium_id 
inner join ipl_match c on c.match_id=a.match_id 
inner join (select match_id, case 
when toss_winner =1 then team_id1
when toss_winner=2 then team_id2
end as toss_winner_teamid, 
case 
when match_winner =1 then team_id1
when match_winner=2 then team_id2
end as match_winner_id  from ipl_match) as match_winner  on a.match_id=match_winner.match_id and match_winner_id=toss_winner_teamid
group by stadium_id, toss_winner_teamid order by 1,2) as match_win 
on mat_stad.stadium_id=match_win.stadium_id and mat_stad.team_id=match_win.toss_winner_teamid;

#4	What is the total no. of bids placed on the team that has won highest no. of matches?

select match_winner_id, match_won, no_of_bids from 
(select  count(*) as match_won,
case 
when match_winner =1 then team_id1
when match_winner=2 then team_id2
end as match_winner_id  from ipl_match a 
inner join ipl_match_schedule b on a.match_id=b.match_id
group by match_winner_id
) as match_winner
join
(select bid_team,count(*) as no_of_bids from ipl_bidding_details group by bid_Team) as no_of_bids
on bid_team=match_winner_id order by match_won desc;

#5 identify the team which has the highest jump in its total points (in terms of percentage) from the previous year to current year.

SELECT ts1.team_id, t.team_name,((ts1.total_points-ts2.total_points)/ts2.total_points)*100 AS percentage_change_in_pts
FROM ipl_team_standings ts1 INNER JOIN ipl_team_standings ts2
INNER JOIN ipl_team t
ON t.team_id = ts1.team_id
WHERE ts2.tournmt_id != ts1.tournmt_id
AND ts1.team_id = ts2.team_id
ORDER BY percentage_change_in_pts DESC LIMIT 1;


