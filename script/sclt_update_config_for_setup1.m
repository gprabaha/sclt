function conf = sclt_update_config_for_setup1(conf)

if ( nargin < 2 )
  do_save = true;
end

%%%%%%%%%%%%%%%%%%
% Reward details %
%%%%%%%%%%%%%%%%%%
conf.REWARDS.prob_reward = 0.2;
conf.REWARDS.det_reward = 0.05;
conf.REWARDS.key_press = 0.1;

%%%%%%%%%%%%%%%%%%%
% Subject details %
%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hardware interface details %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

conf.INTERFACE.gaze_source_type = 'digital_eyelink';  % 'mouse', 'digital_eyelink', 'analog_input'
conf.INTERFACE.reward_output_type = 'arduino'; % 'arduino', 'ni', 'none'
conf.INTERFACE.save_data = true;
conf.INTERFACE.stop_key = KbName( 'escape' );

%%%%%%%%%%%%%%%%%%
% Screen details %
%%%%%%%%%%%%%%%%%%
calibration_rect = [0, 0, 1600, 900];

conf.SCREEN.rect = [];
conf.SCREEN.index = 3;
conf.SCREEN.calibration_rect = calibration_rect;
% Debug screen
% conf.DEBUG_SCREEN.is_present = true;
conf.DEBUG_SCREEN.is_present = true;
conf.DEBUG_SCREEN.index = 1;
conf.DEBUG_SCREEN.background_color = [ 0 0 0 ];
% Debug screen rect accounts for resolution of monkey monitor
conf.DEBUG_SCREEN.rect = calibration_rect;
% Calib screen
conf.CALIB_SCREEN.full_rect = [];
conf.CALIB_SCREEN.index = 3;
conf.CALIB_SCREEN.calibration_rect = calibration_rect;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixation square properties %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
conf.STIMULI.setup.central_fixation.size = [125, 125];
conf.STIMULI.setup.central_fixation.target_padding = 40;
conf.STIMULI.setup.central_fixation_hold.size = [125, 125];
conf.STIMULI.setup.central_fixation.target_padding = 40;
conf.STIMULI.setup.reward_cue.size = [125, 125];
conf.STIMULI.setup.reward_cue.target_padding = 40;
conf.STIMULI.setup.gaze_cursor.size = [20, 20];

%%%%%%%%%%%%%%%%%%%
% Port for reward %
%%%%%%%%%%%%%%%%%%%
conf.SERIAL.port = 'COM3';

%%%%%%%%%%%%%%%
% Saving data %
%%%%%%%%%%%%%%%
conf.INTERFACE.save_data = true;
conf.repositories = fileparts( sclt.util.get_project_folder() );
conf.PATHS.data = fullfile( sclt.util.get_project_folder(), 'data' );
conf.PATHS.remote = fullfile( 'C:\Users\setup1\Dropbox (ChangLab)\prabaha_changlab\scl-training\fellini');


%%%%%%%%%%%%%%%%%%%
% Save new config %
%%%%%%%%%%%%%%%%%%%
if ( do_save )
  sclt.config.save( conf );
end

end