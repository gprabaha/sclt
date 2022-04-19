function deliver_pulsed_reward(program, channel, pulse_time, num_pulses)

if nargin < 4
  num_pulses = 1;
end

ni_reward_manager = program.Value.ni_reward_manager;
arduino_reward_manager = program.Value.arduino_reward_manager;

disp('Delivering reward!');

if ( ~isempty(ni_reward_manager) )
  for i = 1:num_pulses
    trigger( ni_reward_manager, pulse_time );
    pause( 0.3 );
  end
  
elseif ( ~isempty(arduino_reward_manager) )
  for i = 1:num_pulses
    reward( arduino_reward_manager, channel, pulse_time * 1e3 ); % to ms
    pause( 0.3 );
  end
end

end