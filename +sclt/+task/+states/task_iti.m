function state = task_iti(program, conf)

state = ptb.State();
state.Name = 'task_iti';
state.Duration = conf.TIMINGS.time_in.task_iti;

state.Entry = @(state) entry(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

flip( program.Value.window );
if program.Value.config.DEBUG_SCREEN.is_present
    flip( program.Value.debug_window );
end

end

function exit(state, program)

next( state, program.Value.states('new_trial') );

end