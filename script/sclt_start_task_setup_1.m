%% Social cue learning training initiation script for setup 1

KbName('UnifyKeyNames');

conf = sclt.util.get_config_with_current_task_params;
conf = sclt_update_config_for_setup1( conf );

sclt.task.start( conf );