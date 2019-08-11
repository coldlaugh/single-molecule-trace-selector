% SIMREPS_TRACE_SIMULATOR_MAKE   Generate MEX-function
%  SiMREPS_trace_simulator_mex from SiMREPS_trace_simulator.
% 
% Script generated from project 'SiMREPS_trace_simulator.prj' on 02-Aug-2018.
% 
% See also CODER, CODER.CONFIG, CODER.TYPEOF, CODEGEN.

%% Create configuration object of class 'coder.MexCodeConfig'.
cfg = coder.config('mex');
cfg.GenerateReport = false;
cfg.ReportPotentialDifferences = false;

%% Define argument types for entry-point 'SiMREPS_trace_simulator'.
ARGS = cell(1,1);
ARGS{1} = cell(3,1);
ARGS{1}{1} = coder.typeof(0);
ARGS{1}{2} = coder.typeof(0);
ARGS{1}{3} = coder.typeof(0);

%% Invoke MATLAB Coder.
codegen -config cfg SiMREPS_trace_simulator -args ARGS{1} -nargout 4

