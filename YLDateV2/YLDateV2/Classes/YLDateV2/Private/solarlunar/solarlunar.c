#import "solarlunar.h"

#define LEAP(year) ( ((year%400 == 0) || (year%4 == 0 && year%100 != 0)) ? 1:0 ) 
#define ABS(num) ( (num) < 0 ? (-(num)):(num) )
#define PRINT(i) printf("%d\n", (i))

/**************************
 for solar calendar  date 
**************************/
/********************************
solar calendar format:
    In internal show: solar calendar date -1.12.31 is -1L, and 1.1.1 is 0L.
    and other date adds 1 or minus 1 one by one, as follows:
    ..., -n,-n+1,...,-1,0,1,...,n... 
    why choose such format, the main reason is that SOLAR CALENDAR VARIABLE can support 
        the internal operation +,-,<,>,<=,>=,==.  
*********************************/
    
static unsigned int solar_month[12]={31,28,31,30,31,30,31,31,30,31,30,31}; 
static unsigned int reverse_solar_month[12]={31,30,31,30,31,31,30,31,30,31,28,31}; 

solar_calendar solar_creat_date(const int year, const unsigned int month, const unsigned int day)
{
    solar_calendar so = 0L; /*attention 0L is 1.1.1, -1L is -1.12.31 */
    unsigned int days = 0;
    int i, absyear;
    
    /* input checking... */
    if( year == 0 ||     /* In solar calendar, there is no Year 0 */
        (month < 1) || (month > 12) ||
        (day < 1) || (day > 31) ) {
        return 1L;
    }
    
    absyear = ABS(year);
    so += (absyear-1)*365;
    for(i = 1; i < absyear; i++) {
        if(LEAP(i))
            so++;
    }
    
    for(i = 1; i < month; i++) {
        days += solar_month[i-1];
    }
   
    if(month >2 && LEAP(absyear))
        days++;
    
    days += day;
    year > 0 ? (so += days) : (so = -( so + (365+LEAP(absyear)-days+1) ));
    
    /* attention: 0L is 1.1.1, all solar more than zero reduce 1. */
    return so > 0 ? so-1 : so ;
}  
              
int solar_get_year(const solar_calendar solar_date)
{
    int year = 1;
    solar_calendar temp;
    temp = (solar_date >= 0) ? solar_date+1 : ABS(solar_date);
                 
    //error: year = solar_date /365.         
    while(temp > (365u + LEAP(year))) {
        temp -= (365u + LEAP(year));
        year++;
    }
        
    return solar_date >= 0 ? year : -year;
}

unsigned int solar_get_month(const solar_calendar solar_date)
{
    int year = 1;
    unsigned int month = 1u;
    unsigned int *month_day;
    solar_calendar temp;
    temp = (solar_date >= 0) ? solar_date+1 : ABS(solar_date);
             
    while(temp > (365u + LEAP(year))) {
        temp -= (365u + LEAP(year));
        year++;
    }
    
    month_day = solar_date > 0 ? solar_month : reverse_solar_month;

    if(LEAP(year))
        solar_date >= 0 ? (month_day[1] = 29) : (month_day[10] = 29);
    while(temp > month_day[month-1]) {
        temp -= month_day[month-1];
        month++;
    }
    
    solar_date >= 0 ? (month_day[1] = 28) : (month_day[10] = 28);
        
    return solar_date >= 0 ? month : 13-month;

}
        
unsigned int solar_get_day(const solar_calendar solar_date)
{
    int year = 1;
    unsigned int month = 1u;
    unsigned int *month_day;
    solar_calendar temp;
    temp = (solar_date >= 0) ? solar_date+1 : ABS(solar_date);

    while(temp > (365u + LEAP(year))) {
        temp -= (365u + LEAP(year));
        year++;
    }
    
    month_day = (solar_date >= 0 ? solar_month : reverse_solar_month);

    if(LEAP(year))
        solar_date >= 0 ? (month_day[1] = 29) : (month_day[10] = 29);
    while(temp > month_day[month-1]) {
        temp -= month_day[month-1];
        month++;
    }
    
    if(solar_date < 0)
        temp = month_day[month-1]-temp+1;
    solar_date >= 0 ? (month_day[1] = 28) : (month_day[10] = 28);
    
    return (unsigned int)temp;
}

unsigned int solar_get_days(const int year, unsigned int month)
{
    return solar_month[month-1] + ( month == 2 ? LEAP(ABS(year)) : 0 );
}

weeks solar_weeks_day(const solar_calendar solar_date)
{
    /* 1900/1/1 is monday. */
    return solar_date >= 0 ?
            (weeks)(solar_date%7 + 1) :
            (weeks)(8 - ((ABS(solar_date)-1)%7 + 1));
}


boolean is_leap_year(const int year)
{
    return LEAP(ABS(year));
}






/**************************
for lunar calendar date.
**************************/
/********************************
lunar calendar format:
    base date: 1899.12.1 (in solar calendar date: 1900.1.1).
    top date:  2099.12.30
    
	In internal show: lunar calendar date 1899.12.1 is 1L.
    and other date adds 1 one by one, as follows:
    1,...,n... 
    why choose such format, the main reason is that SOLAR CALENDAR VARIABLE can support 
        the internal operation +,-,<,>,<=,>=,==.  
*********************************/  

static struct { unsigned int year;
                unsigned int leap_month; /* leap month(0 for no) */
                unsigned int month[13];  /*days in month(0: 29days,1:30days, incude leap month) */
            }lunar_table[] = {         
                1900, 8,0,1,0,0,1,0,1,1,0,1,1,0,1,
                1901, 0,0,1,0,0,1,0,1,0,1,1,1,0,0,
                1902, 0,1,0,1,0,0,1,0,1,0,1,1,1,0,
                1903, 5,0,1,0,1,0,0,1,0,0,1,1,0,1,
                1904, 0,1,1,0,1,0,0,1,0,0,1,1,0,0,
                1905, 0,1,1,0,1,1,0,0,1,0,1,0,1,0,
                1906, 4,0,1,1,0,1,0,1,0,1,0,1,0,1,
                1907, 0,0,1,0,1,0,1,1,0,1,0,1,0,0,
                1908, 0,1,0,0,1,1,0,1,0,1,1,0,1,0,
                1909, 2,0,1,0,0,1,0,1,0,1,1,1,0,1,
                1910, 0,0,1,0,0,1,0,1,0,1,1,1,0,0,
                1911, 6,1,0,1,0,0,1,0,0,1,1,0,1,1,
                1912, 0,1,0,1,0,0,1,0,0,1,1,0,1,0,
                1913, 0,1,1,0,1,0,0,1,0,0,1,0,1,0,
                1914, 5,1,1,0,1,0,1,0,1,0,0,1,0,1,
                1915, 0,1,0,1,1,0,1,0,1,0,1,0,0,0,
                1916, 0,1,1,0,1,0,1,1,0,1,0,1,0,0,
                1917, 2,1,0,0,1,0,1,1,0,1,1,0,1,0,
                1918, 0,1,0,0,1,0,1,0,1,1,0,1,1,0,
                1919, 7,0,1,0,0,1,0,0,1,1,0,1,1,1,
                1920, 0,0,1,0,0,1,0,0,1,0,1,1,1,0,
                1921, 0,1,0,1,0,0,1,0,0,1,0,1,1,0,
                1922, 5,1,0,1,1,0,0,1,0,0,1,0,1,1,
                1923, 0,0,1,1,0,1,0,1,0,0,1,0,1,0,
                1924, 0,0,1,1,0,1,1,0,1,0,1,0,0,0,
                1925, 4,1,0,1,0,1,1,0,1,1,0,1,0,1,
                1926, 0,0,0,1,0,1,0,1,1,0,1,1,0,0,
                1927, 0,1,0,0,1,0,1,0,1,0,1,1,1,0,
                1928, 2,0,1,0,0,1,0,0,1,0,1,1,1,1,
                1929, 0,0,1,0,0,1,0,0,1,0,1,1,1,0,
                1930, 6,0,1,1,0,0,1,0,0,1,0,1,1,0,
                1931, 0,1,1,0,1,0,1,0,0,1,0,1,0,0,
                1932, 0,1,1,1,0,1,0,1,0,0,1,0,1,0,
                1933, 5,0,1,1,0,1,1,0,1,0,1,0,0,1,
                1934, 0,0,1,0,1,1,0,1,0,1,1,0,1,0,
                1935, 0,0,0,1,0,1,0,1,1,0,1,1,0,0,
                1936, 3,1,0,0,1,0,0,1,1,0,1,1,1,0,
                1937, 0,1,0,0,1,0,0,1,0,1,1,1,0,0,
                1938, 7,1,1,0,0,1,0,0,1,0,1,1,0,1,
                1939, 0,1,1,0,0,1,0,0,1,0,1,0,1,0,
                1940, 0,1,1,0,1,0,1,0,0,1,0,1,0,0,
                1941, 6,1,1,0,1,1,0,1,0,0,1,0,1,0,
                1942, 0,1,0,1,1,0,1,0,1,0,1,0,1,0,
                1943, 0,0,1,0,1,0,1,1,0,1,0,1,0,0,
                1944, 4,1,0,1,0,1,0,1,0,1,1,0,1,1,
                1945, 0,0,0,1,0,0,1,0,1,1,1,0,1,0,
                1946, 0,1,0,0,1,0,0,1,0,1,1,0,1,0,
                1947, 2,1,1,0,0,1,0,0,1,0,1,0,1,1,
                1948, 0,1,0,1,0,1,0,0,1,0,1,0,1,0,
                1949, 7,1,0,1,1,0,1,0,0,1,0,1,0,1,
                1950, 0,0,1,1,0,1,1,0,0,1,0,1,0,0,
                1951, 0,1,0,1,1,0,1,0,1,0,1,0,1,0,
                1952, 5,0,1,0,1,0,1,0,1,1,0,1,0,1,
                1953, 0,0,1,0,0,1,1,0,1,1,0,1,0,0,
                1954, 0,1,0,1,0,0,1,0,1,1,0,1,1,0,
                1955, 3,0,1,0,1,0,0,1,0,1,0,1,1,1,
                1956, 0,0,1,0,1,0,0,1,0,1,0,1,1,0,
                1957, 8,1,0,1,0,1,0,0,1,0,1,0,1,0,
                1958, 0,1,1,1,0,1,0,0,1,0,1,0,1,0,
                1959, 0,0,1,1,0,1,0,1,0,1,0,1,0,0,
                1960, 6,1,0,1,0,1,1,0,1,0,1,0,1,0,
                1961, 0,1,0,1,0,1,0,1,1,0,1,0,1,0,
                1962, 0,0,1,0,0,1,0,1,1,0,1,1,0,0,
                1963, 4,1,0,1,0,0,1,0,1,0,1,1,1,0,
                1964, 0,1,0,1,0,0,1,0,1,0,1,1,1,0,
                1965, 0,0,1,0,1,0,0,1,0,0,1,1,0,0,
                1966, 3,1,1,1,0,1,0,0,1,0,0,1,1,0,
                1967, 0,1,1,0,1,1,0,0,1,0,1,0,1,0,
                1968, 7,0,1,0,1,1,0,1,0,1,0,1,0,1,
                1969, 0,0,1,0,1,0,1,1,0,1,0,1,0,0,
                1970, 0,1,0,0,1,0,1,1,0,1,1,0,1,0,
                1971, 5,0,1,0,0,1,0,1,0,1,1,1,0,1,
                1972, 0,0,1,0,0,1,0,1,0,1,1,0,1,0,
                1973, 0,1,0,1,0,0,1,0,0,1,1,0,1,0,
                1974, 4,1,1,0,1,0,0,1,0,0,1,1,0,1,
                1975, 0,1,1,0,1,0,0,1,0,0,1,0,1,0,
                1976, 8,1,1,0,1,0,1,0,1,0,0,1,0,1,
                1977, 0,1,0,1,1,0,1,0,1,0,1,0,0,0,
                1978, 0,1,0,1,1,0,1,1,0,1,0,1,0,0,
                1979, 6,1,0,0,1,0,1,1,0,1,1,0,1,0,
                1980, 0,1,0,0,1,0,1,0,1,1,0,1,1,0,
                1981, 0,0,1,0,0,1,0,0,1,1,0,1,1,0,
                1982, 4,1,0,1,0,0,1,0,0,1,0,1,1,1,
                1983, 0,1,0,1,0,0,1,0,0,1,0,1,1,0,
                1984, 10,1,0,1,1,0,0,1,0,0,1,0,1,1,
                1985, 0,0,1,1,0,1,0,1,0,0,1,0,1,0,
                1986, 0,0,1,1,0,1,1,0,1,0,1,0,0,0,
                1987, 6,1,0,1,0,1,1,0,1,1,0,1,0,0,
                1988, 0,1,0,1,0,1,0,1,1,0,1,1,0,0,
                1989, 0,1,0,0,1,0,1,0,1,0,1,1,1,0,
                1990, 5,0,1,0,0,1,0,0,1,0,1,1,1,1,
                1991, 0,0,1,0,0,1,0,0,1,0,1,1,1,0,
                1992, 0,0,1,1,0,0,1,0,0,1,0,1,1,0,
                1993, 3,0,1,1,0,1,0,1,0,0,1,0,1,0,
                1994, 0,1,1,1,0,1,0,1,0,0,1,0,1,0,
                1995, 8,0,1,1,0,1,0,1,1,0,0,1,0,1,
                1996, 0,0,1,0,1,1,0,1,0,1,1,0,0,0,
                1997, 0,1,0,1,0,1,0,1,1,0,1,1,0,0,
                1998, 5,1,0,0,1,0,0,1,1,0,1,1,0,1,
                1999, 0,1,0,0,1,0,0,1,0,1,1,1,0,0,
                2000, 0,1,1,0,0,1,0,0,1,0,1,1,0,0,
                2001, 4,1,1,0,1,0,1,0,0,1,0,1,0,1,
                2002, 0,1,1,0,1,0,1,0,0,1,0,1,0,0,
                2003, 0,1,1,0,1,1,0,1,0,0,1,0,1,0,
                2004, 2,0,1,0,1,1,0,1,0,1,0,1,0,1,
                2005, 0,0,1,0,1,0,1,1,0,1,0,1,0,0,
                2006, 7,1,0,1,0,1,0,1,0,1,1,0,1,1,
                2007, 0,0,0,1,0,0,1,0,1,1,1,0,1,0,
                2008, 0,1,0,0,1,0,0,1,0,1,1,0,1,0,
                2009, 5,1,1,0,0,1,0,0,1,0,1,0,1,1,
                2010, 0,1,0,1,0,1,0,0,1,0,1,0,1,0,
                2011, 0,1,0,1,1,0,1,0,0,1,0,1,0,0,
                2012, 4,1,0,1,1,0,1,0,1,0,1,0,1,0,
                2013, 0,1,0,1,0,1,1,0,1,0,1,0,1,0,
                2014, 9,0,1,0,1,0,1,0,1,1,0,1,0,1,
                2015, 0,0,1,0,0,1,0,1,1,1,0,1,0,0,
                2016, 0,1,0,1,0,0,1,0,1,1,0,1,1,0,
                2017, 6,0,1,0,1,0,0,1,0,1,0,1,1,1,
                2018, 0,0,1,0,1,0,0,1,0,1,0,1,1,0,
                2019, 0,1,0,1,0,1,0,0,1,0,0,1,1,0,
                2020, 4,0,1,1,1,0,1,0,0,1,0,1,0,1,
                2021, 0,0,1,1,0,1,0,1,0,1,0,1,0,0,
                2022, 0,1,0,1,0,1,1,0,1,0,1,0,1,0,
                2023, 2,0,1,0,0,1,1,0,1,1,0,1,0,1,
                2024, 0,0,1,0,0,1,0,1,1,0,1,1,0,0,
                2025, 6,1,0,1,0,0,1,0,1,0,1,1,1,0,
                2026, 0,1,0,1,0,0,1,0,0,1,1,1,0,0,
                2027, 0,1,1,0,1,0,0,1,0,0,1,1,0,0,
                2028, 5,1,1,1,0,1,0,0,1,0,0,1,1,0,
                2029, 0,1,1,0,1,0,1,0,1,0,0,1,1,0,
                2030, 0,0,1,0,1,1,0,1,0,1,0,1,0,0,
                2031, 3,0,1,1,0,1,0,1,1,0,1,0,1,0,
                2032, 0,1,0,0,1,0,1,1,0,1,1,0,1,0,
                2033, 11,0,1,0,0,1,0,1,0,1,1,1,0,1,
                2034, 0,0,1,0,0,1,0,1,0,1,1,0,1,0,
                2035, 0,1,0,1,0,0,1,0,0,1,1,0,1,0,
                2036, 6,1,1,0,1,0,0,1,0,0,1,0,1,1,
                2037, 0,1,1,0,1,0,0,1,0,0,1,0,1,0,
                2038, 0,1,1,0,1,0,1,0,1,0,0,1,0,0,
                2039, 5,1,1,0,1,1,0,1,0,1,0,1,0,0,
                2040, 0,1,0,1,1,0,1,0,1,1,0,1,0,0,
                2041, 0,0,1,0,1,0,1,1,0,1,1,0,1,0,
                2042, 2,0,1,0,0,1,0,1,0,1,1,0,1,1,
                2043, 0,0,1,0,0,1,0,0,1,1,0,1,1,0,
                2044, 7,1,0,1,0,0,1,0,0,1,0,1,1,1,
                2045, 0,1,0,1,0,0,1,0,0,1,0,1,1,0,
                2046, 0,1,0,1,0,1,0,1,0,0,1,0,1,0,
                2047, 5,1,0,1,1,0,1,0,1,0,0,1,0,1,
                2048, 0,0,1,1,0,1,1,0,1,0,0,1,0,0,
                2049, 0,1,0,1,0,1,1,0,1,1,0,1,0,0,
                2050, 3,0,1,0,1,0,1,0,1,1,0,1,1,0,
                2051, 0,1,0,0,1,0,0,1,1,0,1,1,1,0,
                2052, 8,0,1,0,0,1,0,0,1,0,1,1,1,1,
                2053, 0,0,1,0,0,1,0,0,1,0,1,1,1,0,
                2054, 0,0,1,1,0,0,1,0,0,1,0,1,1,0,
                2055, 6,0,1,1,0,1,0,1,0,0,1,0,1,0,
                2056, 0,1,1,1,0,1,0,1,0,0,1,0,1,0,
                2057, 0,0,1,1,0,1,0,1,1,0,0,1,0,0,
                2058, 4,1,0,1,0,1,0,1,1,0,1,1,0,0,
                2059, 0,1,0,1,0,1,0,1,0,1,1,1,0,0,
                2060, 0,1,0,0,1,0,0,1,0,1,1,1,0,0,
                2061, 3,1,1,0,0,1,0,0,1,0,1,1,1,0,
                2062, 0,1,1,0,0,1,0,0,1,0,1,1,0,0,
                2063, 7,1,1,0,1,0,1,0,0,1,0,1,0,1,
                2064, 0,1,1,0,1,0,1,0,0,1,0,1,0,0,
                2065, 0,1,1,0,1,1,0,1,0,0,1,0,1,0,
                2066, 5,0,1,0,1,1,0,1,0,1,0,1,0,1,
                2067, 0,0,1,0,1,0,1,1,0,1,0,1,0,0,
                2068, 0,1,0,1,0,0,1,1,0,1,1,0,1,0,
                2069, 4,0,1,0,1,0,0,1,0,1,1,1,0,1,
                2070, 0,0,1,0,1,0,0,1,0,1,1,0,1,0,
                2071, 8,1,0,1,0,1,0,0,1,0,1,0,1,1,
                2072, 0,1,0,1,0,1,0,0,1,0,1,0,1,0,
                2073, 0,1,0,1,1,0,1,0,0,1,0,1,0,0,
                2074, 6,1,0,1,1,0,1,0,1,0,1,0,1,0,
                2075, 0,1,0,1,0,1,1,0,1,0,1,0,1,0,
                2076, 0,0,1,0,1,0,1,0,1,1,0,1,0,0,
                2077, 4,1,0,1,0,0,1,0,1,1,1,0,1,0,
                2078, 0,1,0,1,0,0,1,0,1,1,0,1,1,0,
                2079, 0,0,1,0,1,0,0,1,0,1,0,1,1,0,
                2080, 3,1,0,1,0,1,0,0,1,0,0,1,1,1,
                2081, 0,0,1,1,0,1,0,0,1,0,0,1,1,0,
                2082, 7,0,1,1,1,0,0,1,0,1,0,0,1,1,
                2083, 0,0,1,1,0,1,0,1,0,1,0,1,0,0,
                2084, 0,1,0,1,0,1,1,0,1,0,1,0,1,0,
                2085, 5,0,1,0,0,1,1,0,1,1,0,1,0,1,
                2086, 0,0,1,0,0,1,0,1,1,0,1,1,0,0,
                2087, 0,1,0,1,0,0,1,0,1,0,1,1,1,0,
                2088, 4,0,1,0,1,0,0,1,0,0,1,1,1,0,
                2089, 0,1,1,0,1,0,0,1,0,0,1,1,0,0,
                2090, 8,1,1,1,0,1,0,0,1,0,0,1,1,0,
                2091, 0,1,1,0,1,0,1,0,1,0,0,1,0,0,
                2092, 0,1,1,0,1,1,0,1,0,1,0,1,0,0,
                2093, 6,0,1,1,0,1,0,1,1,0,1,0,1,0,
                2094, 0,0,1,0,1,0,1,1,0,1,1,0,1,0,
                2095, 0,0,1,0,0,1,0,1,0,1,1,1,0,0,
                2096, 4,1,0,1,0,0,1,0,0,1,1,1,0,1,
                2097, 0,1,0,1,0,0,1,0,0,1,1,0,1,0,
                2098, 0,1,1,0,1,0,0,0,1,0,1,0,1,0,
                2099, 2,1,1,0,1,1,0,0,1,0,0,1,0,1,
            };


lunar_calendar lunar_creat_date(const int year, const int month, const int day)
{
    lunar_calendar lu = 1L;
    //unsigned int temp;
    unsigned int tyear, tmonth, maxmonth;
    
    /* base date: 1899.12.1(lu = 1L)  top date: 2099/12/30 */

    /* checking input.., wrong date return 1L */
    if( (year < 1899) || (year > 2099) || 
        (month < 1) || (month > 12) ||
        (day < 1) || (day > 30) ) {
        return lu;
    }
    if(year == 1899)   /* if the date is between between 1899.12.1 and 1899.12.30, just return the "day" */
        return (long)day;
        
    /* lunar table search */
    for(tyear = 0; tyear <= year-1900; tyear++) {
        if(tyear == (year - 1900)) {  /* in the "year" , only minus 1 ~ "month"-1 month. attention: in there, we ignore the leap month */
            if( (lunar_table[year-1900].leap_month != 0) && (month > lunar_table[year-1900].leap_month))
                maxmonth = month + 1;
                
            else
                maxmonth = month;
        }else if(lunar_table[tyear].leap_month != 0)  /* not in the "year"1~13 and exist a leap month */
            maxmonth = 14;   
        else                    /* not in the "year" but not exist leap month */
            maxmonth = 13;   
        /* add all the month */ 
        for(tmonth = 1; tmonth < maxmonth; tmonth++) {
            lu += (29 + lunar_table[tyear].month[tmonth-1]);
        }
    }
    
    lu += (day + 30 - 1); /* add the "day" and the days between 1899.12.1 and 1899.12.30 */
                          /* minus 1 because of lu's initialtion value is 1 */
    return lu;
}

unsigned int lunar_get_year(const lunar_calendar lunar_date)
{
    lunar_calendar lu = lunar_date;
    unsigned int year = 0u /* the year 1900's position in lunar_table */;
    int maxmonth, i;

    if(lunar_date <= 30) {/* before 1899.12.30 inclusively, it contains the wrong lunar_date(lunar_date < 1).  */
        return 1899u;
    }else{
        lu -= 30; /* minus the days between 1899.12.1 and 1899.12.30 */
        /* lunar table search */
        while(1) {
            if(lunar_table[year].leap_month != 0)  /* exist a leap month */
                maxmonth = 13;   
            else                    /* not exist leap month */
                maxmonth = 12;   
             /* test condition: lu is larger than next month */ 
            for(i = 1; i <= maxmonth && lu > (lunar_table[year].month[i-1]+29); i++) {
                
                lu -= (29 + lunar_table[year].month[i-1]);
            }
            if(i <= maxmonth) /* previous for loop: lu is smaller than next month */ 
                break;
            year++;
        }
    }
    
    return 1900u + year;
}

unsigned int lunar_get_month(const lunar_calendar lunar_date)
{
    lunar_calendar lu = lunar_date;
    unsigned year = 0u, month;
    int i, maxmonth;

    if(lunar_date <= 30) /* before 1899.12.30 inclusively, it contains the wrong lunar_date(lunar_date < 1) */
        month = 12;
    else{
        lu -= 30; /* minus the days between 1899.12.1 and 1899.12.30 */
        /* lunar table search */
        while(1) {
           if(lunar_table[year].leap_month != 0)  /* not in the "year"1~13 and exist a leap month */
                maxmonth = 13;   
            else                    /* not in the "year" but not exist leap month */
                maxmonth = 12;   
             /* test condition: lu is larger than next month */
            for(i = 1; i <= maxmonth && lu > (lunar_table[year].month[i-1]+29); i++) {
                lu -= (29 + lunar_table[year].month[i-1]);
            }
            if(i <= maxmonth) { /* previous for loop: lu is smaller than next month */ 
                /* if leap month is exist and  i is larger than leap month, month = i - 1, otherwise month = i. */
                month = i - ( (maxmonth == 13 && i > lunar_table[year].leap_month) ? 1 : 0  );
				if ((maxmonth == 13 && (i-1)==lunar_table[year].leap_month)) {
					month=100;//如果是闰月则返回100,可通过Get_Leap_Month获取确切月份
				}
                break;
            }
            year++;
        }
    }

    return month;
}


unsigned int lunar_get_day(const lunar_calendar lunar_date)
{
    lunar_calendar lu = lunar_date;
    unsigned year = 0u /* the year 1900's position in lunar_table */;
    int maxmonth, i;

    if(lunar_date <= 30) {/* before 1899.12.30 inclusively, it contains the wrong lunar_date(lunar_date < 1).  */
        return (unsigned int)lu;
    }else{
        lu -= 30; /* minus the days between 1899.12.1 and 1899.12.30 */
        /* lunar table search */
       while(1) {
           if(lunar_table[year].leap_month != 0)  /* not in the "year"1~13 and exist a leap month */
                maxmonth = 13;   
            else                    /* not in the "year" but not exist leap month */
                maxmonth = 12;   
             /* test condition: lu is larger than next month */ 
            for(i = 1; i <= maxmonth && lu > (lunar_table[year].month[i-1]+29); i++) {
                lu -= (29 + lunar_table[year].month[i-1]);
            }
            if(i <= maxmonth) /* previous for loop: lu is smaller than next month */ 
                break;
            year++;
        }
    }
    
    return (unsigned int)lu;
}


unsigned int lunar_get_days(const int year, const unsigned int month)
{
	int tyear, tmonth;
	
	tyear = ( ( year < 1899 || year > 2099 ) ? 1899 : year ); 
	tmonth = ( month > 12 ? 1 : month); 
	/* attention: this implemetion do not return the leap month's days */
	if(tyear == 1899)
		return 30;
	else     /* do not return the leap month */
       return  29 + 
                ( ( (lunar_table[tyear-1900].leap_month != 0) && 
                    (tmonth > lunar_table[tyear-1900].leap_month) ) ? 
                    lunar_table[tyear-1900].month[tmonth] : lunar_table[tyear-1900].month[tmonth-1] );
}


unsigned int lunar_leap_days(const int year)
{
    int leap_month;

	leap_month = lunar_leap_month(year);
	
	if(leap_month == 0)  /* does not have a leap month and includes such condition: year == 1899 */
		return 0;
    else
        return 29 + lunar_table[year-1900].month[leap_month];
}


unsigned lunar_weeks_day(const lunar_calendar lunar_date)
{
	/* 1899.12.1 is monday and it's internal date is 1L */
	return (weeks) ( (lunar_date - 1L) % 7L + 1 );
}
	

int lunar_leap_month(const int year)
{
	int tyear;
    tyear = ( ( year < 1899 || year > 2099 ) ? 1899 : year ); 
	if(year == 1899) /* i don't kown the leap month is exist or not */ 
		return 0;
	else
		return lunar_table[year-1900].leap_month;
}
	


/***********************************************************
limited practical function: solar date converts to lunar date vice versa.

lunar date: 1899.12.30 -------- solar date: 1900.1.1 
************************************************************/

lunar_calendar solar2lunar(const solar_calendar sc)
{
	solar_calendar so;
	
    so = solar_creat_date(1900,1,1);
    if(sc >= 0) /* after the date 1900.1.1 inclusively */
		return sc-so+1;
	else
		return 1;  /* temporarily return value */
}

solar_calendar lunar2solar(const lunar_calendar lu)
{
	solar_calendar so;
	
    so = solar_creat_date(1900,1,1);	
    return lu + so -1;
}

int monthInfo(int year,int month,boolean isLeapMonth) {
	int leap = lunar_table[year-1900].leap_month;
	if (isLeapMonth || (leap > 0 && month > leap)) {
		return lunar_table[year-1900].month[month];
	}
	return lunar_table[year-1900].month[month-1];
}
