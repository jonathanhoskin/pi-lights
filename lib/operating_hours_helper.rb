require 'SolarEventCalculator'

module OperatingHoursHelper

  LAT = -36.90194388138392
  LNG = 174.62602709730263

  def inside_operating_hours
    current_time = Time.now
    se = SolarEventCalculator.new(current_time,LAT,LNG)
    sunrise = se.compute_civil_sunrise('Pacific/Auckland')
    sunset = se.compute_civil_sunset('Pacific/Auckland')
    return true if current_time < sunrise || current_time > sunset

    false
  end

end
