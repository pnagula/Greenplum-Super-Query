-- list of software packages required 

  -- Greenplum PostGIS Extension
  -- Greenplum Fuzzy String Match Extension
  -- MADlib
  -- GPText


drop table if exists results;
create table results 
(id integer,
firstname varchar(50),
lastname varchar(50),
amount float,
tran_date timestamp,
lat float,
lng float,
address varchar(100),
description varchar(150),
score float
);

drop function if exists get_people(text,text,integer,integer,float,float);
CREATE FUNCTION get_people(text,text,integer,integer,float,float) RETURNS integer
AS $$
declare 
linkchk integer;
v1 record;
v2 record;
begin
-- truncate results table

 execute 'truncate table results;';

-- loop thru people sounds like first parameter person and meet all search criteria (eg:- amount > 200, time < 24, distance between reference location and ATM location < 2 KM) 
 

 for v1 in select distinct a.id,a.firstname,a.lastname,amount,tran_date,c.lat,c.lng,address,a.description,d.score from 
    people a,transactions b,location c,

    --GPText.search() function is used to know if people work at Pivotal

    (SELECT w.id, q.score
     FROM people w,
     gptext.search(TABLE(SELECT 1 SCATTER BY 1), 'gpadmin.public.people' , 'Pivotal', null) q
     WHERE (q.id::integer) = w.id order by 2 desc) d
    
     --GPDB Fuzzy String Match SoundEx() function is used to know if people name sounds like argument 1 
    
     where soundex(firstname)=soundex($1) and a.id=b.id and amount > $3 and (extract(epoch from tran_date) - extract(epoch from now()))/3600 < $4 
   
     --PostGIS st_distance_sphere() and st_makepoint() are used to calculate distance between reference lat,longs and database lat,longs
    
     and st_distance_sphere(st_makepoint($5, $6),st_makepoint(c.lng, c.lat))/1000.0 <= 2.0 and b.locid=c.locid and a.id=d.id
 loop

-- loop thru people sounds like second parameter person and meet all search criteria (eg:- amount > 200, time < 24, distance between reference location and ATM location < 2 KM) 

   for v2 in select distinct a.id,a.firstname,a.lastname,amount,tran_date,c.lat,c.lng,address,a.description,d.score
    from people a,transactions b,location c,

    --GPText.search() function is used to know if people work at Pivotal

    (SELECT w.id, q.score
     FROM people w,
     gptext.search(TABLE(SELECT 1 SCATTER BY 1), 'gpadmin.public.people' , 'Pivotal', null) q
     WHERE (q.id::integer) = w.id order by 2 desc) d
    
    --GPDB Fuzzy String Match SoundEx() function is used to know if people name sounds like argument 2
    
    where soundex(firstname)=soundex($2) and a.id=b.id and amount > $3  and  (extract(epoch from tran_date) - extract(epoch from now()))/3600 < $4 
    
    --PostGIS st_distance_sphere() and st_makepoint() are used to calculate distance between reference lat,longs and database lat,longs
    
    and st_distance_sphere(st_makepoint($5, $6),st_makepoint(c.lng, c.lat))/1000.0 <= 2.0 and b.locid=c.locid and a.id=d.id
 loop

   -- check to see if they have direct link between them 
   
   --MADlib Graph Breadth First Search is used to know if the people have direct link, BFS allows to change query for indirect links as well.
   
      execute 'DROP TABLE IF EXISTS out, out_summary;';
      execute  'SELECT madlib.graph_bfs(
                         ''people'',      -- Vertex table
                         ''id'',          -- Vertix id column (NULL means use default naming)
                         ''links'',        -- Edge table
                         NULL,'          
                         ||v1.id||',             -- Source vertex for BFS
                         ''out'');'  ;       
       select 1 into linkchk from out where dist=1 and id=v2.id;

   -- if they have direct link then we got people with all search criteria and direct link between them, so insert into results table
       if linkchk is not null  then
          insert into results values (v1.id,v1.firstname,v1.lastname,v1.amount,v1.tran_date,v1.lat,v1.lng,v1.address,v1.description,v1.score);
          insert into results values (v2.id,v2.firstname,v2.lastname,v2.amount,v2.tran_date,v2.lat,v2.lng,v2.address,v2.description,v2.score);
      end if;
    end loop;
 end loop;
 return 0;
end
$$ LANGUAGE plpgsql;

-- run the function to see results
	--	  person1 , person 2, amount, duration in hours, longtitude, latitude (in question)
select get_people('Pavan','Peter',200,24,103.912680, 1.309432) ;