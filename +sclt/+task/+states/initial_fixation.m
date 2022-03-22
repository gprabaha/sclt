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
targets = program.Value.targets;
window = program.Value.window;

rand_position = get_central_fix_pos( program );
stimuli.central_fixation.Position = set( stimuli.central_fixation.Position, rand_position );

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

if ( state.UserData.acquired )
    next( state, states('decision') );
else
    next( state, states('error_iti') );
end

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