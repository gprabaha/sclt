src_dir = '~/repositories/sclt/';
dst_dir = '~/repositories/new';
replace_str = 'sclt';
replace_with = 'sclt';

ms = shared_utils.io.find( src_dir, '.m', true );

for i = 1:numel(ms)
  src_file = fileread( ms{i} );
  
  [~, src_filename, ext] = fileparts( src_file );
  src_str = strfind( ms{i}, src_dir );
  rest = ms{i}(src_str+numel(src_dir):end);
  dst_p = fullfile( dst_dir, rest );
  
  dst_file = strrep( src_file, replace_str, replace_with );
  shared_utils.io.require_dir( fileparts(dst_p) );
  fid = fopen( dst_p, 'w' );
  fwrite( fid, dst_file );
  fclose( fid );
end