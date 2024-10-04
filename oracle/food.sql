
remark we create the table. you can have any table name here like create table table. Make sure to add the parentheses so the general structure is create table table_name
CREATE TABLE food (
/*we have the primary key UUID*/
    food_id RAW(16) DEFAULT sys_guid() PRIMARY KEY,
--because there is a unique constraint on food, the max length is 1000. That's why we can't make food 4000.
    food varchar2(1000) not null,
    CONSTRAINT unique_food UNIQUE ( food ),
    date_eaten timestamp(9) with time zone default systimestamp(9)/*date_eaten could be null if we actually do not know the date we ate some food, unlike date_created
    which has a not null constraint and is not nullable.*/,
/* we add note if there is something special about that record, for example, if I had to choose between undergraduate and graduate in note I could put I'm in accelerated masters degree. or if it only had */
/* freshman sophomore junior senior I could add in note that I'm a fifth year student. Or if there was only first middle last and someone had 2 middle names, they could put this in note.*/
/*we want to add an additional column date_eated. date_eated/date_read. This would be slighly different from date_created, because a record could have been added after the fact but 
we eaten earlier, read earlier. food eaten, bible read, book read. So for example, maybe I entered it on 2024-10-03 but ate the food on 2024-09-01. The default is there because you're probably
entering it as you go, but there is a significant semantic difference between when the record/row became part of the table, and when the thing it represents happened/was done/became a thing.
*/    -- Additional columns for note and dates
    note                       VARCHAR2(4000),  -- General-purpose note field
/* date_created is helpful for establishing when the record was created. note that we use a timestamp, which includes a date and time. Also note that we include a time zone. MySQL does not support time zones.*/
/* also note that we use as the default systimestamp which will give the current date time.*/
/* also note that we use 9. 9 is for nanoseconds. 0 is for seconds s, 3 for milliseconds ms, 6 for microseconds ?s, 9 for nanoseconds ns.*/
/* we can make date_created not null because it has a default value so the person doesn't have to enter it.*/
    date_created               TIMESTAMP(9) WITH TIME ZONE DEFAULT systimestamp(9) NOT NULL,
/* date_updated is not the same as date_created. You could have it so date_updated defaults to date_created, too, but instead I store this in a virtual column. If date_updated is null, that means that record*/
/* has not been updated. date_updated could also be called date_modified. So for each record we store when it was created and when it was last modified.*/
    date_updated               TIMESTAMP(9) WITH TIME ZONE,
        date_created_or_updated    TIMESTAMP(9) WITH TIME ZONE GENERATED ALWAYS AS ( coalesce(date_updated, date_created) ) VIRTUAL
);

/* we create a trigger so date_updated is set when the record is updated. I'm not sure if we need to enable insert as well, like if have a record say 1, null, 3, and we insert 2 into null, would date_updated be fired.
 or would it only count if we updated 1 to 2 or 3 to 4? I'm not sure. in that case, we might need before update or insert on food.*/
CREATE OR REPLACE TRIGGER trigger_set_date_updated_food
BEFORE UPDATE ON food
FOR EACH ROW
BEGIN
/* you should not do :NEW.date_updated := systimestamp(9). That will throw an error and not work. This is only in a trigger. you can use systimestamp(9) in the table (see above).*/
    :NEW.date_updated := systimestamp;
END;
/