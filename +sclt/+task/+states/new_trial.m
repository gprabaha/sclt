function state = new_trial(program, conf)

state = ptb.State();
state.Name = 'new_trial';

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

% Update the position of different stimuli
stimuli = program.Value.stimuli;
program.Value.stimuli = update_stimuli_position( stimuli, program );

% Update the positions of the reward cue targets
targets = program.Value.targets;
%program.Value.targets = update_target_position( targets, program );
program.Value.targets = update_target_durations( targets, program );

data_scaffold = make_trial_data_scaffold( program );

if isempty( program.Value.data.Value )
  program.Value.data.Value = data_scaffold;
else
  program.Value.data.Value(end+1) = data_scaffold;
  display_trial_performance( program );
end
if strcmp( program.Value.config.INTERFACE.gaze_source_type, 'digital_eyelink' )
  sclt.util.el_draw_rect( 0 );
end

end

function loop(state, program)

end

function exit(state, program)

states = program.Value.states;
next( state, states('fixation') );

end

function stimuli = update_stimuli_position(stimuli, program)

rand_position = get_central_fix_pos( program );

% Fixation
stimuli.central_fixation.Position = set( stimuli.central_fixation.Position, rand_position );

% Decision
stimuli.central_fixation_hold.Position = set( stimuli.central_fixation_hold.Position, stimuli.central_fixation.Position );
num_rew_cues = program.Value.structure.num_rew_cues;
rand_position(1,:) = get_reward_cue_pos( program );
if num_rew_cues == 2
  rand_position(2,:) = [1 1] - rand_position(1,:);
end
for rew_cue = 1:num_rew_cues
  stim_name = sclt.util.nth_reward_cue_name( rew_cue );
  stimuli.(stim_name).Position = set( stimuli.central_fixation.Position, rand_position(rew_cue, :) );
end

end

function position = get_central_fix_pos(program)

position = [ 0.5, 0.5 ];

structure = program.Value.structure;
fix_radius = structure.fix_position_radius;
span = fix_radius - 0;

offset_seed = rand( 1, 2 );
signed_offset = [1, 1] - 2*offset_seed;  % Unif random number from -1 to 1
normalized_offset = span*signed_offset;

position = position + normalized_offset;

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

function targets = update_target_durations( targets, program )

structure = program.Value.structure;
num_rew_cues = program.Value.structure.num_rew_cues;
% Fixation time
targets.central_fixation.Duration = structure.fixation_time;
% Fixation hold time during decision
targets.central_fixation_hold.Duration = structure.fixation_hold_time;
% Target reward cue acquiring dutation
for i = 1:num_rew_cues
  rew_cue_name = sclt.util.nth_reward_cue_name( i );
  targets.(rew_cue_name).Duration = structure.cue_collection_time;
end

end

function data_scaffold = make_trial_data_scaffold( program )

state_names = program.Value.structure.state_names;

data_scaffold = struct();

if isempty( program.Value.data.Value )
  data_scaffold.trial_number = 1;
else
  data_scaffold.trial_number = numel( program.Value.data.Value ) + 1;
end

data_scaffold.stimuli = program.Value.stimuli;
data_scaffold.targets = program.Value.targets;
data_scaffold.structure = program.Value.structure;
data_scaffold.interface = program.Value.interface;
data_scaffold.rewards = program.Value.rewards;

data_scaffold.fixations_initiated_overall = nan;
data_scaffold.fixations_initiated_last_10 = nan;
data_scaffold.fixations_accuracy_overall = nan;
data_scaffold.fixations_accuracy_last_10 = nan;

for state_ind = 1:numel(state_names)
  state = state_names{state_ind};
  data_scaffold = update_state_fields_in_data_scaffold( data_scaffold, program, state );
end

end

function data_scaffold = update_state_fields_in_data_scaffold(data_scaffold, program, state)

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
      num_rew_cues = program.Value.structure.num_rew_cues;
      data_scaffold.(state).cue_entry_times = nan( 1, num_rew_cues );
      data_scaffold.(state).cue_exit_times = nan( 1, num_rew_cues );
      data_scaffold.(state).cues_acquired = nan( 1, num_rew_cues );
    case 'prob_reward'
      data_scaffold.(state).reward_start_time = nan;
      data_scaffold.(state).was_reward_delivered = nan;
      data_scaffold.(state).reward_delay = nan;
  end
end

end

function display_trial_performance( program )

clc;
num_trials_to_display = program.Value.config.INTERFACE.num_trials_to_display;

structure = program.Value.structure;

fprintf('Fixation time = %0.2f; Fixation hold time = %0.2f; Cue collection time = %0.2f\n\n',...
  structure.fixation_time,...
  structure.fixation_hold_time,...
  structure.cue_collection_time...
)

data = program.Value.data.Value(1:end-1);

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
if isfield( data, 'choice' )
  choice_data = flip( [ data.choice ] );
  allCueChosen = get_cue_chosen( choice_data );
  allHeldFixation = [ decision_data.held_fixation ];
  allHeldFixation( isnan( allHeldFixation ) ) = false;
end

num_trials = numel(data);
start_ind = 1;
end_ind = min( num_trials_to_display, num_trials );
snippet = start_ind:end_ind;
TrNo = allTrialNumber(snippet)';
InitFix = allInitiatedFixation(snippet)';
AcqFix = allAcquiredFixation(snippet)';
disp_data = table(TrNo, InitFix, AcqFix);
if isfield( data, 'decision' )
  HeldFix = allHeldFixation(snippet)';
  disp_data = table(TrNo, InitFix, AcqFix, HeldFix);
end
if isfield( data, 'choice' )
  CueChosen = allCueChosen(snippet)';
  disp_data = table(TrNo, InitFix, AcqFix, HeldFix, CueChosen);
end

disp( disp_data );

total_initiated_trials = sum( allInitiatedFixation );
total_fixations = sum( allAcquiredFixation );
if isfield( data, 'decision' )
  total_fixation_held = sum( allHeldFixation );
end
if isfield( data, 'choice' )
  total_cues_chosen = sum( logical( allCueChosen ) );
end

snippet = 1:min(num_trials, 10);
initiated_in_last_10 = sum( allInitiatedFixation(snippet) );
fixations_in_last_10 = sum( allAcquiredFixation(snippet) );
if isfield( data, 'decision' )
  fixation_held_in_last_10 = sum( allHeldFixation(snippet) );
end
if isfield( data, 'choice' )
  total_cues_chosen_in_last_10 = sum( logical( allCueChosen(snippet) ) );
end

fprintf( 'Ratio of:\n')
fprintf( 'InitTrial:TotTrial;   Overall = %0.3f; Last 10 trials = %0.3f\n',...
  total_initiated_trials/num_trials, initiated_in_last_10/numel(snippet) );
fprintf( 'FixAcq:FixInit;       Overall = %0.3f; Last 10 trials = %0.3f\n',...
  total_fixations/total_initiated_trials, fixations_in_last_10/initiated_in_last_10 );


fixations_initiated_overall = total_initiated_trials/num_trials;
fixations_accuracy_overall = total_fixations/total_initiated_trials;
program.Value.data.Value(end-1).fixations_initiated_overall = fixations_initiated_overall;
program.Value.data.Value(end-1).fixations_accuracy_overall = fixations_accuracy_overall;

if program.Value.data.Value(end-1).fixation.initiated_fixation
  program.Value.data.Value(end-1).fixations_initiated_last_10 = initiated_in_last_10/numel(snippet);
  program.Value.data.Value(end-1).fixations_accuracy_last_10 = fixations_in_last_10/initiated_in_last_10;
else
  program.Value.data.Value(end-1).fixations_initiated_last_10 = nan;
  program.Value.data.Value(end-1).fixations_accuracy_last_10 = nan;
end

if isfield( data, 'decision' )
  fprintf( 'FixHeld:FixInit;      Overall = %0.3f; Last 10 trials = %0.3f\n',...
    total_fixation_held/total_initiated_trials, fixation_held_in_last_10/initiated_in_last_10 );
end
if isfield( data, 'choice' )
  fprintf( 'CorChoice:FixInit;    Overall = %0.3f; Last 10 trials = %0.3f\n',...
    total_cues_chosen/total_initiated_trials, total_cues_chosen_in_last_10/initiated_in_last_10 );
end

data = program.Value.data.Value(1:end-1);

fix_initiated_last_10 = [ data.fixations_initiated_last_10 ];
fix_accuracy_last_10 = [ data.fixations_accuracy_last_10 ];
trials = [ data.trial_number ];

clf;
hold on;
plot( trials, fix_initiated_last_10, 'r.-', 'LineWidth', 1, 'MarkerSize', 10);
plot( trials, fixations_initiated_overall * ones( 1, numel( trials ) ), 'r--', 'LineWidth', 2 );
plot( trials, fix_accuracy_last_10, 'b.-', 'LineWidth', 1, 'MarkerSize', 10 );
plot( trials, fixations_accuracy_overall * ones( 1, numel( trials ) ), 'b--', 'LineWidth', 2);
hold off;
legend({'Init Last 10', 'Init Overall', 'Acc Last 10', 'Acc Overall'}, 'Location', 'Best');
ylabel('Fraction');
xlabel('Trial number');
drawnow;

end

function allCueChosen = get_cue_chosen( choice_data )

allCueChosen = nan( 1, numel(choice_data) );
cues_acquired = { choice_data.cues_acquired }';
for i = 1:numel(cues_acquired)
  cues_acq_this_trial = cues_acquired{i};
  if any( isnan(cues_acq_this_trial) )
    allCueChosen(i) = 0;
  else
    acquired_cue_this_trial = find( cues_acq_this_trial );
    if isempty(acquired_cue_this_trial)
      allCueChosen(i) = 0;
    else
      allCueChosen(i) = acquired_cue_this_trial;
    end
  end
end

end

