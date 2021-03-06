%% Social cue learning training initiation script for mac
KbName('UnifyKeyNames');

conf = sclt.util.get_config_with_current_task_params;

conf.STRUCTURE.state_names = { 'new_trial',...
  'fixation',...
  'prob_reward',...
  'task_iti',...
  'error_iti'...
  };
conf.STRUCTURE.fixation_time = 0.3;
conf.STRUCTURE.fixation_hold_time = 0.5;
conf.STRUCTURE.cue_collection_time = 0.25;
conf.STRUCTURE.fix_position_radius = 0.2; % Fixation square will appear within this radius
conf.STRUCTURE.num_rew_cues = 2;
conf.STRUCTURE.target_position_radius  = 0.4; % Targets appear with inner radius of fix radius and outer radius as this
conf.STRUCTURE.incorporate_var_delay = true;
conf.STRUCTURE.var_delay_times = linspace( 0.4, 0.6, 5 );


%%%%%%%%%%%%%%%%%%%%%%
% Stimuli Properties %
%%%%%%%%%%%%%%%%%%%%%%
conf.STIMULI.setup.central_fixation.size = [50, 50];
conf.STIMULI.setup.central_fixation.target_padding = 10;
conf.STIMULI.setup.central_fixation_hold.size = [50, 50];
conf.STIMULI.setup.central_fixation.target_padding = 10;
conf.STIMULI.setup.reward_cue.size = [50, 50];
conf.STIMULI.setup.reward_cue.target_padding = 10;
conf.STIMULI.setup.gaze_cursor.size = [10, 10];
conf.STIMULI.setup.gaze_cursor.color = [0 255 255];

figure();
sclt.task.start( conf );