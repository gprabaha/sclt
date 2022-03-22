function state = choice(program, conf)

state = ptb.State();
state.Name = 'choice';
state.Duration = conf.TIMINGS.time_in.choice;

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
debug_window = program.Value.debug_window;

% stimuli.choice0.Position = set( stimuli.choice0.Position, rand(1, 2) );

% Use 

reset( targets.reward_cue );
reset( targets.central_fixation );

draw( stimuli.reward_cue, window );
flip( window );


if program.Value.config.DEBUG_SCREEN.is_present
    debug_window = program.Value.debug_window;
    draw( stimuli.reward_cue, debug_window );
    flip( debug_window );
end

end

function loop(state, program)

%% Edit!!
% Loop has to check through all reward cues and abort either if any of the
% target has been collected or if fixation broke in the attempt

targ = program.Value.targets.reward_cue;

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
    if any( strcmp(state_names,'var_delay') )
        next( state, states('var_delay') );
    else
        next( state, states('prob_reward') );
    end
else
    next( state, states('error_iti') );
end


end