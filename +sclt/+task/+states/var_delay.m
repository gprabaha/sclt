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
if program.Value.config.DEBUG_SCREEN.is_present
    flip( program.Value.debug_window );
end

end

function exit(state, program)

next( state, program.Value.states('prob_reward') );

end