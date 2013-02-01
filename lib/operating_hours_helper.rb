require 'time'

module OperatingHoursHelper

  def inside_operating_hours
    current_time = Time.now
    next_sunset = Time.parse(`python sunset.py`.chomp)
    next_sunrise = Time.parse(`python sunrise.py`.chomp)

    puts "Checking operating hours"
    puts "next_sunset: #{next_sunset}"
    puts "next_sunrise: #{next_sunrise}"

    # After sunset, when sunrise and sunset are tomorrow
    if next_sunrise_is_tomorrow(next_sunrise,current_time) && next_sunset_is_tomorrow(next_sunset,current_time)
      puts "After sunset, when sunrise and sunset are tomorrow"
      return true 
    end

    # Before sunrise, when sunrise is today
    if !next_sunrise_is_tomorrow(next_sunrise,current_time)
      puts "Before sunrise, when sunrise is today"
      return true
    end

    # After sunset, when sunset is earlier today, sunrise is tomorrow
    if next_sunrise_is_tomorrow(next_sunrise,current_time) && next_sunset < current_time
      puts "After sunset, when sunset is earlier today, sunrise is tomorrow"
      return true
    end

    puts "Not inside operating hours"
    false
  end

  def end_of_today
    now = Time.now
    end_of_today = Time.local(now.year, now.month, now.day, 23, 59, 59, 999999.999)
    puts "End of today: #{end_of_today}"
    return end_of_today
  end

  def next_sunrise_is_tomorrow(next_sunrise,current_time)
    return next_sunrise > end_of_today
  end

  def next_sunset_is_tomorrow(next_sunset,current_time)
    return next_sunset > end_of_today
  end

end