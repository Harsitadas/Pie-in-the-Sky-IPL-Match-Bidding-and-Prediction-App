  # 1. 1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage.
  
select bdr_dt.bidder_id 'Bidder ID', bdr_dt.bidder_name 'Bidder Name', 
(select count(*) from ipl_bidding_details bid_dt 
where bid_dt.bid_status = 'won' and bid_dt.bidder_id = bdr_dt.bidder_id) / 
(select no_of_bids from ipl_bidder_points bdr_pt 
where bdr_pt.bidder_id = bdr_dt.bidder_id)*100 as 'Percentage of Wins (%)'
from ipl_bidder_details bdr_dt order by 3 desc;

# 2. 2.	Display the number of matches conducted at each stadium with the stadium name and city.

select ipl_std.STADIUM_NAME, ipl_std.CITY, count(ipl_scl.STADIUM_ID) as Number_of_Matches from ipl_stadium ipl_std
join ipl_match_schedule ipl_scl
on ipl_std.STADIUM_ID = ipl_scl.STADIUM_ID
group by ipl_std.STADIUM_NAME, ipl_std.CITY
order by Number_of_Matches desc;

# 3. In a given stadium, what is the percentage of wins by a team which has won the toss?

select stadium_id 'Stadium ID', stadium_name 'Stadium Name',
(select count(*) from ipl_match m join ipl_match_schedule ms on m.match_id = ms.match_id
where ms.stadium_id = s.stadium_id and (toss_winner = match_winner)) /
(select count(*) from ipl_match_schedule ms where ms.stadium_id = s.stadium_id) * 100 
as 'Percentage of Wins by teams who won the toss (%)'
from ipl_stadium s;

#4. 4.	Show the total bids along with the bid team and team name.

select bdg.BID_TEAM,tea.TEAM_NAME,count(BID_TEAM) as Total_Bids
from ipl_team tea inner join ipl_bidding_details bdg
on tea.TEAM_ID=bdg.BID_TEAM
group by bdg.BID_TEAM,tea.TEAM_NAME
order by BID_TEAM;

# 5. Show the team id who won the match as per the win details.

select distinct(ipl_tm.TEAM_ID), ipl_mch.WIN_DETAILS 
from ipl_match ipl_mch join ipl_team ipl_tm
on ipl_mch.TEAM_ID2 = ipl_tm.TEAM_ID;

# 6. Display total matches played, total matches won and total matches lost by the team along with its team name.
 
 select mat.TEAM_ID1,tea.TEAM_NAME,count(MATCH_ID) as `Matches Played`,
sum(case when tea.TEAM_ID=mat.MATCH_WINNER then 1
else 0 end) as `Matches Won`,
sum(case when tea.TEAM_ID<>mat.MATCH_WINNER then 1
else 0 end) as `Matches Lost`
from ipl_match mat inner join ipl_team tea
on mat.TEAM_ID1=tea.TEAM_ID
group by mat.TEAM_ID1;

# 7.	Display the bowlers for the Mumbai Indians team.  

select ipl_ply.PLAYER_NAME,ipl_tm.PLAYER_ROLE,tea.team_name
from ipl_team_players ipl_tm 
join ipl_player ipl_ply
on ipl_tm.PLAYER_ID = ipl_ply.PLAYER_ID
join ipl_team tea
on tea.TEAM_ID = ipl_tm.TEAM_ID
where PLAYER_ROLE like '%Bowler%' and tea.REMARKS like '%MI';

# 8.	How many all-rounders are there in each team, Display the teams with more than 4 all-rounders in descending order.
select ipl_tm.TEAM_NAME,count(ipl_ply.PLAYER_ROLE) as More_than_4_all_rounders
from ipl_team_players ipl_ply 
join ipl_team ipl_tm
on ipl_ply.TEAM_ID = ipl_tm.TEAM_ID
where PLAYER_ROLE like '%All-Rounder%'
group by ipl_tm.TEAM_NAME
having count(ipl_ply.PLAYER_ROLE) > 4
order by More_than_4_all_rounders desc;

# 9. Write a query to get the total bidders points for each bidding status of those bidders who bid on CSK when it won the match in M. Chinnaswamy Stadium bidding year-wise.
#    Note the total bidders’ points in descending order and the year is bidding year.
#    Display columns: bidding status, bid date as year, total bidder’s points


select bid_det.BID_STATUS,year(bid_det.BID_DATE) as Year,bid_pt.TOTAL_POINTS as 'total bidder’s points' 
from ipl_bidding_details bid_det join ipl_bidder_points bid_pt
on bid_det.BIDDER_ID = bid_pt.BIDDER_ID
join ipl_match_schedule mat_sc
on mat_sc.SCHEDULE_ID = bid_det.SCHEDULE_ID
join ipl_stadium ipl_stad
on ipl_stad.STADIUM_ID = mat_sc.STADIUM_ID
join ipl_match mat
on mat.MATCH_ID = mat_sc.MATCH_ID
join ipl_team tea
on tea.TEAM_ID = mat.TEAM_ID1
where STADIUM_NAME like '%M. Chinnaswamy Stadium%' and tea.REMARKS like '%CSK%' and mat.TEAM_ID1 = mat.MATCH_WINNER;

# 10.	Extract the Bowlers and All Rounders those are in the 5 highest number of wickets.
# Note 
# 1. use the performance_dtls column from ipl_player to get the total number of wickets
# 2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
# 3. Do not use joins in any cases.
# 4. Display the following columns teamn_name, player_name, and player_role.

SELECT Team_name,Player_name,Player_role FROM 
(SELECT 
ipl_player.PLAYER_ID,
PLAYER_NAME, 
DENSE_RANK() OVER(ORDER BY CAST(TRIM(BOTH ' ' FROM substring_index(SUBSTRING_INDEX(PERFORMANCE_DTLS,'Dot',1),'Wkt-',-1))
AS SIGNED INT) DESC ) AS WICKET_RANK,
PLAYER_ROLE,
Team_name
FROM
 ipl_player,ipl_team_players,ipl_team
where 
 ipl_player.PLAYER_ID=ipl_team_players.PLAYER_ID  and ipl_team.TEAM_ID=ipl_team_players.TEAM_ID
and 
 PLAYER_ROLE in ('Bowler','All-Rounder'))T
where WICKET_RANK<=5;
select * from ipl_player;

#11. show the percentage of toss wins of each bidder and display the results in descending order based on the percentage

select bdr.BIDDER_ID, bdr.BIDDER_NAME,
count(if((mat.TEAM_ID1=bdg.BID_TEAM and mat.TOSS_WINNER=1) or
(mat.TEAM_ID2=bdg.BID_TEAM and mat.TOSS_WINNER=2),1,null))/count(*)*100 as Toss_Win_Percentage
from ipl_match mat inner join ipl_match_schedule schd
on mat.MATCH_ID=schd.MATCH_ID
inner join ipl_bidding_details bdg
on schd.SCHEDULE_ID =bdg.SCHEDULE_ID
inner join ipl_bidder_details bdr
on bdg.BIDDER_ID=bdr.BIDDER_ID
inner join ipl_bidder_points pts
on bdr.BIDDER_ID=pts.BIDDER_ID
group by bdr.BIDDER_ID,bdr.BIDDER_NAME
order by Toss_Win_Percentage desc;

#12.find the IPL season which has min duration and max duration.
#   Output columns should be like the below:
#   Tournment_ID, Tourment_name, Duration column, Duration

with ipl as (SELECT Tournmt_ID, Tournmt_name,
DATEDIFF(TO_DATE, FROM_DATE) AS Duration,
CASE
WHEN DATEDIFF(TO_DATE, FROM_DATE) = (SELECT MAX(DATEDIFF(TO_DATE, FROM_DATE) ) FROM IPL_Tournament) THEN 'Max_duration'
WHEN DATEDIFF(TO_DATE, FROM_DATE) = (SELECT MIN(DATEDIFF(TO_DATE, FROM_DATE) ) FROM IPL_Tournament) THEN 'Min_duration'
END AS Duration_Column
FROM IPL_Tournament)
SELECT * FROM ipl
WHERE
Duration_Column IS NOT NULL;

#13.	Write a query to display to calculate the total points month-wise for the 2017 bid year. sort the results based on total points in descending order and month-wise in ascending order.
# Note: Display the following columns:
# 1.	Bidder ID, 2. Bidder Name, 3. bid date as Year, 4. bid date as Month, 5. Total points
# Only use joins for the above query queries.

select distinct(bdr.BIDDER_ID),bdr.BIDDER_NAME,year(bdg.BID_DATE) as Year,month(bdg.BID_DATE) as Month,pts.TOTAL_POINTS as Total_Points
from ipl_bidder_details bdr inner join ipl_bidder_points pts
on bdr.BIDDER_ID=pts.BIDDER_ID 
inner join ipl_bidding_details bdg
on pts.BIDDER_ID=bdg.BIDDER_ID
where year(bdg.BID_DATE)=2017
order by Total_Points desc,Month asc ;

#14.	Write a query for the above question using sub queries by having the same constraints as the above question.

select bidder_id, (select bidder_name from ipl_bidder_details where ipl_bidder_details.bidder_id=ipl_bidding_details.bidder_id) as bidder_name,
year(bid_date) as `year`, monthname(bid_date) as `month`, 
(select total_points from ipl_bidder_points where ipl_bidder_points.bidder_id=ipl_bidding_details.bidder_id)
 as total_points from ipl_bidding_details
where year(bid_date)=2017
group by bidder_id,bidder_name,year,month,total_points
order by total_points desc;

#15. Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
#    Output columns should be like:
#    Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, Lowest_3_Bidders  --> columns contains name of bidder;

select * from
(select pts.BIDDER_ID,pts.TOTAL_POINTS,
dense_rank() over(order by pts.TOTAL_POINTS desc) as Ranks,bdr.BIDDER_NAME,'Highest_3_Bidders' as 'Highest/Lowest_3_Bidders'
from  ipl_bidder_points pts inner join ipl_bidder_details bdr
on pts.BIDDER_ID=bdr.BIDDER_ID) temp
where Ranks<4 
union all
(select * from
(select pts.BIDDER_ID,pts.TOTAL_POINTS,
rank() over(order by pts.TOTAL_POINTS ) as Ranks2,bdr.BIDDER_NAME,'Lowest_3_Bidders'
from  ipl_bidder_points pts inner join ipl_bidder_details bdr
on pts.BIDDER_ID=bdr.BIDDER_ID)temp2
where Ranks2<4);

# 16.	Create two tables called Student_details and Student_details_backup.

# Table 1: Attributes 		                     # Table 2: Attributes
# Student id, Student name, mail id, mobile no.	 # Student id, student name, mail id, mobile no.

create table Student_details(
Student_id int primary key,
Student_name varchar(50),
mail_id varchar(50),
mobile_no varchar(10)
);

insert into Student_details values
(123,"Harsita","harsitadas418@gmail.com","7381139648"),
(124,"chirashree","chirad123@gmail.com","6371688929"),
(125,"reema","reema23@gmail.com","7890234567");

create table Student_details_backup(
Student_id int primary key,
Student_name varchar(50),
mail_id varchar(50),
mobile_no varchar(10)
);

CREATE TRIGGER after_student_update
AFTER UPDATE ON Student_details
FOR EACH ROW

    UPDATE Student_details_backup
    SET Student_name = NEW.Student_name,
        mail_id = NEW.mail_id,
        mobile_no=NEW.mobile_no
    WHERE Student_id = NEW.Student_id;
        
insert into Student_details_backup values
(123,"Harsita","harsitadas418@gmail.com","7381139648"),
(124,"chirashree","chirad123@gmail.com","6371688929"),
(125,"reema","reema23@gmail.com","7890234567");

update Student_details
set mobile_no="6370836404"
where Student_id=123;

select * from student_details_backup;