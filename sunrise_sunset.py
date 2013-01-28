import ephem
import datetime
 
obs = ephem.Observer()
obs.lat = '-36.9'
obs.long= '174.6'
 
# start_date = datetime.datetime(2008, 1, 1)
# end_date = datetime.datetime(2008, 12, 31)
# td = datetime.timedelta(days=1)
 
sun = ephem.Sun()
 
# sunrises = []
# sunsets = []
# dates = []
 
# date = start_date
# while date < end_date:
# date += td
# dates.append(date)
obs.date = date
rise_time = obs.next_rising(sun).datetime()
print rise_time
# sunrises.append(rise_time)
# set_time = obs.next_setting(sun).datetime()
# sunsets.append(set_time)