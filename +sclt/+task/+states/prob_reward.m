function state = prob_reward(program, conf)

state = ptb.State();
state.Name = 'prob_reward';
state.Duration = conf.TIMINGS.time_in.prob_reward;

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

% Determine the delay before the reward here

state.UserData.acquired = false;
state.UserData.entered = false;
state.UserData.broke = false;

% Draw the acquired target in the reward

flip( program.Value.window );
if program.Value.config.DEBUG_SCREEN.is_present
    flip( program.Value.debug_window );
end

end

function loop(state, program)

@foo;

end

function exit(state, program)

% Deliver reward here
% Ensure that the state exist right after reward delivery, and does not
% wait till the 'Duration' of the state is met

% Verify that the previous state was 'choice' before calculating reward
% probability

quantity = program.Value.rewards.prob_reward;
sclt.util.deliver_reward( program, 1, quantity );

states = program.Value.states;
next( state, states('task_iti') );

end