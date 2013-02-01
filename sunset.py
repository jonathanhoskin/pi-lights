import ephem
from datetime import datetime
from dateutil import tz

obs = ephem.Observer()
obs.lat = '-36.9'
obs.long= '174.6'
obs.date = datetime.utcnow() #.replace(hour=0, minute=0, second=0, microsecond=0)

from_zone = tz.tzutc()
to_zone = tz.tzlocal()

sun = ephem.Sun()

utc = obs.next_setting(sun).datetime()
utc = utc.replace(tzinfo=from_zone)

print utc.astimezone(to_zone)
