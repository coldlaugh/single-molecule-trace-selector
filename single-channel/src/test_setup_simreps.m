disp("==== Testing Compatibility And Settings====")

if verLessThan('matlab','9.4')
    error(strcat('The Script Requires MATLAB Version R2018a or Above. ',...
        + ' You Are Running an Old MATLAB Version. Please Upgrade To Newest Release.'))
end

if verLessThan('stats','11.3')
    error(strcat('The Script Requires Statistics And Machine Learning Toolbox Version 11.3 or Above.', ...
    ' Please Refer to README for Upgrade Instructions.'))
end

n = 'trainNetwork';
pat = '(?<=^.+[\\/]toolbox[\\/])[^\\/]+';
dl_toolbox = regexp(which(n), pat, 'match', 'once');


if verLessThan(dl_toolbox,'11.1')
    error(strcat('The Script Requires Neural Network Toolbox Version 11.1 or Above.', ...
    ' Please Refer to README for Upgrade Instructions.'))
end

try
    settings = jsondecode(fileread('settings.json'));
    settings.workingDir;
    settings.dataFolder;
catch e
    error(strcat('settings.json: ', e.message));
end
    

disp("Everything Looks Great. Ready To Run main_fret.") 

