
function conf = create(do_save)

%   CREATE -- Create the config file. 
%
%     Define editable properties of the config file here.
%
%     IN:
%       - `do_save` (logical) -- Indicate whether to save the created
%         config file. Default is `false`

if ( nargin < 1 ), do_save = false; end

const = sclt.config.constants();

conf = struct();

% ID
conf.(const.config_id) = true;

% PATHS
PATHS = struct();
PATHS.repositories = fileparts( sclt.util.get_project_folder() );
PATHS.data = fullfile( sclt.util.get_project_folder(), 'data' );
PATHS.images = fullfile( sclt.util.get_project_folder(), 'images' );

%   STRUCTURE
STRUCTURE = struct();
% STRUCTURE.state_names = {...
%     'new_trial',...
%     'fixation',...
%     'decision',...
%     'choice',...
%     'var_delay',...
%     'prob_reward',...
%     'fix_delay',...
%     'det_reward' ...
%     'task_iti', ... 
%     'error_iti' ...
% };
STRUCTURE.state_names = {...
    'new_trial',...
    'initial_fixation',...
};
STRUCTURE.fix_position_radius = 0.25; % Fixation square will appear within this radius
STRUCTURE.num_targets = 1;
STRUCTURE.num_trials_per_block = 50;
STRUCTURE.target_position_radius  = 0.5; % Targets appear with inner radius of fix radius and outer radius as this
STRUCTURE.target_types = {'self', 'other', 'neither'};
STRUCTURE.target_rew_probs = [0.2 0.8];

%	INTERFACE
INTERFACE = struct();
INTERFACE.stop_key = KbName( 'escape' );
INTERFACE.gaze_source_type = 'mouse';
INTERFACE.reward_output_type = 'none';
INTERFACE.skip_sync_tests = false;
INTERFACE.tracker_sync_interval = 1;
INTERFACE.allow_hide_mouse = false;
INTERFACE.save_data = false;

%	SCREEN
SCREEN = struct();

SCREEN.full_size = get( 0, 'screensize' );
SCREEN.index = 0;
SCREEN.background_color = [ 0 0 0 ];
SCREEN.rect = [ 0, 0, 400, 400 ];
SCREEN.calibration_rect = [ 0, 0, 400, 400 ];

%	TIMINGS
TIMINGS = struct();

time_in = struct();
time_in.new_trial = 0;
time_in.fixation = 5;
time_in.initial_fixation = 5;
time_in.decision = 1;
time_in.choice = 2;
time_in.var_delay = 1;
time_in.prob_reward = 1;
time_in.fix_delay = 0.5;
time_in.det_reward = 1;
time_in.task_iti = 1;
time_in.error_iti = 3;
time_in.task = inf;

TIMINGS.time_in = time_in;

%	STIMULI
STIMULI = struct();
STIMULI.setup = struct();

non_editable_properties = {{ 'placement', 'has_target', 'image_matrix' }};

STIMULI.setup.central_fixation = struct( ...
    'class',            'Rect', ...
    'size',             [ 50 50 ], ...
    'color',            [ 255 255 255 ], ...
    'position',         [ 0.5 0.5 ], ...
    'placement',        'center', ...
    'has_target',       'true', ...
    'target_duration',  0.3, ...
    'target_padding',   0, ...
    'non_editable',     non_editable_properties ...
);

STIMULI.setup.reward_cue = struct( ...
    'class',            'Rect', ...
    'size',             [ 50 50 ], ...
    'color',            [ 255 0 0 ], ...
    'position',         [ 0.5 0.5 ], ...
    'placement',        'center', ...
    'has_target',       'true', ...
    'target_duration',  0.3, ...
    'target_padding',   0, ...
    'non_editable',     non_editable_properties ...
);

STIMULI.setup.image = struct( ...
    'class',            'Rect' ...
  , 'size',             [ 50, 50 ] ...
  , 'color',            [ 0, 0, 255 ] ...
  , 'position',         [ 0.5, 0.5 ] ...
  , 'placement',        'center' ...
  , 'has_target',       true ...
  , 'target_duration',  0.3 ...
  , 'target_padding',   0 ...
  , 'target_duration_range', [0.1, 0.5] ...
  , 'non_editable',     non_editable_properties ...
);

%	SERIAL
SERIAL = struct();
SERIAL.port = 'COM3';
SERIAL.channels = { 'A' };

% SIGNAL
SIGNAL = struct();
SIGNAL.analog_channel_m1x = 'ai0';
SIGNAL.analog_channel_m1y = 'ai1';
SIGNAL.analog_gaze_input_channel_indices_m1 = [1, 2];
SIGNAL.analog_gaze_input_channel_indices_m2 = [3, 4];

% REWARDS
REWARDS = struct();
REWARDS.prob_reward = 0.2;
REWARDS.det_reward = 0.05;
REWARDS.key_press = 0.1;

% EXPORT
conf.PATHS = PATHS;
conf.STRUCTURE = STRUCTURE;
conf.TIMINGS = TIMINGS;
conf.STIMULI = STIMULI;
conf.SCREEN = SCREEN;
conf.INTERFACE = INTERFACE;
conf.SERIAL = SERIAL;
conf.SIGNAL = SIGNAL;
conf.REWARDS = REWARDS;

if ( do_save )
  sclt.config.save( conf );
end

end