require 'pi_piper'

puts "Press the switch to get started"

PiPiper.watch :pin => 17, :invert => true do |pin|
  puts "Pin 17 changed from #{pin.last_value} to #{pin.value}"
end

PiPiper.watch :pin => 18, :invert => true do |pin|
  puts "Pin 18 changed from #{pin.last_value} to #{pin.value}"
end

PiPiper.wait
