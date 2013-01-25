require 'wiringpi'
require 'eventmachine'

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

class PiLights

  include StateMachine
  include WebSocketServer

  # Times in seconds
  TRIGGER_WAIT_TIME = 90
  MIN_RETRIGGER_INTERVAL = 30
  SAFE_TRIGGER_INTERVAL = 2

  PIN_STATE_OFF = 0
  PIN_STATE_ON = 1

  LIGHT_OUTPUTS = [11,18,8,22,23,24]
  SENSORS = [0,1,15]
  # SENSORS = [0,1,14,15]
  # SENSORS = [0,1,4,14,15]
  # SENSORS = [0,1,4,15]
  SWITCHES = [9,10,25]

  def initialize
      @last_trigger = Time.now - SAFE_TRIGGER_INTERVAL
      @pin_states = {}
      @gp = WiringPi::GPIO.new(WPI_MODE_SYS)

      setup_lights
      setup_sensors
      setup_switches
  end

  def run
    puts "Starting"

    EventMachine.run do
      Signal.trap('TERM') { EventMachine.stop }
      Signal.trap('INT') { EventMachine.stop }

      EventMachine.add_shutdown_hook {
        puts "Shutting down; Cleaning up"
        turn_all_off
        `gpio unexportall`
        puts "Done"
      }

      init_websocket_server
    end
  end

  def setup_lights
    LIGHT_OUTPUTS.each do |output|
      `gpio export #{output} out`
      `gpio -g write #{output} 0`
      # @gp.mode(output,OUTPUT)
      # @gp.write(output,LOW)
    end
  end

  def setup_sensors
    SENSORS.each do |sensor|
      setup_sensor_pin_state(sensor)
      `gpio export #{sensor} in`
      # @gp.mode(sensor,INPUT)
      `gpio -g mode #{sensor} up`
    end
  end

  def setup_switches
    SWITCHES.each do |switch|
      `gpio export #{switch} in`
      # @gp.mode(switch,INPUT)
      `gpio -g mode #{switch} up`
    end
  end

  def setup_sensor_pin_state(pin)
    @pin_states[pin] = {:pin_state => PIN_STATE_OFF, :start_at => nil, :on_count => 0, :killed => false}
  end

  def add_sensor_loop
    @sensor_periodic_timer_loop = EventMachine.add_periodic_timer(0.5) { poll_sensor_pins }
  end

  def poll_sensor_pins
    print "\rPolling sensor pins at: #{Time.now}"
    STDOUT.flush
    SENSORS.each do |sensor|
      trigger_run_timer(sensor) if @gp.read(sensor) == PIN_STATE_ON
    end
  end

  def trigger_run_timer(pin)
    puts "Triggered by pin #{pin} at #{Time.now}"

    if set_pin_state_on(pin)    
      @light_countdown_timer.cancel unless @light_countdown_timer.nil?

      @light_countdown_timer = EventMachine.add_timer(TRIGGER_WAIT_TIME) { turn_all_off }
      turn_all_on
    end
  end

  def turn_all_on
    puts "Turn all on at: #{Time.now}"
    LIGHT_OUTPUTS.each do |output|
      # @gp.write(output,HIGH)
      `gpio -g write #{output} 1`
    end
  end

  def turn_all_off
    puts "Turn all off at #{Time.now}"
    LIGHT_OUTPUTS.each do |output|
      # @gp.write(output,LOW)
      `gpio -g write #{output} 0`
    end
  end
end

PiLights.new.run
