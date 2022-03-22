function conf = sclt_define_config_setup1(do_save)

if ( nargin < 1 )
  do_save = true;
end

%%%%%%%%%%%%%%%
% Load config %
%%%%%%%%%%%%%%%
conf = sclt.config.reconcile( sclt.config.load() );
conf = sclt.config.prune( conf );

%%%%%%%%%%%%%%%%%%
% Task structure %
%%%%%%%%%%%%%%%%%%
% States
conf.STRUCTURE.state_names = { 'new_trial', 'initial_fixation',...
    'decision', 'choice', 'var_delay', 'prob_reward',...
    'task_iti', 'error_iti'...
    };
% Time in states
conf.TIMINGS.time_in.new_trial = 0;
conf.TIMINGS.time_in.initial_fixation = 5;
conf.TIMINGS.time_in.decision = 1;
conf.TIMINGS.time_in.choice = 3;
conf.TIMINGS.time_in.var_delay = 1;
conf.TIMINGS.time_in.prob_reward = 1;
conf.TIMINGS.time_in.task_iti = 1;
conf.TIMINGS.time_in.error_iti = 3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus display parameters %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trial progress display %
%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%
% Generators %
%%%%%%%%%%%%%%


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
conf.INTERFACE.save_data = false;
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
conf.STIMULI.setup.central_fixation.size = [100, 100];
conf.STIMULI.setup.central_fixation.target_padding = 20;
% Add a fix-hold square or something like that to separate hold time and
% fix time
conf.STIMULI.setup.reward_cue.size = [100, 100];
conf.STIMULI.setup.reward_cue.target_padding = 20;

%%%%%%%%%%%%%%%%%%%
% Port for reward %
%%%%%%%%%%%%%%%%%%%
conf.SERIAL.port = 'COM3';

%%%%%%%%%%%%%%%
% Saving data %
%%%%%%%%%%%%%%%
conf.INTERFACE.save_data = true;
conf.PATHS.remote = 'C:\Users\setup1\Dropbox (ChangLab)\prabaha_changlab\scl-training\fellini';


%%%%%%%%%%%%%%%%%%%
% Save new config %
%%%%%%%%%%%%%%%%%%%
if ( do_save )
  sclt.config.save( conf );
end

end