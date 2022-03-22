function start(varargin)

program = sclt.task.setup( varargin{:} );
err = [];

try
  sclt.task.run( program );
catch err
end

delete( program );

if ( ~isempty(err) )
  rethrow( err );
end

end