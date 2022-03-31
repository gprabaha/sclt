function program = setup(conf)

if ( nargin < 1 || isempty(conf) )
  conf = sclt.config.load();
end

conf = sclt.config.reconcile( conf );
program = make_program( conf );

try
  make_all( program, conf );
catch err
  delete( program );
  rethrow( err );
end

end

function program = make_program(conf)

program = ptb.Reference( struct() );
program.Destruct = @sclt.task.shutdown;
program.Value.debug = struct();
program.Value.config = conf;
program.Value.data_directory = session_data_directory( conf );
program.Value.remote_data_directory = session_remote_data_directory( conf );


end

function dir = session_data_directory(conf)

dir = fullfile( conf.PATHS.data, datestr(now, 'mmddyy') );

end

function dir = session_remote_data_directory(conf)

dir = fullfile( conf.PATHS.remote, datestr(now, 'mmddyy') );

end

function make_all(program, conf)

make_task( program, conf );

make_states( program, conf );
make_data( program, conf );

ni_session = make_ni_daq_session( program, conf );
ni_scan_input = make_ni_scan_input( program, conf, ni_session );
ni_scan_output = make_ni_scan_output( program, conf, ni_session );

updater = make_component_updater( program );
window = make_window( program, conf );
debug_window = make_debug_window( program, conf );

data_directory = program.Value.data_directory;
tracker = make_eye_tracker( program, updater, ni_scan_input, data_directory, conf );
sampler = make_gaze_sampler( program, updater, tracker );
make_eye_tracker_sync( program, conf );

make_reward_manager( program, conf, ni_scan_output );

make_structure( program, conf );
make_interface( program, conf );

stimuli = make_stimuli( program, window, conf );
% images = make_images( program, conf );
make_targets( program, updater, window, sampler, stimuli, conf );

handle_cursor( program, conf );
handle_keyboard( program, conf );

end


function task = make_task(program, conf)

time_in = get_time_in( conf );
interface = get_interface( conf );

task = ptb.Task();

task.Duration = time_in.task;
task.Loop = @(task) sclt.task.loop(task, program);
task.exit_on_key_down( interface.stop_key );

program.Value.task = task;

end

function states = make_states(program, conf)

states = containers.Map();

state_names = get_state_names( conf );

for i = 1:numel(state_names)
  state_func = sprintf( 'sclt.task.states.%s', state_names{i} );
  states(state_names{i}) = feval( state_func, program, conf );
end

program.Value.states = states;

end

function data = make_data(program, conf)

data = ptb.Reference();

program.Value.data = data;

end

function ni_session = make_ni_daq_session(program, conf)

ni_session = [];
signal = get_signal( conf );

if ( ~need_make_ni_session(conf) )
  program.Value.ni_session = ni_session;
  program.Value.ni_device_id = '';
  return
end

ni_session = daq.createSession( 'ni' );
ni_device_id = sclt.util.get_ni_daq_device_id();

m1_channel_x = signal.analog_channel_m1x;
m1_channel_y = signal.analog_channel_m1y;

channels = { m1_channel_x, m1_channel_y };

for i = 1:numel(channels)
  addAnalogInputChannel( ni_session, ni_device_id, channels{i}, 'Voltage' );
end

addAnalogOutputChannel( ni_session, ni_device_id, 0, 'Voltage' );

program.Value.ni_session = ni_session;
program.Value.ni_device_id = ni_device_id;

end

function ni_scan_input = make_ni_scan_input(program, conf, ni_session)

ni_scan_input = [];
if ( isempty(ni_session) )
  program.Value.ni_scan_input = [];
  return
end

ni_scan_input = ptb.signal.SingleScanInput( ni_session );
program.Value.ni_scan_input = ni_scan_input;

end

function ni_scan_output = make_ni_scan_output(program, conf, ni_session)

ni_scan_output = [];
if ( isempty(ni_session) )
  program.Value.ni_scan_output = [];
  return
end

ni_scan_output = ptb.signal.SingleScanOutput( ni_session );
program.Value.ni_scan_output = ni_scan_output;

end

function updater = make_component_updater(program)

updater = ptb.ComponentUpdater();
program.Value.updater = updater;

end

function window = make_window(program, conf)

window = ptb.Window();
window.BackgroundColor = conf.SCREEN.background_color;
window.Rect = conf.SCREEN.rect;
window.Index = conf.SCREEN.index;
window.SkipSyncTests = conf.INTERFACE.skip_sync_tests;

open( window );
enable_blending( window );

program.Value.window = window;

end

function debug_window = make_debug_window(program, conf)

debug_window_is_present = conf.DEBUG_SCREEN.is_present;
if (debug_window_is_present)
    
    debug_window = ptb.Window();
    debug_window.Index = conf.DEBUG_SCREEN.index;
    debug_window.BackgroundColor = conf.DEBUG_SCREEN.background_color;
    debug_window.Rect = conf.DEBUG_SCREEN.rect;
    debug_window.SkipSyncTests = conf.INTERFACE.skip_sync_tests;

    program.Value.debug_window_is_present = true;
    program.Value.debug_window = debug_window;
    
  open( debug_window );
  enable_blending( debug_window );
else
  debug_window = [];
  program.Value.debug_window_is_present = false;
end

end

function [tracker_m1, edf_filename] = ...
  make_eye_tracker(program, updater, ni_scan_input, data_directory, conf)

interface = get_interface( conf );
signal = get_signal( conf );
screen = get_screen( conf );

m1_source_type = interface.gaze_source_type;
m1_channel_indices = signal.analog_gaze_input_channel_indices_m1;
calibration_rect = screen.calibration_rect;

[tracker_m1, edf_filename] = make_one_eye_tracker( updater, ni_scan_input ...
  , m1_channel_indices, calibration_rect, m1_source_type, data_directory, conf );

program.Value.tracker = tracker_m1;
program.Value.edf_filename = edf_filename;

end

function [tracker, edf_filename] = ...
  make_one_eye_tracker(updater, ni_scan_input, input_channel_indices ...
  , calibration_rect, source_type, data_directory, conf)

edf_filename = '';

switch ( source_type )
  case 'mouse'
    tracker = ptb.sources.Mouse();
    
  case 'digital_eyelink'
    [tracker, edf_filename] = make_digital_eyelink( data_directory, conf );
    
  case 'analog_input'
    tracker = ...
      make_analog_input_tracker( ni_scan_input, input_channel_indices, calibration_rect );
    
  case 'DebugGenerator'
    tracker = make_debug_generator_tracker();
    
  otherwise
    error( 'Unrecognized source type "%s".', source_type );
end

updater.add_component( tracker );

end

function [tracker, filename] = make_digital_eyelink(data_directory, conf)

interface = get_interface( conf );

tracker = ptb.sources.Eyelink();
initialize( tracker );
filename = '';

if ( interface.save_data )
  filename = edf_filename( data_directory );  
  start_recording( tracker, filename );
  tracker.Destruct = ...
    @(tracker) digital_eyelink_destructor(tracker, data_directory);
  
else
  start_recording( tracker );
end

end

function fname = edf_filename(session_dir)

fname = shared_utils.io.get_next_numbered_filename( session_dir, '.edf' );

end

function digital_eyelink_destructor(tracker, data_directory)

warning( 'off', 'all' );
tracker.conditional_receive_file( require_directory(data_directory) );
warning( 'on', 'all' );

end

function tracker = make_analog_input_tracker(ni_scan_input, channel_indices, calibration_rect)

tracker = ptb.sources.XYAnalogInput( ni_scan_input );
tracker.CalibrationRect = calibration_rect;
tracker.OutputVoltageRange = [-5, 5];
tracker.CalibrationRectPaddingFract = [0.2, 0.2];
tracker.ChannelMapping = channel_indices;

end

function tracker = make_debug_generator_tracker()

tracker = ptb.sources.Generator();

end


function sampler = make_gaze_sampler(program, updater, tracker)

sampler = make_one_gaze_sampler( updater, tracker );
program.Value.sampler = sampler;

end

function sampler = make_one_gaze_sampler(updater, tracker)

sampler = ptb.samplers.Pass();
sampler.Source = tracker;

updater.add_component( sampler );

end

function make_eye_tracker_sync(program, conf)

sync_info = struct();
sync_info.timer = nan;
sync_info.times = [];
sync_info.next_iteration = 1;
sync_info.tracker_sync_interval = conf.INTERFACE.tracker_sync_interval;

program.Value.tracker_sync = sync_info;

end

function make_reward_manager(program, conf, ni_scan_output)

initialize_reward_manager_variables( program, conf );

if ( is_arduino_reward_source(conf) )
  make_arduino_reward_manager( program, conf );
elseif ( is_ni_reward_source(conf) )
  make_ni_reward_manager( program, conf, ni_scan_output );  
end

program.Value.rewards = get_rewards( conf );

end

function initialize_reward_manager_variables(program, conf)

program.Value.arduino_reward_manager = [];
program.Value.ni_reward_manager = [];

end

function make_arduino_reward_manager(program, conf)

serial = get_serial( conf );

port = serial.port;
messages = struct();
channels = serial.channels;

arduino_reward_manager = serial_comm.SerialManager( port, messages, channels );
start( arduino_reward_manager );

program.Value.arduino_reward_manager = arduino_reward_manager;

end

function make_ni_reward_manager(program, conf, ni_scan_output)

channel_index = 1;
reward_manager = ptb.signal.SingleScanOutputPulseManager( ni_scan_output, channel_index );

program.Value.ni_reward_manager = reward_manager;

end


function stimuli = make_stimuli(program, window, conf)

structure = get_structure( conf );
stim_setup = get_stimuli_setup( conf );
stim_names = fieldnames( stim_setup );

stimuli = struct();

for i = 1:numel(stim_names)
  stim_name = stim_names{i};
  % Add code here to iterate through n number of reward_cue target types
  if ( strcmp(stim_name, 'reward_cue') )
    % Generate structure.num_patches patch stimuli.
    for j = 1:structure.num_targets
      use_name = sclt.util.nth_reward_cue_name( j );
      stimuli.(use_name) = make_stimulus( window, stim_setup.(stim_name) );
    end
  else
    % Otherwise, just generate a single stimulus.
    stimuli.(stim_name) = make_stimulus( window, stim_setup.(stim_name) );
  end
end

program.Value.stimuli = stimuli;
program.Value.stimuli_setup = stim_setup;

end


function stim = make_stimulus(window, description)

switch ( description.class )
  case 'Rect'
    stim = ptb.stimuli.Rect();
  case 'Oval'
    stim = ptb.stimuli.Oval();
  otherwise
    error( 'Unrecognized stimulus class "%s".', description.class );
end

if ( isfield(description, 'position') )
  stim.Position = description.position;
  stim.Position.Units = 'normalized';
end

stim.Scale = ptb.WindowDependent( description.size );
stim.Scale.Units = 'px';

if ( isfield(description, 'use_image') && description.use_image )
  try
    [im_mat, ~, im_alpha] = imread( description.image_file );
    
    if ( ~isempty(im_alpha) )
      im_mat(:, :, end+1) = im_alpha;
    end
    
    img = ptb.Image( window, im_mat );
    stim.FaceColor = img;
    
  catch err
    warning( 'Failed to read image: %s.', err.message );
    stim.FaceColor = set( ptb.Color(), description.color );
  end
else
  stim.FaceColor = set( ptb.Color(), description.color );
end

end

function images = make_images(program, conf)

image_p = conf.PATHS.images;
[images, image_filenames] = read_images( image_p );

image_objs = cell( numel(images), 1 );
for i = 1:numel(image_objs)
  image_objs{i} = ptb.Image( program.Value.window, images{i} );
end

program.Value.images = image_objs;
program.Value.image_arrays = images;
program.Value.image_filenames = image_filenames;

end

function [images, image_filenames] = read_images(p)

exts = { '.png', '.jpg' };
imgs = shared_utils.io.find( p, exts );
images = cellfun( @imread, imgs, 'un', 0 );
image_filenames = shared_utils.io.filenames( imgs );

end

function targets = make_targets(program, updater, window, sampler, stimuli, conf)

stim_setup = get_stimuli_setup( conf );
stim_names = fieldnames( stim_setup );
structure = program.Value.structure;

targets = struct();

for i = 1:numel(stim_names)
  stim_name = stim_names{i};
  stim_descr = stim_setup.(stim_name);
  
  if ( stim_descr.has_target )
    if ( strcmp(stim_name, 'reward_cue') )
      for j = 1:structure.num_targets
        use_name = sclt.util.nth_reward_cue_name( j );
        stimulus = stimuli.(use_name);
        target = make_target( stim_descr, stimulus, sampler, window );
        updater.add_component( target );
        targets.(stim_name) = target;
      end
    else
      stimulus = stimuli.(stim_name);
      target = make_target( stim_descr, stimulus, sampler, window );
      updater.add_component( target );
      targets.(stim_name) = target;
    end
  end
end

program.Value.targets = targets;

end

function target = make_target(stim_descr, stimulus, sampler, window)

target = ptb.XYTarget();
target.Sampler = sampler;

switch ( stim_descr.class )
  case {'Rect', 'Oval'}
    bounds = ptb.bounds.Rect();
    bounds.BaseRect = ptb.rects.MatchRectangle( stimulus );
    bounds.BaseRect.Rectangle.Window = window;
    bounds.Padding = stim_descr.target_padding;
    
  otherwise
    error( 'Unrecognized stimulus class "%s".', stim_descr.class );
end

target.Bounds = bounds;
target.Duration = stim_descr.target_duration;

end


function structure = make_structure(program, conf)

structure = get_structure( conf );
program.Value.structure = structure;

end

function interface = make_interface(program, conf)

interface = get_interface( conf );
program.Value.interface = interface;

end

function handle_cursor(program, conf)

interface = get_interface( conf );

if ( interface.allow_hide_mouse )
  HideCursor();
end

end

function handle_keyboard(program, conf)

ListenChar( 2 );

end

function states = get_state_names( conf )

states = conf.STRUCTURE.state_names;

end


function tf = need_make_ni_session(conf)
tf = strcmp( conf.INTERFACE.reward_output_type, 'ni' ) || ...
  is_analog_input_gaze_source( conf );
end

function tf = is_ni_reward_source(conf)
tf = strcmp( conf.INTERFACE.reward_output_type, 'ni' );
end

function tf = is_arduino_reward_source(conf)
tf = strcmp( conf.INTERFACE.reward_output_type, 'arduino' );
end

function tf = is_analog_input_gaze_source(conf)
tf = strcmp( conf.INTERFACE.gaze_source_type, 'analog_input' );
end

function tf = is_mouse_gaze_source(conf)
tf = strcmp( conf.INTERFACE.gaze_source_type, 'mouse' );
end

function rewards = get_rewards(conf)
rewards = conf.REWARDS;
end

function serial = get_serial(conf)
serial = conf.SERIAL;
end

function structure = get_structure(conf)
structure = conf.STRUCTURE;
end

function setup = get_stimuli_setup(conf)
setup = conf.STIMULI.setup;
end

function interface = get_interface(conf)
interface = conf.INTERFACE;
end

function time_in = get_time_in(conf)
time_in = conf.TIMINGS.time_in;
end

function signal = get_signal(conf)
signal = conf.SIGNAL;
end

function screen = get_screen(conf)
screen = conf.SCREEN;
end

function d = require_directory(d)
shared_utils.io.require_dir( d );
end

function varargout = noop(varargin)
% Do nothing.
end