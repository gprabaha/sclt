function state = new_trial(program, conf)

state = ptb.State();
state.Name = 'new_trial';

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)


data = sclt.task.Data();
program.Value.data.Value(end+1) = data;

% [image, image_filename] = structure.image( program );
% 
% data.trial_type = structure.trial_type( program );
% data.image = image;
% data.image_filename = image_filename;
% data.iti_duration = structure.iti_duration( program );
% data.event_times.new_trial.entry = elapsed( program.Value.task );

end

function loop(state, program)

end

function exit(state, program)

states = program.Value.states;
next( state, states('initial_fixation') );

end