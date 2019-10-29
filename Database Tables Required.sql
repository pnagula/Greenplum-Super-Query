 -- people table to hold people information 
 
drop table if exists people;
create table people
(
id integer,
lastname varchar(50),
firstname varchar(50),
Description varchar(150)
);
 
insert into people values
(1,'Nagula','Pavan','Mr.Pavan is Sr.Data Scientist at Pivotal for past 1+ years and he hold a Masters in Computer science');
insert into people values
(2,'Cooper','Peter','Mr.Peter is a Sr.Director at Pivotal and he looks after data business at Pivotal');
insert into people values
(3,'Ng','Chang','Mr.Chang is Vice President at ABC Technologies for past 10 years');
insert into people values
(4,'Yew','Lee','Mr.Lee is Programmer at XYZ Technologies for past 3 years and he holds a Bachelors in Computer science');
insert into people values
(5,'Ng','Chan','Mr.Chan is a Data Engineer consultant who looks after data warehousing piece at ACB Tech');

 --create GPText index on the description text column

SELECT * FROM gptext.drop_index('gpadmin.public.people');

SELECT * FROM gptext.create_index('public', 'people', 'id', 'description', true);

SELECT * FROM gptext.index_status('gpadmin.public.people');

--populate index
SELECT * FROM gptext.index(TABLE(SELECT * FROM people), 'gpadmin.public.people');

SELECT * FROM gptext.commit_index('gpadmin.public.people');


 
--  links table to hold contacts between people
 
 drop table if exists links;
 create table links
 (
 src integer,
 dest integer
 );
 
 insert into links values
 (1,2);
 insert into links values
 (1,3);
 insert into links values
 (2,4);
 insert into links values
 (3,4);
 
 -- transactions table to hold people transaction information such as amount, timestamp, location
 
 drop table if exists transactions;
 create table transactions
 (
 transid integer,
 id integer,
 tran_date timestamp,
 Amount float,
 locid integer
 );
 
 truncate table transactions;
 insert into transactions values
 (1,1,TIMESTAMP '2018-05-03 10:00:00',400.00,1);
 
 insert into transactions values
 (2,2,TIMESTAMP '2018-05-02 13:00:00',250.00,2);
 
 insert into transactions values
 (3,3,TIMESTAMP '2018-05-03 08:00:00',153.00,2);
 
 insert into transactions values
 (4,4,TIMESTAMP '2018-04-30 18:00:00',1400.00,1);
 
 insert into transactions values
 (5,1,TIMESTAMP '2018-05-03 23:30:00',100.00,1);
 
 insert into transactions values
 (6,1,TIMESTAMP '2018-05-03 03:30:00',300.00,2);
 
 
 --location table to hold ATM location
 
 drop table if exists location;
 create table location
 (
 locid integer,
 Address varchar(100),
 lat float,
 lng float
 )
 ;
 truncate table location;
 insert into location values
 (1,'112 E Coast Rd, Singapore 428802',1.3051997,103.9050012);
 
 insert into location values
 (2,'239 E Coast Rd, Singapore 428931',1.3080176,103.9078435);
 
 insert into location values
 (3,'140 Robinson Rd, Singapore 068907',1.2784458,103.848261);