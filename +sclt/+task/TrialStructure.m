classdef TrialStructure < handle
  methods
    function type = trial_type(obj, program)
      types = { 'cs_presentation', 'randomized_fixation', 'image_presentation' };
      ind = randi( numel(types), 1 );
      type = types{ind};
    end
    
    function type = reward_size_label(obj, program)
      types = { 'none', 'small', 'large' };
      ind = randi( numel(types), 1 );
      type = types{ind};
    end
    
    function size = reward_size(obj, label, program)
      rewards = program.Value.rewards;
      
      switch ( label )
        case 'none'
          size = 0;
        case 'small'
          size = rewards.cs_small;
        case 'large'
          size = rewards.cs_large;
        otherwise
          error( 'Unhandled reward size label "%s".', label );
      end
    end
    
    function [image, image_filename] = image(obj, program)
      image = [];
      image_filename = '';
      
      images = program.Value.images;
      image_filenames = program.Value.image_filenames;
      
      if ( isempty(images) )
        warning( 'No images were found.' );
        return
      end
      
      ind = randi( numel(images), 1 );
      image = images{ind};
      image_filename = image_filenames{ind};
    end
    
    function t = iti_duration(obj, program)
      range = program.Value.config.TIMINGS.time_in.iti_range;
      t = (range(2) - range(1)) * rand() + range(1);
    end
  end
end