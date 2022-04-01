function state = decision(program, conf)

state = ptb.State();
state.Name = 'decision';
state.Duration = conf.TIMINGS.time_in.decision;

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

state.UserData.acquired = false;
state.UserData.entered = false;
state.UserData.broke = false;

num_rew_cues = program.Value.structure.num_rew_cues;
stimuli = program.Value.stimuli;
targets = program.Value.targets;
window = program.Value.window;
reset_all( targets );
draw_all( stimuli, num_rew_cues, window );
flip( window );

if strcmp( program.Value.config.INTERFACE.gaze_source_type, 'digital_eyelink' )
  draw_targets_on_eyelink( targets, num_rew_cues );
end

sclt.util.state_entry_timestamp( program, state );

if program.Value.config.DEBUG_SCREEN.is_present
    debug_window = program.Value.debug_window;
    draw_all( stimuli, num_rew_cues, debug_window );
    flip( debug_window );
end

end

function loop(state, program)

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

function draw_all(stimuli, num_targets, window)

draw( stimuli.central_fixation_hold, window );
for i=1:num_targets
  targ_name = sclt.util.nth_reward_cue_name( i );
  draw( stimuli.(targ_name), window );
end

end

function draw_targets_on_eyelink(targets, num_targets, color)

if nargin < 3
  color = 3;
end

rect = get_bounding_rect( targets.central_fixation.Bounds );
sclt.util.el_draw_rect( rect, color );
for i=1:num_targets
  targ_name = sclt.util.nth_reward_cue_name( i );
  rect = get_bounding_rect( targets.(targ_name).Bounds );
  sclt.util.el_draw_rect( rect, color );
end

end