function state = prob_reward(program, conf)

state = ptb.State();
state.Name = 'prob_reward';
state.Duration = conf.TIMINGS.time_in.prob_reward;

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

sclt.util.state_entry_timestamp( program, state );

state.UserData.acquired = false;
state.UserData.entered = false;
state.UserData.broke = false;

% Deliver reward here
% Ensure that the state exits right after reward delivery, and does not
% wait till the 'Duration' of the state is met

% Verify that the previous state was 'choice' before calculating reward
% probability

quantity = program.Value.rewards.prob_reward;
incorporate_var_delay = program.Value.structure.incorporate_var_delay;
if incorporate_var_delay
  pause_duration = get_var_delay(program);
  disp( ['Delay amount: ' num2str( pause_duration )] );
  pause( pause_duration );
end

% Draw the acquired target in the reward
window = program.Value.window;
stimuli = program.Value.stimuli;
num_rew_cues = program.Value.structure.num_rew_cues;
state_names = program.Value.structure.state_names;

if any( strcmp(state_names, 'choice') )
  choice_data = program.Value.data.Value(end).choice;
  draw_acquired_cue( stimuli, choice_data, num_rew_cues, window );
end
flip( window );

if program.Value.config.DEBUG_SCREEN.is_present
    debug_window = program.Value.debug_window;
    if any( strcmp(state_names, 'choice') )
      draw_acquired_cue( stimuli, choice_data, num_rew_cues, debug_window );
    end
    flip( debug_window );
end

% Incorporate probabilistic reward here

program.Value.data.Value(end).(state.Name).was_reward_delivered = false;
% if give_prob_reward
update_reward_start_time( program, state );
sclt.util.deliver_reward( program, 1, quantity );
update_was_reward_delivered( program, state );
% end

end

function loop(state, program)

end

function exit(state, program)

states = program.Value.states;
sclt.util.state_exit_timestamp( program, state );
next( state, states('task_iti') );

end

function var_delay = get_var_delay(program)

structure = program.Value.structure;
var_delay_times = structure.var_delay_times;
var_delay = randsample( var_delay_times, 1 );

end


function draw_acquired_cue(stimuli, choice_data, num_rew_cues, window)

for i = 1:num_rew_cues
  if ~isnan( choice_data.cues_acquired(1, i) )
    if choice_data.cues_acquired(1, i)
      stimui_name = sclt.util.nth_reward_cue_name( i );
      draw( stimuli.(stimui_name), window );
    end
  end
end

end

function update_reward_start_time(program, state)

program.Value.data.Value(end).(state.Name).reward_start_time = ...
  elapsed( program.Value.task );

end

function update_was_reward_delivered(program, state)

program.Value.data.Value(end).(state.Name).was_reward_delivered = true;

end