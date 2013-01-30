require 'wiringpi'
require 'eventmachine'

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

class PiLights
  # Times in seconds
  POLL_LOOP_TIME = 0.33
  TRIGGER_WAIT_TIME = 90
  MIN_RETRIGGER_INTERVAL = 30
  SAFE_SECONDARY_TRIGGER_INTERVAL = 15

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
  include OperatingHoursHelper

  def initialize
    @manual_override_outputs = []
    @connected_websockets = {}
    @last_trigger = Time.now - SAFE_SECONDARY_TRIGGER_INTERVAL
    @last_trigger_pin = nil
    @light_countdown_timer
    @pin_states = {}
    @gp = WiringPi::GPIO.new(WPI_MODE_SYS)

    setup_lights
    setup_sensors
    setup_switches
  end

  def run
    puts "Starting..."

    EventMachine.run do
      Signal.trap('TERM') { EventMachine.stop }
      Signal.trap('INT') { EventMachine.stop }

      EventMachine.add_shutdown_hook {
        puts "Shutting down; Cleaning up"
        @manual_override_outputs = []
        turn_all_off
        `gpio unexportall`
        puts "Done"
      }

      init_websocket_server
      add_sensor_loop
      puts "Started"
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

  def output_pin_state(output)
    `gpio -g read #{output}`.to_i
  end

  def add_sensor_loop
    SENSORS.each do |sensor|
      EventMachine.add_periodic_timer(POLL_LOOP_TIME) { poll_sensor_pin(sensor) }
    end
  end

  def poll_sensor_pin(sensor)
    state = `gpio -g read #{sensor}`.to_i
    trigger_run_timer(sensor) if state == SENSOR_PIN_STATE_ON
  end

  def trigger_run_timer(pin)
    unless inside_operating_hours
      # puts "Outside operating hours, not triggerring"
      return
    end

    if @manual_override_outputs.length > 0
      puts "Manual override is in place, not triggering"
      return
    end

    if set_pin_state_on(pin)
      puts "Triggered by pin #{pin} at #{Time.now}"

      if @light_countdown_timer
        puts "Cancelling last timer, replacing with new timer"
        EventMachine.cancel_timer(@light_countdown_timer)
        set_pin_state(@last_trigger_pin,{:cancelled => true}) unless @last_trigger_pin.nil?
        send_change_to_websockets(:sensor,@last_trigger_pin,0);
      end

      @last_trigger_pin = pin
      send_change_to_websockets(:sensor,@last_trigger_pin,1);

      @light_countdown_timer = EventMachine.add_timer(TRIGGER_WAIT_TIME) {
        send_change_to_websockets(:sensor,@last_trigger_pin,0);
        @last_trigger_pin = nil
        turn_all_off if set_pin_state_off(pin)
        @light_countdown_timer = nil
      }

      turn_all_on
    end
  end

  def turn_output_on(output)
    # Only turn it on if it is off
    if output_pin_state(output) == 0
      puts "Turn on output: #{output}"
      `gpio -g write #{output} 1`
    end

    # Always send the state change, to correct sync issues
    send_change_to_websockets(:output,output,1)
  end

  def turn_all_on
    puts "Turn all on at: #{Time.now}"
    LIGHT_OUTPUTS.each do |output|
      turn_output_on(output)
    end
  end

  def turn_output_off(output)
    # Only turn if off if it is on
    if output_pin_state(output) == 1
      puts "Turn off output: #{output}"
      `gpio -g write #{output} 0`
    end

    # Always send the state change, to correct sync issues
    send_change_to_websockets(:output,output,0)
  end

  def turn_all_off
    if @manual_override_outputs.length > 0
      puts "Manual override is on, will not turn off automatically"
      return
    end

    reset_cancelled_sensor_pins

    puts "Turn all off at #{Time.now}"
    LIGHT_OUTPUTS.each do |output|
      turn_output_off(output)
    end
  end

  def add_manual_override(output)
    @manual_override_outputs << output
    reset_cancelled_sensor_pins
  end

  def delete_manual_override(output)
    @manual_override_outputs.delete(output)
    reset_cancelled_sensor_pins
  end

end

PiLights.new.run
