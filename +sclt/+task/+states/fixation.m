function state = fixation(program, conf)

state = ptb.State();
state.Name = 'fixation';
state.Duration = conf.TIMINGS.time_in.fixation;

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

sclt.util.state_entry_timestamp( program, state );

state.UserData.acquired = false;
state.UserData.entered = false;
state.UserData.broke = false;

stimuli = program.Value.stimuli;
targets = program.Value.targets;
window = program.Value.window;

reset( targets.central_fixation );
draw( stimuli.central_fixation, window );
flip( window );
if strcmp( program.Value.config.INTERFACE.gaze_source_type, 'digital_eyelink' )
  draw_targets_on_eyelink( targets );
end

program.Value.data.Value(end).(state.Name).initiated_fixation = false;

if program.Value.config.DEBUG_SCREEN.is_present
    debug_window = program.Value.debug_window;
    draw( stimuli.central_fixation, debug_window );
    flip( debug_window );
end

end

function loop(state, program)

targ = program.Value.targets.central_fixation;

if ( targ.IsInBounds )
  state.UserData.entered = true;
  program.Value.data.Value(end).(state.Name).initiated_fixation = true;
  if ( targ.IsDurationMet )
      state.UserData.acquired = true;
      program.Value.data.Value(end).(state.Name).acquired_fixation = true;
      escape( state );
      return
  end
elseif ( state.UserData.entered )
  state.UserData.broke = true;
  program.Value.data.Value(end).(state.Name).acquired_fixation = false;
  escape( state );
  return
end

end

function exit(state, program)

states = program.Value.states;
state_names = keys( states );

if ( state.UserData.acquired )
  if any( strcmp(state_names,'decision') )
    sclt.util.state_exit_timestamp( program, state );
    next( state, states('decision') );
  else
    sclt.util.state_exit_timestamp( program, state );
    next( state, states('prob_reward') );
  end
else
  sclt.util.state_exit_timestamp( program, state );
  next( state, states('error_iti') );
end

end

function draw_targets_on_eyelink(targets, color)

if nargin < 2
  color = 3;
end
rect = get_bounding_rect( targets.central_fixation.Bounds );
sclt.util.el_draw_rect( rect, color );

end