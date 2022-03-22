
  function conf = reconcile(conf)

%   RECONCILE -- Add missing fields to config file.
%
%     conf = ... reconcile() loads the current config file and checks for
%     missing fields, that is, fields that are present in the config file
%     that would be generated by ... .config.create(), but which are not
%     present in the saved config file. Any missing fields are set to the
%     contents of the corresponding fields as defined in ...
%     .config.create().
%
%     conf = ... reconcile( conf ) uses the config file `conf`, instead of
%     the saved config file.
%
%     IN:
%       - `conf` (struct) |OPTIONAL|
%     OUT:
%       - `conf` (struct)

if ( nargin < 1 )
  conf = sclt.config.load(); 
end

display = false;
missing = sclt.config.diff( conf, display );

if ( isempty(missing) )
  return;
end

%   don't save
do_save = false;
created = sclt.config.create( do_save );

for i = 1:numel(missing)
  current = missing{i};
  eval( sprintf('conf%s = created%s;', current, current) );
end

end