function state = prob_reward(program, conf)

state = ptb.State();
state.Name = 'prob_reward';
state.Duration = conf.TIMINGS.time_in.prob_reward;

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

quantity = program.Value.rewards.prob_reward;

% Update data and give juice here
% Chosen target stimuli also needs to be displayed

state.UserData.acquired = false;
state.UserData.entered = false;
state.UserData.broke = false;

flip( program.Value.window );
if program.Value.config.DEBUG_SCREEN.is_present
    flip( program.Value.debug_window );
end

sclt.util.deliver_reward( program, 1, quantity );

end

function loop(state, program)

@foo;

end

function exit(state, program)

states = program.Value.states;
next( state, states('task_iti') );

% pct.util.deliver_reward( program, 1, quantity );

end