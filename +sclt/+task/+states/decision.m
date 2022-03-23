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

stimuli = program.Value.stimuli;
% Needs to be modified for multiple reward cues
stimuli = update_stimuli_position( stimuli, program );

targets = program.Value.targets;
targets = update_target_durations( targets, program );

window = program.Value.window;

% Use a function here to reset all targets

reset( targets.reward_cue );
reset( targets.central_fixation );

% Use a function here to draw all stimuli to a particular window

draw( stimuli.reward_cue, window );
draw( stimuli.central_fixation, window );
flip( window );

sclt.util.state_entry_timestamp( program, state );

if program.Value.config.DEBUG_SCREEN.is_present
    debug_window = program.Value.debug_window;
    draw( stimuli.reward_cue, debug_window );
    draw( stimuli.central_fixation, debug_window );
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
      return;
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


function stimuli = update_stimuli_position(stimuli, program)

rand_position = get_reward_cue_pos( program );
stimuli.reward_cue.Position = set( stimuli.central_fixation.Position, rand_position );

end

function targets = update_target_durations( targets, program )

% Fixation hold time
structure = program.Value.structure;
targets.central_fixation.Duration = structure.fixation_hold_time;

end


function position = get_reward_cue_pos(program)

position = [ 0.5, 0.5 ];

structure = program.Value.structure;
fix_radius = structure.fix_position_radius;
target_radius = structure.target_position_radius;

span = target_radius - fix_radius;

offset_seed = rand( 1, 2 );
signed_offset = [1, 1] - 2 * offset_seed;  % Unif random number from -1 to 1
normalized_offset = (fix_radius .* sign( signed_offset )) + signed_offset * span;

position = position + normalized_offset;

end