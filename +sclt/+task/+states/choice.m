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
num_targets = program.Value.structure.num_targets;
targets = program.Value.targets;
window = program.Value.window;

reset_all( targets, num_targets );
draw_all( stimuli, num_targets, window );
flip( window );

sclt.util.state_entry_timestamp( program, state );

if program.Value.config.DEBUG_SCREEN.is_present
    debug_window = program.Value.debug_window;
    draw_all( stimuli, num_targets, debug_window );
    flip( debug_window );
end

end

function loop(state, program)

%% Edit!!
% Loop has to check through all reward cues and abort either if any of the
% target has been collected or if fixation broke in the attempt

targ = program.Value.targets.reward_cue1;

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
    sclt.util.state_exit_timestamp( program, state );
    next( state, states('var_delay') );
  else
    sclt.util.state_exit_timestamp( program, state );
    next( state, states('prob_reward') );
  end
else
  sclt.util.state_exit_timestamp( program, state );
  next( state, states('error_iti') );
end


end

function reset_all(targets, num_targets)

for i=1:num_targets
  targ_name = sclt.util.nth_reward_cue_name( i );
  reset( targets.(targ_name) );
end

end

function draw_all(stimuli, num_targets, window)

for i=1:num_targets
  targ_name = sclt.util.nth_reward_cue_name( i );
  draw( stimuli.(targ_name), window );
end

end