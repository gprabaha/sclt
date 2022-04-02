%% Social cue learning training initiation script for setup 1

KbName('UnifyKeyNames');

conf = sclt.util.get_config_with_current_task_params;
conf = sclt_update_config_for_setup1( conf );

conf.STRUCTURE.state_names = { 'new_trial',...
  'fixation',...
  'prob_reward',...
  'task_iti',...
  'error_iti'...
  };
conf.STRUCTURE.fixation_time = 0.1;
conf.STRUCTURE.fixation_hold_time = 0.1;
conf.STRUCTURE.cue_collection_time = 0.25;
conf.STRUCTURE.fix_position_radius = 0.2; % Fixation square will appear within this radius
conf.STRUCTURE.num_rew_cues = 1;
conf.STRUCTURE.target_position_radius  = 0.4; % Targets appear with inner radius of fix radius and outer radius as this
conf.STRUCTURE.incorporate_var_delay = false;
conf.STRUCTURE.var_delay_times = linspace( 0.4, 0.6, 5 );

%%%%%%%%%%%%%%%%%%%%%%
% Stimuli Properties %
%%%%%%%%%%%%%%%%%%%%%%
conf.STIMULI.setup.central_fixation.size = [125, 125];
conf.STIMULI.setup.central_fixation.target_padding = 40;
conf.STIMULI.setup.central_fixation_hold.size = [125, 125];
conf.STIMULI.setup.central_fixation.target_padding = 40;
conf.STIMULI.setup.reward_cue.size = [125, 125];
conf.STIMULI.setup.reward_cue.target_padding = 40;
conf.STIMULI.setup.gaze_cursor.size = [20, 20];
conf.STIMULI.setup.gaze_cursor.color = [255 255 0];


conf.REWARDS.prob_reward = 0.2;
conf.REWARDS.det_reward = 0.05;
conf.REWARDS.key_press = 0.1;

sclt.task.start( conf );