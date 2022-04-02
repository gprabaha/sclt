function state = decision(program, conf)

state = ptb.State();
state.Name = 'decision';
state.Duration = conf.TIMINGS.time_in.decision;

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

sclt.util.state_entry_timestamp( program, state );

state.UserData.acquired = false;
state.UserData.entered = false;
state.UserData.broke = false;

targets = program.Value.targets;
reset_all( targets );
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

if strcmp( program.Value.config.INTERFACE.gaze_source_type, 'digital_eyelink' )
  draw_targets_on_eyelink( targets, num_rew_cues );
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

targ = program.Value.targets.central_fixation;

if ( targ.IsInBounds )
  state.UserData.entered = true;
  
  if ( targ.IsDurationMet )
      state.UserData.acquired = true;
      program.Value.data.Value(end).(state.Name).held_fixation = true;
      escape( state );
      return
  end
  
elseif ( state.UserData.entered )
  state.UserData.broke = true;
  program.Value.data.Value(end).(state.Name).held_fixation = false;
  escape( state );
  return
end

end

function exit(state, program)

states = program.Value.states;
state_names = keys( states );

if ( state.UserData.acquired )
  if any( strcmp(state_names,'choice') )
    sclt.util.state_exit_timestamp( program, state );
    next( state, states('choice') );
  else
    sclt.util.state_exit_timestamp( program, state );
    next( state, states('prob_reward') );
  end
else
  sclt.util.state_exit_timestamp( program, state );
  next( state, states('error_iti') );
end

end


function reset_all(targets)

reset( targets.central_fixation_hold );

end


function draw_everything(program, window, is_debug)

stimuli = program.Value.stimuli;
targets = program.Value.targets;
draw( stimuli.central_fixation_hold, window );
if is_debug
  bounds = targets.central_fixation_hold.Bounds;
  % Change the target rect to draw in debug window
  bounds.BaseRect.Rectangle.Window = window;
  draw( bounds, window );
  bounds.BaseRect.Rectangle.Window = program.Value.window;
end
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

function draw_targets_on_eyelink(targets, num_targets, color)

if nargin < 3
  color = 3;
end

rect = get_bounding_rect( targets.central_fixation_hold.Bounds );
sclt.util.el_draw_rect( rect, color );
for i=1:num_targets
  targ_name = sclt.util.nth_reward_cue_name( i );
  rect = get_bounding_rect( targets.(targ_name).Bounds );
  sclt.util.el_draw_rect( rect, color );
end

end