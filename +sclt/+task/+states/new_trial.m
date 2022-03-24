function state = new_trial(program, conf)

state = ptb.State();
state.Name = 'new_trial';

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

data_scaffold = make_trial_data_scaffold( program );

if isempty( program.Value.data.Value )
  program.Value.data.Value = data_scaffold;
else
  program.Value.data.Value(end+1) = data_scaffold;
  display_trial_performance( program );
end

end

function loop(state, program)

end

function exit(state, program)

states = program.Value.states;
next( state, states('fixation') );

end

function data_scaffold = make_trial_data_scaffold( program )

state_names = program.Value.structure.state_names;

data_scaffold = struct();

if isempty( program.Value.data.Value )
  data_scaffold.trial_number = 1;
else
  data_scaffold.trial_number = numel( program.Value.data.Value ) + 1;
end

for state_ind = 1:numel(state_names)
  state = state_names{state_ind};
  data_scaffold = update_state_fields_in_data_scaffold( data_scaffold, state );
end

end


function data_scaffold = update_state_fields_in_data_scaffold( data_scaffold, state )

if strcmp( state, 'new_trial' )
  return
else
  data_scaffold.(state).entry_time = nan;
  data_scaffold.(state).exit_time = nan;
  switch state
    case 'fixation'
      data_scaffold.(state).initiated_fixation = nan;
      data_scaffold.(state).acquired_fixation = nan;
    case 'decision'
      data_scaffold.(state).held_fixation = nan;
    case 'choice'
      num_targets = program.Value.structure.num_targets;
      data_scaffold.(state).target_entry_times = nan( 1, num_targets );
      data_scaffold.(state).targets_acquired = nan( 1, num_targets );
    case 'prob_reward'
      data_scaffold.(state).was_reward_delivered = nan;
    case 'var_delay'
      data_scaffold.(state).delay_period = nan;
  end
end

end

function display_trial_performance( program )

clc;
num_trials_to_display = program.Value.config.INTERFACE.num_trials_to_display;

structure = program.Value.structure;

fprintf('Fixation time = %0.2f; Fixation hold time = %0.2f; Target collection time = %0.2f\n\n',...
  structure.fixation_time,...
  structure.fixation_hold_time,...
  structure.target_collection_time...
)

data = program.Value.data.Value;
data(end) = [];

allTrialNumber = flip( [ data.trial_number ] );
fixation_data = flip( [ data.fixation ] );
allInitiatedFixation = [ fixation_data.initiated_fixation ];
allInitiatedFixation( isnan( allInitiatedFixation ) ) = false;
allAcquiredFixation = [ fixation_data.acquired_fixation ];
allAcquiredFixation( isnan( allAcquiredFixation ) ) = false;
if isfield( data, 'decision' )
  decision_data = flip( [ data.decision ] );
  allHeldFixation = [ decision_data.held_fixation ];
  allHeldFixation( isnan( allHeldFixation ) ) = false;
end

num_trials = numel(data);
start_ind = 1;
end_ind = min( num_trials_to_display, num_trials );
snippet = start_ind:end_ind;
TrialNumber = allTrialNumber(snippet)';
InitiatedFixation = allInitiatedFixation(snippet)';
AcquiredFixation = allAcquiredFixation(snippet)';
disp_data = table(TrialNumber, InitiatedFixation, AcquiredFixation);
if isfield( data, 'decision' )
  HeldFixation = allHeldFixation(snippet)';
  disp_data = table(TrialNumber, InitiatedFixation, AcquiredFixation, HeldFixation);
end

disp( disp_data );

total_initiated_trials = sum( allInitiatedFixation );
total_fixations = sum( allAcquiredFixation );
if isfield( data, 'decision' )
  total_fixation_held = sum( allHeldFixation );
end

snippet = 1:min(num_trials, 20);
initiated_in_last_20 = sum( allInitiatedFixation(snippet) );
fixations_in_last_20 = sum( allAcquiredFixation(snippet) );
if isfield( data, 'decision' )
  fixation_held_in_last_20 = sum( allHeldFixation(snippet) );
end

fprintf( 'Ratio of:\n')
fprintf( 'Initiated trials : Total trials;  Overall = %0.3f; Last 20 trials = %0.3f\n',...
  total_initiated_trials/num_trials, initiated_in_last_20/numel(snippet) );
fprintf( 'Fix acquired : Fix initiated;     Overall = %0.3f; Last 20 trials = %0.3f\n',...
  total_fixations/total_initiated_trials, fixations_in_last_20/initiated_in_last_20 );
if isfield( data, 'decision' )
  fprintf( 'Fix held : Fix initiated;         Overall = %0.3f; Last 20 trials = %0.3f\n',...
    total_fixation_held/total_initiated_trials, fixation_held_in_last_20/initiated_in_last_20 );
end

end
