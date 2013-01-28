require 'time'

module OperatingHoursHelper

  def inside_operating_hours
    current_time = Time.now
    next_sunset = Time.parse(`python sunset.py`.chomp)
    next_sunrise = Time.parse(`python sunrise.py`.chomp)

    # After sunset, when sunrise and sunset are tomorrow
    return true if next_sunrise_is_tomorrow(next_sunrise,current_time) && next_sunset_is_tomorrow(next_sunset,current_time)

    # Before sunrise
    return true if !next_sunrise_is_tomorrow(next_sunrise,current_time)

    # After sunset, when sunset is earlier today, sunrise is tomorrow
    return true if next_sunrise_is_tomorrow(next_sunrise,current_time) && next_sunset < current_time

    false
  end

  def next_sunrise_is_tomorrow(next_sunrise,current_time)
    return next_sunrise.day > current_time.day
  end

  def next_sunset_is_tomorrow(next_sunset,current_time)
    return next_sunset.day > current_time.day
  end

end