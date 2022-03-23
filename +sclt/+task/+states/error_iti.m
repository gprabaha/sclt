function state = error_iti(program, conf)

state = ptb.State();
state.Name = 'error_iti';
state.Duration = conf.TIMINGS.time_in.error_iti;

state.Entry = @(state) entry(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

flip( program.Value.window );

sclt.util.state_entry_timestamp( program, state );

if program.Value.config.DEBUG_SCREEN.is_present
    flip( program.Value.debug_window );
end

end

function exit(state, program)

sclt.util.state_exit_timestamp( program, state );
next( state, program.Value.states('new_trial') );

end