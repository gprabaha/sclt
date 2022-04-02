function state = choice(program, conf)

state = ptb.State();
state.Name = 'choice';
state.Duration = conf.TIMINGS.time_in.choice;

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

sclt.util.state_entry_timestamp( program, state );

num_rew_cues = program.Value.structure.num_rew_cues;

initiate_user_data( state, program );
initiate_cues_acquired( program, state, num_rew_cues );

targets = program.Value.targets;
reset_all( targets, num_rew_cues );
window = program.Value.window;
is_debug = false;
draw_everything( program, window, is_debug );
flip( window );
if program.Value.config.DEBUG_SCREEN.is_present
  debug_window = program.Value.debug_window;
  is_debug = true;
  draw_everything( program, debug_window, is_debug );
  flip( debug_window );
end

end


function loop(state, program)

window = program.Value.window;
is_debug = false;
draw_everything( program, window, is_debug );
flip( window );
if program.Value.config.DEBUG_SCREEN.is_present
    debug_window = program.Value.debug_window;
    is_debug = true;
    draw_everything( program, debug_window, is_debug );
    flip( debug_window );
end

num_rew_cues = program.Value.structure.num_rew_cues;
for i = 1:num_rew_cues
  targ_name = sclt.util.nth_reward_cue_name( i );
  targ = program.Value.targets.(targ_name);
  if ( targ.IsInBounds )
    state.UserData.entered(i) = true;
    update_cue_entry_times( program, state, i );
    if ( targ.IsDurationMet )
      state.UserData.acquired(i) = true;
      update_cues_acquired( program, state, i );
      escape( state );
      return
    end
  elseif ( state.UserData.entered(i) )
    state.UserData.broke(i) = true;
    update_cue_exit_times( program, state, i );
    escape( state );
    return
  end
end

end

function exit(state, program)

states = program.Value.states;

if ( any( state.UserData.acquired ) )
  sclt.util.state_exit_timestamp( program, state );
  next( state, states('prob_reward') );
else
  sclt.util.state_exit_timestamp( program, state );
  next( state, states('error_iti') );
end

end


function initiate_user_data(state, program)

num_rew_cues = program.Value.structure.num_rew_cues;

for i = 1:num_rew_cues
  state.UserData.acquired(i) = false;
  state.UserData.entered(i) = false;
  state.UserData.broke(i) = false;
end

end

function reset_all(targets, num_targets)

for i=1:num_targets
  targ_name = sclt.util.nth_reward_cue_name( i );
  reset( targets.(targ_name) );
end

end


function draw_everything(program, window, is_debug)

stimuli = program.Value.stimuli;
targets = program.Value.targets;
num_rew_cues = program.Value.structure.num_rew_cues;
for i=1:num_rew_cues
  stimui_name = sclt.util.nth_reward_cue_name( i );
  draw( stimuli.(stimui_name), window );
  if is_debug
    bounds = targets.(stimui_name).Bounds;
    bounds.BaseRect.Rectangle.Window = window;
    draw( bounds, window );
    bounds.BaseRect.Rectangle.Window = program.Value.window;
  end
end
sclt.util.draw_gaze_cursor( program, window, is_debug );

end


function initiate_cues_acquired(program, state, num_rew_cues)

for i = 1:num_rew_cues
  program.Value.data.Value(end).(state.Name).cues_acquired(1, i) = false;
end

end


function update_cue_entry_times(program, state, i)

program.Value.data.Value(end).(state.Name).cue_entry_times(1, i) = ...
  elapsed( program.Value.task );

end

function update_cues_acquired(program, state, i)

program.Value.data.Value(end).(state.Name).cues_acquired(1, i) = true;

end

function update_cue_exit_times(program, state, i)

program.Value.data.Value(end).(state.Name).cue_exit_times(1, i) = ...
  elapsed( program.Value.task );

end