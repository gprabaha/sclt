function sclt_calibrate(conf)

KbName('UnifyKeyNames');

if ( nargin < 1 )
  conf = sclt.config.reconcile( sclt.config.load() );
else
  sclt.util.assertions.assert__is_config( conf );
end

conf = sclt_update_config_for_setup1( conf );

screen_info = struct();
screen_info.full_rect = conf.CALIB_SCREEN.full_rect;
screen_info.calibration_rect = conf.CALIB_SCREEN.calibration_rect;
screen_info.screen_index = conf.CALIB_SCREEN.index;
screen_info.debug_screen_index = conf.DEBUG_SCREEN.index;
screen_info.debug_screen_rect = conf.DEBUG_SCREEN.rect;

reward_info = struct();
reward_info.channel_index = 1;
reward_info.size = conf.REWARDS.key_press;  
reward_info.manager_type = reward_manager_type_from_config( conf );
reward_info.serial_port = conf.SERIAL.port;


n_cal_pts = 5;
run_calibration( screen_info, reward_info, n_cal_pts );

end

function type = reward_manager_type_from_config(conf)

type = 'none';

if ( isfield(conf, 'INTERFACE') && isfield(conf.INTERFACE, 'reward_output_type') )
  type = validatestring( conf.INTERFACE.reward_output_type ...
    , {'ni', 'arduino', 'none'}, mfilename, 'reward_output_type' );
end

end