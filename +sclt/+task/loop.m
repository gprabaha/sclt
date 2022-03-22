function loop(task, program)

handle_ni_daq_update( program );

update( program.Value.updater );

if ( strcmp(program.Value.interface.gaze_source_type, 'digital_eyelink') )
  sync_digital_eyelink( task, program );
end

end

function handle_ni_daq_update(program)

if ( ~isempty(program.Value.ni_reward_manager) )
  update( program.Value.ni_reward_manager );
end

if ( ~isempty(program.Value.ni_scan_output) )
  update( program.Value.ni_scan_output );
end

if ( ~isempty(program.Value.ni_scan_input) )
  update( program.Value.ni_scan_input );
end

end

function sync_digital_eyelink(task, program)

sync_info = program.Value.tracker_sync;
should_send_sync_pulse = isnan( sync_info.timer ) || ...
toc( sync_info.timer ) >= sync_info.tracker_sync_interval;

if ( should_send_sync_pulse )
  tracker = program.Value.tracker;
  send_message( tracker, 'sync' );
  mat_time = elapsed( task );

  sync_info.times(sync_info.next_iteration) = mat_time;
  sync_info.next_iteration = sync_info.next_iteration + 1;
  sync_info.timer = tic();

  program.Value.tracker_sync = sync_info;
end

end