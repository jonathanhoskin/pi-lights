require 'wiringpi'
require 'eventmachine'

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

class PiLights
  # Times in seconds
  POLL_LOOP_TIME = 0.1
  TRIGGER_WAIT_TIME = 90
  MIN_RETRIGGER_INTERVAL = 30
  SAFE_TRIGGER_INTERVAL = 2

  SENSOR_PIN_STATE_OFF = 1
  SENSOR_PIN_STATE_ON = 0

  LIGHT_OUTPUTS = [11,18,8,22,23,24]
  SENSORS = [0,1,15]
  # SENSORS = [0,1,14,15]
  # SENSORS = [0,1,4,14,15]
  # SENSORS = [0,1,4,15]
  SWITCHES = [9,10,25]

  include StateMachine
  include WebSocketServer
  include MessageHandler

  def initialize
    @connected_websockets = {}
    @last_trigger = Time.now - SAFE_TRIGGER_INTERVAL
    @last_trigger_pin = nil
    @light_countdown_timer
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
      add_sensor_loop
    end
  end

  def setup_lights
    LIGHT_OUTPUTS.each do |output|
      `gpio export #{output} out`
      `gpio -g write #{output} 0`
    end
  end

  def setup_sensors
    SENSORS.each do |sensor|
      setup_sensor_pin_state(sensor)
      `gpio export #{sensor} in`
      `gpio -g mode #{sensor} up`
    end
  end

  def setup_switches
    SWITCHES.each do |switch|
      `gpio export #{switch} in`
      `gpio -g mode #{switch} up`
    end
  end

  def add_sensor_loop
    @sensor_periodic_timer_loop = EventMachine.add_periodic_timer(POLL_LOOP_TIME) { poll_sensor_pins }
  end

  def poll_sensor_pins
    print "\rPolling sensor pins at: #{Time.now}"
    STDOUT.flush
    SENSORS.each do |sensor|
      state = `gpio -g read #{sensor}`.to_i
      trigger_run_timer(sensor) if state == SENSOR_PIN_STATE_ON
    end
  end

  def trigger_run_timer(pin)
    puts "Triggered by pin #{pin} at #{Time.now}"

    if set_pin_state_on(pin)
      if @light_countdown_timer.respond_to?(:cancel)
        puts "Cancelling last timer, replacing with new timer"
        set_pin_state(@last_trigger_pin,{:cancelled => true}) unless @last_trigger_pin.nil?
        @light_countdown_timer.cancel
      end

      @last_trigger_pin = pin

      @light_countdown_timer = EventMachine.add_timer(TRIGGER_WAIT_TIME) {
        @last_trigger_pin = nil
        turn_all_off if set_pin_state_off(pin)
      }

      turn_all_on
    end
  end

  def turn_output_on(output)
    `gpio -g write #{output} 1`
  end

  def turn_all_on
    puts "Turn all on at: #{Time.now}"
    LIGHT_OUTPUTS.each do |output|
      turn_output_on(output)
    end
  end

  def turn_output_off(output)
    `gpio -g write #{output} 0`
  end

  def turn_all_off
    puts "Turn all off at #{Time.now}"
    LIGHT_OUTPUTS.each do |output|
      turn_output_off(output)
    end
  end
end

PiLights.new.run
