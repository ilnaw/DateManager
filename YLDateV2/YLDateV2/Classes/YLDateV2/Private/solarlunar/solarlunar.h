#ifndef SOLAR_LUNAR_DATE
#define SOLAR_LUNAR_DATE

/***********************************
 Author:: luodongshui
 began date: 2007/9/19 
 Name: solar and lunar calendar date library.
 Copyright: anyone.
 lasted update Date: 2007-9-28 20:39:04
 Description: a solar and lunar calendar date library and convert solar date to lunar date Vice versa.
*************************************/
 
 /**************************************
 1. solar calendar interface:
 
 date range: any date.....
        
 functions for solar calendar date: 
 1. initialize a solar calendar date. *
 2. get the year of a solar calendar date. * 
 3. get the month of a solar calendar date.  *
 4. get the day of a solar calendar date. *
 5. judge a year is leap year or not. *
 6. get the weeks day associate with a solar calendar date. *
 7. get the days of a month of a year. *
 8. SOLAR CALENDAR VARIABLE can support the internal operation +(n),-,<,>,<=,>=,==,=.    
*************************************/

/***********************************
 2. lunar calendar interfece:
 
 date range: from 1899.1.1 to 2099.12.30
 
 functions for lunar calendar date: 
 1. initialize a lunar calendar date.
 2. get the year of a lunar calendar date.
 3. get the month of a lunar calendar date.
 4. get the day of a lunar calendar date.
 5. get the days of a month of a year.
 6. get the days of a leap month of a year.
 7. get the weeks day associate with a lunar calendar date.
 8. get the leap month of a year.
 9. LUNAR CALENDAR VARIABLE can support the internal operation +,-,<,>,<=,>=,==,=.
******************************************/

/*******************************************  
 practical functions:
        
 1. convert solar calendar date to lunar calendar date.
 2. convert lunar calendar date to solar calendar date.
*******************************************/

typedef enum boolean { bfalse=0, btrue=1} boolean; 
typedef enum weeks {monday = 1, tuesday, wednesday, thurday, friday, saturday, sunday} weeks;

/* for solar calendar  date */
typedef long solar_calendar;

solar_calendar solar_creat_date(const int year, const unsigned int month, const unsigned int day);

int solar_get_year(const solar_calendar solar_date);
unsigned int solar_get_month(const solar_calendar solar_date);
unsigned int solar_get_day(const solar_calendar solar_date);

boolean is_leap_year(const int year);
unsigned int solar_get_days(const int year, unsigned int month);

weeks solar_weeks_day(const solar_calendar solar_date);



/* for lunar calendar  date */
typedef long lunar_calendar;

lunar_calendar lunar_creat_date(const int year, const int month, const int day);

unsigned int lunar_get_year(const lunar_calendar lunar_date);
unsigned int lunar_get_month(const lunar_calendar lunar_date);
unsigned int lunar_get_day(const lunar_calendar lunar_date);

unsigned int lunar_get_days(const int year, unsigned int month);
unsigned int lunar_leap_days(const int year);
int lunar_leap_month(const int year);

weeks lunar_weeks_day(const lunar_calendar lunar_date);

/* practical function */
lunar_calendar solar2lunar(const solar_calendar sc);
solar_calendar lunar2solar(const lunar_calendar lu);

int monthInfo(int year,int month,boolean isLeapMonth);

#endif








