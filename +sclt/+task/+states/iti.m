function state = iti(program, conf)

state = ptb.State();
state.Name = 'iti';
state.Duration = conf.TIMINGS.time_in.iti;

state.Entry = @(state) entry(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

data = sclt.util.data_this_trial( program );
state.Duration = data.iti_duration;

flip( program.Value.window );

end

function exit(state, program)

next( state, program.Value.states('new_trial') );

end