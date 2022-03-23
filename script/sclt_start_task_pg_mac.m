%% Social cue learning training initiation script for mac
KbName('UnifyKeyNames');

conf = sclt.util.get_config_with_current_task_params;

conf.STRUCTURE.num_targets = 2;
conf.INTERFACE.num_trials_to_display = 3;

sclt.task.start( conf );