function state = var_delay(program, conf)

state = ptb.State();
state.Name = 'var_delay';
state.Duration = conf.TIMINGS.time_in.var_delay;

state.Entry = @(state) entry(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

% Write a function to get variable delay here and updatr state.Duration

flip( program.Value.window );
sclt.util.state_entry_timestamp( program, state );

pause_duration = get_var_delay(program);
disp( ['Delay amount: ' num2str( pause_duration )] );
pause( pause_duration );

if program.Value.config.DEBUG_SCREEN.is_present
    flip( program.Value.debug_window );
end

end

function exit(state, program)

states = program.Value.states;
sclt.util.state_exit_timestamp( program, state );
next( state, states('prob_reward') );

end

function var_delay = get_var_delay(program)

structure = program.Value.structure;
var_delay_times = structure.var_delay_times;
var_delay = randsample( var_delay_times, 1 );

end
