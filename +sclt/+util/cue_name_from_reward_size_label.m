function name = cue_name_from_reward_size_label(label)

switch ( lower(label) )
  case 'small'
    name = 'cue_small_reward';
  case 'large';
    name = 'cue_large_reward';
  case 'none';
    name = 'cue_no_reward';
  otherwise
    error( 'Unrecognized reward size label "%s".', label );
end

end