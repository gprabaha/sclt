function conf = get_config_with_current_task_params(do_save)

if nargin<1
  do_save = 1;
end

conf = sclt.config.reconcile( sclt.config.load() );

% Task structure
% conf.STRUCTURE.state_names = { 'new_trial', 'fixation',...
%     'decision', 'choice', 'var_delay', 'prob_reward',...
%     'task_iti', 'error_iti'...
%     };
conf.STRUCTURE.state_names = { 'new_trial',...
  'fixation',...
  'decision',...
  'prob_reward',...
  'task_iti',...
  'error_iti'...
  };
conf.STRUCTURE.fixation_time = 0.3;
conf.STRUCTURE.fixation_hold_time = 0.5;
conf.STRUCTURE.cue_collection_time = 0.25;
conf.STRUCTURE.fix_position_radius = 0.2; % Fixation square will appear within this radius
conf.STRUCTURE.num_rew_cues = 1;
conf.STRUCTURE.num_trials_per_block = 50;
conf.STRUCTURE.target_position_radius  = 0.4; % Targets appear with inner radius of fix radius and outer radius as this
conf.STRUCTURE.target_types = {'self', 'other', 'neither'};
conf.STRUCTURE.target_rew_probs = [0.2 0.8];
conf.STRUCTURE.incorporate_var_delay = false;
conf.STRUCTURE.var_delay_times = linspace( 0.4, 0.6, 5 );

% Timings
conf.TIMINGS.time_in.new_trial = 0;
conf.TIMINGS.time_in.fixation = 5;
conf.TIMINGS.time_in.decision = 1;
conf.TIMINGS.time_in.choice = 3;
conf.TIMINGS.time_in.var_delay = 1;
conf.TIMINGS.time_in.prob_reward = 1;
conf.TIMINGS.time_in.task_iti = 1;
conf.TIMINGS.time_in.error_iti = 3;


% Screen retails
conf.SCREEN.rect = [0, 0, 400, 400];
conf.SCREEN.calibration_rect = [0, 0, 400, 400];
conf.SCREEN.index = 0;

conf.DEBUG_SCREEN.is_present = true;
conf.DEBUG_SCREEN.index = 0;
conf.DEBUG_SCREEN.background_color = [ 0 0 0 ];
% Debug screen rect accounts for resolution of monkey monitor
conf.DEBUG_SCREEN.rect = [600, 0, 800, 200];

% stimuli
conf.STIMULI.setup.central_fixation.size = [50, 50];  % px
conf.STIMULI.setup.reward_cue.size = [50, 50];
conf.STIMULI.setup.gaze_cursor.size = [20, 20];

% interface
conf.INTERFACE.gaze_source_type = 'mouse';  % 'mouse', 'digital_eyelink', 'analog_input'
conf.INTERFACE.reward_output_type = 'none'; % 'arduino', 'ni', 'none'
conf.INTERFACE.save_data = false;
conf.INTERFACE.stop_key = KbName( 'escape' );
conf.INTERFACE.num_trials_to_display = 10;

% paths
conf.PATHS.images;  % where to load images from.
conf.PATHS.data;    % where to save data to.

%%%%%%%%%%%%%%%%%%%
% Save new config %
%%%%%%%%%%%%%%%%%%%
if ( do_save )
  sclt.config.save( conf );
end


end