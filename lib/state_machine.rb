module StateMachine

  def setup_sensor_pin_state(pin)
    @pin_states[pin] = {:pin_state => PIN_STATE_OFF, :start_at => nil, :on_count => 0, :cancelled => false}
  end
  
  def set_pin_state(pin,state)
  @pin_states[pin].merge!(state)
  end

  def set_pin_state_on(pin)
    safe_trigger_threshold = Time.now - SAFE_TRIGGER_INTERVAL
    if @last_trigger > safe_trigger_threshold && pin == @last_trigger_pin
      # print "\r"
      # print "Only just got triggered, will not turn on again: #{safe_trigger_threshold}"
      # STDOUT.flush
      return false
    end

    ps = @pin_states[pin]

    # Going from OFF -> ON from cold
    if ps[:pin_state] == PIN_STATE_OFF && !ps[:cancelled]
      set_pin_state(pin, {
        :pin_state => PIN_STATE_ON,
        :start_at => Time.now,
        :on_count => 1
      })
      puts "Will turn on from pin: #{pin}"
      @last_trigger = Time.now
      return true
    end

    retrigger_threshold = ps[:start_at] + MIN_RETRIGGER_INTERVAL

    # Allow cancelled pin to retrigger if it has hit the retrigger threshold
    if ps[:cancelled] && retrigger_threshold > Time.now
      set_pin_state(pin, {
        :pin_state => PIN_STATE_ON,
        :start_at => Time.now,
        :on_count => 1,
        :cancelled => false
      })
      puts "Will retrigger from previous cancelled pin: #{pin}"
      @last_trigger = Time.now
      return true
    end

    # Don't allow cancelled pin to retrigger until it hits the retrigger threshold
    if ps[:cancelled] && Time.now < retrigger_threshold
      set_pin_state(pin, { :on_count => (ps[:on_count] + 1) })
      # puts "Will not yet retrigger from previous cancelled pin: #{pin}"
      return false
    end

    # This is probably a valid retrigger
    if ps[:pin_state] == PIN_STATE_ON && Time.now > retrigger_threshold
      set_pin_state(pin, { 
        :start_at => Time.now,
        :on_count => 1
      })
      # puts "Retrigger threshold: #{retrigger_threshold}"
      puts "Will retrigger from pin: #{pin}"
      @last_trigger = Time.now
      return true
    end

    # This is probably a trigger from the duty cycle, ignore
    if ps[:pin_state] == PIN_STATE_ON
      ps[:on_count] += 1
      diff = Time.now - ps[:start_at]
      per_second = ps[:on_count] / diff
      print "\r" 
      print "Ignoring pin getting set on at: #{per_second}/s"
      STDOUT.flush

      set_pin_state(pin, { :on_count => ps[:on_count] })
      return false
    end

    # puts "Should not hit here in set_pin_state_on"
    return false
  end

  def set_pin_state_off(pin)
    ps = @pin_states[pin]
    end_at = ps[:start_at] + MIN_RETRIGGER_INTERVAL

    # Have gone past the allowed end time for this pin
    if ps[:pin_state] == PIN_STATE_ON && Time.now > end_at
      set_pin_state(pin, { 
        :pin_state => PIN_STATE_OFF,
        :start_at => nil,
        :on_count => 0,
        :cancelled => false
      })
      puts "Can turn off from pin: #{pin}"
      return true
    end

    # Have not yet hit the end time for this pin
    if ps[:pin_state] == PIN_STATE_ON && Time.now < end_at
      # diff = Time.now - ps[:start_at]
      # per_second = count / diff
      # puts "Ignored pin set off"
      return false
    end

    # puts "Should not hit here in set_pin_state_off"
    return false
  end
end