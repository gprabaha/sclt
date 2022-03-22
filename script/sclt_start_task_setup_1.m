%% Social cue learning training initiation script for setup 1


conf = sclt.config.reconcile( sclt.config.load() );

% Task structure
conf.STRUCTURE.state_names = { 'new_trial', 'initial_fixation',...
    'decision', 'choice', 'var_delay', 'prob_reward',...
    'task_iti', 'error_iti'...
    };

% Timings
conf.TIMINGS.time_in.new_trial = 0;
conf.TIMINGS.time_in.initial_fixation = 5;
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
conf.STIMULI.setup.central_fixation.size = [100, 100];  % px
conf.STIMULI.setup.reward_cue.size = [100, 100];

% interface
conf.INTERFACE.gaze_source_type = 'mouse';  % 'mouse', 'digital_eyelink', 'analog_input'
conf.INTERFACE.reward_output_type = 'none'; % 'arduino', 'ni', 'none'
conf.INTERFACE.save_data = false;

% paths
conf.PATHS.images;  % where to load images from.
conf.PATHS.data;    % where to save data to.

sclt.task.start( conf );