function state = initial_fixation(program, conf)

state = ptb.State();
state.Name = 'initial_fixation';
state.Duration = conf.TIMINGS.time_in.initial_fixation;

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

state.UserData.acquired = false;
state.UserData.entered = false;
state.UserData.broke = false;

stimuli = program.Value.stimuli;
stimuli = update_stimuli_position( stimuli, program );

targets = program.Value.targets;
targets = update_target_durations( targets, program );

window = program.Value.window;

reset( targets.central_fixation );
draw( stimuli.central_fixation, window );
flip( window );

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
  
  if ( targ.IsDurationMet )
      state.UserData.acquired = true;
      escape( state );
      return;
  end
  
elseif ( state.UserData.entered )
  state.UserData.broke = true;
  escape( state );
  return
end

end

function exit(state, program)

states = program.Value.states;
state_names = keys( states );

if ( state.UserData.acquired )
    if any( strcmp(state_names,'decision') )
        next( state, states('decision') );
    else
        next( state, states('prob_reward') );
    end
else
    next( state, states('error_iti') );
end

end

function out_stimuli = update_stimuli_position(stimuli, program)

out_stimuli = stimuli;

rand_position = get_central_fix_pos( program );
out_stimuli.central_fixation.Position = set( out_stimuli.central_fixation.Position, rand_position );

end

function out_targets = update_target_durations( targets, program )

out_targets = targets;

% Fixation time
structure = program.Value.structure;
out_targets.central_fixation.Duration = structure.fixation_time;

end


function position = get_central_fix_pos(program)

position = [ 0.5, 0.5 ];

structure = program.Value.structure;
fix_radius = structure.fix_position_radius;
span = fix_radius - 0;

offset_seed = rand( 1, 2 );
signed_offset = [1, 1] - 2 * offset_seed;  % Unif random number from -1 to 1
normalized_offset = signed_offset * span;

position = position + normalized_offset;

end