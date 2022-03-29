function shutdown(program)

try
  save_data( program );
catch err
  warning( err.message );
end

close_window( program );
close_arduino( program );
delete_trackers( program );

handle_cursor();
handle_keyboard();

end

function delete_trackers(program)

if ( isfield(program.Value, 'tracker') )
  delete_tracker( program.Value.tracker );
end

end

function delete_tracker(tracker)

try
  delete( tracker );
catch err
  warning( err.message );
end

end

function close_arduino(program)

try
  reward_manager = program.Value.arduino_reward_manager;
  
  if ( ~isempty(reward_manager) )
    close( reward_manager );
  end
  
catch err
  warning( err.message );
end

end

function close_window(program)

try
  close( program.Value.window )
catch err
  warning( err.message );
end

end

function handle_cursor()

try
  ShowCursor();
catch err
  warning( err.message );
end

end

function handle_keyboard()

try
  ListenChar( 0 );
catch err
  warning( err.message );
end

end

function save_data(program)

if ( ~isfield(program.Value, 'data') )
  return
end

data = program.Value.data.Value;

if ( isempty(data) )
  return
end

do_save = program.Value.interface.save_data;
if ( ~do_save )
  return
end

data_p = program.Value.data_directory;
shared_utils.io.require_dir( data_p );
data_fname = sprintf( 'sclt-%s', strrep(datestr(now), ':', '_') );

% Convert to struct to avoid needing access to the sclt.task.Data class to
% load data.
warning( 'off', 'all' );
simple_data = arrayfun( @struct, data );
warning( 'on', 'all' );

save( fullfile(data_p, data_fname), 'simple_data' );

end